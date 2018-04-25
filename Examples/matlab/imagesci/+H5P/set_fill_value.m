function set_fill_value(plist_id, type_id, value)
%H5P.set_fill_value  Set fill value for dataset creation property list.
%   H5P.set_fill_value(plist_id, type_id, value) sets the fill value for a
%   the dataset creation property list specified by plist_id. value
%   specifies the fill value and type_id the datatype of the fill value.
%   Setting value to an empty array indicates that the fill value is to be
%   undefined.
%
%   Example:  create a double precision dataset with a fill value of -999.
%       fid = H5F.create('myfile.h5');
%       type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       dims = [100 50];
%       h5_dims = fliplr(dims);
%       h5_maxdims = h5_dims;
%       space_id = H5S.create_simple(2,h5_dims,h5_maxdims);
%       dcpl = H5P.create('H5P_DATASET_CREATE');
%       fill_time = H5ML.get_constant_value('H5D_FILL_TIME_ALLOC');
%       H5P.set_fill_time(dcpl,fill_time);
%       type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       H5P.set_fill_value(dcpl,type_id,-999);
%       dset_id = H5D.create(fid,'DS',type_id,space_id,dcpl);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5P.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_fill_value', plist_id, type_id, value);            
