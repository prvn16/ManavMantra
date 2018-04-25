% Copyright 2016 The MathWorks, Inc.

function out = resizeAllDimUsingNearestNeighbor(in, indices)
% Resize row and column dimensions simultaneously using a single
% multidimensional indexing operation.

subscripts = indices;
subscripts(length(indices) + 1:ndims(in)) = {':'};
out = in(subscripts{:});
end