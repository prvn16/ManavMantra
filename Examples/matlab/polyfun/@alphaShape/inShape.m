% inShape  Test whether a point is inside the alpha shape
%    IN = inShape(SHP,QX,QY) returns the in/out status of the query points 
%    (QX, QY) with respect to the 2D alpha shape. QX and QY are arrays that 
%    specify the coordinates of the points. IN is a logical array of size 
%    equal to QX and QY. IN(k) is true if the query point (QX(k),QY(k)) 
%    is within the alpha shape.
%
%    IN = inShape(SHP,QX,QY,QZ) returns the in/out status of the query 
%    points (QX, QY, QZ) with respect to the 3D alpha shape. QX, QY and QZ 
%    are arrays that specify the coordinates of the points. IN is a logical 
%    array of size equal to QX, QY and zq. IN(k) is true if the query point 
%    (QX(k), QY(k), QZ(k)) is within the alpha shape.
%
%    IN = inShape(SHP,QP) returns the in/out status of the query points 
%    QP with respect to the alpha shape. QP has M rows representing M query
%    points and 2 or 3 columns. IN is a logical array of size equal to QP.
%    IN(k) is true if the query point (QP(k,:)) is within the alpha shape.
% 
%    IN = inShape(...,REGIONID) returns the in/out status with respect to 
%    the region whose ID is REGIONID and 1 <= REGIONID <= numRegions(SHP).
%
%    [IN, REGIONID] = inShape(...) returns in addition REGIONID, the ID of 
%    the region that contains the query point. If the query point is not 
%    within the shape REGIONID is set to NaN.
%
%    Example: Compute the alpha shape of a set of 2D points then
%             test whether query points are inside or outside the shape
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
%      % Create a grid of test points to test against the shape.
%      % Plot points inside in red and outside in blue.
%      [qx, qy] = meshgrid(-10:2:25, -10:2:10);
%      in = inShape(shp,qx,qy);
%      plot(shp,'EdgeColor','none');
%      hold on;
%      % Plot points inside in red and outside in blue.
%      plot(qx(in),qy(in),'r.')
%      plot(qx(~in),qy(~in),'b.')
%      hold off
%
%    See also alphaShape, alphaShape.plot

% Copyright 2013-2014 The MathWorks, Inc.