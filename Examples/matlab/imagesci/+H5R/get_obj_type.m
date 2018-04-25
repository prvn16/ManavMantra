function output = get_obj_type(id, ref_type, ref)
%H5R.get_obj_type  Return type of referenced object.
%   obj_type = H5R.get_obj_type(id, ref_type, ref) returns the type of
%   object that an object reference points to. Valid ref_types are:
%   H5R_OBJECT or H5R_DATASET_REGION.  Valid return values correspond to
%   the following values:
%
%       'H5O_TYPE_GROUP'          - object is a group
%       'H5O_TYPE_DATASET'        - object is a dataset
%       'H5O_TYPE_NAMED_DATATYPE' - object is a named datatype
%
%   This function corresponds to the 1.8 interface version of
%   H5Rget_obj_type in the HDF5 library C API.
%
%   Example:
%       plist = 'H5P_DEFAULT';
%       space = 'H5S_ALL';
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/reference');
%       ref_data = H5D.read(dset_id,'H5T_STD_REF_OBJ',space,space,plist);
%       obj_type = H5R.get_obj_type(fid,'H5R_OBJECT',ref_data(:,1));
%       switch(obj_type)
%           case H5ML.get_constant_value('H5O_TYPE_GROUP')
%               fprintf('group\n');
%           case H5ML.get_constant_value('H5O_TYPE_DATASET')
%               fprintf('dataset\n');
%           case H5ML.get_constant_value('H5O_TYPE_NAMED_DATATYPE')
%               fprintf('named datatype\n');
%       end
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5R, H5ML.get_constant_value.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Rget_obj_type', id, ref_type, ref);            
