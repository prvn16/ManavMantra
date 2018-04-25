function dspace_id = get_space(attr_id)
%H5A.get_space  Retrieve copy of attribute dataspace.
%   dspace_id = H5A.get_space(attr_id) returns a copy of the dataspace for
%   the attribute specified by attr_id.
%
%   Example:  retrieve the dimensions of an attribute dataspace.
%       fid = H5F.open('example.h5');
%       attr_id = H5A.open(fid,'attr2');
%       space = H5A.get_space(attr_id);
%       [~,dims] = H5S.get_simple_extent_dims(space);
%       H5A.close(attr_id);
%       H5F.close(fid);
%  
%   See also H5A, H5A.open, H5S.close.

%   Copyright 2006-2013 The MathWorks, Inc.

dspace_id = H5ML.hdf5lib2('H5Aget_space', attr_id);            
dspace_id = H5ML.id(dspace_id,'H5Sclose');

