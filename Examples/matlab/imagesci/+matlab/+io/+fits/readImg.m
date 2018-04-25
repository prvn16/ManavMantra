function imgdata = readImg(fptr,fpixel,lpixel,inc)
%readImg Read image data.
%   IMGDATA = readImg(FPTR) reads the entire current image.  The number
%   of rows in IMGDATA will correspond to the value of the NAXIS2 keyword,
%   while the number of columns will correspond to the value of the NAXIS1
%   keyword.  Any further dimensions of IMDATA will correspond to NAXIS3,
%   NAXIS4, and so on.
%
%   IMGDATA = readImg(FPTR,FPIXEL,LPIXEL) reads the subimage 
%   defined by pixel coordinates FPIXEL and LPIXEL.  FPIXEL is the 
%   coordinate of the first pixel and LPIXEL is the coordinate of the last 
%   pixel.  FPIXEL and LPIXEL are one-based. 
%
%   IMGDATA = fits.readImg(FPTR,FPIXEL,LPIXEL,INC) reads the 
%   subimage defined by FPIXEL, LPIXEL, and INC.  INC denotes the inter-
%   element spacing along each extent.
%
%   This function corresponds to the "fits_read_subset" (ffgsv) function in 
%   the CFITSIO library C API.
%
%   Example:  Read an entire image.
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       data = fits.readImg(fptr);
%       fits.closeFile(fptr);
%
%   Example:  Read an 70x80 image subset.
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       img = fits.readImg(fptr,[11 11],[80 90]);
%       fits.closeFile(fptr);
%
%   See also fits, createImg, writeImg.

%   Copyright 2011-2014 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');

sz = matlab.io.fits.getImgSize(fptr);
if isempty(sz)
    imgdata = [];
    return
end

switch(nargin)
	case 1
		fpixel = ones([1 numel(sz)]);
		lpixel = sz;
		inc = ones([1 numel(sz)]);

	case 2
		error(message('MATLAB:imagesci:validate:wrongNumberOfInputs'));

	case 3
		inc = ones([1 numel(sz)]);
end

validateattributes(fpixel,{'double'},{'positive','integer','size',[1 numel(sz)]},'','FPIXEL');
validateattributes(lpixel,{'double'},{'positive','integer','size',[1 numel(sz)]},'','LPIXEL');
validateattributes(inc,   {'double'},{'positive','integer','size',[1 numel(sz)]},'','INC');

if any(fpixel > sz)
    error(message('MATLAB:imagesci:fits:invalidIndex','FPIXEL'));
end
if any(lpixel > sz)
    error(message('MATLAB:imagesci:fits:invalidIndex','LPIXEL'));
end

% FPIXEL cannot exceed LPIXEL.
validateattributes(lpixel-fpixel,{'double'},{'nonnegative'},'','LPIXEL-FPIXEL');

% Now flip the order of NAXIS1 and NAXIS2.
switch(numel(fpixel))
    case 1
        % Do nothing
    case 2
        fpixel = fliplr(fpixel);
        lpixel = fliplr(lpixel);
        inc = fliplr(inc);
    otherwise
        fpixel = [fpixel(2) fpixel(1) fpixel(3:end)];
        lpixel = [lpixel(2) lpixel(1) lpixel(3:end)];
        inc = [inc(2) inc(1) inc(3:end)];
end
imgdata = fitsiolib('read_subset',fptr,fpixel,lpixel,inc);

switch(numel(sz))
    case 1
        imgdata = imgdata';
    case 2
        imgdata = imgdata';
    otherwise
        pdims = [2 1 3:numel(sz)];
        imgdata = permute(imgdata,pdims);
end
