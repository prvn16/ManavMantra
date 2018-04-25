function [superblock, freelist, stab, shhdr] = get_version(fcpl)
%H5P.get_version  Return version information for file creation property list.
%   [superblock freelist stab shhdr] = H5P.get_version(fcpl) returns the
%   version of the super block, the global freelist, the symbol table, and
%   the shared object header. Retrieving this information requires the file
%   creation property list.
%
%   Example:
%       fid = H5F.open('example.h5');
%       fcpl = H5F.get_create_plist(fid);
%       [super,freelist,stab,shhdr] = H5P.get_version(fcpl);
%       H5P.close(fcpl);
%       H5F.close(fid);
%
%   See also H5P.

%   Copyright 2006-2013 The MathWorks, Inc.

[superblock, freelist, stab, shhdr] = H5ML.hdf5lib2('H5Pget_version', fcpl);            
