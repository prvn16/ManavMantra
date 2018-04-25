function nprops = get_nprops(id)
%H5P.get_nprops  Query number of properties in property list or class.
%   nprops = H5P.get_nprops(id) returns the number of properties in the 
%   property list or class specified by id.
%
%   Example:
%       fid = H5F.open('example.h5');
%       fcpl = H5F.get_create_plist(fid);
%       nprops = H5P.get_nprops(fcpl);
%
%   See also H5P.

%   Copyright 2006-2013 The MathWorks, Inc.

nprops = H5ML.hdf5lib2('H5Pget_nprops', id);            
