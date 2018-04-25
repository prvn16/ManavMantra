function datatype_id = get_mem_datatype( dset_id )
%H5ML.get_mem_datatype  Retrieve datatype for dataset ID.
%   DTYPE_ID = H5ML.get_mem_datatype(LOCATION_ID) returns the ID of an HDF5 
%   memory datatype for the dataset or attribute identified by LOCATION_ID.  
%   This HDF5 memory datatype is the default used by H5D.read or H5D.write 
%   when you specify 'H5ML_DEFAULT' as a value of the memory datatype 
%   parameter.
%
%   The identifier returned by H5ML.get_mem_datatype should eventually be
%   closed by calling H5T.close to release resources.
%
%   Example:
%     file_id = H5F.open('example.h5','H5F_ACC_RDONLY','H5P_DEFAULT');
%     dset_id = H5D.open(file_id,'/g1/g1.1/dset1.1.1');
%     datatype_id = H5ML.get_mem_datatype(dset_id)
%     H5T.close(datatype_id);
%     H5D.close(dset_id);
%     H5F.close(file_id);

%   Copyright 2007-2013 The MathWorks, Inc.

datatype_id = H5ML.hdf5lib2('H5MLget_mem_datatype', dset_id);
