function [low,high] = get_libver_bounds(fapl_id)
%H5P.get_libver_bounds  Return library version bounds settings.
%   [low,high] = H5P.get_libver_bounds(fapl_id) gets bounds on library
%   version bounds settings that control the format versions used when
%   creating objects in the file with access property list fapl_id.
%         
%   Example:
%       fid = H5F.open('example.h5');
%       fapl = H5F.get_access_plist(fid);
%       [low,high] = H5P.get_libver_bounds(fapl);
%
%   See also H5P, H5F.get_access_plist, H5P.set_libver_bounds.

%   Copyright 2006-2013 The MathWorks, Inc.


[low,high] = H5ML.hdf5lib2('H5Pget_libver_bounds', fapl_id);

