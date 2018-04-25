% Copyright 2016 The MathWorks, Inc.

function out = resizeAlongDimUsingNearestNeighbor(in, dim, indices)
% Resize using a multidimensional indexing operation.  Preserve the
% array along all dimensions other than dim.  Along dim, use the
% indices input vector as a subscript vector.

num_dims = max(ndims(in), dim);
subscripts = {':'};
subscripts = subscripts(1, ones(1, num_dims));
subscripts{dim} = indices;
out = in(subscripts{:});
end