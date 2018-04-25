function plist_copy = copy(plist_id)
%H5P.copy  Return copy of property list.
%   plist_copy = H5P.copy(plist_id) returns a copy of the property list
%   specified by plist_id.
%
%   Example:  Make a copy of the file creation property list for
%   example.h5.
%       fid = H5F.open('example.h5');
%       fcpl = H5F.get_create_plist(fid);
%       fcpl2 = H5P.copy(fcpl);
%       
%
%   See also H5P.

%   Copyright 2006-2013 The MathWorks, Inc.

plist_copy = H5ML.hdf5lib2('H5Pcopy', plist_id);            
plist_copy = H5ML.id(plist_copy,'H5Pclose');

