function mode = fileMode(fptr)
%fileMode return I/O mode of FITS file
%   MODE = fileMode(FPTR) returns the I/O mode of the opened FITS file.  
%   Possible values returned for MODE are 'READONLY' or 'READWRITE'.
%
%   This function corresponds to the "fits_file_mode" (ffflmd) function in 
%   the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       mode = fits.fileMode(fptr);
%       fits.closeFile(fptr);
%
%   See also fits, createFile, openFile.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','fptr');
mode = fitsiolib('file_mode',fptr);
