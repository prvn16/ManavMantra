function set_fapl_core(fapl_id, increment, backing_store)
%H5P.set_fapl_core  Modify file access to use H5FD_CORE driver.
%   H5P.set_fapl_core(FAPL_ID, MEM_INC, BACKING_STORE) modifies the file
%   access property list to use the H5FD_CORE driver. MEM_INC specifies
%   the increment by which allocated memory is to be increased each time
%   more memory is required. BACKING_STORE is a boolean flag that, when
%   non-zero, indicates the file contents should be written to disk when
%   the file is closed.
%
%   Example:  Create a file image in memory only.
%       plist = 'H5P_DEFAULT';
%       ndatasets = 20;
%       block_size = 1024*1024;
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       H5P.set_fapl_core(fapl,2^16,false);
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',plist,fapl);
%       space_id = H5S.create_simple(1, block_size, []);
%       type_id = H5T.copy('H5T_IEEE_F64LE');
%       data = zeros(block_size,1);
%       for j = 1:ndatasets
%           dsname = sprintf( 'dset%02d', j);
%           fprintf( 'Writing dataset %s...\n',dsname);
%           dsid = H5D.create(fid,dsname,type_id,space_id,'H5P_DEFAULT');
%           H5D.write(dsid,'H5ML_DEFAULT',space_id,space_id,plist,data);
%           H5D.close(dsid);
%       end
%       H5P.close(fapl);
%       H5S.close(space_id);
%       H5T.close(type_id);
%       H5F.close(fid);
%       dir('myfile.h5');
%
%   See also H5P, H5P.get_fapl_core.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_fapl_core', fapl_id, increment, backing_store);            
