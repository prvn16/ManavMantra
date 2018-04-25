function output = equal(id1, id2)
%H5P.equal  Determine equality of property lists.
%   value = H5P.equal(plist1_id, plist2_id) returns a positive number if 
%   the two property lists specified are equal, and zero if they are not. 
%   A negative value indicates failure.
%
%   Example:
%       fid = H5F.open('example.h5');
%       fapl = H5F.get_access_plist(fid);
%       fcpl = H5F.get_create_plist(fid);
%       if H5P.equal(fapl,fcpl)
%           fprintf('property lists are equal\n');
%       else
%           fprintf('property lists are not equal\n');
%       end
%
%   See also H5P.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Pequal', id1, id2);            
