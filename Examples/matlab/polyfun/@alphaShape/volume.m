% volume  Volume of the alpha shape
%    V = volume(SHP) returns the volume of the alpha shape.
%
%    V = volume(SHP, REGIONID) returns the volume of a region of the alpha 
%    shape whose ID is REGIONID and 1 <= REGIONID <= numRegions(SHP).
%
%    Note: This method is only applicable to 3D alpha shapes.
%
%    Example: Compute the alpha shape of a set of 3D points
%             then compute the volume of the shape.
%      % Create a set of points P 
%      [x1, y1, z1] = sphere(24);
%      x1 = x1(:);
%      y1 = y1(:);
%      z1 = z1(:);
%      x2 = x1+5;
%      P = [x1 y1 z1; x2 y1 z1];
%      P = unique(P,'rows');
%      % Plot the points
%      plot3(P(:,1),P(:,2),P(:,3),'.')
%      axis equal
%      % Use alphaShape to create a polyhedron that envelops the points
%      % An alpha value of 1 works well for this data set.
%      shp = alphaShape(P,1.5)
%      % Plot the shape in a new figure
%      figure
%      plot(shp)
%      % Compute the total volume
%      totalvol = volume(shp)
%      % Compute the volume of each region separately
%      regionvol = volume(shp, 1:numRegions(shp))
%
%    See also alphaShape, alphaShape.area, alphaShape.volume.

% Copyright 2013-2014 The MathWorks, Inc.