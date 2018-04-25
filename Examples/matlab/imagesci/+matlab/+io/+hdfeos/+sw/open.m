function swfid = open(filename,access)
%open Open swath file.
%   swfid = open(FILENAME) opens an HDF-EOS swath file for read-only 
%   access.
%
%   swfID = sw.open(FILENAME,ACCESS) opens or creates an HDF-EOS 
%   swath file identified by FILENAME and returns a file ID.  ACCESS can 
%   be one of the following string values
%                 
%       'read'   - read-only
%       'rdwr'   - read-write
%       'create' - creates a file, deleting it if it already exists
%       
%   ACCESS defaults to 'read'.
%
%   This routine corresponds to the SWopen function in the HDF-EOS library 
%   C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       sw.close(swfid);
%
%   See also sw, sw.close.

%   Copyright 2010-2013 The MathWorks, Inc.

if nargin < 2
    access = 'read';
end

% Get a full path to the file if we are reading it.
if ~strcmp(access,'create')
    fid = fopen(filename,'r');
    filename = fopen(fid);
    fclose(fid);
end

swfid = hdf('SW','open',filename,access);
hdfeos_sw_error(swfid,'SWopen');
