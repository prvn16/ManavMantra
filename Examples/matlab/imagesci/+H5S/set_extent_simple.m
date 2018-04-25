function set_extent_simple(space_id, rank, h5_dims, h5_maxdims)
%H5S.set_extent_simple  Set size of dataspace.
%   H5S.set_extent_simple(space_id, rank, h5_dims, h5_maxdims) sets the
%   size of the dataspace identified by space_id. rank is the number of
%   dimensions used in the dataspace. h5_dims is an array specifying the
%   size of each dimension of the dataset. h5_maxdims is an array
%   specifying the upper limit on the size of each dimension.
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional 
%   arrays, while MATLAB uses FORTRAN-style ordering. The h5_dims and
%   h5_maxdims parameters assume C-style ordering. Please consult "Using
%   the MATLAB Low-Level HDF5 Functions" in the MATLAB documentation for
%   more information. 
%
%   Example:
%       space_id = H5S.create('H5S_SIMPLE');
%       dims = [100 200];
%       h5_dims = fliplr(dims);
%       maxdims = [100 H5ML.get_constant_value('H5S_UNLIMITED')];
%       h5_maxdims = fliplr(maxdims);
%       H5S.set_extent_simple(space_id,2,h5_dims, h5_maxdims);
% 
%   See also H5S, H5S.create, H5S.get_simple_extent_dims, 
%   H5ML.get_constant_value.

%   Copyright 2006-2013 The MathWorks, Inc.

% Handle case of h5_maxdims = {'H5S_UNLIMITED', 'H5S_UNLIMITED'} by turning
% it into a numeric array.
if iscell(h5_maxdims) 
	numeric_maxdims = zeros(size(h5_maxdims));
	for j = 1:numel(h5_maxdims)
		if ischar(h5_maxdims{j})
			numeric_maxdims(j) = H5ML.get_constant_value(h5_maxdims{j});	
		else
			numeric_maxdims(j) = h5_maxdims{j};
		end
	end
	h5_maxdims = numeric_maxdims;
end
H5ML.hdf5lib2('H5Sset_extent_simple', space_id, rank, h5_dims, h5_maxdims);            
