function cornerness = cornermetric(varargin)
%CORNERMETRIC Create corner metric matrix from image.
%
%   CORNERMETRIC is not recommended. Use detectHarrisFeatures or 
%   detectMinEigenFeatures and the cornerPoints class in
%   Computer Vision System Toolbox instead.
%
%   C = CORNERMETRIC(I) generates a corner metric matrix for the grayscale
%   or logical image I. The corner metric, C, is used to detect corner
%   features in I and is the same size as I. Larger values in C correspond
%   to pixels in I with a higher likelihood of being a corner feature.
%
%   C = CORNERMETRIC(I,METHOD) generates a corner metric matrix for the
%   grayscale or logical image I using the specified METHOD.  Supported
%   METHOD's are:
%
%      'Harris'            : The Harris corner detector. This is the
%                            default METHOD.
%      'MinimumEigenvalue' : Shi & Tomasi's minimum eigenvalue method.
%
%   C = CORNERMETRIC(...,PARAM1,VAL1,PARAM2,VAL2,...) generates a corner
%   metric matrix for I, specifying parameters and corresponding values
%   that control various aspects of the corner metric calculation
%   algorithm.
%
%   Parameters include:
%   -------------------
%
%   'FilterCoefficients'     A vector, V, of filter coefficients for the
%                            separable smoothing filter. The full filter
%                            kernel is given by the outer product, V*V'.
%                            The length of the vector must be odd and at
%                            least 3.
%
%                            Default value: fspecial('gaussian',[5 1],1.5)
%
%   'SensitivityFactor'      A scalar k, 0 < k < 0.25, specifying the
%                            sensitivity factor used in the Harris
%                            detection algorithm. The smaller the value
%                            of k the more likely the algorithm is to
%                            detect sharp corners. This parameter is only
%                            valid with the 'Harris' method.
%
%                            Default value: 0.04
%
%   Example
%   -------
%   Find corner features in pout.tif image
%
%       % compute cornerness
%       I = imread('pout.tif');
%       I = I(1:150,1:120);
%       subplot(1,3,1);
%       imshow(I);
%       title('Original Image');
%       C = cornermetric(I);
%
%       % adjust corner metric for viewing
%       C_adjusted = imadjust(C);
%       subplot(1,3,2);
%       imshow(C_adjusted);
%       title('Corner Metric');
%
%       % find & display some corner features
%       corner_peaks = imregionalmax(C);
%       corner_idx = find(corner_peaks == true);
%       [r g b] = deal(I);
%       r(corner_idx) = 255;
%       g(corner_idx) = 255;
%       b(corner_idx) = 0;
%       RGB = cat(3,r,g,b);
%       subplot(1,3,3);
%       imshow(RGB);
%       title('Corner Points');
%
%   See also CORNER, EDGE.

%   Copyright 2008-2017 The MathWorks, Inc.

%   References
%   ----------
%   [1] C. Harris and M. Stephens. "A Combined Corner and Edge Detector."
%       Proceedings of the 4th Alvey Vision Conference. August 1988, pp.
%       147-151.
%   [2] J. Shi and C. Tomasi. "Good Features to Track." Proceedings of the
%       IEEE Conference on Computer Vision and Pattern Recognition. June
%       1994, pp. 593-600.

% parse inputs
args = matlab.images.internal.stringToChar(varargin);
[I,method,sensitivity_factor,filter_coef] = parseInputs(args{:});

% convert to double data to normalize results
I = convertToDouble(I);

% reshape coefficients and generate filter
filter_coef = filter_coef(:);
w = filter_coef * filter_coef';

% here is the original math.  it's optimized below to reduce memory usage
% dx = imfilter(I,[-1 0 1],'replicate','same','conv');
% dy = imfilter(I,[-1 0 1]','replicate','same','conv');
% A = dx .* dx;
% B = dy .* dy;
% C = dx .* dy;

% compute gradients
A = imfilter(I,[-1 0 1] ,'replicate','same','conv');
B = imfilter(I,[-1 0 1]','replicate','same','conv');

% only use valid gradients
A = A(2:end-1,2:end-1);
B = B(2:end-1,2:end-1);

% compute A, B, and C
C = A .* B;
A = A .* A;
B = B .* B;

% filter A, B, and C
A = imfilter(A,w,'replicate','full','conv');
B = imfilter(B,w,'replicate','full','conv');
C = imfilter(C,w,'replicate','full','conv');

% clip to image size
removed = (numel(filter_coef)-1) / 2 - 1;
A = A(removed+1:end-removed,removed+1:end-removed);
B = B(removed+1:end-removed,removed+1:end-removed);
C = C(removed+1:end-removed,removed+1:end-removed);

% 'Harris'
if strcmpi(method,'Harris')
    cornerness = (A .* B) - (C .^ 2) - sensitivity_factor * ( A + B ) .^ 2;
    
% 'MinimumEigenvalue'
else
    cornerness = ((A + B) - sqrt((A - B) .^ 2 + 4 * C .^ 2)) / 2;
end


%-------------------------------------------------------------------------
function [I,method,sensitivity_factor,filter_coef] = parseInputs(varargin)

parser = commonCornerInputParser(mfilename);

% parse input
parser.parse(varargin{:});

% assign outputs
I = parser.Results.Image;
method = parser.Results.Method;
sensitivity_factor = parser.Results.SensitivityFactor;
filter_coef = parser.Results.FilterCoefficients;

% check for incompatible parameters.  if user has specified a sensitivity
% factor with method other than harris, we error.  We made the sensitivity
% factor default value a string to determine if one was specified or if the
% default was provided since we cannot get this information from the input
% parser object.
method_is_not_harris = ~strcmpi(method,'Harris');
sensitivity_factor_specified = ~ischar(sensitivity_factor);
if method_is_not_harris && sensitivity_factor_specified
    error(message('images:cornermetric:invalidParameterCombination'));
end

% convert from default strings to actual values.
if ischar(sensitivity_factor)
    sensitivity_factor = str2double(sensitivity_factor);
end

%------------------------------------
function new_im = convertToDouble(im)

if isa(im,'uint8') ||...
        isa(im,'double') ||...
        isa(im,'logical') ||...
        isa(im,'int16') ||...
        isa(im,'single') ||...
        isa(im,'uint16')
    new_im = im2double(im);
    
elseif isa(im,'uint32')
    range = getrangefromclass(im);
    new_im = double(im) / range(2);
    
elseif isa(im,'int32')
    new_im = (double(im) + 2^31) / (2^32);
    
elseif isa(im,'int8')
    new_im = (double(im) + 2^7) / (2^8);
    
end
