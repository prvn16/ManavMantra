function [rowlen,nrows,ttype,tbcol,tform,tunit,extname] = readATblHdr(fptr)
%readATblHdr read header information from current ASCII table
%   [ROWLEN,NROWS,TTYPE,TBCOL,TFORM,TUNIT,EXTNAME] = readATblHdr(fptr) reads
%   header information for the current ASCII table.
%
%   This function corresponds to the "fits_read_atblhdrll" (ffghtbll) 
%   function in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movAbsHDU(fptr,5);
%       [rowlen,nrows,ttype,tbcol,tform,tunit,extname] = fits.readATblHdr(fptr);
%       fits.closeFile(fptr);
%
%   See also fits, fits.readBTblHdr.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');

[rowlen,nrows,ttype,tbcol,tform,tunit,extname] = fitsiolib('read_atblhdr',fptr);
