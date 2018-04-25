function varargout = get_array_dims(type_id)
%H5T.get_array_dims  Return array dimension extents.
%   dimsizes = H5T.get_array_dims(type_id) returns the sizes of
%   the dimensions and the dimension permutations of the specified array 
%   datatype object.  This interface corresponds to the 1.8 version of
%   H5Tget_array_dims.
%
%   [ndims dimsizes perm] = H5T.get_array_dims(type_id) corresponds to
%   the 1.6 version of the interface.  It is strongly deprecated.
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional 
%   arrays, while MATLAB uses FORTRAN-style ordering.  Please consult 
%   "Using the MATLAB Low-Level HDF5 Functions" in the MATLAB documentation 
%   for more information.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/array2D');
%       type_id = H5D.get_type(dset_id);
%       h5_dims = H5T.get_array_dims(type_id);
%       dims = fliplr(h5_dims);
%
%   See also H5T, H5T.array_create, H5T.get_array_ndims.

%   Copyright 2006-2013 The MathWorks, Inc.

dims = H5ML.hdf5lib2('H5Tget_array_dims',type_id);            

varargout = cell(1,nargout);
switch nargout
case 1
	varargout{1} = dims;
case 2
	% 1.6.x version
	varargout{1} = numel(dims);
	varargout{2} = dims;
case 3
	% 1.6.x version
	varargout{1} = numel(dims);
	varargout{2} = dims;
	varargout{3} = [];  % never implemented
end
