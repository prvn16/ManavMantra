function crt_order_flags = get_link_creation_order(gcpl_id)
%H5P.get_link_creation_order  Query if link creation order is tracked.
%   crt_order_flags = H5P.get_link_creation_order(gcpl_id) queries whether
%   link creation order is tracked or indexed in a group with creation
%   property list identifier gcpl_id.  The creation order flags should be 
%   one of the following constant values:
%
%          H5P_CRT_ORDER_TRACKED
%          H5P_CRT_ORDER_INDEXED
%
%   Example:
%       tracked = H5ML.get_constant_value('H5P_CRT_ORDER_TRACKED');
%       indexed = H5ML.get_constant_value('H5P_CRT_ORDER_INDEXED');
%       gcpl = H5P.create('H5P_GROUP_CREATE');
%       order = H5P.get_link_creation_order(gcpl);
%       if bitand(order,tracked)
%           fprintf('order is tracked\n');
%       end
%       if bitand(order,indexed)
%           fprintf('order is indexed\n');
%       end
%           
%   See also H5P, H5P.set_link_creation_order, H5ML.get_constant_value,
%   bitand.

%   Copyright 2009-2014 The MathWorks, Inc.

crt_order_flags = H5ML.hdf5lib2('H5Pget_link_creation_order', gcpl_id);            
