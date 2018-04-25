function set_layout(dcpl, layout)
%H5P.set_layout  Set type of storage for dataset.
%   H5P.set_layout(dcpl, layout) sets the type of storage used to store 
%   the raw data for the dataset creation property list, dcpl. layout
%   specifies the type of storage layout for raw data: H5D_COMPACT, 
%   H5D_CONTIGUOUS, or H5D_CHUNKED.
%
%   Example:  
%         fid = H5F.create('myfile.h5');
%         type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%         dims = [100 200];
%         h5_dims = fliplr(dims);
%         space_id = H5S.create_simple(2,dims,[]);
%         dcpl = H5P.create('H5P_DATASET_CREATE');
%         layout = H5ML.get_constant_value('H5D_CONTIGUOUS');
%         H5P.set_layout(dcpl,layout);
%         dset_id = H5D.create(fid,'DS',type_id,space_id,dcpl);
%         H5D.close(dset_id);
%         H5F.close(fid);
%
%   See also H5P, H5P.get_layout, H5P.set_chunk.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_layout', dcpl, layout);            
