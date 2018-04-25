function r_estimated = chradii(varargin)%#codegen
%CHRADII Estimate circle radius for Circular Hough Transform using Radial Histogram method

%   Copyright 2015 The MathWorks, Inc.

[centers, gradientImg, radiusRange] = parseInputs(varargin{:});

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

coder.inline('always');

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
h = accumarraylocal(r - bins(1) + 1, gradientImg, max(r-bins(1)+1,[],1));

% Normalize by circumference.
for idx = 1:numel(h)
    h(idx) = h(idx)/(2*pi*bins(idx));
end

end

function [centers, gradientImg, radiusRange] = parseInputs(varargin)

coder.inline('always');
coder.internal.prefer_const(varargin);

narginchk(3,3);

centers = varargin{1};
gradientImg = varargin{2};
radiusRangeIn = varargin{3};

% Validate PV pairs
checkCenters(centers);
checkGradientImage(gradientImg);
checkRadiusRange(radiusRangeIn);
validateCenters(centers, gradientImg);

radiusRange = double(radiusRangeIn);

end

function checkCenters(centers)

coder.inline('always');

validateattributes(centers,{'numeric'},{'nonsparse','real','positive', ...
    'nonempty','ncols',2}, mfilename,'centers',1);
end

function checkGradientImage(gradientImg)

coder.inline('always');

validateattributes(gradientImg,{'numeric'},{'nonempty',...
    'nonsparse','real','2d'},mfilename,'G',2);
end

function checkRadiusRange(radiusRange) % Radius range has to be a 2-element vector with r(2) > r(1)

coder.inline('always');

validateattributes(radiusRange,{'numeric'},{'nonnan','nonsparse',...
    'integer','positive','finite','vector','numel',2},...
    mfilename,'R',3);
coder.internal.errorIf (radiusRange(1) >= radiusRange(2),...
    'images:imfindcircles:invalidRadiusRange');
end

function validateCenters(centers, gradientImg)

coder.inline('always');

coder.internal.errorIf(~(all(centers(:,1) <= size(gradientImg,2)) && ...
    all(centers(:,2) <= size(gradientImg,1))),...
    'images:imfindcircles:outOfBoundCenters');

end

function out = accumarraylocal(yc, w, sz)

coder.inline('always');

out = complex(zeros(sz,1));

for idx = 1:numel(yc)
    out(yc(idx)) = out(yc(idx)) + w(idx); 
end

end
