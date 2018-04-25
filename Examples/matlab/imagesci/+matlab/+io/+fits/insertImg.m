function insertImg(fptr,bitpix,naxes)
%insertImg insert FITS image just after current image.
%   insertImage(FPTR,BITPIX,NAXES) inserts a new image extension immediately 
%   following the current HDU.  If the file has just been created, a new 
%   primary array is inserted at the beginning of the file.  Any following 
%   extensions in the file will be shifted down to make room for the new 
%   extension. If the current HDU is the last HDU in the file then the new 
%   image extension will simply be appended to the end of the file. 
%
%   This function corresponds to the "fits_insert_imgll" (ffiimgll) function 
%   in the CFITSIO library C API.
%
%   Example:  Create an 150x300 image between the 1st and 2nd images in a
%   FITS file.
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       fits.createImg(fptr,'byte_img',[100 200]);
%       fits.createImg(fptr,'byte_img',[200 400]);
%       fits.movAbsHDU(fptr,1);
%       fits.insertImg(fptr,'byte_img',[150 300]);
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','mode','min');
%
%   See also fits, createImg.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(bitpix,{'char'},{'nonempty'},'','BITPIX');
bitpix = validatestring(bitpix,{'BYTE_IMG','SHORT_IMG','LONG_IMG','LONGLONG_IMG','FLOAT_IMG','DOUBLE_IMG'});
bitpix = matlab.io.fits.getConstantValue(bitpix);

validateattributes(naxes,{'double'},{'row','positive'},'','NAXES');

% Permute the order of the dimensions accordingly.
switch(numel(naxes))
    case 1
        % do nothing
    case 2
        naxes = fliplr(naxes);
    otherwise
        naxes = [naxes(2) naxes(1) naxes(3:end)];
end
fitsiolib('insert_img',fptr,bitpix,naxes);
