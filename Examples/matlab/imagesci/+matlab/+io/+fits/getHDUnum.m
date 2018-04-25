function n = getHDUnum(fptr)
%getHDUnum return number of current HDU in FITS file
%   N = getHDUnum(FPTR) returns the number of the current HDU in the FITS
%   file.  The primary array has HDU number 1.
%
%   This function corresponds to the "fits_get_hdu_num" (ffghdn) function 
%   in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       n = fits.getHDUnum(fptr);
%       fits.closeFile(fptr);
%
%   See also fits, getNumHDUs, getHDUtype.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');

n = fitsiolib('get_hdu_num',fptr);
