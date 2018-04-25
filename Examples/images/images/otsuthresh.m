function [t,em] = otsuthresh(counts)
%OTSUTHRESH Global histogram threshold using Otsu's method.
%   T = OTSUTHRESH(COUNTS) computes a global threshold from histogram
%   counts COUNTS that minimizes the intraclass variance for a bimodal
%   histogram. T is a normalized intensity value that lies in the range [0,
%   1] and can be used with IMBINARIZE to convert an intensity image to a
%   binary image.
%
%   [T, EM] = OTSUTHRESH(COUNTS) returns effectiveness metric, EM, as the
%   second output argument. It indicates the effectiveness of thresholding
%   using threshold T and is in the range [0, 1]. The lower bound is
%   attainable only by histogram counts with all data in a single non-zero
%   bin. The upper bound is attainable only by histogram counts with
%   two non-zero bins.
%
%   Class Support
%   -------------
%   The histogram counts COUNTS must be a real, non-sparse, numeric vector.
%
%   Example 
%   -------
%   This example shows how to compute a threshold from an image histogram
%   and binarize the image .
%
%   % Read an image of coins and compute a 16-bin histogram.
%   I = imread('coins.png');
%   counts = imhist(I, 16);
%
%   % Compute a global threshold using the histogram counts.
%   T = otsuthresh(counts);
%
%   % Binarize image using computed threshold.
%   BW = imbinarize(I,T);
%
%   figure, imshow(BW)
%
%
%   See also IMBINARIZE, GRAYTHRESH.

% Copyright 2015 The MathWorks, Inc.

validateattributes(counts, {'numeric'}, {'real','nonsparse','vector','nonnegative','finite'}, mfilename, 'COUNTS');

num_bins = numel(counts);

% Make counts a double column vector
counts = double( counts(:) );

% Variables names are chosen to be similar to the formulas in
% the Otsu paper.
p = counts / sum(counts);
omega = cumsum(p);
mu = cumsum(p .* (1:num_bins)');
mu_t = mu(end);

sigma_b_squared = (mu_t * omega - mu).^2 ./ (omega .* (1 - omega));

% Find the location of the maximum value of sigma_b_squared.
% The maximum may extend over several bins, so average together the
% locations.  If maxval is NaN, meaning that sigma_b_squared is all NaN,
% then return 0.
maxval = max(sigma_b_squared);
isfinite_maxval = isfinite(maxval);
if isfinite_maxval
    idx = mean(find(sigma_b_squared == maxval));
    % Normalize the threshold to the range [0, 1].
    t = (idx - 1) / (num_bins - 1);
else
    t = 0.0;
end

% compute the effectiveness metric
if nargout > 1
    if isfinite_maxval
        em = maxval/(sum(p.*((1:num_bins).^2)') - mu_t^2);
    else
        em = 0;
    end
end

end
