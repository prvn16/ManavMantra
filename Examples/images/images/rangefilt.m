function J = rangefilt(varargin)
%RANGEFILT Local range of image.  
%   J = RANGEFILT(I) returns the array J, where each output pixel contains the
%   range value (maximum value - minimum value) of the 3-by-3 neighborhood
%   around the corresponding pixel in the input image I. I can have any
%   dimension.  The output image J is the same size as the input image I.
%  
%   J = RANGEFILT(I,NHOOD) performs range filtering of the input image I where
%   you specify the neighborhood in NHOOD.  NHOOD is a multidimensional array
%   of zeros and ones where the nonzero elements specify the neighborhood for
%   the range filtering operation.  NHOOD's size must be odd in each dimension.
%  
%   By default, RANGEFILT uses the neighborhood true(3). RANGEFILT determines
%   the center element of the neighborhood by FLOOR((SIZE(NHOOD) + 1)/2). For
%   information about specifying neighborhoods, see Notes.
%
%   Class Support
%   -------------      
%   I can be logical or numeric and must be real and nonsparse.  NHOOD can be
%   logical or numeric and must contain zeros and/or ones.
%  
%   The output image J is the same class as I, except for signed integer data
%   types. The output class for signed integer data types is the corresponding
%   unsigned integer data type.  For example, if the class of I is int8, then
%   the class of J is uint8.
%
%   Notes
%   -----    
%   RANGEFILT uses the morphological functions IMDILATE and IMERODE to
%   determine the maximum and minimum values in the specified neighborhood.
%   Consequently, RANGEFILT uses the padding behavior of these morphological
%   functions.  
%  
%   To specify the neighborhoods of various shapes, such as a disk, use the
%   STREL function to create a structuring element object and then use the
%   Neighborhood property to extract the neighborhood from the structuring
%   element object.
%  
%   Example (2-D)
%   -------------
%       % Identify the two flying objects in liftingbody.png by measuring the
%       % local range.
%
%       I = imread('liftingbody.png');
%       J = rangefilt(I);
%       imshow(I);
%       figure, imshow(J);
%  
%   Example (3-D)
%   ------------        
%       I = imread('autumn.tif'); 
%  
%       % Convert the image to L*a*b* colorspace to separate the intensity
%       % information into a single plane of the image.
%
%       cform = makecform('srgb2lab'); 
%       LAB = applycform(I, cform); 
%  
%       % Calculate the local range in each layer to quantify land cover
%       % changes.
%
%       rLAB = rangefilt(LAB);
%       imshow(I);
%       figure, imshow(rLAB(:,:,1),[]);
%       figure, imshow(rLAB(:,:,2),[]);
%       figure, imshow(rLAB(:,:,3),[]);
%  
%   See also STDFILT, ENTROPYFILT, STREL. 

%   Copyright 1993-2015 The MathWorks, Inc.
%   

[I, h] = ParseInputs(varargin{:});

% NHOOD is reflected across its origin in order for IMDILATE
% to return the local maxima of I in NHOOD if it is asymmetric. A symmetric NHOOD
% is naturally unaffected by this reflection.
reflectH = h(:);
reflectH = flipud(reflectH);
reflectH = reshape(reflectH, size(h));

dilateI = imdilate(I,reflectH);

% IMERODE returns the local minima of I in NHOOD.
erodeI = imerode(I,h);  

% Set the output classes for signed integer data types.
class_in = class(I);
class_out = class_in;
switch class_in
 case 'int8'
  class_out = 'uint8';
 case 'int16'
  class_out = 'uint16';
 case 'int32'
  class_out = 'uint32';
end

% Calculate the range with imlincomb instead of imsubtract so that you can
% specify the output class.  Use the relational operator to calculate the
% range for a logical image to be efficient.
if strcmp(class_in, 'logical')
  J = dilateI > erodeI;
else
  J = imlincomb(1, dilateI, -1, erodeI, class_out);
end
         
%%%%%%%%%%%%%%%ParseInputs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [I,H] = ParseInputs(varargin)

narginchk(1,2);

validateattributes(varargin{1},{'numeric' 'logical'},...
              {'real','nonsparse','nonnan'}, ...
              mfilename,'I',1);
I = varargin{1};

if nargin == 2
  validateattributes(varargin{2},{'logical','numeric'},{'nonempty','nonsparse'}, ...
                mfilename,'NHOOD',2);
  H = varargin{2};
  

  % H must contain zeros and or ones.
  bad_elements = (H ~= 0) & (H ~= 1);
  if any(bad_elements(:))
    error(message('images:rangefilt:invalidNeighborhoodValue'))
  end

  % H's size must be odd.
  sizeH = size(H);
  if any(floor(sizeH/2) == (sizeH/2) )
    error(message('images:rangefilt:invalidNeighborhoodSize'))
  end
  
  % Convert to logical
  H = H ~= 0;
  
else
  H = true(3);
end
