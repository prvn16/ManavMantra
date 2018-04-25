function set_sym_k(plist_id, ik, lk)
%H5P.set_sym_k  Set size of parameters used to control symbol table nodes.
%   H5P.set_sym_k(plist_id, ik, lk) sets the size of parameters used to 
%   control the symbol table nodes for the file access property list, 
%   plist_id.  ik is one half the rank of a tree that stores a symbol table 
%   for a group.  lk is one half of the number of symbols that can be 
%   stored in a symbol table node.
% 
%   Example:
%       fcpl = H5P.create('H5P_FILE_CREATE');
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       H5P.set_sym_k(fcpl,32,8);
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.get_sym_k.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_sym_k', plist_id, ik, lk);            
