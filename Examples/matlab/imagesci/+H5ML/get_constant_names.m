function names = get_constant_names()
%H5ML.get_constant_names Get a list of constants known by the HDF5 library.
%   This function will return a list of known library contants,
%   definitions, and enumerations.  When these strings are supplied as
%   actual parameters to HDF5 functions, they will automatically be
%   converted to the appropriate numeric value.
%
%   Function parameters:
%     names: a alphabetized cell array of names.
%
%   Example:
%     names = H5ML.get_constant_names();
%

%   Copyright 2006-2013 The MathWorks, Inc.

names = H5ML.hdf5lib2('H5MLget_constant_names')';
names = sort(names); %#ok<TRSRT>
