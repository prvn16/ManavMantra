function writeComment(fptr,comment)
%writeComment write or append COMMENT keyword to CHU
%   writeComment(FPTR,COMMENT) writes (appends) a COMMENT keyword to 
%   the CHU. The comment string will be continued over multiple keywords if 
%   it is longer than 70 characters.
%
%   This function corresponds to the "fits_write_comment" (ffpcom) function 
%   in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       fits.createImg(fptr,'byte_img',[100 200]);
%       fits.writeComment(fptr,'this is a comment');
%       fits.writeComment(fptr,'this is another comment');
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','mode','full');
%
%   See also fits, writeHistory, writeDate.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(comment,{'char'},{'nonempty'},'','COMMENT');

fitsiolib('write_comment',fptr,comment);
