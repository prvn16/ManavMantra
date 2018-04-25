function outSz = computeCatSize(dim, szsCell)
%computeCatSize Compute the resulting size for CAT(DIM,...)
%    OUTSZ = computeCatSize(DIM, SZSCELL) computes the size of the result of a
%    CAT(DIM,...) operation. SZSCELL is a cell array of sizes. Each size can
%    contain NaN entries for dimensions with unknown sizes - these will be
%    treated as matching other sizes.
%
%    Array sizes that *might* correspond to [] arrays must not be passed into
%    this function, as they cannot be handled correctly since the result depends
%    on whether the unknown dimensions turn out to be zero or not. 

% Copyright 2016 The MathWorks, Inc.

assert(~any(cellfun(@iArrayMightBeSquareEmpty, szsCell)));

if iAllInputArrays2DEmpty(szsCell)
    outSz = iShortCircuitFor2DEmpty(dim, szsCell);
    return
end

% Get the reference size that we will use to compare against.
pdimref = iFindReferenceDim(szsCell);
% Pad trailing dims with 1
if dim>numel(pdimref)
    pdimref(end+1:dim) = 1;
end
% Now accumulate in the concatenation dimension
ndimref = numel(pdimref);
pdimref(dim) = 0;

for idx = 1:numel(szsCell)
    ignoreEmpty = false;
    pdim = szsCell{idx};
    ndim = iNdims(pdim);
    for jdx = 1:ndimref
        % Skip ahead for: CAT dimension; NaN in reference dimension; or NaN in comparing
        % dimension.
        if jdx == dim || isnan(pdimref(jdx)) || ...
                (jdx <= ndim && isnan(pdim(jdx)))
            continue;
        end
        dimsDontMatch = ...
            ((jdx <= ndim && pdim(jdx) ~= pdimref(jdx)) || ...
             (jdx > ndim && pdimref(jdx) ~= 1));
        if dimsDontMatch
            [problem, ignoreEmpty] = iArrayDimensionMismatchCat(pdim);
            if problem
                % Note we always throw an error with text corresponding to
                % 'matrixDimensionMismatch', as this is the message used for all
                % cases throwing an error at this level. (Other messages are
                % used when combining structs and cells).
                error('MATLAB:catenate:dimensionMismatch', '%s', ...
                      getString(message('MATLAB:catenate:matrixDimensionMismatch')));
            end
        end
    end
    if ~ignoreEmpty
        if dim <= ndim
            pdimref(dim) = pdimref(dim) + pdim(dim);
        else
            pdimref(dim) = pdimref(dim) + 1;
        end
    end
end

% Trim trailing ones in 3rd or later positions.
outSz = pdimref(1:iNdims(pdimref));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract NDIMS from a size vector, taking care of vectors like [1,2,1]
function n = iNdims(sz)
% Need the last non-unity value
n = find(sz ~= 1, 1, 'last');
if isempty(n) || n < 2
    n = 2;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% True if and only if szVec represents [].
function tf = iIs2DEmpty(szVec)
tf = isequal(szVec, [0, 0]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the reference size for concatenation. Start by finding the element of
% szsCell with the highest NDIMS value (disregarding 2D empties), and also
% attempting to fill in any NaN values if present.
function pdimref = iFindReferenceDim(szsCell)
% The implementation here combines elements of the C++ version's
% FindLargestArrayDimensions and FindLargestArray.
is2DEmpty = cellfun(@iIs2DEmpty, szsCell);
% Note that prior checks should ensure that there are some non-2d-empties
szsCell(is2DEmpty) = [];
ndimsPerArray = cellfun(@numel, szsCell);
[~, idx] = max(ndimsPerArray);
pdimref = szsCell{idx};
if any(isnan(pdimref))
    % Attempt to fill NaN values from remaining sizes.
    for idx = 1:numel(szsCell)
        thisDim = szsCell{idx};
        thisDim = [thisDim, ones(1, numel(pdimref) - numel(thisDim))]; %#ok<AGROW> incorrect analysis
        % Supply missing dimension values if this dimension vector has any.
        dimsToSupply = isnan(pdimref) & ~isnan(thisDim);
        if any(dimsToSupply)
            pdimref(dimsToSupply) = thisDim(dimsToSupply);
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = iAllInputArrays2DEmpty(szsCell)
tf = all(cellfun(@iIs2DEmpty, szsCell));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the resulting size of concatenating a series of [].
function sz = iShortCircuitFor2DEmpty(dim, szsCell)
ndimsOut = max(dim, 2);
sz = [zeros(1, 2), ones(1, ndimsOut - 2)];
if dim <= 2
    sz(dim) = 0;
else
    sz(dim) = numel(szsCell);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For CAT, [] arrays are ignored if they mismatch, but considered if they do
% not.
function [problem, ignoreEmpty] = iArrayDimensionMismatchCat(pdim)
problem = false;
ignoreEmpty = false;
if ~iIs2DEmpty(pdim)
    problem = true;
else
    ignoreEmpty = true;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return TRUE if the size vector *might* correspond to a [] empty array, but it
% is not *guaranteed* to correspond to []. I.e. one of: [NaN, 0], [0, NaN],
% [NaN, NaN]. [0, 0] is fine.
function tf = iArrayMightBeSquareEmpty(szVec)
tf = numel(szVec) == 2 && any(isnan(szVec)) && ...
     all(arrayfun(@(d) d == 0 || isnan(d), szVec));
end
