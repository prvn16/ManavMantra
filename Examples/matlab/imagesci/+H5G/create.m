function group_id = create(varargin)
%H5G.create  Create group.
%   group_id = H5G.create(loc_id,name,size_hint) creates a new group with 
%   the name specified by name at the location specified by loc_id. loc_id 
%   can be a file or group identifier. size_hint specifies the number of
%   bytes to reserve for the names that will appear in the group.  This
%   interface corresponds to the 1.6 version of H5Gcreate.
%
%   group_id = H5G.create(loc_id,name,lcpl_id,gcpl_id,gapl_id) creates 
%   a new group with link creation, group creation, and group access 
%   property lists lcpl_id, gcpl_id, and gapl_id.  This interface 
%   corresponds to the 1.8 version of H5Gcreate.
%
%   Example:  Create an HDF5 file 'myfile.h5' with a group 'my_group' with 
%   default property list settings.
%       fid = H5F.create('myfile.h5');
%       plist = 'H5P_DEFAULT';
%       gid = H5G.create(fid,'my_group',plist,plist,plist);
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5G, H5G.open, H5G.close.

%   Copyright 2006-2013 The MathWorks, Inc.


group_id = H5ML.hdf5lib2('H5Gcreate', varargin{:});            
group_id = H5ML.id(group_id,'H5Gclose');
