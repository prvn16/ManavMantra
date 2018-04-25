function link(varargin)
%H5O.link  Create hard link to specified object.
%   H5O.link(obj_id,new_loc_id,new_link_name,lcpl_id,lapl_id) creates
%   a hard link to an object, where new_loc_id and new_name specify the
%   location. lcpl_id and lapl_id are the link creation and access property
%   lists associated with the new link.
%
%   H5O.link is designed to add additional structure to an existing file 
%   so that, for example, an object can be shared among multiple
%   groups.
%
%   Example:  Create a hard link from group '/g2' to the dataset '/g1/ds1'.
%       plist_id = 'H5P_DEFAULT';
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',plist_id,plist_id);
%       gid1 = H5G.create(fid,'/g1',plist_id);
%       space_id = H5S.create_simple(1,10,[]);
%       ds1 = H5D.create(gid1,'ds1','H5T_NATIVE_INT',space_id,plist_id);
%       gid2 = H5G.create(fid,'/g2',plist_id);
%       H5O.link(ds1,gid2,'ds2',plist_id,plist_id);
%       H5D.close(ds1);
%       H5S.close(space_id);
%       H5G.close(gid2); H5G.close(gid1);
%       H5F.close(fid);
%
%   See also H5O, H5L.create_hard, H5L.create_soft.
   
%   Copyright 2009-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Olink', varargin{:});            
