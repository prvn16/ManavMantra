function attr_id = open_by_idx(varargin)
%H5A.open_by_idx  Open attribute specified by index.
%   attr_id = H5A.open_by_idx(loc_id,obj_name,idx_type,order,n)
%   opens an existing attribute at index n attached to an object specified
%   by its location loc_id and name obj_name. 
%   
%   idx_type is the type of index and valid values include the following: 
%   
%      'H5_INDEX_NAME'      - an alpha-numeric index by attribute name
%      'H5_INDEX_CRT_ORDER' - an index by creation order
%  
%   order specifies the index traversal order. Valid values include the
%   following: 
%   
%      'H5_ITER_INC'    - iteration is from beginning to end
%      'H5_ITER_DEC'    - iteration is from end to beginning
%      'H5_ITER_NATIVE' - iteration is in the fastest available order
% 
%   attr_id = H5A.open_by_idx(loc_id,obj_name,idx_type,order,n,aapl_id,lapl_id) 
%   opens an attribute with attribute access property list aapl_id and link
%   access property list lapl_id.  aapl_id must currently be specified as
%   'H5P_DEFAULT'.  lapl_id may also be specified by 'H5P_DEFAULT'.
%  
%   Example:  loop through a set of dataset attributes in reverse
%   alphabetical order.
%       fid = H5F.open('example.h5');
%       gid = H5G.open(fid,'/g1/g1.1');
%       dset_id = H5D.open(fid,'/g1/g1.1/dset1.1.1');
%       info = H5O.get_info(dset_id);
%       for idx = 0:info.num_attrs-1
%           attr_id =H5A.open_by_idx(gid,'dset1.1.1','H5_INDEX_NAME','H5_ITER_DEC',idx);
%           fprintf('attribute name:  %s\n', H5A.get_name(attr_id));
%           H5A.close(attr_id);
%       end
%       H5G.close(gid);
%       H5F.close(fid);
%  
%   See also H5A, H5A.open, H5A.open_by_name, H5A.close.

%   Copyright 2009-2013 The MathWorks, Inc.

if nargin == 5
    varargin = [varargin {'H5P_DEFAULT','H5P_DEFAULT'} ];
end
raw_attr_id = H5ML.hdf5lib2('H5Aopen_by_idx', varargin{:});   
attr_id = H5ML.id(raw_attr_id,'H5Aclose');

