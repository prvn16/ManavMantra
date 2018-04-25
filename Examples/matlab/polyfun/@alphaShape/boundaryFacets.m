% boundaryFacets  Boundary facets of the alpha shape
%    BF = boundaryFacets(SHP) returns a matrix BF that represents the 
%    triangulation facets on the boundary of the alpha shape. In 2D BF 
%    represents edge segments and in 3D BF represents triangles. BF is 
%    of size m-by-n, where m is the number of boundary facets and n is the 
%    number of vertices per facet. The vertices of the facets index into 
%    the array of points SHP.Points. 
%
%    BF = boundaryFacets(SHP, REGIONID) returns a matrix of the boundary 
%    facets BF that defines the boundary of a region of the alpha shape 
%    whose ID is REGIONID and 1 <= REGIONID <= numRegions(SHP).
%
%    [BF, P] = boundaryFacets(...) returns a matrix of the boundary facets BF
%    that has vertices defined in terms of a compact array of coordinates P.
%    P is of size m-by-ndim where m is the number of points on the boundary
%    of the alpha shape and 2<=ndim<=3.
%    
%    Example 1: Compute the alpha shape of a set of 2D points and
%               plot the alpha shape boundary.
%      % Create a set of points (x,y)
%      th = (pi/12:pi/12:2*pi)';
%      x1 = [reshape(cos(th)*(1:5), numel(cos(th)*(1:5)),1); 0];
%      y1 = [reshape(sin(th)*(1:5), numel(sin(th)*(1:5)),1); 0];
%      x = [x1; x1+15;];
%      y = [y1; y1];
%      % Plot the points
%      plot(x,y,'.')
%      axis equal
%      % Use alphaShape to create a polygon that envelops the points
%      % An alpha value of 2 works well for this data set.
%      shp = alphaShape(x,y,2)
%      % Compute the boundary of the alpha shape and plot it.
%      [bf, p] = shp.boundaryFacets();
%      bf = bf';
%      xp = p(:,1);
%      yp = p(:,2);
%      xp = xp(bf);
%      yp = yp(bf);
%      numedges = size(bf,2);
%      xp = [xp; NaN(1, numedges)];
%      yp = [yp; NaN(1, numedges)];
%      xp = xp(:);
%      yp = yp(:);  
%      hold on
%      plot(xp,yp,'-k');
%      hold off
%
%    Example 2: Compute the alpha shape of a set of 3D points and
%               plot the alpha shape boundary.
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
%      % An alpha value of 1.5 works well for this data set.
%      shp = alphaShape(P,1.5)
%      % Compute the boundary of the alpha shape and plot it.
%      [tri, xyz] = shp.boundaryFacets();
%      hold on
%      trisurf(tri,xyz(:,1),xyz(:,2),xyz(:,3),'FaceColor', 'cyan', ...
%              'FaceAlpha', 0.3)
%      hold off
%
%    See also alphaShape, alphaShape.Alpha, alphaShape.plot, triangulation.

%   Copyright 2013-2014 The MathWorks, Inc.
%   Built-in function.
