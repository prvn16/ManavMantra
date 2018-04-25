function set_nbit(plist_id)
%H5P.set_nbit  Setup use of N-Bit filter.
%   H5P.set_nbit(plist_id) sets the N-Bit filter, H5Z_FILTER_NBIT, in 
%   the dataset creation property list plist_id.
%
%   See also H5P.

%   Copyright 2009-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_nbit',plist_id);
