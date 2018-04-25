function [name, offset, size] = get_external(plist_id, idx)
%H5P.get_external  Return information about external file.
%   [name offset size] = H5P.get_external(plist_id, idx) returns 
%   information about the external file specified by the dataset creation 
%   property list plist_id. The idx specifies the external file index,
%   which is a number from zero to N-1, where N is the value returned by
%   H5P.get_external_count. The name returns the name of the external file
%   (limited by 2048 characters). The offset returns the location in bytes,
%   from the beginning of the external file, where the data starts. The
%   size returns the size of the external data. 
%
%   See also H5P, H5P.get_external_count.

%   Copyright 2006-2013 The MathWorks, Inc.

[name, offset, size] = H5ML.hdf5lib2('H5Pget_external', plist_id, idx);            
