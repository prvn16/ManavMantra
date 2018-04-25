function space_id = create_simple(rank, h5_dims, h5_maxdims)
%H5S.create_simple  Create new simple dataspace.
%   space_id = H5S.create_simple(rank, h5_dims, h5_maxdims) creates a new 
%   simple dataspace and opens it for access. rank is the number of 
%   dimensions used in the dataspace. h5_dims is an array specifying the
%   size of each dimension of the dataset. h5_maxdims is an array
%   specifying the upper limit on the size of each dimension. space_id is a
%   dataspace identifier. 
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional 
%   arrays, while MATLAB uses FORTRAN-style ordering. The h5_dims and
%   h5_maxdims parameters assume C-style ordering. Please consult "Using
%   the MATLAB Low-Level HDF5 Functions" in the MATLAB documentation for
%   more information. 
%
%   Example:  Create a dataspace for a dataset with 10 rows and 5 columns.
%       dims = [10 5];
%       h5_dims = fliplr(dims);
%       h5_maxdims = h5_dims;
%       space_id = H5S.create_simple(2,h5_dims,h5_maxdims);
%
%   Example:  Create a dataspace for a dataset with 10 rows and 5 columns
%   such that the dataset is extendible along the column dimension.
%       dims = [10 5];
%       h5_dims = fliplr(dims);
%       maxdims = [10 H5ML.get_constant_value('H5S_UNLIMITED')];
%       h5_maxdims = fliplr(maxdims);
%       space_id = H5S.create_simple(2,h5_dims,h5_maxdims);
%
%   See also H5S, H5S.create, H5S.close, H5ML.get_constant_value.

%   Copyright 2006-2017 The MathWorks, Inc.

% Handle case of maxdims = {'H5S_UNLIMITED', 'H5S_UNLIMITED'} by turning
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
space_id = H5ML.hdf5lib2('H5Screate_simple', rank, h5_dims, h5_maxdims);            
space_id = H5ML.id(space_id,'H5Sclose');
