function htype = movAbsHDU(fptr,hdunum)
%moveAbsHDU Move to specified absolute HDU number.
%   HTYPE = fits.movAbsHDU(FPTR,HDUNUM) moves to a specified absolute HDU 
%   number (starting with 1 for the primary array) in the FITS file.  The 
%   possible values for HTYPE are: 
%
%       'IMAGE_HDU' 
%       'ASCII_TBL'
%       'BINARY_TBL'
%
%   This function corresponds to the "fits_move_abs_hdu" function in the 
%   CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       n = fits.getNumHDUs(fptr);
%       for j = 1:n
%           htype = fits.movAbsHDU(fptr,j);
%           fprintf('HDU %d:  "%s"\n', j, htype);
%       end
%       fits.closeFile(fptr);
%
%   See also fits, getNumHDUs, movRelHDU, movNamHDU.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'movAbsHDU','FPTR');
validateattributes(hdunum,{'double'},{'integer','scalar'},'movAbsHDU','HDUNUM');

htype = fitsiolib('movabs_hdu',fptr,hdunum);
