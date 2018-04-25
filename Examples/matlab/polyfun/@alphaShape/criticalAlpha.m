% criticalAlpha  Alpha value defining a critical transition in the shape
% Ac = criticalAlpha(SHP, TRANSITIONTYPE) returns a critical alpha value Ac.
%    The TRANSITIONTYPE input can be:
%      'all-points' -  Ac is the lowest alpha value for which the shape
%                      encloses all points.
%      'one-region' -  Ac is the lowest alpha value for which the shape
%                      encloses all points and represents a single region.
%
%    Example 1:
%    % Create an alpha shape from a set of points in the plane and compute
%    % the 'all-points' critical alpha value.
%      % Create a set of points (x,y)
%      th = (pi/12:pi/12:2*pi)';
%      x1 = [reshape(cos(th)*(1:5), numel(cos(th)*(1:5)),1); 0];
%      y1 = [reshape(sin(th)*(1:5), numel(sin(th)*(1:5)),1); 0];
%      x = [x1; x1+15;];
%      y = [y1; y1];
%      % Create an alphaShape from the set of points.
%      shp = alphaShape(x,y)
%      % Compute the point critical value
%      pc = criticalAlpha(shp,'all-points')
%      figure
%      shp.Alpha = pc;
%      plot(shp);
%      % The next alpha value in the spectrum will not contain all
%      % points in the shape.
%      s = alphaSpectrum(shp);
%      % Find the index of the 'all-points' alpha:
%      idx = find(s == pc);
%      % Set the alpha value to the next in the spectrum.
%      shp.Alpha = s(idx+1);
%      plot(shp,'EdgeColor','none')
%      hold on
%      plot(x,y,'.')
%      hold off
%
%    Example 2:
%    % Create an alpha shape from a set of points in the plane and compute
%    % the 'one-region' critical alpha value.
%      % Create a set of points (x,y)
%      th = (pi/12:pi/12:2*pi)';
%      x1 = [reshape(cos(th)*(1:5), numel(cos(th)*(1:5)),1); 0];
%      y1 = [reshape(sin(th)*(1:5), numel(sin(th)*(1:5)),1); 0];
%      x = [x1; x1+15;];
%      y = [y1; y1];
%      % Create an alphaShape from the set of points.
%      shp = alphaShape(x,y)
%      % Compute the point critical value
%      pc = criticalAlpha(shp,'one-region')
%      figure
%      shp.Alpha = pc;
%      plot(shp);
%      % The next alpha value in the spectrum will not contain all
%      % points in the shape.
%      s = alphaSpectrum(shp);
%      % Find the index of the 'one-region' alpha:
%      idx = find(s == pc);
%      % Set the alpha value to the next in the spectrum.
%      shp.Alpha = s(idx+1);
%      figure
%      plot(shp)
%      
%
%    See also alphaShape, alphaShape.Alpha, alphaShape.alphaSpectrum.

% Copyright 2013-2014 The MathWorks, Inc.
