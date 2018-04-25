function crt_order_flags = get_attr_creation_order(ocpl_id)
%H5P.get_attr_creation_order  Return tracking order and indexing settings.
%   crt_order_flags = H5P.get_attr_creation_order(ocpl_id) retrieves tracking
%   and indexing settings for attribute creation order.  If crt_order_flags
%   is zero, then the attribute creation order is neither tracked or 
%   indexed.  Otherwise the creation order flags should be one of the 
%   following constant values:
%
%       H5P_CRT_ORDER_TRACKED
%       H5P_CRT_ORDER_INDEXED
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/integer');
%       dcpl = H5D.get_create_plist(dset_id);
%       flags = H5P.get_attr_creation_order(dcpl);
%       switch ( flags )
%           case 0
%               fprintf('neither tracked nor indexed\n');
%           case H5ML.get_constant_value('H5P_CRT_ORDER_TRACKED')
%               fprintf('tracked\n');
%           case H5ML.get_constant_value('H5P_CRT_ORDER_INDEXED')
%               fprintf('indexed\n');
%       end
%       H5P.close(dcpl);
%       H5D.close(dset_id);
%       H5F.close(fid);
%  
%   See also H5P, H5P.set_attr_creation_order, H5ML.get_constant_value.

%   Copyright 2009-2014 The MathWorks, Inc.

crt_order_flags = H5ML.hdf5lib2('H5Pget_attr_creation_order', ocpl_id);            

