function buf = get_linkval(loc_id,name)
%H5G.get_linkval  Return name of object specified by symbolic link.
%
%   H5G.get_linkval is not recommended.  Use H5L.get_val instead.
%
%   buf = H5G.get_linkval(loc_id, name) returns the name of the object that 
%   the symbolic link specified by name points to. loc_id is a file or 
%   group identifier.
%
%   The HDF5 group has deprecated the use of this function.
%
%   See also H5G, H5L.get_val.

%   Copyright 2006-2013 The MathWorks, Inc.

buf = H5ML.hdf5lib2('H5Gget_linkval', loc_id,name);
