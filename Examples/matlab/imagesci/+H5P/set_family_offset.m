function set_family_offset(fapl_id, offset)
%H5P.set_family_offset  Set offset property for family of files.
%   H5P.set_family_offset(fapl_id, offset) sets offset property in the file
%   access property list specified by fapl_id for low-level access to a
%   file in a family of files. offset identifies a user-determined location
%   from the beginning of the HDF5 file in bytes.
%
%   See also H5P, H5P.get_family_offset.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_family_offset', fapl_id, offset);            
