function attr_id = open_by_name(varargin)
%H5A.open_by_name  Open attribute specified by name.
%   attr_id = H5A.open_by_name(loc_id,obj_name,attr_name) opens an existing
%   attribute attr_name attached to an object specified by its location
%   loc_id and name obj_name.
%  
%   attr_id = H5A.open_by_name(loc_id,obj_name,attr_name,aapl_id,lapl_id)
%   opens an existing attribute with the attribute access property list
%   aapl_id and link access property list lacpl_id.   aapl_id must be
%   specified as 'H5P_DEFAULT'.  lapl_id may also be specified by
%   'H5P_DEFAULT'.
% 
%   Example:
%       fid = H5F.open('example.h5');
%       gid = H5G.open(fid,'/g1/g1.1');
%       attr_id = H5A.open_by_name(gid,'dset1.1.1','attr1');
%       H5A.close(attr_id);
%       H5G.close(gid);
%       H5F.close(fid);
%  
%     See also H5A, H5A.close, H5A.open, H5A.open_by_idx.

%   Copyright 2009-2013 The MathWorks, Inc.

if nargin == 3
    varargin = [varargin {'H5P_DEFAULT','H5P_DEFAULT'}];
end

raw_attr_id = H5ML.hdf5lib2('H5Aopen_by_name', varargin{:});        
attr_id = H5ML.id(raw_attr_id,'H5Aclose');

