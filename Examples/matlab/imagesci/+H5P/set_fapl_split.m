function set_fapl_split(fapl_id, meta_ext, meta_plist_id, raw_ext, raw_plist_id)
%H5P.set_fapl_split  Set file access for emulation of split file driver.
%   H5P.set_fapl_split(fapl_id, meta_ext, meta_plist_id, raw_ext,
%   raw_plist_id) is a compatibility function that enables the multi-file
%   driver to emulate the split driver from HDF5 Releases 1.0 and 1.2.
%   meta_ext is a text string that specifies the metadata filename
%   extension. meta_plist_id is a file access property list identifier for
%   the metadata file. raw_ext is a text string that specifies the raw data
%   filename extension. raw_plist_id is the file access property list
%   identifier for the raw data file.
%
%   See also H5P.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_fapl_split',fapl_id,meta_ext,meta_plist_id,raw_ext,raw_plist_id);            
