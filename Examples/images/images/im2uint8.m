function u = im2uint8(img, varargin) 
%IM2UINT8 Convert image to 8-bit unsigned integers.
%   IM2UINT8 takes an image as input, and returns an image of class uint8.  If
%   the input image is of class uint8, the output image is identical to it.  If
%   the input image is not uint8, IM2UINT8 returns the equivalent image of class
%   uint8, rescaling or offsetting the data as necessary.
%
%   I2 = IM2UINT8(I1) converts the intensity image I1 to uint8, rescaling the
%   data if necessary.
%
%   RGB2 = IM2UINT8(RGB1) converts the truecolor image RGB1 to uint8, rescaling
%   the data if necessary.
%
%   I = IM2UINT8(BW) converts the binary image BW to a uint8 intensity image,
%   changing one-valued elements to 255.
%
%   X2 = IM2UINT8(X1,'indexed') converts the indexed image X1 to uint8,
%   offsetting the data if necessary. Note that it is not always possible to
%   convert an indexed image to uint8. If X1 is double, then the maximum value
%   of X1 must be 256 or less.  If X1 is uint16, the maximum value of X1 must be
%   255 or less.
%
%   Class Support
%   -------------
%   Intensity and truecolor images can be uint8, uint16, double, logical,
%   single, or int16. Indexed images can be uint8, uint16, double or
%   logical. Binary input images must be logical. The output image is uint8.
%
%   Example
%   -------
%       I1 = reshape(uint16(linspace(0,65535,25)),[5 5])
%       I2 = im2uint8(I1)
%
%   See also IM2DOUBLE, IM2INT16, IM2SINGLE, IM2UINT16, UINT8.

%   Copyright 1993-2013 The MathWorks, Inc.

narginchk(1,2);

validateattributes(img,{'double','logical','uint8','uint16','single','int16'}, ...
              {'nonsparse'},mfilename,'Image',1);

if(~isreal(img))
    warning(message('images:im2uint8:ignoringImaginaryPartOfInput'));
    img = real(img);
end

if nargin == 2
  validatestring(varargin{1},{'indexed'},mfilename,'type',2);
end

if isa(img, 'uint8')
    u = img; 
    
elseif isa(img, 'logical')
    u=uint8(img);
    u(img)=255;

else %double, single, uint16, or int16
  if nargin == 1
    if isa(img, 'int16')
      img = int16touint16mex(img);
    end
  
    % intensity image; call MEX-file
    u = grayto8mex(img);
  
  else
    if isa(img, 'int16')
      error(message('images:im2uint8:invalidIndexedImage'))
    
    elseif isa(img, 'uint16')
      if (max(img(:)) > 255)
        error(message('images:im2uint8:tooManyColorsFor8bitStorage'))
      else
        u = uint8(img);
      end
    
    else %double or single
      if max(img(:)) >= 257 
        error(message('images:im2uint8:tooManyColorsFor8bitStorage'))
      elseif min(img(:)) < 1
        error(message('images:im2uint8:invalidIndexValue'))
      else
        u = uint8(img-1);
      end
    end
  end
end
