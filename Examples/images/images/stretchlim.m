function lowhigh = stretchlim(varargin)
%STRETCHLIM Find limits to contrast stretch an image.
%   LOW_HIGH = STRETCHLIM(I,TOL) returns a pair of gray values that can be
%   used by IMADJUST to increase the contrast of an image.
%
%   TOL = [LOW_FRACT HIGH_FRACT] specifies the fraction of the image to
%   saturate at low and high pixel values.
%
%   If TOL is a scalar, TOL = LOW_FRACT, and HIGH_FRACT = 1 - LOW_FRACT,
%   which saturates equal fractions at low and high pixel values.
%
%   If you omit the argument, TOL defaults to [0.01 0.99], saturating 2%.
%
%   If TOL = 0, LOW_HIGH = [min(I(:)); max(I(:))].
%
%   LOW_HIGH = STRETCHLIM(RGB,TOL) returns a 2-by-3 matrix of pixel value
%   pairs to saturate each plane of the RGB image. TOL specifies the same
%   fractions of saturation for each plane.
%
%   Class Support
%   -------------
%   The input image can be uint8, uint16, int16, double, or single, and must
%   be real and nonsparse. The output limits are double and have values
%   between 0 and 1.
%
%   Note
%   ----
%   If TOL is too big, such that no pixels would be left after saturating
%   low and high pixel values, then STRETCHLIM returns [0; 1].
%
%   Example
%   -------
%       I = imread('pout.tif');
%       J = imadjust(I,stretchlim(I),[]);
%       figure, imshow(I), figure, imshow(J)
%
%   See also BRIGHTEN, DECORRSTRETCH, HISTEQ, IMADJUST.

%   Copyright 1999-2014 The MathWorks, Inc.

[img,tol] = ParseInputs(varargin{:});

if isa(img,'uint8')
    nbins = 256;
else
    nbins = 65536;
end

tol_low = tol(1);
tol_high = tol(2);
 
p = size(img,3);

if tol_low < tol_high
    ilowhigh = zeros(2,p);
    for i = 1:p                          % Find limits, one plane at a time
        N = imhist(img(:,:,i),nbins);
        cdf = cumsum(N)/sum(N); %cumulative distribution function
        ilow = find(cdf > tol_low, 1, 'first');
        ihigh = find(cdf >= tol_high, 1, 'first');
        if ilow == ihigh   % this could happen if img is flat
            ilowhigh(:,i) = [1;nbins];
        else
            ilowhigh(:,i) = [ilow;ihigh];
        end
    end
    lowhigh = (ilowhigh - 1)/(nbins-1);  % convert to range [0 1]

else
    %   tol_low >= tol_high, this tolerance does not make sense. For example, if
    %   the tolerance is .5 then no pixels would be left after saturating
    %   low and high pixel values. In all of these cases, STRETCHLIM
    %   returns [0; 1]. See gecks 278249 and 235648.
    lowhigh = repmat([0;1],1,p);
end


%-----------------------------------------------------------------------------
function [img,tol] = ParseInputs(varargin)

narginchk(1, 2);

img = varargin{1};
validateattributes(img, {'uint8', 'uint16', 'double', 'int16', 'single'}, {'real', ...
    'nonsparse','nonempty'}, mfilename, 'I or RGB', 1);
if (ndims(img) > 3)
    error(message('images:stretchlim:dimTooHigh'))
end

tol = [.01 .99]; %default
if nargin == 2
    tol = varargin{2};
    switch numel(tol)
        case 1
            tol(2) = 1 - tol;

        case 2
            if (tol(1) >= tol(2))
                error(message('images:stretchlim:invalidTolOrder'))
            end
        otherwise
            error(message('images:stretchlim:invalidTolSize'))
    end
end

if ( any(tol < 0) || any(tol > 1) || any(isnan(tol)) )
    error(message('images:stretchlim:tolOutOfRange'))
end
