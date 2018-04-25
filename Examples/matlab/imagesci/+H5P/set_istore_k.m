function set_istore_k(plist_id, ik)
%H5P.set_istore_k  Set size of parameter for indexing chunked datasets.
%   H5P.set_istore_k(plist_id, ik) sets the size of the parameter used to 
%   control the B-trees for indexing chunked datasets for the file creation
%   property list specified by plist_id. ik is one half the rank of a tree 
%   that stores chunked raw data.
%
%   Example:
%       fcpl = H5P.create('H5P_FILE_CREATE');
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       H5P.set_istore_k(fcpl,64);
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.get_istore_k.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_istore_k', plist_id, ik);            
