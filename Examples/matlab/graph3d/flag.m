function map = flag(m)
%FLAG   Alternating red, white, blue, and black color map
%   FLAG(M) returns an M-by-3 matrix containing a "flag" colormap.
%   Increasing M increases the granularity emphasized by the map.
%   FLAG, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB uses the length of the
%   default colormap.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(flag)
%
%   See also HSV, GRAY, HOT, COOL, COPPER, PINK, BONE, 
%   COLORMAP, RGBPLOT.

%   C. Moler, 7-4-91, 8-19-92.
%   Copyright 1984-2015 The MathWorks, Inc.

if nargin < 1
   f = get(groot,'CurrentFigure');
   if isempty(f)
      m = size(get(groot,'DefaultFigureColormap'),1);
   else
      m = size(f.Colormap,1);
   end
end

% f = [red; white; blue; black]
f = [1 0 0; 1 1 1; 0 0 1; 0 0 0];

% Generate m/4 vertically stacked copies of f with Kronecker product.
e = ones(ceil(m/4),1);
map = kron(e,f);
map = map(1:m,:);
