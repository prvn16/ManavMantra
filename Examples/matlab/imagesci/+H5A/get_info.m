function info = get_info(attr_id)
%H5A.get_info  Retrieve information about attribute.
%   info = H5A.get_info(attr_id) returns information about an attribute
%   specified by attr_id.  
%
%   Example:  
%       fid = H5F.open('example.h5');
%       gid = H5G.open(fid,'/');
%       attr_id = H5A.open(gid,'attr1');
%       info = H5A.get_info(attr_id);
%       H5A.close(attr_id);
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5A, H5A.open.

%   Copyright 2009-2013 The MathWorks, Inc.

info = H5ML.hdf5lib2('H5Aget_info', attr_id);            

