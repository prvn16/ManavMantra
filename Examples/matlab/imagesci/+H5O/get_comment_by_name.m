function comment = get_comment_by_name(loc_id,name,lapl_id)
%H5O.get_comment_by_name  Retrieve comment for specified object.
%   comment = H5O.get_comment_by_name(loc_id,name,lapl_id) retrieves a
%   comment where a location id and name together specify the object. A
%   link access property list may affect the outcome if a link is traversed
%   to access the object.
%
%   Example:
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       comment = H5O.get_comment_by_name(fid,'g4/world','H5P_DEFAULT');
%       H5F.close(fid);
%
%   See also H5O, H5O.get_comment, H5O.set_comment,
%   H5O.set_comment_by_name.

%   Copyright 2009-2013 The MathWorks, Inc.

comment = H5ML.hdf5lib2('H5Oget_comment_by_name', loc_id,name,lapl_id);            
