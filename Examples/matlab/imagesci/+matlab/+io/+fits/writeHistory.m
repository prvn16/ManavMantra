function writeHistory(fptr,history)
%writeHistory write or append HISTORY keyword to CHU
%   writeHistory(FPTR,HISTORY) writes (appends) a HISTORY keyword to 
%   the CHU. The history string will be continued over multiple keywords if 
%   it is longer than 70 characters.
%
%   This function corresponds to the "fits_write_history" (ffphis) function 
%   in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       fits.createImg(fptr,'byte_img',[100 200]);
%       fits.writeHistory(fptr,'this is a history keyword');
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','mode','full');
%
%   See also fits, writeComment, writeDate.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(history,{'char'},{'nonempty'},'','HISTORY');

fitsiolib('write_history',fptr,history);
