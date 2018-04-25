function map = lines(m)
%LINES  Color map with the line colors.
%   LINES(M) returns an M-by-3 matrix containing a "ColorOrder"
%   colormap. LINES, by itself, is the same length as the current
%   colormap. If no figure exists, MATLAB uses the length of the
%   default colormap.
%
%   For example, to set the colormap of the current figure:
%
%       colormap(lines)
%
%   See also HSV, GRAY, PINK, COOL, BONE, COPPER, FLAG, 
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

c = get(groot,'DefaultAxesColorOrder');

map = c(rem(0:m-1,size(c,1))+1,:);


