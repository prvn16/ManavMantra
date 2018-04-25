function nrows = getNumRows(fptr)
%getNumRows get number of rows in table
%   nrows = getNumRows(FPTR) gets the number of rows in the current FITS 
%   table.
%       
%   This function corresponds to the "fits_get_num_rowsll" (ffgnrwll) 
%   function in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movAbsHDU(fptr,2);
%       ncols = fits.getNumCols(fptr);
%       nrows = fits.getNumRows(fptr);
%       fits.closeFile(fptr);
%
%   See also fits, getNumCols.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
nrows = fitsiolib('get_num_rows',fptr);
