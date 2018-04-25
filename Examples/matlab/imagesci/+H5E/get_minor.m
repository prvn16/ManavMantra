function err_string = get_minor(minor_number)
%H5E.get_minor  Return description of minor error number.
%   err_string = H5E.get_minor(minor_number) returns a character string
%   describing an error specified by the minor error number, minor_number.
%
%   The HDF5 group has deprecated the use of this function.
%
%   See also H5E, H5E.get_major.

%   Copyright 2006-2013 The MathWorks, Inc.
           
err_string = H5ML.hdf5lib2('H5Eget_minor', minor_number);            
