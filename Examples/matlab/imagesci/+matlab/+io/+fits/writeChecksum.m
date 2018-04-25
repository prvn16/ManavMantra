function writeChecksum(fptr)
%writeChecksum compute and write checksum for current HDU
%   writeChecksum(FPTR) computes and writes the DATASUM and CHECKSUM
%   keyword values for the current HDU into the current header.  If the
%   keywords already exist, their values will be updated only if necessary
%   (i.e., if the file has been modified since the original keyword values
%   were computed).
%
%   This function corresponds to the "fits_write_chksum" (ffpcks) function 
%   in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       fits.createImg(fptr,'long_img',[10 20]);
%       fits.writeChecksum(fptr)
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','mode','full');
%
%   See also fits, fitsdisp.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','fptr');

fitsiolib('write_chksum',fptr);
