function [memb_map, memb_fapl, memb_name, memb_addr, relax] = get_fapl_multi(fapl_id)
%H5P.get_fapl_multi  Return information about multi-file access property list.
%   [memb_map memb_fapl memb_name memb_addr relax] =
%   H5P.get_fapl_multi(fapl_id) returns information about the multi-file
%   access property list specified by fapl_id. memb_map maps memory usage
%   types to other memory usage types. memb_fapl is a property list for
%   each memory usage type. memb_name is the name generator for names of
%   member files. relax is a Boolean value that, when non-zero, allows
%   read-only access to incomplete file sets.
%
%   See also H5P, H5P.set_fapl_multi

%   Copyright 2006-2013 The MathWorks, Inc.

[memb_map, memb_fap, memb_name, memb_addr, relax] = H5ML.hdf5lib2('H5Pget_fapl_multi', fapl_id);            
for i = 1 : H5ML.get_constant_value('H5FD_MEM_NTYPES')
   memb_fapl(i) = H5ML.id(memb_fap(i),'H5Pclose'); %#ok<AGROW>
end

