function output = isa_class(plist_id, pclass_id)
%H5P.isa_class  Determine if property list is member of class.
%   output = H5P.isa_class(plist_id, pclass_id) returns a positive number 
%   if the property list specified by plist_id is a member of the class 
%   specified by pclass_id, zero if it is not, and a negative value to 
%   indicate an error.
%
%    Example:
%        fid = H5F.open('example.h5');
%        fcpl = H5F.get_create_plist(fid);
%        if H5P.isa_class(fcpl,'H5P_FILE_ACCESS')
%            fprintf('fcpl is a file access property list\n');
%        else
%            fprintf('fcpl is not a file access property list\n');
%        end
%
%   See also H5P, H5P.get_class.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Pisa_class', plist_id, pclass_id);            
