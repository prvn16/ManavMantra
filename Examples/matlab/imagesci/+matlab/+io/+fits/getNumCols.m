function ncols = getNumCols(fptr)
%getNumCols get number of columns in table.
%   ncols = getNumCols(FPTR) gets the number of columns in the current 
%   FITS table.
%       
%   This function corresponds to the "fits_get_num_cols" (ffgncl) function in the
%   CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movAbsHDU(fptr,2);
%       ncols = fits.getNumCols(fptr);
%       nrows = fits.getNumRows(fptr);
%       fits.closeFile(fptr);
%
%   See also fits, getNumRows.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
ncols = fitsiolib('get_num_cols',fptr);
