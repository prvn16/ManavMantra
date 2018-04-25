function set_alignment(fapl_id, threshold, alignment)
%H5P.set_alignment  Set alignment properties for file access property list.
%   H5P.set_alignment(fapl_id, threshold, alignment) sets the alignment
%   properties of the file access property list specified by fapl_id so
%   that any file object greater than or equal in size to threshold (in
%   bytes) is aligned on an address which is a multiple of alignment.
%
%   In most cases the default values of threshold and alignment result in
%   the best performance.
%
%   See also H5P, H5P.get_alignment.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_alignment', fapl_id, threshold, alignment);            
