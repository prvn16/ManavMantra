function offset = get_family_offset(fapl_id)
%H5P.get_family_offset  Return offset for family file driver.
%   offset = H5P.get_family_offset(fapl_id) retrieves the value of offset
%   from the file access property list, fapl_id. offset is the offset of
%   the data in the HDF5 file that is stored on disk in the selected member
%   file in a family of files.
%
%   See also H5P, H5P.set_family_offset.

%   Copyright 2006-2013 The MathWorks, Inc.

offset = H5ML.hdf5lib2('H5Pget_family_offset', fapl_id);            
