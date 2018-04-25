function writeImg(fptr,data,fpixel)
%writeImg write to FITS image
%   writeImg(FPTR,DATA) writes an entire image to the FITS data array.
%   The number of rows and columns in DATA must equal the values of the 
%   NAXIS2 and NAXIS1 keywords respectively.  Any further extents must 
%   correspond to the NAXIS3, NAXIS4 ... NAXISn keywords respectively.
%
%   writeImg(FPTR,DATA,FPIXEL) writes a subset of an image to the FITS
%   data array.  FPIXEL gives the coordinate of the first pixel in the 
%   image region.
%
%   This function corresponds to the "fits_write_subset" (ffpss) function in 
%   the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       fits.createImg(fptr,'long_img',[256 512]);
%       data = reshape(1:256*512,[256 512]);
%       data = int32(data);
%       fits.writeImg(fptr,data);
%       fits.closeFile(fptr);
%
%   Example:  create an 80x40 uint8 image and set all but the outermost
%   pixels to 1.
%       import matlab.io.*
%       fptr = fits.createFile('myfile.fits');
%       fits.createImg(fptr,'uint8',[80 40]);
%       data = ones(78,38);
%       fits.writeImg(fptr,data,[1 1]);
%       fits.closeFile(fptr);
%
%   See also fits, readImg, createImg.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
valid_datatypes = {'int8','uint8','int16','uint16','int32','uint32','int64','single','double'};
validateattributes(data,valid_datatypes,{'nonempty','real'},'','DATA');

% Figure out what kind of data we have here rather than the mex-file.
switch(class(data))
	case 'int8'
		datatype = matlab.io.fits.getConstantValue('TSBYTE');
	case 'uint8'
		datatype = matlab.io.fits.getConstantValue('TBYTE');
	case 'int16'
		datatype = matlab.io.fits.getConstantValue('TSHORT');
	case 'uint16'
		datatype = matlab.io.fits.getConstantValue('TUSHORT');
	case 'int32'
		datatype = matlab.io.fits.getConstantValue('TINT');
	case 'uint32'
		datatype = matlab.io.fits.getConstantValue('TUINT');
	case 'int64'
		datatype = matlab.io.fits.getConstantValue('TLONGLONG');
	case 'single'
		datatype = matlab.io.fits.getConstantValue('TFLOAT');
	case 'double'
		datatype = matlab.io.fits.getConstantValue('TDOUBLE');
end


sz = matlab.io.fits.getImgSize(fptr);

% Permute the data properly.
switch ( numel(sz) ) 
    case 1
        data = data';
    case 2
        data = data';
        sz = fliplr(sz);
    otherwise
        pdims = [2 1 3:numel(sz)];
        data = permute(data,pdims);
        sz = [sz(2) sz(1) sz(3:end)];
end

switch(nargin)
	case 2
		fpixel = ones(1,numel(sz));
 	    lpixel = sz;
	case 3
        fpixel = fliplr(fpixel);
        dataSize = size(data);
%         dataSize = [dataSize(2) dataSize(1) dataSize(3:end)];
		validateattributes(fpixel,{'double'},{'row','positive','integer'},'','FPIXEL');
        lpixel = fpixel + dataSize - 1;
end

if any(fpixel > sz)
    error(message('MATLAB:imagesci:fits:invalidIndex','FPIXEL'));
end
if any(lpixel > sz)
    error(message('MATLAB:imagesci:fits:invalidIndex','LPIXEL'));
end


fitsiolib('write_subset',fptr,data,datatype,fpixel,lpixel);
