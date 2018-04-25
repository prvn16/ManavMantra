function closeFile(fptr)
%closeFile Close FITS file.
%   closeFile(FPTR) closes an open FITS file.
%
%   This function corresponds to the "fits_close_file" (ffclos) function in 
%   the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits','READONLY');
%       fits.closeFile(fptr);
%
%   See also fits, createFile, openFile.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');

fitsiolib('close_file',fptr);
