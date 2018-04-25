function attach_scale(dataset_id,dimscale_id,idx)
%H5DS.attach_scale  Attach dimension scale to specific dataset dimension.
%   H5DS.attach_scale(dataset_id,dimscale_id,idx) attaches a dimension
%   scale dimscale_id to dimension idx of the dataset dataset_id.
% 
%   Note:  The ordering of the dimension scale indices are the same as the
%   HDF5 library C API.  
%
%   Example:  Add the 'lon' and 'lat' dimension scales to the 'world'
%   dataset.
%       plist = 'H5P_DEFAULT';
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.h5');
%       copyfile(srcFile,'myfile.h5');
%       fileattrib('myfile.h5','+w');
%       fid = H5F.open('myfile.h5','H5F_ACC_RDWR',plist);
%       world_dset_id = H5D.open(fid,'/g4/world',plist);
%       lat_dset_id = H5D.open(fid,'/g4/lat',plist);
%       lon_dset_id = H5D.open(fid,'/g4/lon',plist);
%       H5DS.attach_scale(world_dset_id,lat_dset_id,0);
%       H5DS.attach_scale(world_dset_id,lon_dset_id,1);
%       H5D.close(lat_dset_id);
%       H5D.close(lon_dset_id);
%       H5D.close(world_dset_id);
%       H5F.close(fid);
%
%   See also H5DS, H5DS.detach_scale.

%   Copyright 2009-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5DSattach_scale', dataset_id, dimscale_id, idx);            
