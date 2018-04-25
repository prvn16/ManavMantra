function createImg(fptr,bitpix,naxes)
%createImg create FITS image
%   createImg(FPTR,BITPIX,NAXES) creates a new primary image or image
%   extension with a specified datatype BITPIX and size NAXES.  If the FITS
%   file is currently empty then a primary array is created, otherwise a 
%   new image extension is appended to the file.
%
%   The first two elements of NAXES correspond to the NAXIS2 and NAXIS1 
%   keywords, while any additional elements correspond to the NAXIS3, 
%   NAXIS4 ... NAXISn keywords.
%
%   The datatype BITPIX may be given as either a CFITSIO name or as the
%   corresponding MATLAB datatype.
%
%       'byte_img'     - 'uint8'
%       'short_img'    - 'int16'
%       'long_img'     - 'int32'
%       'longlong_img' - 'int64'
%       'float_img'    - 'single'
%       'double_img'   - 'double'
%
%   This function corresponds to the "fits_create_imgll" (ffcrimll) 
%   function in the CFITSIO library C API.
%
%   Example:  Create two images in a new FITS file.  There will 100 rows
%   (NAXIS2 keyword) and 200 columns (NAXIS1 keyword) in the first image,
%   and 256 rows (NAXIS2 keyword), 512 columns (NAXIS1 keyword), and 3 
%   planes (NAXIS3 keyword) in the second image.
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       fits.createImg(fptr,'int16',[100 200]);
%       fits.createImg(fptr,'byte_img',[256 512 3]);
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits');
%
%   See also fits, insertImg, createTbl, readImg, writeImg,
%   setCompressionType.

%   Copyright 2011-2014 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');

validateattributes(bitpix,{'char'},{'nonempty'},'','BITPIX');
bitpix = validatestring(bitpix,{'BYTE_IMG','UINT8','SHORT_IMG','INT16','LONG_IMG','INT32','LONGLONG_IMG','INT64','FLOAT_IMG','SINGLE','DOUBLE_IMG','DOUBLE'});
switch bitpix
    case 'UINT8'
        bitpix = 'BYTE_IMG';
    case 'INT16'
        bitpix = 'SHORT_IMG';
    case 'INT32'
        bitpix = 'LONG_IMG';
    case 'INT64'
        bitpix = 'LONGLONG_IMG';
    case 'SINGLE'
        bitpix = 'FLOAT_IMG';
    case 'DOUBLE';
        bitpix = 'DOUBLE_IMG';
end
bitpix = matlab.io.fits.getConstantValue(bitpix);

if isempty(naxes)
    validateattributes(naxes,{'double'},{},'','NAXES');
else
    validateattributes(naxes,{'double'},{'row','positive','integer'},'','NAXES');
end

% Permute the order of the dimensions accordingly.
switch(numel(naxes))
    case {0, 1}
        % do nothing
    case 2
        naxes = fliplr(naxes);
    otherwise
        naxes = [naxes(2) naxes(1) naxes(3:end)];
end
fitsiolib('create_img',fptr,bitpix,naxes);
