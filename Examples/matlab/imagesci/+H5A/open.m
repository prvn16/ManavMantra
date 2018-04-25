function attr_id = open(obj_id,attr_name,acpl_id)
%H5A.open  Open attribute. 
%   attr_id = H5A.open(obj_id,attr_name) opens an attribute for an object specified 
%   by a parent object identifier and attribute name.  
% 
%   attr_id = H5A.open(obj_id,attr_name,aapl_id) opens an attribute with an 
%   attribute access property list identifier, aapl_id.  The only currently valid
%   value for aapl_id is 'H5P_DEFAULT'.
%  
%   Example:  
%       fid = H5F.open('example.h5');
%       gid = H5G.open(fid,'/');
%       attr_id = H5A.open(gid,'attr1');
%       H5A.close(attr_id);
%       H5G.close(gid);
%       H5F.close(fid);
%  
%   See also H5A, H5A.close, H5A.open_by_name, H5A.open_by_idx.

%   Copyright 2009-2013 The MathWorks, Inc.

if nargin ~= 3
    acpl_id = 'H5P_DEFAULT';
end

id = H5ML.hdf5lib2('H5Aopen', obj_id, attr_name, acpl_id);
attr_id = H5ML.id(id, 'H5Aclose');

