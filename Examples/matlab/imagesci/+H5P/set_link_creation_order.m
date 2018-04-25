function set_link_creation_order(gcpl_id,crt_order_flags)
%H5P.set_link_creation_order  Set creation order tracking and indexing.
%   H5P.set_link_creation_order(gcplId,crt_order_flags) sets creation 
%   order tracking and indexing for links in the group with group 
%   creation property list gcpl_id.
%
%   The creation order flags should be one of the following constant values:
%       H5P_CRT_ORDER_TRACKED
%       H5P_CRT_ORDER_INDEXED
%
%   If only H5P_CRT_ORDER_TRACKED is set, HDF5 will track link creation 
%   order in any group created with the group creation property list 
%   gcpl_id. If both H5P_CRT_ORDER_TRACKED and H5P_CRT_ORDER_INDEXED are 
%   set, HDF5 will track link creation order in the group and index 
%   links on that property.  
%
%   Example:
%       tracked = H5ML.get_constant_value('H5P_CRT_ORDER_TRACKED');
%       indexed = H5ML.get_constant_value('H5P_CRT_ORDER_INDEXED');
%       order = bitor(tracked,indexed);
%       gcpl = H5P.create('H5P_GROUP_CREATE');
%       H5P.set_link_creation_order(gcpl,order);
% 
%   See also H5P, H5P.get_link_creation_order, H5ML.get_constant_value.

%   Copyright 2009-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_link_creation_order', gcpl_id,crt_order_flags);            

