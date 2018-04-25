function move2(src_id, src, dst_id, dst)
%H5G.move2  Rename specified object.
%
%   H5G.move2 is not recommended.  Use H5L.move instead.
%
%   H5G.move2(src_loc_id, src_name, dst_loc_id, dst_name) renames the file 
%   or group object specified by src_loc_id, with the name specified by 
%   src_name, with the name specified by dst_name and location specified by 
%   dst_loc_id.
%
%   The HDF5 group has deprecated the use of this function.
%
%   See also H5G, H5L.move.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Gmove2', src_id, src, dst_id, dst);            
