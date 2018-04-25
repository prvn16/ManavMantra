function varargout = gather(varargin)
%GATHER Execute queued operations and collect tall array into workspace
%   X = GATHER(TX) executes all queued operations required to calculate
%   tall array TX, then collects the results in the local workspace as X.
%
%   Gathering a tall array involves evaluating the underlying operations
%   needed to compute the result. Most operations on tall arrays are
%   deferred until you call GATHER to be efficient for big data. To fully
%   utilize the advantages of tall arrays it is important to use GATHER
%   only when you need to see output.
%
%   The GATHER function returns the entire result into the local memory of
%   MATLAB. Therefore, if the tall array has not been reduced in some way
%   (for example by using a summarizing function such as MIN or SUM), then
%   the call to GATHER can cause MATLAB to run out of memory. If you are
%   unsure whether the result can fit in memory, use GATHER(HEAD(TX)) or
%   GATHER(TAIL(TX)) to bring only a small portion of the result into
%   memory.
%
%   [X1,X2,...] = GATHER(TX1,TX2,...) gathers multiple tall arrays at the
%   same time. This syntax is more efficient than multiple separate calls
%   to GATHER.
%
%   Example:
%      % Create a datastore.
%      varnames = {'ArrDelay', 'DepDelay', 'Origin', 'Dest'};
%      ds = datastore('airlinesmall.csv', 'TreatAsMissing', 'NA', ...
%         'SelectedVariableNames', varnames);
%
%      % Create a tall table from the datastore.
%      tt = tall(ds);
%
%      % Compute the minimum and maximum arrival delays, ignoring NaN values. 
%      % minDelay and maxDelay are unevaluated tall arrays.
%      minDelay = min(tt.ArrDelay, [], 'omitnan'); 
%      maxDelay = max(tt.ArrDelay, [], 'omitnan');
%
%      % Here we gather both values simultaneously, forcing evaluation.
%      [localMin, localMax] = gather(minDelay, maxDelay);
%
%   See also: TALL, TALL/HEAD, TALL/TAIL.

%   Copyright 2015-2017 The MathWorks, Inc.

if nargout > nargin
    error(message('MATLAB:bigdata:array:GatherInsufficientInputs'));
end

varargout = cell(1, max(nargout, 1));
[varargout{:}] = iGather(varargin{:});

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = iGather(varargin)

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

isArgTall = cellfun(@istall, varargin);

% We GATHER all RHS arguments, and return the values of only those requested.
numToReturn = max(1, nargout);
try
    % First gather the tall inputs, and check the adaptors had correct information.
    tallArgs = unpackValueImpls(varargin(isArgTall));
    [gatheredTalls{1:sum(isArgTall)}] = gather(tallArgs{:});
    cellfun(@iAssertAdaptorMatches, gatheredTalls, varargin(isArgTall));

    % Then, gather the non-tall inputs. Here we're presuming a
    % lowest-common-denominator single-input-only form of GATHER.
    otherArgs = cellfun(@gather, varargin(~isArgTall), 'UniformOutput', false);

    % Stitch the various gathered arrays back into a single cell array
    allOutputs             = cell(1, nargin);
    allOutputs(isArgTall)  = gatheredTalls;
    allOutputs(~isArgTall) = otherArgs;

    % Return only those requested.
    varargout = allOutputs(1:numToReturn);
catch err
    matlab.bigdata.internal.util.assertNotInternal(err);
    if matlab.internal.display.isHot
        msg = getString(message('MATLAB:bigdata:array:ErrorDuringGather'));
        err = appendToMessage(err, msg);
    end
    updateAndRethrow(err);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iAssertAdaptorMatches(local, tvar)

assertionFmtPrefix = 'An internal consistency error occurred. Details:\n';

adaptor = matlab.bigdata.internal.adaptors.getAdaptor(tvar);
actualClass = class(local);
expectedClass = adaptor.Class;
if ~isempty(expectedClass)
    assert(strcmp(expectedClass, actualClass), ...
           [assertionFmtPrefix, ...
            '  Class of output incorrect. Expected: %s, actual: %s.'], ...
           expectedClass, actualClass);
else
    assert(~ismember(actualClass, matlab.bigdata.internal.adaptors.getStrongTypes()), ...
           [assertionFmtPrefix, ...
            '  Class of output unexpectedly not known. Actual class: %s'], ...
           actualClass);
end

actualNdims = ndims(local);
expectedNdims = adaptor.NDims;
assert(isnan(expectedNdims) || isequal(actualNdims, expectedNdims), ...
       [assertionFmtPrefix, ...
        '  NDIMS of output incorrect. Expected: %d, actual: %d.'], ...
        expectedNdims, actualNdims);
actualSize = size(local);

if ~isnan(expectedNdims)
    expectedSize = adaptor.Size;
    ok = (actualSize == expectedSize) | isnan(expectedSize);
    assert(all(ok), ...
           [assertionFmtPrefix, ...
            '  SIZE of output incorrect. Expected: [%s], actual: [%s].'], ...
           num2str(expectedSize), num2str(actualSize));
end

% Recurse to ensure all nested type/sizes are as expected.
if istable(local) || istimetable(local)
    for ii = 1:width(local)
        iAssertAdaptorMatches(local.(ii), subsref(tvar, substruct('.', ii)));
    end
end

% This will update the TallSize handle behind the scenes so that other arrays
% with the same TallSize get their size populated.
setKnownSize(adaptor, actualSize);
end
