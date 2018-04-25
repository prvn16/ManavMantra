function setHCompSmooth(fptr,smooth)
%setHCompSmooth set smoothing for images compressed with HCOMPRESS.
%   setHCompSmooth(FPTR,SMOOTH) sets the smoothing to be used when 
%   compressing an image with the HCOMPRESS algorithm.  Setting either the 
%   scale or smoothing parameter causes the algorithm to operate in lossy 
%   mode.
%
%   This function corresponds to the "fits_set_hcomp_smooth" function in
%   the CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       data = int32(50*ones(256,512,'double') + 10 * rand([256 512]));
%       fptr = fits.createFile('myfile.fits');
%       fits.setCompressionType(fptr,'HCOMPRESS');
%       fits.setHCompSmooth(fptr,1);
%       fits.createImg(fptr,'long_img',[256 512]);
%       fits.writeImg(fptr,data);
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','mode','full');
%
%   See also fits, setHCompScale, setCompressionType.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(smooth,{'double'},{'scalar','integer'},'','SMOOTH');
fitsiolib('set_hcomp_smooth',fptr,smooth);
