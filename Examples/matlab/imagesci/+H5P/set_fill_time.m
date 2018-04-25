function set_fill_time(plist_id, fill_time)
%H5P.set_fill_time  Set time when fill values are written to dataset.
%   H5P.set_fill_time(plist_id, fill_time) sets the timing for writing fill 
%   values to a dataset in the dataset creation property list plist_id.
%   The timing can be specified by one of the following values:
%   H5D_FILL_TIME_IFSET, H5D_FILL_TIME_ALLOC, or H5D_FILL_TIME_NEVER. 
%
%   Example:  
%       fid = H5F.create('myfile.h5');
%       type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       dims = [100 50];
%       h5_dims = fliplr(dims);
%       h5_maxdims = h5_dims;
%       space_id = H5S.create_simple(2,h5_dims,h5_maxdims);
%       dcpl = H5P.create('H5P_DATASET_CREATE');
%       fill_time = H5ML.get_constant_value('H5D_FILL_TIME_ALLOC');
%       H5P.set_fill_time(dcpl,fill_time);
%       dset_id = H5D.create(fid,'DS',type_id,space_id,dcpl);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5P, H5P.get_fill_time, H5P.get_fill_value,
%   H5P.set_fill_value.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_fill_time', plist_id, fill_time);            
