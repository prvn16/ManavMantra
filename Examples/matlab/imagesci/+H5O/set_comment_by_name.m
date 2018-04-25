function set_comment_by_name(loc_id,rel_name,comment,lapl_id)
%H5O.set_comment_by_name  Set comment for object.
%   H5O.set_comment_by_name(loc_id,rel_name,comment,lapl_id) sets a comment 
%   for an object specified by a location ID and a relative name.  lapl_id 
%   is a link access property list identifier that may affect the outcome
%   if links are traversed.
%
%   Example:
%       plist = 'H5P_DEFAULT';
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',plist,plist);
%       gid = H5G.create(fid,'/g1',plist);
%       H5O.set_comment_by_name(fid,'g1','This is a group comment.',plist);
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5O, H5O.get_comment, H5O.get_comment_by_name,
%   H5O.set_comment.
       
%   Copyright 2009-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Oset_comment_by_name',loc_id,rel_name,comment,lapl_id);
