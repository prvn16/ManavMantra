function value = get(plist_id, name)
%H5P.get  Retrieve value of specified property in property list.
%   value = H5P.get(plist_id, name) retrieves a copy of the value of the
%   property specified by the text string name in the property list
%   specified by plist_id. H5P.get returns the property as an array of
%   uint8 values. You might need to cast the value to an appropriate data
%   type to get a meaningful result.
%
%   Example:
%       plist = H5P.create('H5P_FILE_ACCESS');
%       val = H5P.get(plist, 'rdcc_w0');
%       rdcc_w0 = typecast(val,'double');
%   
%   It is recommended to use alternative functions like H5P.get_chunk,
%   H5P.get_layout, H5P.get_size etc., where available, to get values for
%   the common property names.
%
%   See also H5P, H5P.set, typecast.

%   Copyright 2006-2013 The MathWorks, Inc.

value = H5ML.hdf5lib2('H5Pget', plist_id, name);            
