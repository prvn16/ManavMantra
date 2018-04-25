function imagesize = getImgSize(fptr)
%getImgSize Get size of image.
%   IMAGESIZE = getImgSize(FPTR) returns the number of rows and columns of
%   an image.
%       
%   This function corresponds to the "fits_get_img_size" (ffgisz) 
%   function in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*;
%       fptr = fits.openFile('tst0012.fits');
%       hdus = [1 3 4];
%       for j = hdus;
%           htype = fits.movAbsHDU(fptr,j);
%           sz = fits.getImgSize(fptr);
%           fprintf('HDU %d:  "%s", [', j, htype);
%           for k = 1:numel(sz)
%               fprintf(' %d ', sz(k));
%           end
%           fprintf(']\n');
%       end
%       fits.closeFile(fptr);
%
%   See also fits, createImg, getImgType.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'getImgType','FPTR');
imagesize = fitsiolib('get_img_size',fptr);

% Permute properly.
if numel(imagesize) > 1
    imagesize = [imagesize(2) imagesize(1) imagesize(3:end)];
end
