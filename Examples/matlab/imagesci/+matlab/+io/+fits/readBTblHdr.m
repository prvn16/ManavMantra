function [nrows,ttype,tform,tunit,extname,pcount] = readBTblHdr(fptr)
%readBTblHdr read header information from current binary table
%   [NROWS,TTYPE,TFORM,TUNIT,EXTNAME,PCOUNT] = readBTblHdr(fptr) reads
%   header information for the current binary table.
%
%   This function corresponds to the "fits_read_btblhdrll" (ffghbnll) 
%   function in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movAbsHDU(fptr,2);
%       [nrows,ttype,tform,tunit,extname,pcount] = fits.readBTblHdr(fptr);
%       fits.closeFile(fptr);
%
%   See also fits, fits.readATblHdr.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');

[nrows,ttype,tform,tunit,extname,pcount] = fitsiolib('read_btblhdr',fptr);
