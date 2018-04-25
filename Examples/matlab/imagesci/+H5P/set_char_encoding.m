function set_char_encoding(plist_id,encoding)
%H5P.set_char_encoding  Set character encoding used to encode strings.
%   H5P.set_char_encoding(propList,encoding)  sets the character 
%   encoding used to encode strings or object names that are created 
%   with the property list propList.  The values of encoding should 
%   either be H5T_CSET_ASCII or H5T_CSET_UTF8.
%
%   See also H5P, H5P.get_char_encoding, H5ML.get_constant_value

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_char_encoding', plist_id, encoding);
