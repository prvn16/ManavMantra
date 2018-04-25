function comment = get_comment(loc_id,name)
%H5G.get_comment  Return comment for specified object.
% 
%   H5G.get_comment is not recommended.  Use H5O.get_comment instead.  
%
%   comment = H5G.get_comment(loc_id, name) returns the comment for the
%   object specified by loc_id and name. loc_id is a file, group, or named 
%   datatype. name is the object in loc_id whose comment is to be 
%   retrieved. 
%
%   The HDF5 group has deprecated the use of this function.
%
%   See also H5G, H5O.get_comment.

%   Copyright 2006-2013 The MathWorks, Inc.

comment = H5ML.hdf5lib2('H5Gget_comment', loc_id,name);
