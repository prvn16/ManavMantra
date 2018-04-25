function out = cumfunCommon(fcnStruct, in, varargin)
%CUMFUNCOMMON Common logic for accumulating a tall array
%
%   See also TALL/CUMMIN, TALL/CUMMAX, TALL/CUMSUM, TALL/CUMPROD.

%   Copyright 2016-2017 The MathWorks, Inc.

in = tall.validateType(in, fcnStruct.Name, {'numeric', 'logical', 'duration'}, 1);
tall.checkNotTall(upper(fcnStruct.Name), 1, varargin{:});

[args, flags]      = splitArgsAndFlags(varargin{:});
[dirFlag, nanFlag] = iValidateFlags(flags, fcnStruct.Name, fcnStruct.DefaultNaNFlag);

if strcmp(dirFlag, 'reverse')
    error(message('MATLAB:bigdata:array:ReverseNotSupported', upper(fcnStruct.Name)));
end

switch numel(args)
    case 0
        dim = getDefaultReductionDimIfKnown(in.Adaptor);
        
    case 1
        dim = args{1};
        if ~isnumeric(dim) || ~isscalar(dim) || ~isreal(dim) || dim ~= floor(dim)
            error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
        end
        
    otherwise
        error(['MATLAB:',fcnStruct.Name,':wrongFlag'], ...
            '%s', ...
            getString(message('MATLAB:cumfun:wrongFlag')));
end

if isempty(dim)
    % Unknown dimension. Decide at runtime.
    out = ternaryfun( size(in,1)==1, ...
        slicefun(@(x) fcnStruct.SliceAccumFcn(x, dirFlag, nanFlag), in), ...
        iAccumulateInTallDim(fcnStruct, in, dirFlag, nanFlag) );
    
elseif dim == 1
    out = iAccumulateInTallDim(fcnStruct, in, dirFlag, nanFlag);
    
else
    out = slicefun(@(x) fcnStruct.SliceAccumFcn(x, dim, dirFlag, nanFlag), in);
    
end

% Set the output type using the rule provided
out = invokeOutputInfo(fcnStruct.TypeRule, out, {in});

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First pass - go through the data and calculate the reduced result per partition.
%
% This function is used within a StatefulFunction, where 'partResults' is the state.
% 'partResult' is the reduced value in the 1st dimension
% 'partitionResult' is a 1x2 table containing the partition Id and the
% accumulated result of the entire partition, otherwise it's empty
function [partResult, hasFinished, partitionResult] = iReducePartition(fcnStruct, partResult, info, in, nanFlag)

import matlab.bigdata.internal.util.indexSlices;

hasFinished = info.IsLastChunk;
if ~isempty(in)
    % Maybe update partition-wide reduced result
    resultThisChunk = fcnStruct.TallReduceFcn(in, nanFlag);
    if isempty(partResult)
        partResult = resultThisChunk;
    else
        partResult = fcnStruct.SliceAdjustFcn(partResult, resultThisChunk, nanFlag);
    end
end
if info.IsLastChunk && ~isempty(partResult)
    partitionResult = iMakeResultTableRow(info.PartitionId, partResult);
else
    % intra-partition chunk or empty partition => emit empty table row
    partitionResult = iMakeResultTableRow([], indexSlices(partResult, []));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper function that creates a single row of the partitionId - result
% mapping table.
function tableRow = iMakeResultTableRow(partitionId, result)
tableRow = table(...
    partitionId, result, ...
    'VariableNames', {'PartitionId', 'Result'});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Accumulate the values for one chunk. The initial chunk is offset by
% the result from previous partitions and each subsequent chunk offset by
% the final value from previous chunk.
%
% This function is used within a StatefulFunction, where 'endPt' is the
% state.
% 'endPt' is a slice representing the last slice before this chunk.
% 'in' is the input data
% 'partitionResults' is a table mapping partition Id to accumulated result
% The next argument would be the direction flag...
function [endPt, hasFinished, out] = iAccumulateChunk(fcnStruct, ...
    endPt, info, in, partitionResults, ~, nanFlag)

import matlab.bigdata.internal.util.indexSlices;

hasFinished = info.IsLastChunk;

% Take care with empty chunks
if isempty(in)
    % Invoke TallAccumFcn on empty input so that output has correct type.
    out = fcnStruct.TallAccumFcn(in);
    return;
end

firstNonEmptyPartition = min(partitionResults.PartitionId);

if isempty(endPt) && info.PartitionId > firstNonEmptyPartition
    % First slice of a subsequent partition - look in the results from
    % previous partitions.
    prevPartitionFilter = partitionResults.PartitionId < info.PartitionId;
    prevPartitionResults = partitionResults{prevPartitionFilter, 'Result'};
    % Reduce previous results. Note, when omitnan is specified, NaNs exist
    % in accumulated results for the following reasons:
    %  1. NaNs that originate from calculation (e.g. Inf + -Inf). These
    %     should be propagated to successor partitions. This is hit by
    %     cumsum and cumprod.
    %  2. NaNs that are emitted because the input is all NaN. These
    %     should not be propagated to successor partitions. This is hit by
    %     cummin and cummax.
    if fcnStruct.ForcePropagateDerivedNaNs
        endPt = fcnStruct.TallReduceFcn(prevPartitionResults, 'includenan');
    else
        endPt = fcnStruct.TallReduceFcn(prevPartitionResults, nanFlag);
    end
end

out = fcnStruct.TallAccumFcn(in, nanFlag);

% Adjust using the previous end-point (if any). We must do this after the
% accumulation so that NaN propagates correctly.
if ~isempty(endPt)
    out(:,:) = fcnStruct.SliceAdjustFcn(endPt(1,:), out(:,:), nanFlag);
end

endPt = indexSlices(out, size(out, 1));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the accumulation in the tall dimension. Uses a partitionfun to
% compute results per partition, and then another partitionfun to offset
% those, broadcasting the partition results.
function out = iAccumulateInTallDim(fcnStruct, in, dirFlag, nanFlag)

import matlab.bigdata.internal.util.StatefulFunction;
import matlab.bigdata.internal.FunctionHandle;
import matlab.bigdata.internal.broadcast;

% First up, we need the result per partition to offset each partition
resultPerPartitionFcn = StatefulFunction(@(partResult, info, x) iReducePartition(fcnStruct, partResult, info, x, nanFlag));
resultPerPartition    = partitionfun(FunctionHandle(resultPerPartitionFcn), in);
resultPerPartition    = broadcast(resultPerPartition);

% Next, we can compute the actual cumulative result
cumFcn      = StatefulFunction(@(endPt, info, x, partResults) iAccumulateChunk(fcnStruct, endPt, info, x, partResults, dirFlag, nanFlag));
out         = partitionfun(FunctionHandle(cumFcn), in, resultPerPartition);
out.Adaptor = copySizeInformation(out.Adaptor, in.Adaptor);
% The framework will assume out is partition dependent because it is
% derived from partitionfun. It is not, so we must correct this.
out = copyPartitionIndependence(out, in);
if isPartitionIndependent(in)
    out = markPartitionIndependent(out);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get a direction and nan flag, attempting to throw errors appropriately.
function [dirFlag, nanFlag] = iValidateFlags(flags, fcnName, defaultNaNFlag)
FCNNAME   = upper(fcnName);
dirFlags   = {'forward', 'reverse'};
nanFlags   = {'omitnan', 'includenan'};
validFlags = [dirFlags, nanFlags];
flags      = cellfun(@(s) validatestring(s, validFlags, FCNNAME), flags, 'UniformOutput', false);

dirFlag = iPickFlag(flags, dirFlags, dirFlags{1}, {['MATLAB:',fcnName,':duplicateDirection'], ...
    'MATLAB:cumfun:duplicateDirection'});
nanFlag = iPickFlag(flags, nanFlags, defaultNaNFlag, {['MATLAB:',fcnName,':duplicateNaNFlag'], ...
    'MATLAB:cumfun:duplicateNaNFlag'});

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get a unique flag, or throw the right error when a duplicate is supplied.
% 'validFlags' should have the default flag as the first element.
function flag = iPickFlag(flags, validFlags, defaultFlag, duplicateErrorIds)
flagMatch = ismember(flags, validFlags);
switch sum(flagMatch)
    case 0
        % Use the default
        flag = defaultFlag;
    case 1
        flag = flags{flagMatch};
    otherwise
        error(duplicateErrorIds{1}, '%s', getString(message(duplicateErrorIds{2})));
end
end
