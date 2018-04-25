function plist_id = get_create_plist(file_id)
%H5F.get_create_plist  Return file creation property list.
%   fcpl_id = H5F.get_create_plist(file_id) returns a file creation 
%   property list identifier identifying the creation properties used to 
%   create the file specified by file_id.
%
%   Example:
%       fid = H5F.open('example.h5');
%       fcpl = H5F.get_create_plist(fid);
%       H5P.close(fcpl);
%       H5F.close(fid);
%        
%   See also H5F, H5F.get_access_plist.

%   Copyright 2006-2013 The MathWorks, Inc.

plist_id = H5ML.hdf5lib2('H5Fget_create_plist', file_id);            
plist_id = H5ML.id(plist_id,'H5Pclose');
