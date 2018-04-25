function set_comment(obj_id,comment)
%H5O.set_comment  Set comment for object.
%   H5O.set_comment(obj_id,comment) sets a comment for the object specified
%   by obj_id.
%
%   Example:
%       plist = 'H5P_DEFAULT';
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',plist,plist);
%       gid = H5G.create(fid,'/g1',plist);
%       H5O.set_comment(gid,'This is a group comment.');
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5O, H5O.get_comment, H5O.get_comment_by_name,
%   H5O.set_comment_by_name.
       
%   Copyright 2009-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Oset_comment',obj_id,comment);
