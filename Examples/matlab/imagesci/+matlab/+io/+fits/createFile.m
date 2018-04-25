function fptr = createFile(filename)
%createFile create FITS file
%   FPTR = createFile(FILENAME) creates a FITS file.  An error will be
%   returned if the specified file already exists, unless the filename is
%   prefixed with an exclamation point (!). In that case CFITSIO will
%   overwrite (delete) any existing file with the same name.
%
%   This function corresponds to the "fits_create_file" (ffinit) function in 
%   the CFITSIO library C API.
%
%   Example:  Create a new FITS file.
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       fits.createImg(fptr,'uint8',[256 512]);
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits');
%
%   See also fits, openFile, closeFile, createImg, createTbl.

%   Copyright 2011-2016 The MathWorks, Inc.

validateattributes(filename,{'char'},{'row','nonempty'},'','FILENAME');

% Append the ".fits" extension if necessary.
[path,name,ext] = fileparts(filename);
if isempty(ext)
    filename = [path filesep() name '.fits'];
end

fptr = fitsiolib('create_file',filename);
