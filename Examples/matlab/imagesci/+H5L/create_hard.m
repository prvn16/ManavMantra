function create_hard(varargin)
%H5L.create_hard  Create hard link.
%   H5L.create_hard(obj_loc_id,obj_name,link_loc_id,link_name,lcpl_id,lapl_id)
%   creates a new hard link to a pre-existing object in an HDF5 file. The
%   new link may be one of many that point to that object. obj_loc_id and
%   obj_name specify the location and name, respectively, of the target
%   object, i.e., the object to which the new hard link points.
%
%   link_loc_id and link_name specify the location and name, respectively,
%   of the new link. link_name is interpreted relative to link_loc_id.
%
%   lcpl_id and lapl_id are the link creation and access property lists
%   associated with the new link.
%
%   Example:
%       fid = H5F.create('myfile.h5');
%       gid1 = H5G.create(fid,'/g1',0);
%       gid2 = H5G.create(gid1,'g2',0);
%       gid3 = H5G.create(gid2,'g3',0);
%       lcpl = 'H5P_DEFAULT';
%       lapl = 'H5P_DEFAULT';
%       H5L.create_hard(gid2,'g3',gid1,'g4',lcpl,lapl);
%       H5G.close(gid3);
%       H5G.close(gid2);
%       H5G.close(gid1);
%       H5F.close(fid);
%
%   See also H5L, H5L.create_soft.

%   Copyright 2009-2013 The MathWorks, Inc.


H5ML.hdf5lib2('H5Lcreate_hard', varargin{:});            
