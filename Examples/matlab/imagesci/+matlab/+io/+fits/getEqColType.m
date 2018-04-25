function [dtype,repeat,width] = getEqColType(fptr,colnum)
%getEqColType returns column datatype, repeat value, and width in bytes
%   [DTYPE,REPEAT,WIDTH] = getEqColType(FPTR,COLNUM) returns the equivalent
%   data type needed to store the scaled column datatype, the vector repeat
%   value, and the width in bytes of a column in an ASCII or binary table.
%
%   This function corresponds to the "fits_get_eqcoltypell" (ffeqtyll) 
%   function in the CFITSIO library C API.
%
%   Example:  Get information about the 'FLUX' column in the 2nd HDU.
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movAbsHDU(fptr,2);
%       [dtype,repeat,width] = fits.getEqColType(fptr,5);
%       fits.closeFile(fptr);
%
%   See also fits, getColType.

%   Copyright 2011-2017 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','fptr');
validateattributes(colnum,{'double'},{'scalar'},'','colnum');

[dtype,repeat,width] = fitsiolib('get_eqcoltype',fptr,colnum);

