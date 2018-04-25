function [ttype,tunit,typechar,repeat,scale,zero,nulval,tdisp] = getBColParms(fptr,colnum)
%getBColParms get BINARY table information
%   [TTYPE,TUNIT,TYPECHAR,REPEAT,SCALE,ZERO,NULVAL,TDISP] = getBColParms(FPTR,COLNUM)
%   gets information about an existing BINARY table column.
%
%   This function corresponds to the "fits_get_bcolparms" (ffgbcl) function in 
%   the CFITSIO library C API.
%
%   Example:  Get information about the second column in a binary table.
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movAbsHDU(fptr,2);
%       [ttype,tunit,typechar,repeat,scale,zero,nulval,tdisp]= fits.getBColParms(fptr,2);
%       fits.closeFile(fptr);
%
%   See also fits, getAColParms.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(colnum,{'double'},{'scalar','integer','positive'},'','COLNUM');

[ttype,tunit,typechar,repeat,scale,zero,nulval,tdisp] = fitsiolib('get_bcolparms',fptr,colnum);
