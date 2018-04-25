function htype = movRelHDU(fptr,nmove)
%moveRelHDU move relative number of HDUs from current HDU
%   HDUTYPE = moveRelHDU(FPTR,NMOVE) moves a relative number of HDUs forward 
%   or backward from the current HDU and returns the HDU type HDUTYPE of the 
%   resulting HDU.  The possible values for HTYPE are: 
%
%       'IMAGE_HDU' 
%       'ASCII_TBL'
%       'BINARY_TBL'
%
%   This function corresponds to the "fits_movrel_hdu" (ffmrhd) function in 
%   the CFITSIO library C API.
%
%   Example:  Move through each HDU in succession, then move backwards
%   twice by two HDUs.
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       n = fits.getNumHDUs(fptr);
%       for j = 1:n
%           htype = fits.movAbsHDU(fptr,j);
%           fprintf('HDU %d:  "%s"\n', j, htype);
%       end
%       htype = fits.movRelHDU(fptr,-2);
%       n = fits.getHDUnum(fptr);
%       fprintf('HDU %d:  "%s"\n', n, htype);
%       htype = fits.movRelHDU(fptr,-2);
%       n = fits.getHDUnum(fptr);
%       fprintf('HDU %d:  "%s"\n', n, htype);
%       fits.closeFile(fptr);
%
%   See also fits, movAbsHDU,  movNamHDU.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(nmove,{'double'},{'integer','scalar'},'','NMOVE');

htype = fitsiolib('movrel_hdu',fptr,nmove);
