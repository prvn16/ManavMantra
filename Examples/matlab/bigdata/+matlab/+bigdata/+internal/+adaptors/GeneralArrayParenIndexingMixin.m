%GeneralArrayParenIndexingMixin mixin for standard array-based indexing

% Copyright 2016-2017 The MathWorks, Inc.

classdef GeneralArrayParenIndexingMixin
    methods
        function out = subsrefParens(obj, pa, szPa, S)
            [outPa, isTallSizeUnchanged, newTallSize, outSmallSizes] = ...
                subsrefParensImpl(pa, szPa, S);
            newAdaptor = resetSizeInformation(obj);
            if isTallSizeUnchanged
                newAdaptor = copyTallSize(resetSizeInformation(obj), obj);
            elseif ~isnan(newTallSize)
                % Update tall size in-place
                setTallSize(newAdaptor, newTallSize);
            end
            
            % We can work out the small sizes ourselves in the case where there's a single
            % subscript, and we can guarantee that we're a column vector.
            isGuaranteedColumnVector = obj.NDims == 2 && obj.getSizeInDim(2) == 1;
            inTallSize = obj.getSizeInDim(1);
            isGuaranteedNotScalar = isGuaranteedColumnVector && ~isnan(inTallSize) && inTallSize ~= 1;
            if numel(S(1).subs) == 1 && isGuaranteedColumnVector && isGuaranteedNotScalar
                newAdaptor = resetSmallSizes(newAdaptor, 1);
            else
                % We can use the small sizes computed by subsrefParensImpl
                if ~isempty(outSmallSizes)
                    newAdaptor = resetSmallSizes(newAdaptor, outSmallSizes);
                end
            end
            out   = tall(outPa, newAdaptor);
        end
        
        function out = subsasgnParens(obj, pa, ~, S, b)
        %subsasgnParens Implementation of subsasgn for () case (non-deleting)
        %   outPa = subsasgnParens(inPa, szPa, S, b)
        %   outPa and inPa are PartitionedArrays, S is the substruct, b is the right-hand side.

            if numel(S) ~= 1
                % a(1,2).foo = 3 or similar.
                error(message('MATLAB:bigdata:array:SubsasgnParensSingleLevel'));
            end

            subs = S.subs;

            isColonSubscript = cellfun(@matlab.bigdata.internal.util.isColonSubscript, subs);
            if ~isColonSubscript(1) && ~istall(subs{1})
                error(message('MATLAB:bigdata:array:SubsasgnFirstDimTallOrColon'));
            end
            if istall(subs{1})
                subs{1} = tall.validateType(subs{1}, 'subsasgn', {'logical'}, 1);
            end
            
            if istall(b)
                % We do not support colonized LHS if the RHS is also tall.
                if numel(S.subs) == 1 && obj.isKnownNotColumn()
                    error(message('MATLAB:bigdata:array:SubsasgnSingleSubDims'));
                end
                
                % If we can, check small sizes here.
                contactAdaptor = iGetSubsasgnParenContactAdaptor(obj, subs(2:end));
                bAdaptor = matlab.bigdata.internal.adaptors.getAdaptor(b);
                if isKnownDifferentSmallSize(contactAdaptor, bAdaptor)
                    error(message('MATLAB:subsassigndimmismatch'));
                end
                
                if istall(subs{1})
                    idxAdaptor = matlab.bigdata.internal.adaptors.getAdaptor(subs{1});
                    if idxAdaptor.isKnownNotColumn()
                        error(message('MATLAB:bigdata:array:SubsasgnFirstDimTallOrColon'));
                    end
                    if isKnownDifferentTallSize(obj, idxAdaptor)
                        error(message('MATLAB:subsassigndimmismatch'));
                    end
                    wasPartitionIndependent = isPartitionIndependent(pa,hGetValueImpl(b), hGetValueImpl(subs{1}));
                    pa = generalpartitionfun(...
                        @(info, ca, cb, filter) iApplyTallWithTallIdx(info, ca, cb, filter, subs{2:end}),...
                        pa, hGetValueImpl(b), hGetValueImpl(subs{1}));
                    if wasPartitionIndependent
                        pa = markPartitionIndependent(pa);
                    end
                else
                    % subs{1} must be a colon.
                    if isKnownDifferentTallSize(obj, bAdaptor)
                        error(message('MATLAB:subsassigndimmismatch'));
                    end
                    pa = slicefun(@(ca, cb) iApplyTallWithColon(ca, cb, subs{:}), pa, hGetValueImpl(b));
                end
            elseif isscalar(b)
                if istall(subs{1})
                    pa = slicefun(@(pa, filter) iApplyScalar(pa, b, filter, subs{2:end}), pa, hGetValueImpl(subs{1}));
                else
                    pa = slicefun(@(pa) iApplyScalar(pa, b, subs{:}), pa);
                end
            else
                error(message('MATLAB:bigdata:array:SubsasgnValueMustBeScalarOrTall'));
            end

            obj = iSubsasgnParenUpdateSmallSizes(obj, subs(2:end));
            out = tall(pa, obj);
        end
        
        function out = subsasgnParensDeleting(obj, pa, szPa, S)
        %subsasgnParensDeleting Deleting subsasgn implementation for tall arrays

            isColonSubscript = cellfun(@matlab.bigdata.internal.util.isColonSubscript, S.subs);
            isDefinitelyEmptySubscript = cellfun(@(x) ~istall(x) && isempty(x), S.subs);

            numColons = sum(isColonSubscript);
            numSubs   = numel(S.subs);

            if numColons == numSubs
                % Need to return empty of the right size and class. We must use CHUNKFUN as the
                % result is going to be a different size in the tall dimension.
                pa = chunkfun(@(x) iDeleteAll(x, S.subs{:}), pa);
            elseif numColons ~= numSubs - 1
                % All other cases require only a single non-colon subscript
                error(message('MATLAB:bigdata:array:SubsasgnDeletingTooManyNonColons'));
            elseif any(isDefinitelyEmptySubscript)
                % There's an empty subscript - do nothing
            elseif istall(S.subs{1})
                % Here we defer to subsref to do the work by negating the subscript.
                tallSubscript = S.subs{1};
                ss = substruct('()', {~tallSubscript, S.subs{2:end}});
                pa = subsrefParensImpl(pa, szPa, ss);
            elseif isColonSubscript(1)
                % Finally, we must have a colon in first place ...
                assert(isColonSubscript(1));

                if ~isnan(obj.NDims) && obj.NDims ~= numel(S.subs)
                    error(message('MATLAB:bigdata:array:SubsasgnInvalidNumberOfSubscripts'));
                end

                % ... and we delete the non-tall dimensions.
                pa = slicefun(@(x) iDeleteNonTall(x, S.subs{:}), pa);
            else
                % Unhandled cases. Numeric (non-empty) first subscripts etc.
                error(message('MATLAB:bigdata:array:SubsasgnDeletingInvalidTallSubscript'))
            end
            out   = tall(pa, resetSizeInformation(obj));
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function A = iApplyScalar(A, B, varargin)
% We allow:
% 1. One logical subscript with dimensions matching A
% 2. One logical subscript if A is a vector
% 3. One colon subscript
% 4. Number of subscripts matches ndims A, first subscript must be logical or colon
    if numel(varargin)==1
        if isequal(size(varargin{1}), size(A)) || ...
                matlab.bigdata.internal.util.isColonSubscript(varargin{1})
            % (1) or (3), OK
        else
            % (2), only OK if A is a vector and numel(subs)==numel(A)
            isNDVector = (sum(size(A)~=1) == 1); % Only one non-unity dimension
            
            if ~isNDVector || numel(A) ~= numel(varargin{1})
                error(message('MATLAB:bigdata:array:SubsasgnSingleSubDims'));
            end
        end
    end

    varargin(2:end) = iResolveEndMarkers(size(A), 2, varargin(2:end));
    
    A(varargin{:}) = B;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subsasgn a tall array into a tall array of equal height, with colon as
% first subscript.
%
% This will be called for variants of:
%  tX = tall(rand(10,1));
%  tX(:,2) = -tX(:,1);
function A = iApplyTallWithColon(A, B, varargin)
if numel(varargin) == 1 && ~iscolumn(A)
    error(message('MATLAB:bigdata:array:SubsasgnSingleSubDims'));
end
varargin(2:end) = iResolveEndMarkers(size(A), 2, varargin(2:end));
A(varargin{:}) = B;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subsasgn a tall array into a tall array that has been indexed via a
% logical column vector.
%
% This will be called for variants of:
%  tX = tall(rand(10,1));
%  tX(tX < 0.5) = -tX(tX < 0.5);
function [hasFinished, unusedInputs, A] = iApplyTallWithTallIdx(info, A, B, idx, varargin)
import matlab.bigdata.internal.util.indexSlices;

if numel(varargin) == 0 && ~iscolumn(A)
    error(message('MATLAB:bigdata:array:SubsasgnSingleSubDims'));
end
if ~islogical(idx) || ~iscolumn(idx)
    error(message('MATLAB:bigdata:array:SubsasgnFirstDimTallOrColon'))
end

varargin = iResolveEndMarkers(size(A), 2, varargin);

% First we need to determine which of a, b or idx is going to limit how
% much we can do in this current invocation.
numASlices = min(size(A, 1), size(idx, 1));
numBSlices = size(B, 1);
numIndexedASlices = sum(idx(1 : numASlices), 1);
if numBSlices >= numIndexedASlices
    numBSlices = numIndexedASlices;
else
    % We want to go up-to the last slice of a before we need to assign
    % using a slice of b we don't have.
    indexedAPositions = [find(idx), numel(numASlices) + 1];
    numASlices = indexedAPositions(numBSlices + 1) - 1;
end

% Move the slices we can't use now to the next invocation.
unusedInputs = {...
    indexSlices(A, numASlices + 1 : size(A, 1)), ...
    indexSlices(B, numBSlices + 1 : size(B, 1)), ...
    indexSlices(idx, numASlices + 1 : size(idx, 1)) };
A(numASlices + 1 : end, :) = [];
idx(numASlices + 1 : end, :) = [];
B(numASlices + 1 : end, :) = [];

% Do the subsasgn operation now that its scoped to everything this one
% invocation can do.
A(idx, varargin{:}) = B;

% Guard against one input finishing earlier than other inputs.
%
% This is necessary because the generalpartitionfun primitive does not
% perform alignment of inputs.
%
% This enforces the two restrictions:
%  1. This partition of tA and tIdx must be the same height.
%  2. This partition of tB must be the same height as sum of idx for this
%     partition.
if any(info.IsLastChunk)
    aIsFinished = info.IsLastChunk(1);
    aHasUnused = ~isempty(unusedInputs{1});
    idxIsFinished = info.IsLastChunk(3);
    idxHasUnused = ~isempty(unusedInputs{3});
    isAIdxMismatch = (aIsFinished && idxHasUnused) || (idxIsFinished && aHasUnused);
    
    bIsFinished = info.IsLastChunk(2);
    bHasUnused = ~isempty(unusedInputs{2});
    aIdxIsFinished = aIsFinished && idxIsFinished;
    aIdxHasUnused = aHasUnused || idxHasUnused;
    isABMismatch = (aIdxIsFinished && bHasUnused) || (bIsFinished && aIdxHasUnused);
    
    if isAIdxMismatch || isABMismatch
        error(message('MATLAB:bigdata:array:IncompatibleTallIndexing'));
    end
end

hasFinished = all(info.IsLastChunk);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subscripts = iResolveEndMarkers(szA, firstSubIndex, subscripts)
% Resolve end markers for this chunk. Here we rely on the fact that the number
% of subscripts must match the dimensionality of A.
    for idx = 1:numel(subscripts)
        if isa(subscripts{idx}, 'matlab.bigdata.internal.util.EndMarker')
            subscripts{idx} = subscripts{idx}.resolve(szA, idx + firstSubIndex - 1);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Used for the case where the subscripts are known up front.
function x = iDeleteAll(x, varargin)
    x(varargin{:}) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Used for the case where we're deleting only in the non-tall dimension.
function x = iDeleteNonTall(x, varargin)
    if numel(varargin) ~= ndims(x)
        % Get here for tx = tall(rand(3,3,3));
        % tx(:,1) = []
        error(message('MATLAB:bigdata:array:SubsasgnInvalidNumberOfSubscripts'));
    end
    varargin(2:end) = iResolveEndMarkers(size(x), 2, varargin(2:end));
    x(varargin{:}) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get an adaptor for the array that would be generated if the LHS of a
% subsasgn operation was instead subsref. This is used to guard against
% invalid small sizes for a tall RHS in a subsasgn operation.
function obj = iGetSubsasgnParenContactAdaptor(obj, smallSubscripts)
if isempty(smallSubscripts)
    obj = resetSmallSizes(obj, 1);
    return;
end
smallSizes = getReshapedSmallSizes(obj, numel(smallSubscripts));
smallSizes = getSubsrefParenSmallSizes(smallSubscripts, smallSizes);
obj = resetSmallSizes(obj, smallSizes);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update the small sizes of an adaptor to account for any growth as a
% result of subsasgn outside the size of the array.
function obj = iSubsasgnParenUpdateSmallSizes(obj, smallSubscripts)

% If no small subscripts, we only indexed into the tall dimension, which
% isn't allowed to grow.
if isempty(smallSubscripts)
    return;
end
% We need the size/shape of input to determine anything about the output.
if isnan(obj.NDims)
    return;
end

smallSizes = obj.SmallSizes;
if numel(smallSubscripts) < numel(smallSizes)
    % Last dimension cannot be grown if number of subscripts is less than
    % number of dimensions of LHS.
    maxLastDim = prod(smallSizes(numel(smallSubscripts) + 1 : end));
else
    smallSizes(1, end + 1 : numel(smallSubscripts)) = 1;
    maxLastDim = inf;
end

for idx = 1:numel(smallSubscripts)
    sub = smallSubscripts{idx};
    
    if isEquivalentToLiteralColon(sub)
        % Propagate through the existing value.
    elseif isnumeric(sub)
        if ~isempty(sub)
            smallSizes(idx) = max(max(sub(:)), smallSizes(idx));
        end
    elseif islogical(sub)
        lastTrue = find(sub(:), 1, 'last');
        if ~isempty(lastTrue)
            smallSizes(idx) = max(lastTrue, smallSizes(idx));
        end
    elseif isColonDescriptor(sub)
        smallSizes(idx) = max(sub.Stop, smallSizes(idx));
    elseif isEndMarker(sub)
        if ~isnan(smallSizes(idx))
            smallSizes(idx) = max(max(resolve(sub, [smallSizes(idx), 1], 1)), smallSizes(idx));
        end
    elseif isobject(sub)
        sub = subsindex(sub) + 1;
        smallSizes(idx) = max(sub(:));
    else
        smallSizes(idx) = nan;
    end
end

% Last dimension cannot be grown if number of subscripts is less than
% number of dimensions of LHS.
if smallSizes(numel(smallSubscripts)) > maxLastDim
    error(message('MATLAB:indexed_matrix_cannot_be_resized'));
end
    
obj = resetSmallSizes(obj, smallSizes);
end
