function setBscale(fptr,bscale,bzero)
%setBscale reset image scaling
%   setBscale(FPTR,BSCALE,BZERO) resets the scaling factors in the primary 
%   array or image extension according to the equation
%
%       output = (FITS array) * BSCALE + BZERO  
%
%   The inverse formula is used when writing data values to the FITS file. 
%
%   This only affects the automatic scaling performed when the data 
%   elements are read, it does not change the BSCALE and BZERO keyword 
%   values. 
%
%   Example:  
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.setBscale(fptr,2.0,0.5);
%       data = fits.readImg(fptr);
%       fits.closeFile(fptr);
%
%   See also fits, readImg.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(bscale,{'double'},{'scalar'},'','BSCALE');
validateattributes(bzero,{'double'},{'scalar'},'','BZERO');

fitsiolib('set_bscale',fptr,bscale,bzero);
