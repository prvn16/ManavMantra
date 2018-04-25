function p = pink(m)
%PINK   Pastel shades of pink color map
%   PINK(M) returns an M-by-3 matrix containing a "pink" colormap.
%   PINK, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB uses the length of the
%   default colormap.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(pink)
%
%   See also HSV, GRAY, HOT, COOL, BONE, COPPER, FLAG, 
%   COLORMAP, RGBPLOT.

%   C. Moler, 5-11-91, 8-19-92.
%   Copyright 1984-2015 The MathWorks, Inc.

if nargin < 1
   f = get(groot,'CurrentFigure');
   if isempty(f)
      m = size(get(groot,'DefaultFigureColormap'),1);
   else
      m = size(f.Colormap,1);
   end
end

p = sqrt((2*gray(m) + hot(m))/3);
