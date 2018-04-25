function output = get_nmembers(type_id)
%H5T.get_nmembers  Return number of elements in enumeration type.
%   output = H5T.get_nmembers(type_id) retrieves the number of fields in a 
%   compound datatype or the number of members of an enumeration datatype.
%   type_id is a datatype identifier.
%
%   Example:  Determine the number of fields in a compound dataset.
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/compound');
%       dtype_id = H5D.get_type(dset_id);
%       nmembers = H5T.get_nmembers(dtype_id);
%
%   See also H5T.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tget_nmembers',type_id); 
