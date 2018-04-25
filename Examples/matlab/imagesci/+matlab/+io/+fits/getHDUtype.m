function htype = getHDUtype(fptr)
%getHDUtype return type of current HDU
%   HTYPE = getHDUtype(FPTR) returns the type of the current HDU in the FITS 
%   file. The possible values for HTYPE are: 
%
%       'IMAGE_HDU' 
%       'ASCII_TBL'
%       'BINARY_TBL'
%
%   This function corresponds to the "fits_get_hdu_type" (ffghdt) function 
%   in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       n = fits.getNumHDUs(fptr);
%       for j = 1:n
%           fits.getHDUtype(fptr);
%       end
%       fits.closeFile(fptr);
%
%   See also fits, getHDUnum

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');

htype = fitsiolib('get_hdu_type',fptr);
