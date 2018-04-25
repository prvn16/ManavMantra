function writeDate(fptr)
%writeDate write DATE keyword to CHU
%   writeDate(FPTR) writes the DATE keyword to the CHU.
%
%   This function corresponds to the "fits_write_date" (ffpdat) function 
%   in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       fits.createImg(fptr,'byte_img',[100 200]);
%       fits.writeDate(fptr);
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','mode','full');
%
%   See also fits, writeComment, writeHistory.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
fitsiolib('write_date',fptr);
