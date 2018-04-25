function plist_id = get_access_plist(file_id)
%H5F.get_access_plist  Return file access property list.
%   fapl_id = H5F.get_access_plist(file_id) returns the file access
%   property list identifier of the file specified by file_id.
%
%   Example:
%       fid = H5F.open('example.h5');
%       fapl = H5F.get_access_plist(fid);
%       H5P.close(fapl);
%       H5F.close(fid);
%
%   See also H5F, H5F.get_create_plist.

%   Copyright 2006-2013 The MathWorks, Inc.

plist_id = H5ML.hdf5lib2('H5Fget_access_plist', file_id);            
plist_id = H5ML.id(plist_id,'H5Pclose');
