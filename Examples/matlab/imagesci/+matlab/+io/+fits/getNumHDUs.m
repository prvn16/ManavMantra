function num_hdus = getNumHDUs(fptr)
%getNumHDUs Return total number of HDUs in FITS file. 
%   N = getNumHDUs(FPTR) returns the number of completely defined HDUs in 
%   a FITS file. If a new HDU has just been added to the FITS file, then 
%   that last HDU will only be counted if it has been closed, or if data 
%   has been written to the HDU. The current HDU remains unchanged by this 
%   routine.
%
%   This function corresponds to the "fits_get_num_hdus" (ffthdu) function 
%   in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       n = fits.getNumHDUs(fptr);
%       fits.closeFile(fptr);
%
%   See also fits, getHDUnum.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'getNumHDUs','FPTR');
num_hdus = fitsiolib('get_num_hdus',fptr);
