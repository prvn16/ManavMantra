function c = cool(m)
%COOL   Shades of cyan and magenta color map
%   COOL(M) returns an M-by-3 matrix containing a "cool" colormap.
%   COOL, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB uses the length of the
%   default colormap.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(cool)
%
%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   C. Moler, 8-19-92.
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
c = [r 1-r ones(m,1)]; 
