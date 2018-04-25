function datatype = getImgType(fptr)
%getImgType Get data type of image.
%   DATATYPE = getImgType(FPTR) gets the data type of an image.  DATATYPE
%   could be returned as one of the following strings:
%
%       'BYTE_IMG'
%       'SHORT_IMG'
%       'LONG_IMG'
%       'LONGLONG_IMG'
%       'FLOAT_IMG'
%       'DOUBLE_IMG'
%       
%   This function corresponds to the "fits_get_img_type" (ffgidt) function 
%   in the CFITSIO library C API.
%
%   Example:
%       fptr = fits.openFile('tst0012.fits');
%       hdus = [1 3 4];
%       for j = hdus;
%           htype = fits.movAbsHDU(fptr,j);
%           dtype = fits.getImgType(fptr);
%           fprintf('HDU %d:  "%s", "%s"\n', j, htype, dtype);
%       end
%       fits.closeFile(fptr);
%
%   See also fits, getImgSize.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(fptr,{'uint64'},{'scalar'},'getImgType','FPTR');
datatype = fitsiolib('get_img_type',fptr);
