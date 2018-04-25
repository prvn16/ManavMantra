function c = copper(m)
%COPPER Linear copper-tone color map
%   COPPER(M) returns an M-by-3 matrix containing a "copper" colormap.
%   COPPER, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB uses the length of the
%   default colormap.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(copper)
%
%   See also HSV, GRAY, HOT, COOL, BONE, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   C. Moler, 8-17-88, 8-19-92.
%   Copyright 1984-2015 The MathWorks, Inc.

if nargin < 1
   f = get(groot,'CurrentFigure');
   if isempty(f)
      m = size(get(groot,'DefaultFigureColormap'),1);
   else
      m = size(f.Colormap,1);
   end
end

c = min(1,gray(m)*diag([1.2500 0.7812 0.4975]));
