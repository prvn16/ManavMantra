function out = vertcat(varargin)
%VERTCAT Vertical concatenation
%   Vertical concatenation for tall.
%
%   Limitations:
%   Vertical concatenation of character arrays is not supported.

% Copyright 2015-2017 The MathWorks, Inc.

% We cannot support vertical concatenation of tall char arrays.
for ii = 1 : numel(varargin)
    clz = tall.getClass(varargin{ii});
    if clz == "char"
        error(message('MATLAB:bigdata:array:VertcatUnsupportedChar'));
    elseif clz == ""
        varargin{ii} = lazyValidate(varargin{ii}, {@(x) ~ischar(x), 'MATLAB:bigdata:array:VertcatUnsupportedChar'});
    end
end

% Deal with any local inputs. These should be combined into one of the tall
% inputs.
args = iDealWithLocalInputs(varargin);

% If we have more than one input left, do a genuine tall-tall vertcat
if numel(args)>1
    out = iTallTallVertcat(args{:});
else
    out = args{1};
end

% The framework will assume the output is partition dependent because the
% implementation of tall/vertcat uses partitionfun. It is not, so we must
% correct this.
if isPartitionIndependent(varargin{:})
    out = markPartitionIndependent(out);
end

end

function out = iTallTallVertcat(varargin)

out = wrapUnderlyingMethod(@vertcatpartitions, {}, varargin{:});

inAdaptors = cellfun(@(x) matlab.bigdata.internal.adaptors.getAdaptor(x), varargin, ...
    'UniformOutput', false);

% Now try to work out the output type and size (will throw if we can detect
% inconsistent sizes)
try
    out.Adaptor = matlab.bigdata.internal.adaptors.combineAdaptors(1,inAdaptors);
catch err
    % combineAdaptors can throw a variety of errors that should appear to come from
    % this method.
    throw(err);
end

end

function args = iDealWithLocalInputs(args)
% Helper to combine local data into the tall inputs. The result will be one
% or more tall arrays that need full tall-to-tall concatenation.
isLocalInput = ~cellfun(@istall, args);

% Loop, combining one local input with its neighbor until the only
% arguments left are tall arrays.
while any(isLocalInput)
    idx = find(isLocalInput, 1, 'first');
    if idx<numel(args)
        % Combine with next input
        if isLocalInput(idx+1)
            % Combine two local inputs
            args{idx+1} = vertcat(args{idx}, args{idx+1});
        else
            args{idx+1} = iCombineTallWithLocal(@iPrepend, args{idx+1}, args{idx});
        end
    else
        % Combine with previous input (we know this must be present and
        % must be tall).
        args{idx-1} = iCombineTallWithLocal(@iAppend, args{idx-1}, args{idx});
    end
    % Update the arg list
    args(idx) = [];
    isLocalInput(idx) = [];
end
end

function out = iCombineTallWithLocal(mergeFcn, tallData, localData)
% Merge a local input into a tall input

out = partitionfun(@(info,x) mergeFcn(info,x,localData), tallData);

% Now try to work out the output type and size (will throw if we can detect
% inconsistent sizes)
import matlab.bigdata.internal.adaptors.getAdaptor;
inAdaptors = {getAdaptor(tallData), getAdaptor(localData)};
try
    out.Adaptor = matlab.bigdata.internal.adaptors.combineAdaptors(1,inAdaptors);
catch err
    % combineAdaptors can throw a variety of errors that should appear to come from
    % this method.
    throw(err);
end

end

function [hasFinished, tallData] = iPrepend(info, tallData, localData)
% Prepend localData to the first chunk of the first partition. There's
% probably a much better way to do this, but...

% Only prepend the data to the first chunk in the first partition.
if (info.PartitionId==1) && (info.RelativeIndexInPartition==1)
    tallData = vertcat(localData, tallData);
end
hasFinished = info.IsLastChunk;
end

function [hasFinished, tallData] = iAppend(info, tallData, localData)
% Append localData to the last chunk of the last partition. There's
% probably a much better way to do this, but...

% Only append the data to the last chunk in the last partition.
if (info.IsLastChunk) && (info.PartitionId==info.NumPartitions)
    tallData = vertcat(tallData, localData);
end
hasFinished = info.IsLastChunk;
end
