%scatteredInterpolant   Scattered data interpolation
%   scatteredInterpolant performs interpolation on scattered data that
%   resides in 2-D or 3-D space. A scattered data set is defined by sample
%   points X and corresponding values v. A scatteredInterpolant object F
%   represents a surface of the form v = F(X). Interpolated values vq at
%   query points Xq are obtained by evaluating the interpolant, vq = F(Xq).
%
%   F = scatteredInterpolant creates an empty scattered data interpolant.
%
%   F = scatteredInterpolant(X,v) creates an interpolant that fits a
%   surface of the form v = F(X) to the sample data set (X,v). The sample
%   points X must have size NPTS-by-2 in 2-D or NPTS-by-3 in 3-D, where
%   NPTS is the number of points. Each row of X contains the coordinates of
%   one sample point. The values v must be a column vector of length NPTS.
%
%   F = scatteredInterpolant(x,y,v) and F = scatteredInterpolant(x,y,z,v)
%   also allow the sample point locations to be specified in alternative
%   column vector format when working in 2-D and 3-D.
%
%   F = scatteredInterpolant(...,METHOD) specifies the method used to
%   interpolate the data. METHOD must be one of the following:
%       'linear'  - (default) Linear interpolation
%       'nearest' - Nearest neighbor interpolation
%       'natural' - Natural neighbor interpolation
%   The 'natural' method is C1 continuous except at the sample points. The
%   'linear' method is C0 continuous. The 'nearest' method is discontinuous.
%
%   F = scatteredInterpolant(...,METHOD,EXTRAPOLATIONMETHOD) also specifies
%   the extrapolation method used for query points outside the convex hull.
%   EXTRAPOLATIONMETHOD must be one of the following:
%       'linear'  - (default if METHOD is 'linear' or 'natural')
%                   Linear extrapolation based on boundary gradients
%       'nearest' - (default if METHOD is 'nearest') Evaluates to the value
%                   of the nearest neighbor on the convex hull boundary
%       'none'    - Queries outside the convex hull return NaN
%
%   Example:
%     % Construct a scatteredInterpolant F from locations x,y and values v
%       t = linspace(3/4*pi,2*pi,50)';
%       x = [3*cos(t); 2*cos(t); 0.7*cos(t)];
%       y = [3*sin(t); 2*sin(t); 0.7*sin(t)];
%       v = repelem([-0.5; 1.5; 2],length(t));
%       F = scatteredInterpolant(x,y,v)
%     % Evaluate F at query locations xq,yq to obtain interpolated values vq
%       tq = linspace(3/4*pi+0.2,2*pi-0.2,40)';
%       xq = [2.8*cos(tq); 1.7*cos(tq); cos(tq)];
%       yq = [2.8*sin(tq); 1.7*sin(tq); sin(tq)];
%       vq = F(xq,yq);
%     % Plot the sample data (x,y,v) and interpolated query data (xq,yq,vq)
%       plot3(x,y,v,'.',xq,yq,vq,'.'), grid on
%       title('Linear Interpolation')
%       xlabel('x'), ylabel('y'), zlabel('Values')
%       legend('sample data','interpolated query data','Location','best')
%     % Change the interpolation method from 'linear' to 'nearest'
%       F.Method = 'nearest'
%     % Perform nearest neighbor interpolation and plot the result
%       vq = F(xq,yq);
%       figure
%       plot3(x,y,v,'.',xq,yq,vq,'.'), grid on
%       title('Nearest Interpolation')
%       xlabel('x'), ylabel('y'), zlabel('Values')
%       legend('sample data','interpolated query data','Location','best')
%
%   scatteredInterpolant properties:
%       Points              - Locations of the scattered sample points
%       Values              - Values associated with each sample point
%       Method              - Method used to interpolate at query points
%       ExtrapolationMethod - Extrapolation method used outside the convex hull
%
%   scatteredInterpolant methods:
%       vq = F(Xq) evaluates the scatteredInterpolant F at scattered query
%       points Xq and returns a column vector of interpolated values vq.
%       Each row of Xq contains the coordinates of one query point.
%
%       vq = F(xq,yq) and vq = F(xq,yq,zq) also allow the scattered query
%       points to be specified as column vectors of coordinates.
%
%       Vq = F(Xq,Yq) and Vq = F(Xq,Yq,Zq) evaluates F at gridded query
%       points specified in full grid format as 2-D and 3-D arrays created
%       from grid vectors using [Xq,Yq,Zq] = NDGRID(xqg,yqg,zqg).
%
%       Vq = F({xqg,yqg}) and Vq = F({xqg,yqg,zqg}) also allow a grid of
%       query points to be specified in compact form as grid vectors. Use
%       this syntax to conserve memory when the query points form a large
%       grid. Vq has the same size as the grid: LENGTH(xqg)-by-LENGTH(yqg)
%       or LENGTH(xqg)-by-LENGTH(yqg)-by-LENGTH(zqg).
%
%   See also griddedInterpolant, griddata, delaunayTriangulation

%   Copyright 2008-2015 The MathWorks, Inc.
%   Built-in function.

%{
properties
    %Points - Defines the locations of the scattered sample points
    %   The size of Points is NPTS-by-2 in 2-D and NPTS-by-3 in 3-D, where
    %   NPTS is the number of scattered sample points.
    %   If column vectors of x,y or x,y,z coordinates are used to construct
    %   the interpolant, they are consolidated into a single matrix Points.
    Points;

    %Values - Defines the value associated with each scattered sample point
    %	Values is a column vector of length NPTS, where NPTS is the number
    %   of scattered sample points.
    Values;

    %Method - Defines the method used to interpolate the data
    %   Method must be one of the following:
    %       'linear'  - (default) Linear interpolation
    %       'nearest' - Nearest neighbor interpolation
    %       'natural' - Natural neighbor interpolation
    %   The 'natural' method is C1 continuous except at the sample points. The
    %   'linear' method is C0 continuous. The 'nearest' method is discontinuous.
    Method;

    %ExtrapolationMethod - Defines the method used to extrapolate the data
    %   ExtrapolationMethod must be one of the following:
    %       'linear'  - (default if METHOD is 'linear' or 'natural')
    %                   Linear extrapolation based on boundary gradients
    %       'nearest' - (default if METHOD is 'nearest') Evaluates to the value
    %                   of the nearest neighbor on the convex hull boundary
    %       'none'    - Queries outside the convex hull return NaN
    ExtrapolationMethod;
end
%}
