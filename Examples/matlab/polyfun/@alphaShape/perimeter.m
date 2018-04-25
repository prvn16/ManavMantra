% perimeter  Perimeter of the alpha shape
%    L = perimeter(SHP) returns the perimeter of the alpha shape.
%    The perimeter of any interior holes is included in the computation.
%
%    L = perimeter(SHP, REGIONID) returns the perimeter of a region of the 
%    alpha shape whose ID is REGIONID and 1 <= REGIONID <= numRegions(SHP). 
%    The perimeter of any interior holes is included in the computation.
%
%    Note: This method is only applicable to 2D alpha shapes.
%
%    Example: Compute the alpha shape of a set of 2D points
%             then compute the perimeter of the shape.
%      % Create a set of points (x,y)
%      th = (pi/12:pi/12:2*pi)';
%      x1 = [reshape(cos(th)*(1:5), numel(cos(th)*(1:5)),1); 0];
%      y1 = [reshape(sin(th)*(1:5), numel(sin(th)*(1:5)),1); 0];
%      x = [x1; x1+15;];
%      y = [y1; y1];
%      % Use alphaShape to create a polygon that envelops the points.
%      % An alpha value of 2 works well for this data set.
%      shp = alphaShape(x,y,2)
%      figure
%      plot(shp,'EdgeColor','none')
%      % Compute the total perimeter
%      totalperim = perimeter(shp)
%      % Compute the perimeter of each region separately
%      regionperim = perimeter(shp, 1:numRegions(shp))
%
%    See also alphaShape, alphaShape.area.

% Copyright 2013-2014 The MathWorks, Inc.