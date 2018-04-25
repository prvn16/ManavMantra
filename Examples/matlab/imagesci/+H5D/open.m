function dataset_id = open(varargin)
%H5D.open  Open specified dataset.
%   dataset_id = H5D.open(loc_id, name) opens the dataset specified by name
%   in the file or group specified by loc_id. 
%
%   dataset_id = H5D.open(loc_id, name, dapl_id) opens the dataset 
%   specified by name in the file or group specified by loc_id. The dataset 
%   access property list, dapl_id, provides information regarding access to 
%   the dataset. 
%
%   Example:
%       fid = H5F.open('example.h5'); 
%       gid = H5G.open(fid,'/g2'); 
%       dset_id = H5D.open(gid,'dset2.2');
%       H5D.close(dset_id);
%       H5F.close(fid);
%						 
%   See also H5D, H5D.close.

%   Copyright 2006-2013 The MathWorks, Inc.

dataset_id = H5ML.hdf5lib2('H5Dopen', varargin{:});            
dataset_id = H5ML.id(dataset_id,'H5Dclose');
