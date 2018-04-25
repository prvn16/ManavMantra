function obj_id = open_by_idx(loc_id,group_name, idx_type, order, n, lapl_id)
%H5O.open_by_idx  Open object specified by index.
%   obj_id = H5O.open_by_idx(loc_id,group_name, idx_type, order, n, lapl_id) 
%   opens the n-th object in the group specified by loc_id and group_name. 
%   loc_id specifies a file or group, group_name specifies the group
%   relative to loc_id in which the object can be found.
%
%   Two parameters are used to establish the iteration: index_type
%   and order.  index_type specifies the type of index by which objects 
%   are ordered. Valid values include the following:
%
%      'H5_INDEX_NAME'       Alpha-numeric index on name 
%      'H5_INDEX_CRT_ORDER'  Index on creation order   
%
%   order specifies the order in which the links are to be referenced 
%   for the purposes of this function. Valid values include the following:
%
%      'H5_ITER_INC'     Increasing order 
%      'H5_ITER_DEC'     Decreasing order 
%      'H5_ITER_NATIVE'  Fastest available order  
%
%   n specifies the zero-based position of the object within the index. 
%   lapl_id specifies the link access property list to be used in accessing 
%   the object. 
%
%   Example:
%       fid = H5F.open('example.h5');
%       idx_type = 'H5_INDEX_NAME';
%       order = 'H5_ITER_DEC';
%       obj_id = H5O.open_by_idx(fid,'g3',idx_type,order,0,'H5P_DEFAULT');
%       H5O.close(obj_id);
%       H5F.close(fid);
%
%   See also H5O, H5O.open, H5O.close.
   
%   Copyright 2009-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Oopen_by_idx',loc_id,group_name,idx_type,order,n,lapl_id);
obj_id = H5ML.id(output,'H5Oclose');
