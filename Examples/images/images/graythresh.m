function [level, em] = graythresh(I)
%GRAYTHRESH Global image threshold using Otsu's method.
%   LEVEL = GRAYTHRESH(I) computes a global threshold (LEVEL) that can be
%   used to convert an intensity image to a binary image with IMBINARIZE.
%   LEVEL is a normalized intensity value that lies in the range [0, 1].
%   GRAYTHRESH uses Otsu's method, which chooses the threshold to minimize
%   the intraclass variance of the thresholded black and white pixels.
%
%   [LEVEL, EM] = GRAYTHRESH(I) returns effectiveness metric, EM, as the
%   second output argument. It indicates the effectiveness of thresholding
%   of the input image and it is in the range [0, 1]. The lower bound is
%   attainable only by images having a single gray level, and the upper
%   bound is attainable only by two-valued images.
%
%   Class Support
%   -------------
%   The input image I can be uint8, uint16, int16, single, or double, and it
%   must be nonsparse.  LEVEL and EM are double scalars. 
%
%   Example
%   -------
%       I = imread('coins.png');
%       level = graythresh(I);
%       BW = imbinarize(I,level);
%       figure, imshow(BW)
%
%   See also OTSUTHRESH, IMBINARIZE, IMQUANTIZE, MULTITHRESH, RGB2IND.

%   Copyright 1993-2015 The MathWorks, Inc.

% Reference:
% N. Otsu, "A Threshold Selection Method from Gray-Level Histograms,"
% IEEE Transactions on Systems, Man, and Cybernetics, vol. 9, no. 1,
% pp. 62-66, 1979.


validateattributes(I,{'uint8','uint16','double','single','int16'},{'nonsparse'}, ...
              mfilename,'I',1);

if ~isempty(I)
  % Convert all N-D arrays into a single column.  Convert to uint8 for
  % fastest histogram computation.
  I = im2uint8(I(:));
  num_bins = 256;
  counts = imhist(I,num_bins);
  
  if nargout <= 1
      level = otsuthresh(counts);
  else
      [level,em] = otsuthresh(counts);
  end
else
  level = 0.0;
  em = 0;
end



