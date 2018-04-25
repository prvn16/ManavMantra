% area  Area of the alpha shape
%    S = area(SHP) returns the area of the alpha shape.
%
%    S = area(SHP, REGIONID) returns the area of a region of the alpha shape 
%    whose ID is REGIONID and 1 <= REGIONID <= numRegions(SHP).
%
%    Note: This method is only applicable to 2D alpha shapes.
%
%    Example: Compute the alpha shape of a set of 2D points
%             then compute the area of the shape.
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
%      % Compute the total area
%      totalarea = area(shp)
%      % Compute the area of each region separately
%      regionareas = area(shp, 1:numRegions(shp))
%
%    See also alphaShape, alphaShape.perimeter

% Copyright 2013-2014 The MathWorks, Inc.