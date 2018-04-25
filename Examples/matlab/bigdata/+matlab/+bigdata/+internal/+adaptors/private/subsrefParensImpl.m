function [outPa, isTallSizeUnchanged, outTallSize, outSmallSizes] = ...
    subsrefParensImpl(inPa, szPa, S)
%subsrefParensImpl Implementation of subsref for () case
%   [outPa, isTallSizeUnchanged, outTallSize] = subsrefParens(inPa, szPa, S)
%   outPa and inPa are PartitionedArrays, S is the
%   substruct. isTallSizeUnchanged is true when indexing did not modify the tall
%   size. outTallSize is a scalar double array indicating the resulting size of
%   the operation, if known (NaN if not known). outSmallSizes is a vector
%   specifying the small sizes of the result - might be [] if not known
%   (i.e. single-subscript case).
%
%   This implementation is intended to operate on all underlying classes of
%   tall.

% Copyright 2016-2017 The MathWorks, Inc.

nargoutchk(0,4);

subs = S.subs;
outPa = inPa;
outTallSize = NaN;
isTallSizeUnchanged = false;

if isempty(subs)
    isTallSizeUnchanged = true;
    outSmallSizes = [];
    return
end

if any(cellfun(@(v) isa(v, 'tall'), subs(2:end)))
    error(message('MATLAB:bigdata:array:TallSubscriptInNonTallDimension'));
end

outSmallSizes = getSubsrefParenSmallSizes(subs(2:end));

if ~istall(subs{1})
    if isEquivalentToLiteralColon(subs{1})
        % Convert EndMarker to literal colon
        subs{1} = ':';
    end
    if iIsTailIndexing(subs{1})
        % 'end'-based indexing in tall dimension.
        [outPa, outTallSize] = iEndBasedIndexing(inPa, szPa, subs);
    elseif matlab.bigdata.internal.util.isOneToKSubscript(subs{1})
        reverse = subs{1}(1) ~= 1;
        numRowsToSelect = double(max(subs{1}));
        outTallSize = numRowsToSelect;
        outPa = iOneToNIndexing(inPa, szPa, reverse, numRowsToSelect, subs);
    elseif iIs1ToKColonDescriptor(subs{1})
        colonDescriptor = subs{1};
        reverse = (colonDescriptor.Stride == -1);
        if isempty(colonDescriptor)
            % Index expressions like "1:0" end up here - the 'Stride' is
            % still 1, but the Stop is less than the Start.
            numRowsToSelect = 0;
        else
            numRowsToSelect = double(max([colonDescriptor.Start, colonDescriptor.Stop]));
        end
        outTallSize = numRowsToSelect;
        outPa = iOneToNIndexing(inPa, szPa, reverse, numRowsToSelect, subs);
    elseif matlab.bigdata.internal.util.isColonSubscript(subs{1})
        % Just apply the indexing to slices
        outPa = iHandleExtraSubscripts(outPa, subs(2:end));
        isTallSizeUnchanged = true;
    elseif isColonDescriptor(subs{1}) || isColonEndMarker(subs{1})
        % We special case colon forms because we can resolve colon forms on
        % the workers. This results in less client -> worker communication.
        [outPa, outTallSize] = iColonFormIndexing(inPa, szPa, subs);
    elseif isa(subs{1}, 'timerange') || isa(subs{1}, 'withtol') || ...
            isdatetime(subs{1}) || isduration(subs{1}) || ...
            ischar(subs{1}) || iscellstr(subs{1}) || isstring(subs{1})
        % time related indexing into a timetable.
        outPa = chunkfun(@subsref, inPa, S);
    else
        [outPa, outTallSize] = iGeneralNonTallNumericIndexing(inPa, szPa, subs);
    end
elseif tall.getClass(subs{1}) == "logical"
    % First subscript must be tall logical vector.
    subs{1} = tall.validateColumn(subs{1}, 'MATLAB:bigdata:array:TallSubscriptVector');
    outPa = filterslices(hGetValueImpl(subs{1}), outPa);
    % There might be no more work to do here, but error checking on the number of
    % subscripts happens here.
    outPa = iHandleExtraSubscripts(outPa, subs(2:end));
else
    % Attempt numeric indexing. This implementation will fallback to
    % logical indexing if the underlying type does actually turn out to be
    % logical and this was not known in advance.
    subs{1} = tall.validateColumn(subs{1}, 'MATLAB:bigdata:array:TallSubscriptVector');
    % There might be no more work to do here, but error checking on the number of
    % subscripts happens here.
    outPa = iHandleExtraSubscripts(outPa, subs(2:end));
    outPa = subsrefTallNumeric(outPa, hGetValueImpl(subs{1}));
end

if numel(subs) == 1 && ~istall(subs{1})
    % Unfortunately, when indexing with a single non-tall subscript, we must
    % discard size information since the array might be a tall scalar -
    % indexing a tall scalar results in a row or column depending on the
    % orientation of the subscript.
    isTallSizeUnchanged = false;
    outTallSize = NaN;
    outSmallSizes = [];
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = iIsTailIndexing(subscript)
tf = isEndMarker(subscript) && subscript.isValidTallEndExpression();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% True only if the subscript is a ColonDescriptor object describing 1:K or
% K:-1:1.
function tf = iIs1ToKColonDescriptor(sub)
if isColonDescriptor(sub) && ~hasNonIntegerIndex(sub)
    tf = (sub.Start == 1 && sub.Stride == 1) || ...
         (sub.Stop  == 1 && sub.Stride == -1);
else
    tf = false;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to resolve EndMarker instances for the given chunk.
% subs is the cell array of subscripts
function subs = iResolveEndMarkersForChunk(subs, firstDimOfSubs, chunk)

totalNumSubscripts = firstDimOfSubs - 1 + numel(subs);
indexingDims = max(2, totalNumSubscripts);
[indexingSize{1:indexingDims}] = size(chunk);
indexingSize = [indexingSize{:}];
for idx = 1:numel(subs)
    if isEndMarker(subs{idx})
        workingDim = firstDimOfSubs + idx - 1;
        subs{idx} = subs{idx}.resolve(indexingSize, workingDim);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = iAssertGotEnoughRows(x, fullSz, numRowsExpected)
if fullSz(1) < numRowsExpected
    error(message('MATLAB:bigdata:array:InsufficientRowsForTallSubscript'));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, outTallSize] = iEndBasedIndexing(in, szPa, subs) %#ok<INUSL>
endExpression = subs{1};
remainingSubscripts = subs(2:end);

[ok, numRowsToSelect, reverse] = endExpression.isValidTallEndExpression();
outTallSize = numRowsToSelect;
if ok
    % We use extractTail as this has extra logic to handle the fact that
    % reduction between partitions can occur in any order.
    out = matlab.bigdata.internal.lazyeval.extractTail(in, numRowsToSelect);
    szPa = clientfun(@size, out);

    out = aggregatefun(@(x) iSelectRowsAtEnd(numRowsToSelect, remainingSubscripts, x), ...
                       @(x) iSelectRowsAtEnd(numRowsToSelect, [], x), out);
    out = clientfun(@(x, sz) iAssertGotEnoughRows(x, sz, numRowsToSelect), out, szPa);
    if reverse
        out = clientfun(@(x) flip(x, 1), out);
    end
    if isempty(remainingSubscripts)
        % Single subscript case - might need to fix shape of scalar
        out = clientfun(@(x, sz) iFixScalarSingleSubscript(x, sz, endExpression), out, szPa);
    end
else
    error(message('MATLAB:bigdata:array:InvalidEndSubscript'));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = iSelectRowsAtEnd(numRowsToSelect, remainingSubscripts, x)
if iscell(remainingSubscripts)
    % Aggregate phase - need to subselect higher dimensions
    iErrorCheckNumSubscripts(x, remainingSubscripts);
else
    % Reduce phase - keep everything in higher dimensions
    remainingSubscripts = repmat({':'}, 1, ndims(x) - 1);
end
numRowsToSelect = min(size(x,1), numRowsToSelect);
endOffset = numRowsToSelect - 1;
remainingSubscripts = iResolveEndMarkersForChunk(remainingSubscripts, 2, x);
out = x(end-endOffset:end, remainingSubscripts{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = iFixScalarSingleSubscript(x, fullSz, sub1)
if isequal(fullSz, [1 1])
    if isEndMarker(sub1)
        sub1 = resolve(sub1, fullSz, 1);
    end
    if isrow(sub1)
        x = reshape(x, 1, []);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = iOneToNIndexing(in, inSzPa, reverse, numRowsToSelect, subs)
% This is to make 1:N indexing more efficient and to handle the fact that
% reduction between partitions can occur in any order.
remainingSubscripts = subs(2:end);
out = matlab.bigdata.internal.lazyeval.extractHead(in, numRowsToSelect);
szPa = clientfun(@size, out);

out = aggregatefun(@(x) iSelectRowsAtBeginning(numRowsToSelect, remainingSubscripts, x), ...
                   @(x) iSelectRowsAtBeginning(numRowsToSelect, [], x), out);
out = clientfun(@(x, sz) iAssertGotEnoughRows(x, sz, numRowsToSelect), out, szPa);
if reverse
    out = clientfun(@(x) flip(x, 1), out);
end
if isempty(remainingSubscripts)
    % Single subscript case - might need to fix shape of scalar
    out = clientfun(@(x, sz) iFixScalarSingleSubscript(x, sz, subs{1}), out, inSzPa);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = iSelectRowsAtBeginning(numRowsToSelect, remainingSubscripts, x)
if iscell(remainingSubscripts)
    % Aggregate phase - need to subselect higher dimensions
    iErrorCheckNumSubscripts(x, remainingSubscripts);
else
    % Reduce phase - keep everything in higher dimensions
    remainingSubscripts = repmat({':'}, 1, ndims(x) - 1);
end
numRowsToSelect = min(size(x,1), numRowsToSelect);
remainingSubscripts = iResolveEndMarkersForChunk(remainingSubscripts, 2, x);
out = x(1:numRowsToSelect, remainingSubscripts{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Take a first subscript and either resolve it to numeric form, or leave it as a
% ColonDescriptor. This only supports subscripts that have a colon form.
function [resolved, outTallSize] = iResolveColonFormFirstSubscript(sub)

if isColonDescriptor(sub)
    resolved = sub;
    isAllRealIntegerGE1 = isreal(resolved.Start) && ...
        isreal(resolved.Stride) && ...
        resolved.Start == floor(resolved.Start) && ...
        resolved.Stride == floor(resolved.Stride) && ...
        resolved.Start >= 1;
    
    outTallSize = prod(size(resolved)); %#ok<PSIZE> ColonDescriptor numel returns 1

elseif isEndMarker(sub)
    % End markers are tricky. We can support them, but only in the case where they
    % turn out to be monotonically increasing or decreasing. There's no way
    % from the client to work out if that is going to be the case - consider
    % something like "x = 1:10; x([end-3, 10])". So, we defer some of the
    % error checking to GATHER time.
    resolved            = sub;  % Will be interpreted on the workers
    isAllRealIntegerGE1 = true; % Will be checked on the workers
    outTallSize         = computeResultingSize(resolved);
end
if ~isAllRealIntegerGE1
    error(message('MATLAB:badsubscript', ...
        getString(message('MATLAB:matrix:badTypeIndices'))));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sub, minAndMax, reverse, isVector] = iResolveColonDescriptorSub1ThisChunk(...
    inSub, chunkOffset, chunkTallSize)

if inSub.Stride == 0
    % Subscript of form 1:0:7 - MATLAB treats this as empty.
    sub = zeros(1,0);
    minAndMax = [NaN,NaN];
    reverse = false;
    isVector = true;
    return;
end

A          = double(inSub.Start);
D          = double(inSub.Stride);
B          = double(inSub.Stop);
chunkRange = [(1 + chunkOffset), (chunkOffset + chunkTallSize)];

% Given colon form A:D:B, we need to find n1 and n2 such that
% A + n1 * D is the first value inside the chunk range and
% A + n2 * D is the last value inside the chunk range

if D > 0
    % Increasing colon form, first value must exceed A and start of chunk.
    % A + n1 * D >= max(A, chunkRange(1))
    n1 = ceil((max(A, chunkRange(1)) - A) / D);
    % Last value must not exceed neither B nor end of chunk
    % A + n2 * D <= min(B, chunkRange(2))
    n2 = floor((min(B, chunkRange(2)) - A) / D);
else
    % Decreasing colon form, first value must exceed neither A nor end of chunk
    % A + n1 * D <= min(A, chunkRange(2))
    n1 = ceil((min(A, chunkRange(2)) - A) / D);
    % Last value must exceed B and start of chunk
    % A + n2 * D >= max(B, chunkRange(1))
    n2 = floor((max(B, chunkRange(1)) - A) / D);
end
newStart = A + n1 * D;
newStop  = A + n2 * D;
sub      = (newStart:D:newStop) - chunkOffset;

% Calculate overall start and stop
minAndMax   = [min(sub), max(sub)];

% Calculate reverse
reverse = D < 0;

% Always a vector
isVector = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sub, minAndMax, reverse, isVector] = iResolveEndMarkerSub1ThisChunk(...
    inSub, chunkOffset, chunkTallSize, totalTallSize)

% Start by using the end marker's 'resolve' method to convert to a numeric
% representation over the whole tall size.
numericSub = resolve(inSub, [totalTallSize, 1], 1);
isVector   = isvector(numericSub);
numericSub = numericSub(:);
isNonDecreasing = issorted(numericSub);
isNonIncreasing = issorted(flip(numericSub));

assert(isNonDecreasing || isNonIncreasing, ...
    'Assertion failed: General EndMarker reached optimized codepath for colon form EndMarker');

% Now is the first chance we get to check the validity of the end expression.
if ~(isreal(numericSub) && ...
        all(numericSub == floor(numericSub)) && ...
        all(numericSub >= 1))
    error(message('MATLAB:badsubscript', ...
        getString(message('MATLAB:matrix:badTypeIndices'))));
end
reverse = ~isNonDecreasing;

minAndMax = [min(numericSub), max(numericSub)];

sub   = numericSub - chunkOffset;
valid = sub > 0 & sub <= chunkTallSize;
sub   = sub(valid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Given a tall subscript, and the offset and tall size of this chunk, resolve the
% subscript in terms of local indices for this chunk. This only supports
% ColonDescriptor and EndMarkers that have a colon form.
function [sub, minAndMax, reverse, isVector] = iResolveColonFormSub1ThisChunk(...
    inSub, chunkOffset, chunkTallSize, totalTallSize)

if isColonDescriptor(inSub)
    [sub, minAndMax, reverse, isVector] = iResolveColonDescriptorSub1ThisChunk(...
        inSub, chunkOffset, chunkTallSize);
else
    [sub, minAndMax, reverse, isVector] = iResolveEndMarkerSub1ThisChunk(...
        inSub, chunkOffset, chunkTallSize, totalTallSize);
end
if ~isempty(minAndMax) && minAndMax(2) > totalTallSize
    error(message('MATLAB:badsubscript', ...
        getString(message('MATLAB:matrix:indexExceedsDims'))));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numeric colon-form indexing partition function.
% 'x' is a chunk of the tall array being indexed
% 'subs' are the subscripts being applied - ColonDescriptor or EndMarker
% 'partSlices' is the number of slices per partition
% 'out' is the indexed chunk
function [hasFinished, out, reverse] = iColonFormIndexingImpl(info, x, subs, partSlices)

% First the usual check that we have the required number of subscripts.
iErrorCheckNumSubscripts(x, subs(2:end));

% Use CUMSUM to compute the starting point for each partition
partitionOffsets = cumsum([1; partSlices]);
totalTallSize    = partitionOffsets(end) - 1;

% Use the partition information to resolve the tall subscript, and apply it.
thisPartition   = info.PartitionId;
thisChunkOffset = partitionOffsets(thisPartition) - 1 + info.RelativeIndexInPartition - 1;
[sub1_valid, sub1MinMax, reverse, isSub1Vector] = ...
    iResolveColonFormSub1ThisChunk(subs{1}, thisChunkOffset, size(x, 1), totalTallSize);

% If we are indexing a vector with a single subscript, that subscript must be a
% vector - otherwise the shape would change. (Note that if we are indexing a
% matrix, then "iErrorCheckNumSubscripts" ensures that we have 1 subscript per
% dimension, and therefore it's OK to have non-vector subscripts, as these are
% treated as vectors)
szX       = size(x);
szX(1)    = totalTallSize;
isXVector = numel(szX) == 2 && any(szX == 1);
if isscalar(subs) && isXVector && ~isSub1Vector
    error(message('MATLAB:bigdata:array:FirstSubscriptVector'));
end

% Resolve any end markers in other subscript positions
subs(2:end)     = iResolveEndMarkersForChunk(subs(2:end), 2, x);
out             = x(sub1_valid, subs{2:end});

if reverse
    % If the subscript is in decreasing order, then we must flip the result of the
    % chunk index here, it will be flipped back later at the client.
    out = flip(out, 1);
end

if info.RelativeIndexInPartition ~= 1
    % Don't need to return 'resolve' if we're not in the first chunk of the
    % partition.
    reverse = false(0,1);
end

% Can this partition possibly supply any more values? Not if either all
% requested slices are after this partition starts, or all requested slices have
% already been supplied. We are definitely finished if the tall subscript was
% empty.
if isempty(subs{1})
    hasFinished = true;
elseif isempty(sub1MinMax)
    hasFinished = info.IsLastChunk;
else
    allRequestedSlicesAreAfterThisPartition = sub1MinMax(1) >= partitionOffsets(thisPartition+1);
    thisChunkFinalGlobalIndex               = thisChunkOffset + size(x, 1);
    allRequestedSlicesHaveBeenSupplied      = sub1MinMax(2) <= thisChunkFinalGlobalIndex;
    hasFinished = info.IsLastChunk || ...
        allRequestedSlicesAreAfterThisPartition || ...
        allRequestedSlicesHaveBeenSupplied;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implementation of colon numeric indexing - i.e. where the first subscript
% is either a colon descriptor or an end marker in colon form.
function [outPa, outTallSize] = iColonFormIndexing(inPa, szPa, subs)

% We require that the first subscript is monotonic. This might reverse the
% subscript, and indicate this has been done so it can be undone later.
[subs{1}, outTallSize] = iResolveColonFormFirstSubscript(subs{1});

% Now we've got a non-decreasing first subscript, let's get the partition and
% broadcast that.
partSlices = matlab.bigdata.internal.lazyeval.getPartitionSizes(inPa);
partSlices = matlab.bigdata.internal.broadcast(reducefun(@vertcat, partSlices));

% Finally all the general numeric indexing implementation with the partition
% information.
[outPa, reverse] = partitionfun(@(info, x, partSlices) iColonFormIndexingImpl(info, x, subs, partSlices), ...
                                inPa, partSlices);
outPa = clientfun(@iMaybeFlipInDim1, outPa, reverse);
if isscalar(subs)
    % Single subscript case - might need to fix shape of scalar
    outPa = clientfun(@(x, sz) iFixScalarSingleSubscript(x, sz, subs{1}), outPa, szPa);
end

% The framework will assume outPa is partition dependent because it is
% derived from partitionfun. It is not, so we must correct this.
if isPartitionIndependent(inPa)
    outPa = markPartitionIndependent(outPa);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Used with clientfun to conditionally flip the result of indexing operation.
function x = iMaybeFlipInDim1(x, reverse)
if any(reverse)
    x = flip(x, 1);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implementation of 'general' numeric indexing - i.e. where the first subscript
% is not handled as colon descriptor etc.
function [outPa, outTallSize] = iGeneralNonTallNumericIndexing(inPa, szPa, subs)

if islogical(subs{1})
    subs{1} = find(subs{1});
end

if isEndMarker(subs{1})
    outputCanBeRow = true;
    outTallSize = computeResultingSize(subs{1});
    resolvedFirstSub = clientfun(@(sz) subs{1}.resolve(sz, 1), szPa);
    if isscalar(subs)
        resolvedFirstSub = elementfun(@iVerifyVector, resolvedFirstSub);
    end
    resolvedFirstSub = clientfun(@iColonize, resolvedFirstSub);
else
    if isnumeric(subs{1})
        resolvedFirstSub = double(subs{1});
    else
        resolvedFirstSub = 1 + subsindex(subs{1});
    end
    
    outputCanBeRow = isrow(resolvedFirstSub);
    outTallSize = numel(resolvedFirstSub);
    if isscalar(subs)
        resolvedFirstSub = iVerifyVector(resolvedFirstSub);
    end
    resolvedFirstSub = iColonize(resolvedFirstSub);
    resolvedFirstSub = matlab.bigdata.internal.lazyeval.LazyPartitionedArray.createFromConstant(resolvedFirstSub(:), szPa.Executor);
end

% There might be no more work to do here, but error checking on the number of
% subscripts happens here.
outPa = iHandleExtraSubscripts(inPa, subs(2:end));

outPa = subsrefTallNumeric(outPa, resolvedFirstSub);
if isscalar(subs) && outputCanBeRow
    % Single subscript case - might need to fix shape of scalar
    outPa = clientfun(@(x, sz) iFixScalarSingleSubscript(x, sz, subs{1}), outPa, szPa);
    outTallSize = NaN;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sub = iVerifyVector(sub)
if ~isvector(sub)
    matlab.bigdata.internal.throw(...
        message('MATLAB:bigdata:array:FirstSubscriptVector'));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sub = iColonize(sub)
sub = sub(:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% when we're actually executing, we can assert that we have sufficient
% subscripts for the size of the value. If the value is not a *column* vector,
% we need at least two subscripts - i.e. we can reshape the small dimensions,
% but not the tall dimension.
function iErrorCheckNumSubscripts(value, nonTallSubscriptsCell)
if ~iscolumn(value) && numel(nonTallSubscriptsCell) < 1
    error(message('MATLAB:bigdata:array:IndexingArrayWithTooFewSubscripts', ...
                  ndims(value), 1 + numel(nonTallSubscriptsCell)));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Applied to a partitioned array after filtering in the tall dimension to
% handle extra subscripts.
function outPa = iHandleExtraSubscripts(inPa, subs)
subs = cellfun(@matlab.bigdata.internal.broadcast, subs, 'UniformOutput', false);
outPa = chunkfun(@iSliceSubsref, inPa, subs{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Applied per chunk to handle extra subscripts.
function out = iSliceSubsref(in, varargin)
iErrorCheckNumSubscripts(in, varargin);
remainingSubscripts = iResolveEndMarkersForChunk(varargin, 2, in);
out = subsref(in, substruct('()', [{':'}, remainingSubscripts]));
end
