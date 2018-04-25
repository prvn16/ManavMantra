function gfid = open(filename,access)
%open Open grid file.
%   gfid = open(FILENAME,ACCESS) opens or creates an HDF-EOS 
%   grid file identified by FILENAME and returns a file ID.  ACCESS can 
%   be one of the following string values
%                 
%       'read'   - read-only
%       'rdwr'   - read-write
%       'create' - creates a file, deleting it if it already exists
%
%   If ACCESS is not provided, it defaults to 'read'.
%       
%   This function corresponds to the GDopen function in the HDF-EOS library
%   C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gd.close(gfid);
%
%   See also gd, gd.attach, gd.close.

%   Copyright 2010-2013 The MathWorks, Inc.

if nargin == 1
    access = 'read';
end


% Get a full path to the file if we are reading it.
if ~strcmp(access,'create')
    fid = fopen(filename,'r');
    if fid == -1
        error(message('MATLAB:imagesci:validate:fileOpen',filename));
    end
    filename = fopen(fid);
    fclose(fid);
end

gfid = hdf('GD','open',filename,access);
hdfeos_gd_error(gfid,'GDopen');
