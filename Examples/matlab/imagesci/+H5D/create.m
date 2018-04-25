function dataset_id = create(varargin)
%H5D.create  Create new dataset.
%   dataset_id = H5D.create(loc_id, name, type_id, space_id, plist_id) 
%   creates the data set specified by name in the file or in the group 
%   specified by loc_id. type_id and space_id identify the datatype and 
%   dataspace, respectively. plist_id identifies the dataset creation
%   property list.  This interface corresponds to the H5Dcreate1 function
%   in the HDF5 library C 1.6 API.
%
%   dataset_id = H5D.create(loc_id,name,type_id,space_id,lcpl_id,dcpl_id,dapl_id) 
%   creates the data set with three distinct property lists:
%
%      lcpl_id:  link creation property list
%      dcpl_id:  dataset creation property list
%      dapl_id:  dataset access property list
%
%   This interface corresponds to the H5Dcreate function in the HDF5 
%   library C 1.8 API.
%
%   Example:  
%       % Create a 10x5 double precision dataset with default property
%       % list settings.
%       fid = H5F.create('myfile.h5');
%       type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       dims = [10 5];
%       h5_dims = fliplr(dims);
%       h5_maxdims = h5_dims;
%       space_id = H5S.create_simple(2,h5_dims,h5_maxdims);
%       dcpl = 'H5P_DEFAULT';
%       dset_id = H5D.create(fid,'DS',type_id,space_id,dcpl);
%       H5S.close(space_id);
%       H5T.close(type_id);
%       H5D.close(dset_id);
%       H5F.close(fid);
%       h5disp('myfile.h5');
%       
%   Example:  
%       % Create a 6x3 fixed length string dataset.  Each string will
%       % have a length of four characters.
%       fid = H5F.create('myfile_strings.h5');
%       type_id = H5T.copy('H5T_C_S1');
%       H5T.set_size(type_id,4);
%       dims = [6 3];
%       h5_dims = fliplr(dims);
%       h5_maxdims = h5_dims;
%       space_id = H5S.create_simple(2,h5_dims,h5_maxdims);
%       dcpl = 'H5P_DEFAULT';
%       dset_id = H5D.create(fid,'DS',type_id,space_id,dcpl);
%       H5S.close(space_id);
%       H5T.close(type_id);
%       H5D.close(dset_id);
%       H5F.close(fid);
%       h5disp('myfile_strings.h5');
%       
%   See also H5D, H5D.close, H5S.create_simple, H5S.close, H5T.copy.

%   Copyright 2006-2013 The MathWorks, Inc.

id = H5ML.hdf5lib2('H5Dcreate', varargin{:} );
dataset_id = H5ML.id(id,'H5Dclose');
