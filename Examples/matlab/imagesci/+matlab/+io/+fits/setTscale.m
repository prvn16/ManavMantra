function setTscale(fptr,colnum,tscale,tzero)
%setTscale reset image scaling
%   setTscale(FPTR,COLNUM,TSCALE,TZERO) resets the scaling factors for a table
%   column according to the equation 
%
%       output = (FITS array) * TSCALE + TZERO  
%
%   The inverse formula is used when writing data values to the FITS file. 
%
%   This only affects the automatic scaling performed when the data 
%   elements are read, it does not change the TSCALE and TZERO keyword 
%   values. 
%
%   Example:  Turn off automatic scaling in a table column where the TSCALE
%   and TZERO keywords are present.
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movAbsHDU(fptr,2);
%       scaled_data = fits.readCol(fptr,3);
%       fits.setTscale(fptr,3,1.0,0.0);
%       unscaled_data = fits.readCol(fptr,3);
%       fits.closeFile(fptr);
%
%   See also fits, readImg.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(colnum,{'double'},{'scalar','integer','positive'},'','COLNUM');
validateattributes(tscale,{'double'},{'scalar'},'','TSCALE');
validateattributes(tzero,{'double'},{'scalar'},'','TZERO');

fitsiolib('set_tscale',fptr,colnum,tscale,tzero);

