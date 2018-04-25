function [nkeys,morekeys] = getHdrSpace(fptr)
%getHdrSpace Return number of keywords in header.
%   [NKEYS,MOREKEYS] = fits.getHdrSpace(FPTR) Return the number of existing 
%   keywords (not counting the END keyword) and the amount of space 
%   currently available for more keywords. It returns MOREKYES = -1 if the 
%   header has not yet been closed. Note that the CFITSIO library will 
%   dynamically add space if required when writing new keywords to a header 
%   so in practice there is no limit to the number of keywords that can be 
%   added to a header.  
%
%   This function corresponds to the "fits_get_hdrspace" (ffghsp) function 
%   in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       [nkeys,morekeys] = fits.getHdrSpace(fptr);
%       fits.closeFile(fptr);
%
%   See also fits.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
[nkeys,morekeys] = fitsiolib('get_hdrspace',fptr);
