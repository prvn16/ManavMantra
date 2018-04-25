function set_userblock(fcpl, sz)
%H5P.set_userblock  Set user block size.
%   H5P.set_userblock(plist_id, size) sets the user block size of the file 
%   creation property list, plist_id. 
%
%   Example:
%       fcpl = H5P.create('H5P_FILE_CREATE');
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       H5P.set_userblock(fcpl,4096);
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.get_userblock.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_userblock', fcpl, sz);            
