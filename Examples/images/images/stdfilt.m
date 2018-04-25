function J = stdfilt(varargin)
%STDFILT Local standard deviation of image.
%   J = STDFILT(I) returns the array J, where each output pixel contains
%   the standard deviation value of the 3-by-3 neighborhood around the
%   corresponding pixel in the input image I. I can have any dimension.
%   The output image J is the same size as the input image I.
%
%   For pixels on the borders of I, STDFILT uses symmetric padding.  In
%   symmetric padding, the values of padding pixels are a mirror reflection
%   of the border pixels in I.
%
%   J = STDFILT(I,NHOOD) performs standard deviation filtering of the input
%   image I where you specify the neighborhood in NHOOD.  NHOOD is a
%   multidimensional array of zeros and ones where the nonzero elements
%   specify the neighbors.  NHOOD's size must be odd in each dimension.
%
%   By default, STDFILT uses the neighborhood ones(3). STDFILT determines
%   the center element of the neighborhood by FLOOR((SIZE(NHOOD) + 1)/2).
%   For information about specifying neighborhoods, see Notes.
%
%   Class Support
%   -------------
%   I can be logical or numeric and must be real and nonsparse.  NHOOD can
%   be logical or numeric and must contain zeros and/or ones.  I and NHOOD
%   can have any dimension. J is double.
%
%   Notes
%   -----
%   1. To specify the neighborhoods of various shapes, such as a disk, use
%      the STREL function to create a structuring element object and then 
%      use the Neighborhood property to extract the neighborhood from the 
%      structuring element object.
%
%   2. If the image contains Infs or NaNs, the behavior of stdfilt is
%      undefined. Propagation of Infs or NaNs may not be localized to the
%      neighborhood around the Inf/NaN pixel.
%
%   Examples
%   --------
%       I = imread('circuit.tif');
%       J = stdfilt(I);
%       imshow(I);
%       figure, imshow(J,[]);
%
%   See also STD2, RANGEFILT, ENTROPYFILT, STREL.

%   Copyright 1993-2015 The MathWorks, Inc.


narginchk(1,2);

validateattributes(varargin{1},{'numeric','logical'},{'real','nonsparse'}, ...
    mfilename, 'I',1);
I = varargin{1};

if nargin == 2
    validateattributes(varargin{2},{'logical','numeric'},{'nonsparse'}, ...
        mfilename,'NHOOD',2);
    h = varargin{2};
    
    
    % h must contain zeros and/or ones.
    bad_elements = (h ~= 0) & (h ~= 1);
    if any(bad_elements(:))
        error(message('images:stdfilt:invalidNeighborhoodValue'))
    end
    
    % h's size must be a factor of 2n-1 (odd).
    sizeH = size(h);
    if ~all(rem(sizeH,2))
        error(message('images:stdfilt:invalidNeighborhoodSize'))
    end
    
    if ~isa(h,'double')
        h = double(h);
    end
    
else
    h = ones(3);
end

isBoxKernel = all(h(:));
isIntegralFilterFaster = useIntegralFilter(I,size(h));

if (~isa(I,'double'))
    I = double(I);
end

% Use box filtering if kernel is a box filter and is 2-D or 3-D.
if isBoxKernel && isIntegralFilterFaster
    J = images.internal.algstdboxfilt(I, size(h));
else
    J = images.internal.algstdfilt(I, h);
end

end


function TF = useIntegralFilter(I, hsize)
%useIntegralFilter Determine whether integral box filtering should be used.

dim = numel(hsize);
if dim==2
    TF = prod(hsize)>images.internal.getBoxFilterThreshold();
elseif dim==3 && ndims(I)<=3
    TF = true;
else
    TF = false;
end
end