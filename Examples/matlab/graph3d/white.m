function w = white(m)
%WHITE  All white color map
%   WHITE(M) returns an M-by-3 matrix containing a white colormap.
%   WHITE, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB uses the length of the
%   default colormap.
%
%   For example, to reset the colormap of the current figure:
%
%      colormap(white)
%
%   See also HSV, GRAY, HOT, COOL, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   Copyright 1984-2015 The MathWorks, Inc.

if nargin < 1
   f = get(groot,'CurrentFigure');
   if isempty(f)
      m = size(get(groot,'DefaultFigureColormap'),1);
   else
      m = size(f.Colormap,1);
   end
end

w = ones(m,3);
