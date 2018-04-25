function set_label(dataset_id,idx,label)
%H5DS.set_label  Set label for dataset dimension.
%   H5DS.set_label(dataset_id,idx,label) sets a label for dimension idx
%   of the dataset dataset_id.
%
%   Note:  The ordering of the dimension scale indices are the same as the
%   HDF5 library C API. 
%
%   Example:  
%       plist = 'H5P_DEFAULT';
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.h5');
%       copyfile(srcFile,'myfile.h5');
%       fileattrib('myfile.h5','+w');
%       fid = H5F.open('myfile.h5','H5F_ACC_RDWR',plist);
%       world_dset_id = H5D.open(fid,'/g4/world',plist);
%       H5DS.set_label(world_dset_id,0,'latitude');
%       H5DS.set_label(world_dset_id,1,'longitude');
%       H5D.close(world_dset_id);
%       H5F.close(fid);
%
%   See also H5DS, H5DS.get_label.

%   Copyright 2009-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5DSset_label', dataset_id, idx, label);            
