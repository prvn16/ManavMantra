function name = get_name(loc_id,ref_type,ref, varargin)
%H5R.get_name  Return name of referenced object.
%   name = H5R.get_name(loc_id,ref_type,ref) retrieves the name for the 
%   object identified by ref.  loc_id is the identifier for the dataset
%   containing the reference or for the group containing that dataset. 
%   ref_type specifies the type of the reference ref. Valid ref_types are
%   'H5R_OBJECT' or 'H5R_DATASET_REGION'.  
%
%   name = H5R.get_name(loc_id, ref_type, ref, Name1, Value1) retrieves the
%   name for the object identified by ref. The name-value pair specifies
%   the text encoding to be used to interpret the reference name. 
%
%   Name-Value Pairs
%   ----------------
%   'TextEncoding'  - Defines the character encoding to be used for
%                     interpreting the reference name. It takes values
%                     'system' or 'UTF-8'. Default value is 'system'. 
%
%   Example:
%       plist = 'H5P_DEFAULT';
%       space = 'H5S_ALL';
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/reference');
%       ref_data = H5D.read(dset_id,'H5T_STD_REF_OBJ',space,space,plist);
%       name = H5R.get_name(dset_id,'H5R_OBJECT',ref_data(:,1));
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5R, H5I.get_name.

%   Copyright 2009-2017 The MathWorks, Inc.

useUtf8 = matlab.io.internal.imagesci.h5ParseEncoding(varargin);
name = H5ML.hdf5lib2('H5Rget_name', loc_id, ref_type, ref, useUtf8);            
