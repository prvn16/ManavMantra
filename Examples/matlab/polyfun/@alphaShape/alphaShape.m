% alphaShape Alpha Shape in 2D and 3D
%    alphaShape is used to create regularized alpha shapes from a set of 
%    points in 2D or 3D space. 
%
%    SHP = alphaShape(X,Y,A) creates a 2D alpha shape of the points (X,Y), 
%    with alpha radius A. X and Y are column vectors that specify the 
%    coordinates. A is a positive scalar that defines the alpha radius. If 
%    A is not specified, the default is the smallest alpha that produces an
%    alpha shape enclosing all of the points.
% 
%    SHP = alphaShape(X,Y,Z,A) creates a 3D alpha shape of the points (X,Y,Z), 
%    with alpha radius A. X, Y and Z are column vectors that specify the 
%    coordinates. A is a positive scalar that defines the alpha radius. If 
%    A is not specified, the default is the smallest alpha that produces an
%    alpha shape enclosing all of the points.
%
%    SHP = alphaShape(P,A) creates a 2D/3D alpha shape of the points P, with 
%    alpha radius A. This syntax is equivalent to the (X,Y,A) and (X,Y,Z,A) 
%    syntaxes where the columns of P are treated as X,Y, or X,Y,Z respectively.
%
%    SHP = alphaShape(...,'Name1',Value1, 'Name2',Value2, ...) 
%    uses name/value pairs to override the default values for 
%    'Name1', 'Name2',...
%    Supported alphaShape options include:
%    HoleThreshold - suppression of interior holes/voids. Specifying a 
%                    'HoleThreshold' of Th, will fill internal holes/voids
%                    that have an area/volume less than or equal to Th.              
%    RegionThreshold - suppression of small regions. Specifying a 
%                    'RegionThreshold' of Tr, will suppress regions that  
%                    have an area/volume less than or equal to Tr.
%    Note: The thresholds are order-dependent; the HoleThreshold is applied
%          before the RegionThreshold.
%
%    Example 1: Compute the alpha shape of a set of 2D points
%      % Create a set of points (x,y)
%      th = (pi/12:pi/12:2*pi)';
%      x1 = [reshape(cos(th)*(1:5), numel(cos(th)*(1:5)),1); 0];
%      y1 = [reshape(sin(th)*(1:5), numel(sin(th)*(1:5)),1); 0];
%      x = [x1; x1+15;];
%      y = [y1; y1];
%      % Use alphaShape to create a polygon that envelops the points
%      % an alpha value of 2 is chosen.
%      figure
%      % Plot the points
%      plot(x,y,'.')
%      axis equal
%      shp = alphaShape(x,y,2)
%      % Plot the alpha shape.
%      hold on
%      plot(shp, 'EdgeColor','none')
%      hold off
%
%    Example 2: Compute the alpha shape of a set of 3D points
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
%      figure
%      shp = alphaShape(P,1)
%      plot(shp)
%
%    Example 3: Compute the alpha shape of a set of 2D points
%               Fill interior holes using the HoleThreshold
%      % Create a set of points (x,y)
%      th = (pi/12:pi/12:2*pi)';
%      x1 = [reshape(cos(th)*(2:5), numel(cos(th)*(2:5)),1);];
%      y1 = [reshape(sin(th)*(2:5), numel(sin(th)*(2:5)),1);];
%      x = [x1; x1+15;];
%      y = [y1; y1];
%      shp = alphaShape(x,y,1)
%      % Plot the alpha shape
%      plot(shp,'EdgeColor','none')
%      % Fill the holes using the HoleThreshold option and plot
%      shp.HoleThreshold = 15
%      figure
%      plot(shp,'EdgeColor','none')
%
%    Example 4: Compute the alpha shape of a set of 2D points
%               Discard small regions using the RegionThreshold
%      % Create a set of points (x,y)
%      th = (pi/12:pi/12:2*pi)';
%      x1 = [reshape(cos(th)*(1:5), numel(cos(th)*(1:5)),1); 0];
%      y1 = [reshape(sin(th)*(1:5), numel(sin(th)*(1:5)),1); 0];
%      x = [x1; x1+15; 25; 26; 26];
%      y = [y1; y1; 0; 0; 0.25];
%      shp = alphaShape(x,y,2)
%      plot(shp,'EdgeColor','none')
%      hold on
%      plot(x,y,'.')
%      hold off
%      % Query the areas of the individual regions
%      area(shp,1:numRegions(shp))
%      % Select a RegionThreshold of 0.2 to remove the small region
%      shp.RegionThreshold = 0.2
%      % Plot to observe the region removed
%      figure
%      plot(shp,'EdgeColor','none')
%
% alphaShape methods:   
%    alphaSpectrum   - Sorted vector of alpha values giving distinct shapes
%    criticalAlpha   - Alpha value defining a critical transition in the shape
%    numRegions      - Number of regions in the shape
%    inShape         - Test whether a point is within the alpha shape
%    nearestNeighbor - Nearest point on the alpha shape boundary
%    alphaTriangulation - Triangulation that fills the alpha shape
%    boundaryFacets  - Boundary facets of alpha shape
%    perimeter       - Perimeter of a 2D alpha shape
%    area            - Area of a 2D alpha shape
%    surfaceArea     - Surface area of a 3D alpha shape
%    volume          - Volume of a 3D alpha shape
%    plot            - Plot an alpha shape
%
% alphaShape properties:
%    Points          - The coordinates of the points
%    Alpha           - The selected alpha value
%    HoleThreshold   - Suppression of interior holes/voids
%    RegionThreshold - Suppression of small regions 
%    
%
%   See also boundary, triangulation, delaunayTriangulation, trisurf,
%            convhull

%   Copyright 2013-2015 The MathWorks, Inc.
%   Built-in function.

%{
properties
    %Points - The coordinates of the points 
    %    The size of Points is mpts-by-ndim, where mpts is the number of
    %    points and ndim is the number of dimensions, 2 <= ndim <= 3.
    %    If column vectors of X,Y or X,Y,Z coordinates are used, the data 
    %    is consolidated into a single matrix.
    Points;
    
    %Alpha - The selected value of alpha radius
    %    A scalar specifying the radius of the alpha disk/sphere used to 
    %    recover the alpha shape.
    Alpha;

    %HoleThreshold - Suppression of interior holes/voids
    %    A scalar specifying the threshold for the suppression of 
    %    interior holes/voids that have area/volume less than or 
    %    equal to the HoleThreshold (default = 0).
    HoleThreshold;

    %RegionThreshold - Suppression of small regions 
    %    A scalar specifying the threshold for the suppression of 
    %    small regions that have area/volume less than or equal to 
    %    the RegionThreshold (default = 0).
    RegionThreshold;
end
%}
