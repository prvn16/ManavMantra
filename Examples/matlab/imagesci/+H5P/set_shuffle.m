function set_shuffle(plist_id)
%H5P.set_shuffle  Setup use of shuffler filter.
%   H5P.set_shuffle(plist_id) sets the shuffle filter, H5Z_FILTER_SHUFFLE, 
%   in the dataset creation property list plist_id.  Compression must be
%   enabled on the dataset creation property list in order to use the
%   shuffle filter, and best results are usually obtained when the shuffle
%   filter is set immediately prior to setting the deflate filter.
%
%   Example:  
%         fid = H5F.create('myfile.h5');
%         type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%         dims = [100 200];
%         h5_dims = fliplr(dims);
%         space_id = H5S.create_simple(2,dims,[]);
%         dcpl = H5P.create('H5P_DATASET_CREATE');
%         chunk_dims = [10 20];
%         h5_chunk_dims = fliplr(chunk_dims);
%         H5P.set_chunk(dcpl,h5_chunk_dims);
%         H5P.set_shuffle(dcpl);
%         H5P.set_deflate(dcpl,5);
%         dset_id = H5D.create(fid,'DS',type_id,space_id,dcpl);
%         H5D.close(dset_id);
%         H5F.close(fid);
%
%   See also H5P, H5P.set_deflate.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_shuffle', plist_id);            
