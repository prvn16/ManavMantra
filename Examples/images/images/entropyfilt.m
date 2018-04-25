function J = entropyfilt(varargin)
%ENTROPYFILT Local entropy of intensity image.
%   J = ENTROPYFILT(I) returns the array J, where each output pixel contains the
%   entropy value of the 9-by-9 neighborhood around the corresponding
%   pixel in the input image I. I can have any dimension.  If I has more than
%   two dimensions, ENTROPYFILT treats it as a multidimensional intensity
%   image and not as a truecolor image.  The output image J is
%   the same size as the input image I.
%
%   For pixels on the borders of I, ENTROPYFILT uses symmetric padding.  In
%   symmetric padding, the values of padding pixels are a mirror reflection
%   of the border pixels in I.
%  
%   J = ENTROPYFILT(I,NHOOD) performs entropy filtering of the input
%   image I where you specify the neighborhood in NHOOD.  NHOOD is a
%   multidimensional array of zeros and ones where the nonzero elements specify
%   the neighbors.  NHOOD's size must be odd in each dimension. 
%
%   By default, ENTROPYFILT uses the neighborhood true(9). ENTROPYFILT
%   determines the center element of the neighborhood by
%   FLOOR((SIZE(NHOOD)+1)/2). To specify the neighborhoods of various
%   shapes, such as a disk, use the STREL function to create a structuring
%   element object and then use the Neighborhood property to extract the
%   neighborhood from the structuring element object.
%
%   Class Support
%   -------------  
%   I can be logical, uint8, uint16, or double, and must be real and
%   nonsparse. NHOOD can be logical or numeric and must contain zeros and/or
%   ones. The output array J is double.
%
%   Notes
%   -----    
%   ENTROPYFILT converts any class other than logical to uint8 for the histogram
%   count calculation so that the pixel values are discrete and directly
%   correspond to a bin value.
%
%   Example
%   -------      
%       I = imread('circuit.tif');
%       J = entropyfilt(I);
%       imshow(I);
%       figure, imshow(J,[]);
%  
%   See also ENTROPY, RANGEFILT, STDFILT, IMHIST.

%   Copyright 1993-2015 The MathWorks, Inc.

%   Reference:
%      Gonzalez, R.C., R.E. Woods, S.L. Eddins, "Digital Image Processing
%      using MATLAB", Chapter 11.
  
[I, h] = ParseInputs(varargin{:});

% Convert to uint8 if not logical and set number of bins for the class.
if islogical(I)
  nbins = 2;
else
  I = im2uint8(I);
  nbins = 256;
end

% Capture original size before padding.
origSize = size(I);

% Pad array. 
padSize = (size(h) -1) / 2;
I = padarray(I,padSize,'symmetric','both');
newSize = size(I);

% Calculate local entropy using MEX-file.
J = entropyfiltmex(I,newSize,h,nbins); 
    
% Append zeros to padSize so that it has the same number of dimensions as the
% padded image.
ndim = ndims(I);
padSize = [padSize zeros(1,(ndim - ndims(padSize)))];

% Extract the "middle" of the result; it should be the same size as
% the input image.
idx = cell(1, ndim);
for k = 1: ndim
  s = size(J,k) - (2*padSize(k));
  first = padSize(k) + 1;
  last = first + s - 1;
  idx{k} = first:last;
end
J = J(idx{:});

if ~isequal(size(J),origSize)
  %should never get here
  error(message('images:entropyfilt:internalError'))
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [I,H] = ParseInputs(varargin)

narginchk(1,2);

validateattributes(varargin{1},{'uint8','uint16','double','single','logical'},...
              {'real', 'nonempty','nonsparse'},mfilename, 'I',1);
I = varargin{1};

if nargin == 1
  H = true(9);
  
else
  H = varargin{2};
  
  % Check H. 
  validateattributes(H,{'logical','numeric'},{'nonempty','nonsparse'},mfilename, ...
                'NHOOD',2);

  
  % H must contain zeros and or ones.
  bad_elements = (H ~= 0) & (H ~= 1);
  if any(bad_elements(:))
    error(message('images:entropyfilt:invalidNeighborhoodValue'))
  end
  
  % H's size must be odd (a factor of 2n-1).
  sizeH = size(H);
  if any(floor(sizeH/2) == (sizeH/2))
    error(message('images:entropyfilt:invalidNeighborhoodSize'))
  end

  % Convert H to a logical array.
  if ~islogical(H)
    H = H ~= 0;
  end
  
end
