function bool = isCompressedImg(fptr)
%isCompressedImg determine if current image is compressed
%   TF = isCompressedImg(FPTR) returns true if the image in the current 
%   HDU is compressed.  
%
%   This function corresponds to the "fits_is_compressed_image" function 
%   in the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       bool = fits.isCompressedImg(fptr);
%       fits.closeFile(fptr);
%
%   See also fits, setCompressionType.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
bool = fitsiolib('is_compressed_image',fptr);
