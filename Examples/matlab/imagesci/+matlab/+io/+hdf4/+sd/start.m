function sdID = start(filename,access)
%start Open HDF file and initialize SD interface.
%   sdID = start(FILENAME) opens the file FILENAME in read-only mode.
%   This routine must be called for each file before any other sd calls can
%   be made on that file.
%
%   sdID = start(FILENAME,ACCESS) opens the file FILENAME with the access 
%   mode specified by ACCESS.  This routine must be called before any 
%   other SD interface operations can be made on that file.  ACCESS may be 
%   one of the following strings:
%   
%       'read'
%       'write' 
%       'create'
%
%   ACCESS defaults to 'read' if not supplied.
%
%   This function corresponds to the SDstart function in the HDF library C
%   API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       sd.close(sdID);
%
%   See also sd, sd.close.

%   Copyright 2010-2013 The MathWorks, Inc.

if nargin < 2
    access = 'read';
end


% Get a full path to the file if we are reading it.
if ~strcmp(access,'create')
    fid = fopen(filename,'r');
    if fid == -1
        error(message('MATLAB:imagesci:validate:fileOpen', filename));
    end
    filename = fopen(fid);
    fclose(fid);
end


sdID = hdf('SD','start',filename,access);
if sdID < 0
    hdf4_sd_error('SDstart');
end
