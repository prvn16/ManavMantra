function r_estimated = chradii(varargin)
%CHRADII Estimate circle radius for Circular Hough Transform using Radial Histogram method
%   R_ESTIMATED = CHRADII(CENTERS,G,[RMIN RMAX]) takes a two-column array
%   CENTERS, which contains the x (first column) and y (second column)
%   coordinates of the center locations, as input. It returns a vector
%   R_ESTIMATED, which contains the estimated radius value for each center
%   and is the same length as the number of rows in CENTERS. G is an array
%   containing the gradient magnitude of the original image (see CHACCUM).
%   RMIN and RMAX are positive integers that specify the minimum and
%   maximum expected radius values.
%
%   The radial histogram method computes the radial histogram of the values
%   in array G over the specified radius range around each center and
%   estimates the circle radius as the location of the highest peak in the
%   radial histogram. This method is typically used as the second stage in
%   the Two-Stage method for Circular Hough Transform (see [1] and [2] for
%   details).
% 
% See also CHACCUM, CHCENTERS, CHRADIIPHCODE, IMFINDCIRCLES, VISCIRCLES.

%   Copyright 2011 The MathWorks, Inc.

%   References:
%   -----------
%   [1] H. K. Yuen, J. Princen, J. Illingworth, and J. Kittler,
%       "Comparative study of Hough Transform methods for circle finding,"
%       Image and Vision Computing, Volume 8, Number 1, 1990, pp. 71–77.
%
%   [2] E. R. Davies, Machine Vision: Theory, Algorithms, Practicalities -
%       Chapter 10, 3rd Edition, Morgan Kauffman Publishers, 2005.

parsedInputs = parse_inputs(varargin{:});

centers            = parsedInputs.Centers;
gradientImg        = parsedInputs.GradientImage; 
radiusRange        = parsedInputs.RadiusRange;

r_estimated = zeros(size(centers,1),1);

%% Radial histogram to determine radius of each peak.
[M, N] = size(gradientImg);
for k = 1:size(centers,1)
    % Determine the extent of the circle in the image
    left = max(floor(centers(k,1) - radiusRange(2)), 1);
    right = min(ceil(centers(k,1) + radiusRange(2)), N);
    top = max(floor(centers(k,2) - radiusRange(2)), 1);
    bottom = min(ceil(centers(k,2) + radiusRange(2)), M);
    % Pass the cropped image (and shifted center) for computing radial histogram
    [h, bins] = radial_histogram(gradientImg(top:bottom, left:right), ...
            centers(k,1)-left+1, centers(k,2)-top+1, radiusRange(1), radiusRange(2));
    [~,idx] = max(h);
    r_estimated(k) = bins(idx);
end
end

function [h, bins] = radial_histogram(gradientImg, xc, yc, r1, r2)

[M,N] = size(gradientImg);
% Determine the pixel distance from the specified center
[xx,yy] = meshgrid(1:N, 1:M);
dx = xx - xc;
dy = yy - yc;
r = hypot(dx, dy);
r = round(r);
r = r(:);

gradientImg = gradientImg(:);

% Retain those pixels which lie within radius range
keep = (r >= r1) & (r <= r2);
gradientImg = gradientImg(keep);
r = r(keep);
bins = (min(r):max(r))';

% Compute the radial histogram by integrating along radius bins
h = accumarray(r - bins(1) + 1, gradientImg);

% Normalize by circumference.
h = h ./ (2*pi*bins);
end

function parsedInputs = parse_inputs(varargin)

narginchk(3,3);

persistent parser;

if(isempty(parser))
    parser = inputParser();
    
    parser.addRequired('Centers',@checkCenters);
    parser.addRequired('GradientImage',@checkGradientImage);
    parser.addRequired('RadiusRange',@checkRadiusRange);
end

% Parse input
parser.parse(varargin{:});
parsedInputs = parser.Results;

validateCenters();

parsedInputs.RadiusRange = double(parsedInputs.RadiusRange);

    function tf = checkCenters(centers)
        validateattributes(centers,{'numeric'},{'nonsparse','real','positive', ...
            'nonempty','ncols',2}, mfilename,'centers',1);        
        tf = true;
    end

    function tf = checkGradientImage(gradientImg)
        validateattributes(gradientImg,{'numeric'},{'nonempty',...
            'nonsparse','real','2d'},mfilename,'G',2);
        tf = true;
    end

    function tf = checkRadiusRange(radiusRange) % Radius range has to be a 2-element vector with r(2) > r(1)
        validateattributes(radiusRange,{'numeric'},{'nonnan','nonsparse',...
            'integer','positive','finite','vector','numel',2},...
            mfilename,'R',3);        
        if (radiusRange(1) >= radiusRange(2))
            error(message('images:imfindcircles:invalidRadiusRange'));
        end
        tf = true;
    end

    function validateCenters
        if (~(all(parsedInputs.Centers(:,1) <= size(parsedInputs.GradientImage,2)) && ...
              all(parsedInputs.Centers(:,2) <= size(parsedInputs.GradientImage,1))))
            error(message('images:imfindcircles:outOfBoundCenters'));
        end
    end
    
end







