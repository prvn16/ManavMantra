function classname = get_class_name(pclass_id)
%H5P.get_class_name  Return name of property list class.
%   classname = H5P.get_class_name(pclass_id) retrieves the name of the 
%   generic property list class. classname is a text string.  If no
%   class is found, the empty string is returned.
%
%   Example:
%       fid = H5F.open('example.h5');
%       fcpl = H5F.get_create_plist(fid);
%       pclass = H5P.get_class(fcpl);
%       name = H5P.get_class_name(pclass);
%
%   See also H5P, H5P.get_class.

%   Copyright 2006-2013 The MathWorks, Inc.

classname = H5ML.hdf5lib2('H5Pget_class_name', pclass_id);            
