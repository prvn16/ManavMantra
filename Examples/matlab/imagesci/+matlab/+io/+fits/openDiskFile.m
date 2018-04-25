function fptr = openDiskFile(filename, mode)
%openDiskFile Open FITS file.
%   FPTR = openDiskFile(FILENAME) opens a existing FITS file in read-only mode 
%   and returns a file pointer FPTR, which will reference the primary
%   array (first header data unit, or "HDU").
%
%   FPTR = openDiskFile(FILENAME,MODE) opens a existing FITS file according to
%   the MODE, which describes the type of access.  MODE may be either
%   'READONLY' or 'READWRITE'.
%
%   This function corresponds to the "fits_open_diskfile" (ffdkopen) function in 
%   the CFITSIO library C API.

%   The openDiskFile routine is similar to the openFile routine except that
%   it does not support the extended filename syntax in the input file
%   name.  This routine simply tries to open the specified input file on
%   magnetic disk.  This routine is mainly for use in cases where the
%   filename (or directory path) contains square or curly bracket
%   characters that would confuse the extended filename parser.
%
%   Example:  Open a file in read-only mode and read image data from the
%   primary array.
%       import matlab.io.*
%       fptr = fits.openDiskFile('tst0012.fits');
%       imagedata = fits.readImg(fptr);
%       fits.closeFile(fptr);
%
%   See also fits, openFile, createFile, closeFile.

%   Copyright 2017 The MathWorks, Inc.

if nargin < 2
    mode = 'READONLY';
end

validateattributes(filename,{'char'},{'nonempty'},'openDiskFile','FILENAME');
validateattributes(mode,    {'char'},{'nonempty'},'openDiskFile','MODE');

mode = validatestring(mode,{'readonly','readwrite'});


% Get the full path name if it's on the path.
fid = fopen(filename,'r');
if fid == -1
    % Check if the filename is specified using the extended syntax.
    % Currently openDiskFile does not support the extended file name
    % syntax. However, as this library behave can change, do not take any
    % action here but pass the fully resolved name to the library.
    try
        filename = matlab.io.fits.internal.resolveExtendedFileName(filename);
    catch ME
        throwAsCaller(ME);
    end
else
    filename = fopen(fid);
    fclose(fid);
end

switch(mode)
    case 'readonly'
        mode = matlab.io.fits.getConstantValue('READONLY');

    case 'readwrite'
        mode = matlab.io.fits.getConstantValue('READWRITE');

end


fptr = fitsiolib('open_diskfile',filename,mode);

