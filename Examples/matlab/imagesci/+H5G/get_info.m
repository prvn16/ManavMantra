function info = get_info(group_id)
%H5G.get_info  Return information about group.
%   info = H5G.get_info(group_id) retrieves information about the group 
%   specified by group_id.  
%
%   Example:
%       fid = H5F.open('example.h5');
%       gid = H5G.open(fid,'/g2');
%       info = H5G.get_info(gid);
%       H5G.close(gid);
%       H5F.close(fid);
%     
%   See also H5G, H5G.open, H5G.create.

%   Copyright 2009-2013 The MathWorks, Inc.

info = H5ML.hdf5lib2('H5Gget_info', group_id );

