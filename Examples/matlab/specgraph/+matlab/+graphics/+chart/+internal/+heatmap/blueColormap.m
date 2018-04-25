function map = blueColormap(m)
% This is an undocumented function and may be removed in a future release.

% Create a monochromatic colormap based on the first color (blue) in the
% default axes color order.

%   Copyright 2016 The MathWorks, Inc.

if nargin < 1
   f = get(groot,'CurrentFigure');
   if isempty(f)
      m = size(get(groot,'DefaultFigureColormap'),1);
   else
      m = size(f.Colormap,1);
   end
end

% First color from the default axes color order.
blue = [0 0.4470 0.7410];

% Effective transparency
a = linspace(0.1,1,m)';

% Linearly interpolate the transparency from a to 1.
% This algorithm is designed so that blueColormap(1) returns a value that
% is exactly equal to the blue in default axes color order.
map = blue.*a + (1 - a);
