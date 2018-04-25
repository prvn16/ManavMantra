function [memb_size, memb_fapl_id] = get_fapl_family(fapl_id)
%H5P.get_fapl_family  Return file access property list information.
%   [memb_size memb_fapl_id] = H5P.get_fapl_family(fapl_id) returns the
%   size in bytes of each file member and the identifier of the file access
%   property list for use with the family driver specified by fapl_id.
%
%   See also H5P, H5P.set_fapl_family.

%   Copyright 2006-2013 The MathWorks, Inc.

[memb_size, raw_memb_fapl_id] = H5ML.hdf5lib2('H5Pget_fapl_family', fapl_id);            
memb_fapl_id = H5ML.id(raw_memb_fapl_id,'H5Pclose');
