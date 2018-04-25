function num_scales = get_num_scales(dataset_id,idx)
%H5DS.get_num_scales  Retrieve number of scales attached to dataset dimension.
%   num_scales = H5DS.get_num_scales(dataset_id,idx) determines the number
%   of dimension scales that are attached to dimension idx of the dataset
%   dataset_id.
%
%   Example:  
%       fid = H5F.open('example.h5');
%       world_dset_id = H5D.open(fid,'/g4/world');
%       num_scales = H5DS.get_num_scales(world_dset_id,0);
%       H5D.close(world_dset_id);
%       H5F.close(fid);
%
%   See also H5DS.

%   Copyright 2009-2013 The MathWorks, Inc.

num_scales = H5ML.hdf5lib2('H5DSget_num_scales', dataset_id, idx);            
