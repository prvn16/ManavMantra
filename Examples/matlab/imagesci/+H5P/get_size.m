function sz = get_size(id, name)
%H5P.get_size  Query size of property value in bytes.
%   sz = H5P.get_size(id, name) returns the size, in bytes, of the 
%   property specified by the text string name in the property list or 
%   property class specified by id. 
%
%   Example:
%       fid = H5F.open('example.h5');
%       fapl = H5F.get_access_plist(fid);
%       sz = H5P.get_size(fapl,'sieve_buf_size');
%
%   See also H5P.

%   Copyright 2006-2013 The MathWorks, Inc.

sz = H5ML.hdf5lib2('H5Pget_size', id, name);            
