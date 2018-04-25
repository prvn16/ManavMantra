function copyHDU(infptr,outfptr)
%copyHDU copy current HDU from one file to another
%   copyHDU(INFPTR,OUTFPTR) copies the current HDU from the FITS file 
%   associated with INFPTR and appends it to the end of the FITS 
%   file associated with OUTFPTR. 
%
%   This function corresponds to the "fits_copy_hdu" (ffcopy) function in 
%   the CFITSIO library C API.
%
%   Example:  Copy the first, third, and fifth HDUs from one file to 
%   another.
%       import matlab.io.*
%       infptr = fits.openFile('tst0012.fits');
%       outfptr = fits.createFile('myfile.fits');
%       fits.copyHDU(infptr,outfptr);
%       fits.movAbsHDU(infptr,3);
%       fits.copyHDU(infptr,outfptr);
%       fits.movAbsHDU(infptr,5);
%       fits.copyHDU(infptr,outfptr);
%       fits.closeFile(infptr);
%       fits.closeFile(outfptr);
%       fitsdisp('tst0012.fits','mode','min','index',[1 3 5]);
%       fitsdisp('myfile.fits','mode','min');
%
%   See also fits, deleteHDU.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(infptr,{'uint64'},{'scalar'},'','INFPTR');
validateattributes(outfptr,{'uint64'},{'scalar'},'','OUTFPTR');

fitsiolib('copy_hdu',infptr,outfptr);
