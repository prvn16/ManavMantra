function name = fileName(fptr)
%fileName return name of FITS file
%   NAME = fileName(FPTR) return the name of the FITS file associated with
%   the file handle.
%
%   This function corresponds to the "fits_file_name" (ffflnm) function in 
%   the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits','READONLY');
%       name = fits.fileName(fptr);
%       fits.closeFile(fptr);
%
%   See also fits, createFile, openFile.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');

name = fitsiolib('file_name',fptr);
