function attr = read(attr_id, dtype_id)
%H5A.read  Read attribute.
%   attr = H5A.read(attr_id) reads the attribute specified by attr_id. 
%   MATLAB will determine the appropriate memory datatype.
% 
%   attr = H5A.read(attr_id, mem_type_id) reads the attribute specified by
%   attr_id.  mem_type_id specifies the attribute's memory datatype and
%   should usually be given as 'H5ML_DEFAULT', which specifies that MATLAB
%   will determine the appropriate memory datatype.
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional 
%   arrays, while MATLAB uses FORTRAN-style ordering.  If the HDF5 library
%   reports the attribute size as 3-by-4-by-5, then the corresponding 
%   MATLAB array size is 5-by-4-by-3.  Please consult "Using the MATLAB 
%   Low-Level HDF5 Functions" in the MATLAB documentation for more
%   information.
%
%   Example:
%       fid = H5F.open('example.h5');
%       gid = H5G.open(fid,'/');
%       attr_id = H5A.open(gid,'attr1');
%       data = H5A.read(attr_id);
%       H5A.close(attr_id);
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5A, H5A.open, H5A.write.

%   Copyright 2006-2013 The MathWorks, Inc.

if nargin == 1
    dtype_id = 'H5ML_DEFAULT';
end

attr = H5ML.hdf5lib2('H5Aread', attr_id, dtype_id);            
