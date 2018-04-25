function sz = get_userblock(fcpl)
%H5P.get_userblock  Return size of user block.
%   sz = H5P.get_userblock(plist_id) returns the size of a user block 
%   in a file creation property list. plist_id is a property list 
%   identifier.
%
%   Example:
%       fid = H5F.open('example.h5');
%       fcpl = H5F.get_create_plist(fid);
%       sz = H5P.get_userblock(fcpl);
%       H5P.close(fcpl);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_userblock.

%   Copyright 2006-2013 The MathWorks, Inc.

sz = H5ML.hdf5lib2('H5Pget_userblock', fcpl);            
