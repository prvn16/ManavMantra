function group_id = open(varargin)
%H5G.open  Open specified group.
%   group_id = H5G.open(loc_id, name) opens the group specified by name at
%   the location specified location, loc_id. loc_id is a file or group
%   identifier. This interface corresponds to the 1.6 version of H5Gopen.
%
%   group_id = H5G.open(loc_id,name,gapl_id) opens the group with an
%   additional group access property list, gapl_id.  This interface
%   corresponds to the 1.8 version of H5Gopen.
%
%   Example:
%       fid = H5F.open('example.h5');
%       gid = H5G.open(fid,'/g2');
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5G, H5G.close, H5P.create.

%   Copyright 2006-2013 The MathWorks, Inc.

group_id = H5ML.hdf5lib2('H5Gopen', varargin{:});            
group_id = H5ML.id(group_id,'H5Gclose');
