function smallSizes = getSubsrefParenSmallSizes(smallSubscripts, smallSizes)
%getSubsrefParenSmallSizes Get the small sizes as if a tall array has been
%indexed by the given small subscripts.
%
% This can also accept and propagate the known small sizes of a tall array
% forward.

% Copyright 2017 The MathWorks, Inc.

% If no small subscripts, we only indexed into the tall dimension, which
% means the array must be a column vector.
if isempty(smallSubscripts)
    smallSizes = 1;
    return;
end

if nargin < 2
    smallSizes = nan(1, numel(smallSubscripts));
end

for idx = 1:numel(smallSubscripts)
    sub = smallSubscripts{idx};
    
    if isEquivalentToLiteralColon(sub)
        % Propagate through the existing value.
    elseif isnumeric(sub) || isColonDescriptor(sub)
        smallSizes(idx) = prod(size(sub)); %#ok<PSIZE> as ColonDescriptor does not expose numel.
    elseif islogical(sub)
        smallSizes(idx) = sum(sub);
    elseif isEndMarker(sub)
        if isnan(smallSizes(idx))
            smallSizes(idx) = computeResultingSize(sub);
        else
            smallSizes(idx) = numel(resolve(sub, [smallSizes(idx), 1], 1));
        end
    elseif isobject(sub)
        sub = subsindex(sub) + 1;
        smallSizes(idx) = numel(sub);
    else
        smallSizes(idx) = nan;
    end
end
