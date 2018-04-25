function info = get_info(obj_id)
%H5O.get_info  Retrieve information for object.
%   info = H5O.get_info(obj_id) retrieves the metadata for an object
%   specified by obj_id.  For details about the object metadata, please
%   refer to the HDF5 documentation.
%
%   Example:  Determine the number of attributes for a dataset.
%       fid = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%       dsetId = H5D.open(fid,'/g1/g1.1/dset1.1.1');
%       info = H5O.get_info(dsetId);
%       info.num_attrs
%
%   Example:  Determine the type of objects in the root group.
%       plist = 'H5P_DEFAULT';
%       fid = H5F.open('example.h5');
%       gid = H5G.open(fid,'/');
%       root_info = H5G.get_info(gid);
%       idx_type = 'H5_INDEX_NAME';
%       order = 'H5_ITER_DEC';
%       for j = 0:root_info.nlinks-1
%          obj_id = H5O.open_by_idx(fid,'/',idx_type,order,j,plist);
%          obj_info = H5O.get_info(obj_id);
%          switch(obj_info.type)
%              case H5ML.get_constant_value('H5G_LINK')
%                  fprintf('Object #%d is a link.\n', j);
%              case H5ML.get_constant_value('H5G_GROUP')
%                  fprintf('Object #%d is a group.\n', j);
%              case H5ML.get_constant_value('H5G_DATASET')
%                  fprintf('Object #%d is a dataset.\n', j);
%              case H5ML.get_constant_value('H5G_TYPE')
%                  fprintf('Object #%d is a named datatype.\n', j);
%          end
%          H5O.close(obj_id);
%       end
%       H5G.close(gid);
%       H5F.close(fid);
%  
%   See also H5O, H5F.open, H5G.open, H5D.open, H5T.open.
   
%   Copyright 2009-2013 The MathWorks, Inc.

info = H5ML.hdf5lib2('H5Oget_info', obj_id);            
