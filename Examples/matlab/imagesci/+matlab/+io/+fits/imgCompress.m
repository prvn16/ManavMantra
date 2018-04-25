function imgCompress(infptr,outfptr)
%imgCompress compress HDU from one file into another
%   imgCompress initializes the output HDU, copies all the keywords, and
%   loops through the input image, compressing the data and writing the 
%   compressed data to the output HDU.
%
%   This function corresponds to the "fits_img_compress" function in the
%   CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       infptr = fits.openFile('tst0012.fits');
%       outfptr = fits.createFile('myfile.fits');
%       fits.setCompressionType(outfptr,'rice');
%       fits.imgCompress(infptr,outfptr);
%       fits.closeFile(infptr);
%       fits.closeFile(outfptr);
%
%   See also fits, setCompressionType.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(infptr,{'uint64'},{'scalar'},'','INFPTR');
validateattributes(outfptr,{'uint64'},{'scalar'},'','OUTFPTR');
fitsiolib('img_compress',infptr,outfptr);
