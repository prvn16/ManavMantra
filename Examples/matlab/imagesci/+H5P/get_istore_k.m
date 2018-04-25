function ik = get_istore_k(plist_id)
%H5P.get_istore_k  Return 1/2 rank of indexed storage B-tree.
%   ik = H5P.get_istore_k(plist_id) returns the chunked storage B-tree 1/2 
%   rank of the file creation property list specified by plist_id.
%
%   Example:
%       fid = H5F.open('example.h5');
%       fcpl = H5F.get_create_plist(fid);
%       ik = H5P.get_istore_k(fcpl);
%       H5P.close(fcpl);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_istore_k.

%   Copyright 2006-2013 The MathWorks, Inc.

ik = H5ML.hdf5lib2('H5Pget_istore_k', plist_id);            
