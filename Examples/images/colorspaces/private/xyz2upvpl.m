function uvlp =xyz2upvpl(xyz)
%XYZ2UPVPL Converts CIEXYZ to CIE u', v', and Luminance
%   uvlp = XYZ2UPVPL(XYZ) converts 1931 CIEXYZ tristimulus values scaled to 1.0
%   to 1976 CIE u',v' Chromaticity and Luminance
%   Both xyz and uvlp are n x 3 vectors
%
%   Example:
%       d50 = getwhitepoint;
%       uvlp = xyz2upvpl(d50)
%       uvlp =
%           0.2092    0.4881    1.0000

%   Copyright 1993-2015 The MathWorks, Inc.
%   Author:  Scott Gregory, 10/18/02
%   Revised: Toshia McCabe, 12/06/02


validateattributes(xyz,{'double'},{'real','2d','nonsparse','finite'},...
              'xyz2upvpl','XYZ',1);
if size(xyz,2) ~= 3
    error(message('images:xyz2upvpl:invalidXyzData'))
end

% There is a singularity when (X,Y,Z) == (0,0,0).  Replace with an
% appropriate value to preserve the chroma value of the neutral axis.
black = 1.0e-16 .* [0.167115861476741, 0.173300464636333, 0.142953358039464];

singularRows = find(sum(xyz,2) == 0);
if (~isempty(singularRows))
    xyz(singularRows,:) = bsxfun(@plus, xyz(singularRows,:), black);
end

uvlp = zeros(size(xyz));
uvlp(:,1) = clipdivide(4 * xyz(:,1), xyz * [1; 15; 3]);
uvlp(:,2) = clipdivide(9 * xyz(:,2), xyz * [1; 15; 3]);
uvlp(:,3) = xyz(:,2);
