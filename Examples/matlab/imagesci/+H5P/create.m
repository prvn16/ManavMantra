function output = create(class_id)
%H5P.create  Create new property list.
%   plist = H5P.create(class_id) creates a new property list as an instance 
%   of the property list class specified by class_id.  class_id can be one 
%   of the following strings or the corresponding constant value.
%
%      'H5P_ATTRIBUTE_CREATE' 
%      'H5P_DATASET_ACCESS' 
%      'H5P_DATASET_CREATE' 
%      'H5P_DATASET_XFER' 
%      'H5P_DATATYPE_CREATE' 
%      'H5P_DATATYPE_ACCESS' 
%      'H5P_FILE_MOUNT' 
%      'H5P_FILE_CREATE' 
%      'H5P_FILE_ACCESS' 
%      'H5P_GROUP_CREATE' 
%      'H5P_GROUP_ACCESS' 
%      'H5P_LINK_CREATE' 
%      'H5P_LINK_ACCESS' 
%      'H5P_OBJECT_COPY' 
%      'H5P_OBJECT_CREATE' 
%      'H5P_STRING_CREATE' 
%
%   class_id can also be an instance of a property list class.
%
%   Example:
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY',fapl);
%
%   See also:  H5P, H5P.close, H5P.get_class, H5ML.get_constant_value.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Pcreate', class_id);            
output = H5ML.id(output,'H5Pclose');
