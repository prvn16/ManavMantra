function [Y, zf] = filter(b, a, X, varargin)
%FILTER One-dimensional digital filter.
%   Y = FILTER(B,A,X)
%   [Y,Zf] = FILTER(...,Zi)
%   FILTER(...,DIM)
%   FILTER(...,[],DIM) or FILTER(...,Zi,DIM)
%
%   Limitations:
%   Zf output argument is not supported when dim > 1
%
%   See also FILTER

% Copyright 2017 The MathWorks, Inc.

narginchk(3,5);
nargoutchk(0,2);
tall.checkNotTall(upper(mfilename), 0, b, a);
tall.checkIsTall(upper(mfilename), 3, X);
tall.checkNotTall(upper(mfilename), 3, varargin{:});
X = tall.validateType(X, mfilename, {'numeric', 'logical'}, 3);
iCheckFilterOpts(b, a, varargin{:});

[zi, dim] = iParseOptionalArgs(X, varargin{:});

if ~isempty(zi) && ~isvector(zi)
    zi = clientfun(@(szX, d) iValidateInitialDelay(b, a, szX, zi, d), size(X), dim);
end

[dimIsKnown, dimValue] = matlab.bigdata.internal.util.isGathered(hGetValueImpl(dim));

if dimIsKnown
    if dimValue == 1
        [Y, zf] = iFilterInTallDim(b, a, X, zi, dim);
    else
        % The delay output zf does not obey the chunk-wise function handle rule
        % when filtering along a small dim.
        if (nargout > 1)
            error(message('MATLAB:bigdata:array:FilterInvalidSecondArgOut'));
        end
        
        Y = iFilterInSmallDim(b, a, X, zi, dim);
    end
else
    if nargout <= 1
        import matlab.bigdata.internal.broadcast
        
        Y = ternaryfun(...
            size(X,1) > 1, ...
            iFilterInTallDim(b, a, X, zi, broadcast(dim)), ...
            iFilterInSmallDim(b, a, X, zi, broadcast(dim)));
    else
        % Only filter in tall dim supports both output arguments
        dim = lazyValidate(dim, {@(d) isequal(d,1) , ...
            'MATLAB:bigdata:array:FilterInvalidSecondArgOut'});
        
        [Y, zf] = iFilterInTallDim(b, a, X, zi, dim);
    end
end

% Filter result is always the same size as the input tall array
Y.Adaptor = copySizeInformation(Y.Adaptor, X.Adaptor);

outputClass = iGetOutputClass(b, a, X.Adaptor.Class, zi);
outputClassKnown = ~isempty(outputClass);
 
if outputClassKnown
    Y = setKnownType(Y, outputClass);
end
% As Y is derived from partitionfun, the framework assumes it is partition
% dependent data. We must correct this before returning Y to the user.
Y = copyPartitionIndependence(Y, X);

if nargout > 1
    % Delay result has size == [max(length(a),length(b))-1 sizeX(2:end)]
    delaySizeInTallDim = max(length(a), length(b)) - 1;
    delaySizeInTallDim = max(delaySizeInTallDim, 0);
    zf.Adaptor = setSizeInDim(zf.Adaptor, 1, delaySizeInTallDim);
    
    if isSmallSizeKnown(X.Adaptor)
        zf.Adaptor = setSmallSizes(zf.Adaptor, X.Adaptor.SmallSizes);
    end
    
    if outputClassKnown
        zf = setKnownType(zf, outputClass);
    end
    % As zf is derived from partitionfun, the framework assumes it is partition
    % dependent data. We must correct this before returning zf to the user.
    zf = copyPartitionIndependence(zf, X);
end

end

function iCheckFilterOpts(b, a, varargin)
% Check supplied filter coefs, zi (when possible), and dim on the client.
% The validity of zi can depend on the size of the input signal 

if ~isempty(varargin) && (~isfloat(varargin{1}) || isvector(varargin{1}) || isempty(varargin{1}))
    % Can check all inputs on the client when zi is a vector => does not
    % depend on the size of the input signal
    checkFcn = @() filter(b, a, [], varargin{:});
elseif length(varargin) > 1
    % Check the dim arg without zi, which must have small sizes that match
    % the input signal
    checkFcn = @() filter(b, a, [], [], varargin{2});
else
    % Can only verify that the filter coefs are sane
    checkFcn = @() filter(b, a, []);
end

try
    checkFcn();
catch e
    throwAsCaller(e)
end
end

function [zi, dim] = iParseOptionalArgs(X, varargin)
zi = [];
dim = findFirstNonSingletonDim(X);

if isempty(varargin)
    return;
end

zi = varargin{1};

if nargin > 2
    dim = tall.createGathered(varargin{2});
end
end

function zi = iValidateInitialDelay(b, a, sizeX, zi, dim)
% Validate that the dimensions of the supplied delay are consistent with
% the input signal.  This is necessary when the delay is a matrix or
% multi-dimensional.  We use filter on the client with a dummy signal that
% is non-empty & non-singular in the filtering dimension for this task.
filterDim = find(sizeX ~=1,1,'first');
sizeX(filterDim) = 2;
dummySignal = zeros(sizeX);
filter(b, a, dummySignal, zi, dim);
end

function outputClass = iGetOutputClass(b, a, inputClass, zi)
% Output class is always double, except when any of the inputs are single
localInputs = {b,a,zi};
localClasses = cellfun(@class, localInputs, 'UniformOutput', false);

if any(strcmpi([localClasses inputClass], 'single'))
    outputClass = 'single';
elseif ~isempty(inputClass)
    % Input class known, and none of the types are single => double output
    outputClass = 'double';
else
    % Input class unknown so leave the output untyped
    outputClass = '';
end
end

function [Y, zf] = iFilterInTallDim(b, a, X, zinitial, dim)
% Apply filter along the tall dimension in two passes:
%
% 1) Compute the zero-state solution within each partition
% 2) Adjust the result to account for 'earlier' partitions.
%
% The correction for FIR filters is localized to the first length(b)-1
% slices of each partition.  This could be represented using a backwards
% stencil operation but instead we make use of the delay output zf to
% propagate the equivalent backwards halo.
%
% For IIR filter, the recursive data dependency requires a synchronous step
% to compute the delays for the partitioned zero-input solution.  This is
% done using the delays found from the first pass (zero-state solution). 
% These corrected delays are then used to calculate the result using the 
% relation:  Y = Y_z0 (zero-state) + Y_x0 (zero-signal)

import matlab.bigdata.internal.util.StatefulFunction
import matlab.bigdata.internal.FunctionHandle
import matlab.bigdata.internal.broadcast

% Use a stateful function to filter each partition, propagating the filter
% delays across chunks and returning the total delay for the entire
% partition.  We also accumulate the number of slices in the partition
% using this stateful function.
initialState = {[], 0}; 
filterPartitionFcn = ...
    @(zi, info, x, dim) iFilterPartition(b, a, x, zi, dim, info);
filterFunctionHandle = ...
    FunctionHandle(StatefulFunction(filterPartitionFcn, initialState));

[Y, delayTable] = partitionfun(filterFunctionHandle, X, dim);
delayTable.Adaptor = iMakeDelayTableAdaptor();

delayTable = clientfun(@iInsertInitialDelay, size(X), delayTable, zinitial);
delayTable.Adaptor = iMakeDelayTableAdaptor();

if isscalar(a)
    % FIR Filter: Use a stateful functor to apply a correction to the head
    % slices of each partition based on previous partition delay.
    numHeadSlices = length(b) - 1;
    statefulAdjustFcn = StatefulFunction(@iFIRAdjustResultFcn, numHeadSlices);
    adjustFunctionHandle = FunctionHandle(statefulAdjustFcn);
    [Y, zf] = partitionfun(adjustFunctionHandle, Y, dim, broadcast(delayTable));
else
    % IIR Filter: first correct the delays to account for earlier
    % partitions.  This is done synchronously due to the recursive data
    % dependency of an IIR filter.  In other words, each partition depends
    % on every previous partition.  This clientfun synchronously runs
    % through a zero-signal array (one chunk at a time) of the same size as
    % tall input.  This effectively corrects the delays by propagating the
    % data dependencies between partitions.
    delayTable = clientfun(@(t) iAdjustIIRDelay(b, a, t), delayTable);
    delayTable.Adaptor = iMakeDelayTableAdaptor();
    
    % Next use a stateful functor that uses the corrected delays to create
    % the partitioned zero-signal solution to add on to the partitioned
    % zero-state solution computed in the first pass.
    adjustFcn = ...
        @(varargin) iIIRAdjustResultFcn(b, a, varargin{:});
    adjustFunctionHandle = ...
        FunctionHandle(StatefulFunction(adjustFcn));

    [Y, zf] = partitionfun(adjustFunctionHandle, Y, dim, broadcast(delayTable));
end

end

function Y = iFilterInSmallDim(b, a, X, zinitial, dim)
% Filter along a non-tall dim.  This is an elementwise operation but the
% dim may be deferred when executed through a ternaryfun.
import matlab.bigdata.internal.broadcast

Y = elementfun(@(varargin) filter(b, a, varargin{:}),...
    X, broadcast(zinitial), broadcast(dim));
end

function [state, hasFinished, y, delayTable] = iFilterPartition(b, a, x, state, dim, info)
% Filter each partition assuming zero initial state within each partition.

if dim ~= 1
    % Early return for ternaryfun execution
    import matlab.bigdata.internal.util.indexSlices
    
    hasFinished = true;
    y = indexSlices(x, []);
    delayTable = iMakeDelayTableRow([], {}, []);
    return;
end

% Unpack state cell 
zi = state{1};
numDataSlices = state{2};

numDataSlices = numDataSlices + size(x,1);

if isempty(x)
    % Empty Chunk => Roll over the previous delay value
    zf = zi;
    if isfloat(x)
        y = x;
    else
        y = double(x);
    end
else
    % Apply the filter and capture the filter delay to propagate onto
    % further chunks
    [y, zf] = filter(b, a, x, zi, dim);
end

if info.IsLastChunk
    if numDataSlices == 0
        % Entire partition is empty, make sure we emit the correct shape
        % for the partition delay
        [~, zf] = filter(b, a, x, zi, dim);
    end
    
    % Emit the final condition of the filter delays as well the total
    % number of slices for this partition.
    % delay is wrapped in a cell since zf could consist of multiple slices
    wrappedDelay = {zf};
    delayTable = iMakeDelayTableRow(...
        info.PartitionId, wrappedDelay, numDataSlices);
else
    % Within the partition emit correctly shaped & typed empty.
    delayTable = iMakeDelayTableRow([], {}, []);
end

% Pack final state
state = {zf, numDataSlices};

hasFinished = info.IsLastChunk;
end

function tableRow = iMakeDelayTableRow(partitionId, delay, numSlices)
tableRow = table(partitionId, delay, numSlices, ...
    'VariableNames', {'PartitionId', 'Delay', 'NumDataSlices'});
end

function dtAdaptor = iMakeDelayTableAdaptor()
import matlab.bigdata.internal.adaptors.getAdaptorForType
import matlab.bigdata.internal.adaptors.TableAdaptor

varNames = {'PartitionId', 'Delay', 'NumDataSlices'};
genericAdaptor = getAdaptorForType('');
varAdaptors = repmat({genericAdaptor}, size(varNames));
dtAdaptor = TableAdaptor(varNames, varAdaptors);
end

function delayTable = iInsertInitialDelay(sizeX, delayTable, zinitial)
% Insert dummy row for 'partition 0' to store the user-supplied initial
% filter delay.  The value can be a vector, matrix, or multidimensional 
% array.  The length/leading dimension will have already been validated but
% is now standardized as follows:
% 
% 1) zinitial should be a column vector to match the output format when
%    filtering in dim == 1
% 2) zinitial is expanded to match the small dimensions of the tall input

if isempty(zinitial)
    % No user supplied delay to insert
    return;
end

if isrow(zinitial)
    zinitial = zinitial.';
end

if isvector(zinitial)
    zinitial = repmat(zinitial, [1 sizeX(2:end)]);
end

dummyRow = iMakeDelayTableRow(0, {zinitial}, 0);
delayTable = [dummyRow; delayTable];
end

function [nh, hasFinished, yfinal, zFinal] = iFIRAdjustResultFcn(nh, info, y, dim, delayTable)
% Adjust the filter result using the delay outputs from each partition
% For an FIR filter, the adjustment is localized to just the first
% length(b) - 1 slices of each partition.

import matlab.bigdata.internal.util.indexSlices

if dim ~= 1
    % Early return for ternaryfun execution
    hasFinished = true;
    yfinal = indexSlices(y, []);
    zFinal = [];
    return;
end

T = iRmEmptyPartitions(delayTable);
priorPartitions = T.PartitionId < info.PartitionId;
priorDelays = T(priorPartitions, :);

if isempty(priorDelays) || nh == 0
    % No adjustment to make:
    % Either processing the first non-empty partition and zero-state input
    % or already processed the head correction for this partition
    yfinal = y;
else
    % Adjust the first nh slices of the result
    [yfinal, numCorrectedSlices] = iApplyHeadCorrection(info, y, priorDelays);
    
    % Decrement the number of head slices that were corrected.
    nh = nh - numCorrectedSlices;
end

% Conditionally emit the final delay
if info.IsLastChunk && info.PartitionId == 1
    zFinal = iAccumulateDelays(delayTable);
else
    zFinal = indexSlices(delayTable.Delay{end}, []);
end

hasFinished = info.IsLastChunk;
end

function [y, numCorrectedSlices] = iApplyHeadCorrection(info, y, delayTable)
% Applies the head correction defined by the delay outputs from previous
% partitions.  This deals with the case where a delay may span multiple
% chunks of a partition.

import matlab.bigdata.internal.util.indexSlices

zprior = iAccumulateDelays(delayTable);

% Work out the indices to correct, starting from the first slice up to
% either the delay length, or the whole chunk (whichever is smaller).
startId = info.RelativeIndexInPartition;
endId = min(size(zprior, 1), startId + size(y,1) - 1);

correction = indexSlices(zprior, startId:endId);
numCorrectedSlices = size(correction, 1);
y(1:numCorrectedSlices, :) = y(1:numCorrectedSlices, :) + correction(:,:);
end

function zprior = iAccumulateDelays(delayTable)
% Accumulate the total delay zprior for the input delayTable.  
% This deals with the case where a delay may span multiple partitions.

% Always supply the dim arg in case zf is a row => 2-d tall input & length(b) == 2
TALL_DIM = 1;

% cumsum the NumDataSlices column to work out whether there are any 
% partitions fall within the delay 'reach'
numDataSlices = delayTable.NumDataSlices;
numDataSlices = circshift(numDataSlices, -1, TALL_DIM);
numDataSlices(end) = 0;
sliceShifts = cumsum(numDataSlices, TALL_DIM, 'reverse');

% Select only the table rows that fall within the delay reach
delaySample = delayTable.Delay{1};
delaySize = size(delaySample);
delayTable = delayTable(sliceShifts < delaySize(1), :);
sliceShifts = sliceShifts(sliceShifts < delaySize(1));

% Simplest case is when the delay is just given by the immediately
% neighboring partition
if height(delayTable) == 1
    zprior = delayTable.Delay{1};
    return;
end
    
% Must have delays that span multiple partitions so accumulate them
% together by applying the appropriate slice shift onto further away
% partitions.  The shift is equal to the total number of slices that stand
% between the partition that emitted the partial delay and the one which we
% are accumulating towards.
zprior = zeros(delaySize, 'like', delaySample);

for ii=1:height(delayTable)
    partitionDelay = delayTable.Delay{ii};
    n = size(zprior, TALL_DIM) - sliceShifts(ii);
    zprior(1 : n, :) = zprior(1 : n, :) + partitionDelay(end - n + 1 : end, :);
end
end

function delayTable = iAdjustIIRDelay(b, a, delayTable)
% Sweep over the delayTable, updating the delays using the zero-signal
% solution.  Start at the second row as the delay of the first row is by
% construction already correct

if sum(delayTable.NumDataSlices) == 0
    % All partitions are empty, nothing to do here
    return;
end

delayTable = iRmEmptyPartitions(delayTable);

delaySize = size(delayTable.Delay{1});

for ii=2:height(delayTable)
    % Extract the previous delay
    prevDelay = delayTable{ii - 1, 'Delay'};
    prevDelay = prevDelay{1};
    
    % Correct the delay for the current row, using a zero-signal input.
    % Work through one chunk at a time until we have processed as many data
    % slices as were in the current partition of the input signal.
    row = delayTable(ii, :);
    NUM_CHUNK_SLICES = 2e4;
    numDataSlices = row.NumDataSlices;
    
    while numDataSlices ~=0
        numSlices = min(numDataSlices, NUM_CHUNK_SLICES);
        zeroSignal = zeros(numSlices, delaySize(2:end));
        [~, zZeroSignal] = filter(b, a, zeroSignal, prevDelay, 1);
        
        % update for next iteration
        prevDelay = zZeroSignal;
        numDataSlices = numDataSlices - numSlices;
    end
    
    % Add the zero-signal delay onto the zero-state delay to obtain the
    % corrected initial state for the partition.
    zZeroState = row.Delay{1};
    zTotal = zZeroState + zZeroSignal;
    
    % Repack the corrected delay back into the table which will then be
    % used in the next iteration to correct the following partition, and
    % onwards until we have corrected the delay for every partition.
    row.Delay = {zTotal};
    delayTable(ii, :) = row;
end
end

function [state, hasFinished, yFinal, zFinal] = iIIRAdjustResultFcn(b, a, state, info, yZeroState, dim, delayTable)
import matlab.bigdata.internal.util.indexSlices

if dim ~=1
    % Early return for ternaryfun execution
    hasFinished = true;
    yFinal = indexSlices(yZeroState, []);
    zFinal = [];
    return;
end

% Unpack the delay from the previous partition
% Don't assume partition Ids are consecutive
prevPartitionRowId = find(delayTable.PartitionId < info.PartitionId, 1, 'last');

if isempty(prevPartitionRowId)
    % Processing first non-empty partition with zero input state
    yFinal = yZeroState;
else
    if isempty(state)
        % Extract the previous delay value and use it to calculate the zero
        % input solution
        prevDelay = delayTable{prevPartitionRowId, 'Delay'};
        prevDelay = prevDelay{1};
    else
        prevDelay = state{1};
    end
    
    zeroSignal = zeros(size(yZeroState));
    [yZeroSignal, zZeroSignal] = filter(b, a, zeroSignal, prevDelay, dim);
    yFinal = yZeroState + yZeroSignal;
    state = {zZeroSignal};
end

finalDelay = delayTable{end, 'Delay'};
finalDelay = finalDelay{1};

% Conditionally emit the final delay
if info.IsLastChunk && info.PartitionId == 1
    zFinal = finalDelay;
else
    zFinal = indexSlices(finalDelay, []);
end

hasFinished = info.IsLastChunk;
end

function T = iRmEmptyPartitions(T)
% Remove rows that correspond to empty partitions
% Except always keep Partition 0 which corresponds to the user supplied
% initial delay.
T = T(T.NumDataSlices ~= 0 | T.PartitionId == 0, :);
end
