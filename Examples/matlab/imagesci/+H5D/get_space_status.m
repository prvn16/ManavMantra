function status = get_space_status(dataset_id)
%H5D.get_space_status  Determine if space is allocated.
%   status = H5D.get_space_status(dataset_id) determines whether space has
%   been allocated for the dataset specified by dataset_id.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g1/g1.1/dset1.1.1');
%       status = H5D.get_space_status(dset_id);
%       switch(status)
%           case H5ML.get_constant_value('H5D_SPACE_STATUS_NOT_ALLOCATED')
%               fprintf('Not allocated.\n');
%           case H5ML.get_constant_value('H5D_SPACE_STATUS_ALLOCATED')
%               fprintf('Allocated.\n');
%           case H5ML.get_constant_value('H5D_SPACE_STATUS_PART_ALLOCATED')
%               fprintf('Part allocated.\n');
%       end
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5D, H5D.get_space.

%   Copyright 2006-2013 The MathWorks, Inc.

status = H5ML.hdf5lib2('H5Dget_space_status', dataset_id);            
