function [ttype,tbcol,tunit,tform,scale,zero,nulstr,tdisp] = getAColParms(fptr,colnum)
%getAColParms get ASCII table information
%   [TTYPE,TBCOL,TUNIT,TFORM,SCALE,ZERO,NULSTR,TDISP] = getAColParms(FPTR,COLNUM)
%   gets information about an existing ASCII table column.
%
%   This function corresponds to the "fits_get_acolparms" (fffacl) function in 
%   the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movAbsHDU(fptr,5);
%       [ttype,tbcol,tunit,tform,scale,zero,nulstr,tdisp] = fits.getAColParms(fptr,2);
%       fits.closeFile(fptr);
%
%   See also fits, getBColParms.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(colnum,{'double'},{'scalar','integer','positive'},'','COLNUM');

[ttype,tbcol,tunit,tform,scale,zero,nulstr,tdisp] = fitsiolib('get_acolparms',fptr,colnum);
