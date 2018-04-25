function BW = im2bw(varargin)
%IM2BW Convert image to binary image by thresholding.
%   IM2BW is not recommended. Use IMBINARIZE instead.
%
%   IM2BW produces binary images from indexed, intensity, or RGB images. To do
%   this, it converts the input image to grayscale format (if it is not already
%   an intensity image), and then converts this grayscale image to binary by
%   thresholding. The output binary image BW has values of 1 (white) for all
%   pixels in the input image with luminance greater than LEVEL and 0 (black)
%   for all other pixels. (Note that you specify LEVEL in the range [0,1], 
%   regardless of the class of the input image.)
%  
%   BW = IM2BW(I,LEVEL) converts the intensity image I to black and white.
%
%   BW = IM2BW(X,MAP,LEVEL) converts the indexed image X with colormap MAP to
%   black and white.
%
%   BW = IM2BW(RGB,LEVEL) converts the RGB image RGB to black and white.
%
%   Note that the function GRAYTHRESH can be used to compute LEVEL
%   automatically.
%
%   Class Support 
%   ------------- 
%   The input image can be uint8, uint16, single, int16, or double and it
%   must be nonsparse. The output image BW is logical. I and X must be 2-D.
%   RGB images are M-by-N-by-3.

%
%   Example
%   -------
%   load trees
%   BW = im2bw(X,map,0.4);
%   figure, imshow(X,map), figure, imshow(BW)
%
%   See also IMBINARIZE, GRAYTHRESH, OTSUTHRESH, ADAPTTHRESH, IND2GRAY,
%   RGB2GRAY.

%   Copyright 1992-2016 The MathWorks, Inc.

[A,map,level] = parse_inputs(varargin{:});

if ndims(A)==3,% RGB is given
  A = rgb2gray(A);
elseif ~isempty(map),% indexed image is given
  A = ind2gray(A,map);
end % nothing to do for intensity image

range = getrangefromclass(A);

if isinteger(A)
  BWp = (A > range(2) *level);

elseif islogical(A)
  %A is already a binary image and does not require thresholding
  warning(message('images:im2bw:binaryInput'))
  BWp = A;
else % double or single
  BWp = (A > level);
end
  
% Output:
if nargout==0 % Show results
  imshow(BWp);
  return;
end
BW = BWp;

%-----------------------------------------------------------------------------
function [A,map,level] = parse_inputs(varargin)

% A       the input RGB (3D), intensity (2D), or indexed (X) image
% map     colormap (:,3)
% level   threshold luminance level


map = [];
level = 0.5;

narginchk(1,3);

validateattributes(varargin{1},...
              {'single','uint8','uint16','int16','logical','double'}, ...
              {'real', 'nonsparse'},mfilename,'I, X or RGB',1);

switch nargin
 case 1 %                          im2bw(RGB) | im2bw(I)
  A = varargin{1};
 case 2
  A = varargin{1};%               im2bw(RGB,level) | im2bw(I,level)
  level = varargin{2};%           im2bw(X,MAP)
 case 3 %                         im2bw(X,MAP,level)
  A = varargin{1};
  map = varargin{2};
  level = varargin{3};
end

% Check validity of the input parameters 
if (ndims(A)==3) && (size(A,3)~=3)   % check RGB image array
    error(message('images:im2bw:trueColorRgbImageMustBeMbyNby3'))
end

if (nargin==2) && ismatrix(A) && (size(level,2)==3) % it is a colormap
  map = level;% and we assume that image given is an indexed image X
  level = 0.5;
end

if ~isempty(map) % check colormap if given
  if (size(map,2) ~= 3) || (ndims(map) > 2) %#ok<ISMAT>
    error(message('images:im2bw:inColormapMustBe2Dwith3Cols'))
    
  elseif (min(map(:))<0) || (max(map(:))>1)
    error(message('images:im2bw:colormapValsMustBe0to1'))
  end
end

if (numel(level)~=1) || (max(level(:))>1) || (min(level(:))<0)
  error(message('images:im2bw:outOfRangeThreshLuminanceLevel'))
end

validateattributes(level,{'numeric'},{'real','scalar'},mfilename,'level');
level = double(level);

% Convert int16 image to uint16.
if isa(A,'int16')
  A = int16touint16mex(A);
end
