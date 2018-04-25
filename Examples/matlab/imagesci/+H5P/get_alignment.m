function [threshold, alignment] = get_alignment(fapl_id)
%H5P.get_alignment  Retrieve alignment properties.
%   [threshold alignment] = H5P.get_alignment(plist_id) retrieves the
%   current settings for alignment properties from the file access property
%   list specified by plist_id.
%
%   Example:
%       fid = H5F.open('example.h5');
%       fapl = H5F.get_access_plist(fid);
%       [threshold, alignment] = H5P.get_alignment(fapl);
%       H5P.close(fapl);
%       H5F.close(fid);
%
%   See also H5P.

%   Copyright 2006-2013 The MathWorks, Inc.

[threshold, alignment] = H5ML.hdf5lib2('H5Pget_alignment', fapl_id);            
