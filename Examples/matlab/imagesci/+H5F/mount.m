function mount(varargin)
%H5F.mount  Mount HDF5 file onto specified location.
%   H5F.mount(loc_id, name, child_id, plist_id) mounts the file specified 
%   by child_id onto the group specified by loc_id and name, using the 
%   mount properties specified by plist_id.   
%
%   Example:  Mount one file with a dataset onto a group in a second file 
%   and access the dataset via the second file.
%       plist = 'H5P_DEFAULT';
%       fid2 = H5F.create('file2.h5','H5F_ACC_TRUNC',plist,plist);
%       gid2 = H5G.create(fid2,'g2',plist,plist,plist);
%       fid1 = H5F.create('file1.h5','H5F_ACC_TRUNC','H5P_DEFAULT','H5P_DEFAULT');
%       space_id = H5S.create('H5S_SCALAR');
%       dset_id = H5D.create(fid1,'DS1','H5T_NATIVE_DOUBLE',space_id,plist);
%       H5S.close(space_id);
%       H5D.close(dset_id);
%       H5F.mount(fid2,'g2',fid1,plist);
%       dset_id1 = H5D.open(fid1,'/g2/DS1',plist);
%       H5D.close(dset_id1);
%       H5F.unmount(fid1,'g2');
%       H5G.close(gid2);
%       H5F.close(fid1);
%       H5F.close(fid2);
% 
%   See also H5F, H5F.unmount.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Fmount', varargin{:});            
