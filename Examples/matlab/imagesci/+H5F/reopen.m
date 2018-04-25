function new_file_id = reopen(file_id)
%H5F.reopen  Reopen HDF5 file.
%   new_file_id = H5F.reopen(file_id) returns a new file identifier for the 
%   already open HDF5 file specified by file_id.  
%
%   See also H5F, H5F.open.

%   Copyright 2006-2013 The MathWorks, Inc.

raw_file_id = H5ML.hdf5lib2('H5Freopen', file_id);         
new_file_id = H5ML.id(raw_file_id,'H5Fclose');
