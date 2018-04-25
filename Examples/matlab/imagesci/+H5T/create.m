function output = create(class_id, size)
%H5T.create  Create new datatype.
%   output = H5T.create(class_id, size) creates a new datatype of the class
%   specified by class_id, with the number of bytes specified by size. 
%   output is a datatype identifier.
%
%   Example:  Create a signed 32-bit enumerated datatype.
%       type_id = H5T.create('H5T_ENUM',4);
%       H5T.set_order(type_id,'H5T_ORDER_LE');
%       H5T.set_sign(type_id,'H5T_SGN_2');
%       H5T.enum_insert(type_id,'black',0);
%       H5T.enum_insert(type_id,'white',1);
%
%   See also H5T, H5T.set_order, H5T.set_sign.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tcreate', class_id, size);
output = H5ML.id(output,'H5Tclose');
