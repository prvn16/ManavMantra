function pack(type_id)
%H5T.pack  Recursively remove padding from compound datatype.
%   H5T.pack(TYPE_ID) recursively removes padding from within a compound 
%   datatype to make it more efficient (space-wise) to store that data. 
%   TYPE_ID is a datatype identifier.
%
%   See also H5T.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Tpack',type_id); 
