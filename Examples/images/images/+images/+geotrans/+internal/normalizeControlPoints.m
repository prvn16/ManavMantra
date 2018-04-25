function [ptsNorm, normMatrixInv] = normalizeControlPoints(pts) %#codegen
%images.geotrans.internal.normalizeControlPoints Normalize control points.
%   ptsOut = images.geotrans.internal.normalizeControlPoints(pts)
%   computes a normalized control points matrix ptsNorm. The centroid of
%   ptsNorm is centered at the origin. The RMS distance from the origin of
%   ptsNorm is sqrt(2). The second output argument normMatrixInv defines a
%   3x3 similarity matrix normMatrixInv is a similarity matrix that is the
%   inverse of the scale and shift applied during point normalization. This
%   is used to denormalize the homography computed as an overconstrained
%   least squares problem.

%   Copyright 2013 The MathWorks, Inc.

% [1] Hartley, R; Zisserman, A. "Multiple View Geometry in Computer
% Vision." Cambridge University Press, 2003. pg. 180-181.

% Define N, the number of control points
N = size(pts,1);

% Compute [xCentroid,yCentroid]
cent = mean(pts, 1);

% Shift centroid of the input points to the origin.
%   ptsNorm(:, 1) = pts(:, 1) - cent(1);
%   ptsNorm(:, 2) = pts(:, 2) - cent(2);
ptsNorm = bsxfun(@minus,pts,cent);

sumOfPointDistancesFromOriginSquared = sum( hypot(ptsNorm(:,1),ptsNorm(:,2)).^2 );

if sumOfPointDistancesFromOriginSquared > 0
    scaleFactor = sqrt(2*N) / sqrt(sumOfPointDistancesFromOriginSquared);
else
    % If all input control points are at the same location, the denominator
    % of the scale factor goes to 0. Don't rescale in this case.
    if isa(pts,'single')
        scaleFactor = single(1);
    else
        scaleFactor = 1.0;
    end
end

% Scale control points by a common scalar scale factor
ptsNorm = ptsNorm .* scaleFactor;

normMatrixInv = [...
    1/scaleFactor,     0,            0;...
    0,            1/scaleFactor,     0;...
    cent(1),      cent(2),      1];