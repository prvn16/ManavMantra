function c = summer(m)
%SUMMER Shades of green and yellow colormap
%   SUMMER(M) returns an M-by-3 matrix containing a "summer" colormap.
%   SUMMER, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB uses the length of the
%   default colormap.
%
%   For example, to reset the colormap of the current figure:
%
%       colormap(summer)
%
%   See also HSV, PARULA, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
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

r = (0:m-1)'/max(m-1,1); 
c = [r .5+r/2 .4*ones(m,1)];
