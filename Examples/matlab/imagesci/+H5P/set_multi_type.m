function set_multi_type(fapl_id, type)
%H5P.set_multi_type  Sepcify type of data accessed with MULTI driver.
%   H5P.set_multi_type(fapl_id, type) sets the type of data property in the 
%   file access or data transfer property list fapl_id. type can have any
%   of the following values: H5FD_MEM_SUPER, H5FD_MEM_BTREE, H5FD_MEM_DRAW,
%   H5FD_MEM_GHEAP, H5FD_MEM_LHEAP, or H5FD_MEM_OHDR.
%
%   See also H5P, H5P.get_multi_type.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_multi_type', fapl_id, type);            
