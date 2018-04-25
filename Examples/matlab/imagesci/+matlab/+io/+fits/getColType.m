function [dtype,repeat,width] = getColType(fptr,colnum)
%getColType return scaled column datatype, repeat value, and width in bytes
%   [DTYPE,REPEAT,WIDTH] = getColType(FPTR,COLNUM) returns the data type,
%   vector repeat value, and the width in bytes of a column in an ASCII or
%   binary table.
%
%   This function corresponds to the "fits_get_coltypell" (ffgtclll) 
%   function in the CFITSIO library C API.
%
%   Example:  Get information about the 'FLUX' column in the 2nd HDU.
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movAbsHDU(fptr,2);
%       [dtype,repeat,width] = fits.getColType(fptr,5);
%       fits.closeFile(fptr);
%
%   See also fits, getEqColType.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','fptr');
validateattributes(colnum,{'double'},{'scalar'},'','colnum');

[dtype,repeat,width] = fitsiolib('get_coltype',fptr,colnum);
