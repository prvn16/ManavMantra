function ref = create(loc_id, name, ref_type, space_id)
%H5R.create  Create reference.
%   ref = H5R.create(loc_id, name, ref_type, space_id) creates the
%   reference, ref, of the type specified in ref_type, pointing to the
%   object specified by name located at loc_id.  ref_type can be either 
%   'H5R_OBJECT', or 'H5R_DATASET_REGION'.  space_id should be -1 if the 
%   ref_type is 'H5R_OBJECT'.
%
%   Example:  Create a double precision dataset and a reference dataset.
%       fid = H5F.create('myfile.h5');
%       type1_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       dims = [10 5];
%       h5_dims = fliplr(dims);
%       h5_maxdims = h5_dims;
%       space1_id = H5S.create_simple(2,h5_dims,h5_maxdims);
%       dcpl = 'H5P_DEFAULT';
%       dset1_id = H5D.create(fid,'my_double',type1_id,space1_id,dcpl);
%       type2_id = 'H5T_STD_REF_OBJ';
%       space2_id = H5S.create('H5S_SCALAR');
%       dset2_id = H5D.create(fid,'my_ref',type2_id,space2_id,dcpl);
%       ref_data = H5R.create(fid,'my_double','H5R_OBJECT',-1);
%       dxpl = 'H5P_DEFAULT';
%       H5D.write(dset2_id,'H5ML_DEFAULT','H5S_ALL','H5S_ALL',dxpl,ref_data);
%       H5D.close(dset1_id);
%       H5D.close(dset2_id);
%       H5F.close(fid);
%
%   See also H5R, H5D.create.

%   Copyright 2006-2013 The MathWorks, Inc.

ref = H5ML.hdf5lib2('H5Rcreate', loc_id, name, ref_type, space_id);
