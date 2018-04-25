% numRegions  Number of regions in the shape
% Nr = numRegions(SHP) returns the number of distinct regions that make up
%    the alpha shape. For an infinite alpha radius, the alpha shape is the
%    same as the convex hull, the number of regions is one. As the value of
%    the alpha radius is reduced the shape may break into separate regions,
%    depending on the point set.
%
%    Example 1: Compute the alpha shape of a set of 2D points
%               and query the number of regions at different alpha values.
%      % Create a set of points (x,y)
%      th = (pi/12:pi/12:2*pi)';
%      x1 = [reshape(cos(th)*(1:5), numel(cos(th)*(1:5)),1); 0];
%      y1 = [reshape(sin(th)*(1:5), numel(sin(th)*(1:5)),1); 0];
%      x = [x1; x1+15;];
%      y = [y1; y1];
%      % Use alphaShape to create a polygon that envelops the points
%      % Choose an initial alpha value of 7.
%      figure
%      shp = alphaShape(x,y,7)
%      plot(shp,'EdgeColor','none')
%      % Query the number of regions
%      nregions = numRegions(shp)
%      %Lower the alpha value to better capture the boundary 
%      shp.Alpha = 2
%      plot(shp,'EdgeColor','none')
%      % Query the number of regions
%      nregions = numRegions(shp)
%
%    See also alphaShape.

% Copyright 2013-2014 The MathWorks, Inc.