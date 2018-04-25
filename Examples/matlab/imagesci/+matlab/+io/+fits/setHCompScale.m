function setHCompScale(fptr,scale)
%setHCompScale set scale parameter for HCOMPRESS algorithm
%   setHCompScale(FPTR,SCALE) sets the scale parameter to be used 
%   with the HCOMPRESS compression algorithm.  Setting the scale parameter
%   causes the algorithm to operate in lossy mode.
%
%   This function corresponds to the "fits_set_hcomp_scale" function in the
%   CFITSIO library C API.
%
%   Example:
%       import matlab.io.*
%       data = 50*ones(256,512,'double') + 10 * rand([256 512]);
%       fptr = fits.createFile('myfile.fits');
%       fits.setCompressionType(fptr,'HCOMPRESS_1');
%       fits.setHCompScale(fptr,2.5);
%       fits.createImg(fptr,'double_img',[256 512]);
%       fits.writeImg(fptr,data);
%       fits.closeFile(fptr);
%       fitsdisp('myfile.fits','mode','full');
%
%   See also fits, fits.setHCompSmooth, fits.setCompressionType.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(scale,{'double'},{'scalar'},'','SCALE');
fitsiolib('set_hcomp_scale',fptr,scale);
