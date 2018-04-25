function movNamHDU(fptr,hdutype,extname,extver)
%moveNamHDU move to first HDU having specific type, and keyword values
%   movNamHDU(FPTR,HDUTYPE,EXTNAME,EXTVER) moves to the first HDU which has
%   the specified extension type and EXTNAME and EXTVER keyword values (or
%   HDUNAME and HDUVER keywords).  
%
%   The hdutype parameter may have a value of 
%
%      'IMAGE_HDU' 
%      'ASCII_TBL' 
%      'BINARY_TBL' 
%      'ANY_HDU' 
%
%   If HDUTYPE is 'ANY_HDU', only the extname and extver values will be 
%   used to locate the correct extension. If the input value of EXTVER is 0 
%   then the EXTVER keyword is ignored and the first HDU with a matching 
%   EXTNAME (or HDUNAME) keyword will be found. 
%
%   This function corresponds to the "fits_movnam_hdu" (ffmnhd) function in 
%   the CFITSIO library C API.
%
%   Example:  
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movNamHDU(fptr,'IMAGE_HDU','quality',1);
%       fits.closeFile(fptr);
%
%   See also fits, movAbsHDU,  movRelHDU.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');

validateattributes(hdutype,{'char'},{'nonempty'},'','HDUTYPE');
hdutype = validatestring(hdutype,{'IMAGE_HDU','ASCII_TBL','BINARY_TBL','ANY_HDU'});
hdutype = fitsiolib('get_constant_value',hdutype);

validateattributes(extname,{'char'},{'nonempty'},'','EXTNAME');
validateattributes(extver,{'double'},{'scalar','integer','nonnegative'},'','EXTVER');

fitsiolib('movnam_hdu',fptr,hdutype,extname,extver);
