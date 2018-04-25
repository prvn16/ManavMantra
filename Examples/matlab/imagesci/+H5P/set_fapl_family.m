function set_fapl_family(fapl_id, memb_size, memb_fapl_id)
%H5P.set_fapl_family  Set file access to use family driver.
%   H5P.set_fapl_family(FAPL_ID, MEMB_SIZE, MEMB_FAPL_ID) sets the file
%   access property list specified by FAPL_ID to use the family driver.
%   MEMB_SIZE is the size in bytes of each file member. MEMB_FAPL_ID is the
%   identifier of the file access property list to be used for each family
%   member.
%
%   Example:
%       plist = 'H5P_DEFAULT';
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       H5P.set_fapl_family(fapl, 8192, plist);
%       fid = H5F.create('family%d.h5','H5F_ACC_TRUNC','H5P_DEFAULT',fapl);
%       type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       dims = [50 25];
%       h5_dims = fliplr(dims);
%       space_id = H5S.create_simple(2,h5_dims,[]);
%       dset_id = H5D.create(fid,'DS',type_id,space_id,plist)
%       data = reshape(1:prod(dims),dims);
%       H5D.write(dset_id,'H5ML_DEFAULT','H5S_ALL','H5S_ALL',plist,data);
%       H5P.close(fapl);
%       H5T.close(type_id);
%       H5S.close(space_id);
%       H5D.close(dset_id);
%       dir('*.h5');
%       h5disp('family%d.h5');
%
%   See also H5P, H5P.get_fapl_family.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_fapl_family', fapl_id, memb_size, memb_fapl_id);            
