% TriScatteredInterp   Scattered data interpolant
% 
%    TriScatteredInterp is not recommended. Use scatteredInterpolant instead.
%
%    TriScatteredInterp is used to perform interpolation on a scattered 
%    dataset that resides in 2D/3D space. A scattered data set defined by 
%    locations X and corresponding values V can be interpolated using a 
%    Delaunay triangulation of X. This produces a surface of the form V = F(X). 
%    The surface can be evaluated at any query location QX, using QV = F(QX), 
%    where QX lies within the convex hull of X. The interpolant F always 
%    goes through the data points specified by the sample.
%
%    F = TriScatteredInterp() Creates an empty scattered data interpolant. 
%    This can subsequently be initialized with sample data points and values 
%    (Xdata, Vdata) via F.X = Xdata and F.V = Vdata.
%
%    F = TriScatteredInterp(X, V) Creates an interpolant that fits a surface 
%    of the form V = F(X) to the scattered data in (X, V). X is a matrix 
%    of size mpts-by-ndim, where mpts is the number of points and ndim is 
%    the dimension of the space where the points reside, ndim >= 2. V is a 
%    column vector that defines the values at X, where the length of V 
%    equals mpts.
%
%    F = TriScatteredInterp(X, Y, V) and F = TriScatteredInterp(X, Y, Z, V) 
%    allow the data point locations to be specified in alternative column 
%    vector format when working in 2D and 3D.
%
%    TriScatteredInterp(DT, V) will be removed in a future release.
%    Use delaunayTriangulation pointLocation and nearestNeighbor instead.
%
%    F = TriScatteredInterp(DT, V) Uses the specified DelaunayTri DT as a 
%    basis for computing the interpolant. DT is a Delaunay triangulation of 
%    the scattered data locations, DT.X. The matrix DT.X is of size 
%    mpts-by-ndim, where mpts is the number of points and ndim is the 
%    dimension of the space where the points reside, 2 <= ndim <= 3. V is a 
%    column vector that defines the values at DT.X, where the length of V 
%    equals mpts. 
%
%    F = TriScatteredInterp(..., METHOD) allows selection of the technique 
%    used to interpolate the data, where METHOD is one of the following; 
%           'natural'   Natural neighbor interpolation
%           'linear'    Linear interpolation (default)
%           'nearest'   Nearest neighbor interpolation
%    The 'natural' method is C1 continuous except at the scattered data 
%    locations. The 'linear' method is C0 continuous, and the 'nearest' 
%    method is discontinuous.
%
%    Example 1:
%        xy = -2.5 + 5*gallery('uniformdata',[200 2],0);
%        x = xy(:,1); y = xy(:,2);
%        v = x.*exp(-x.^2-y.^2);
%
%   % Construct the interpolant
%        F = TriScatteredInterp(x,y,v);
%
%   % Evaluate the interpolant at the locations (xq, yq),
%   %    vq is the corresponding value at these locations.
%        ti = -2:.2:2; 
%        [xq,yq] = meshgrid(ti,ti);
%        vq = F(xq,yq);
%        mesh(xq,yq,vq); hold on; plot3(x,y,v,'o'); hold off
%
%
%    Example 2: Edit the interpolant created in Example 1 
%               to add/remove points or replace values
%
%        % Insert 5 additional sample points, we need to update both F.V and F.X
%        close(gcf)
%        x = rand(5,1); 
%        y = rand(5,1); 
%        v = x.*exp(-x.^2-y.^2);
%        F.V(end+(1:5)) = v;
%        F.X(end+(1:5), :) = [x, y]; 
%
%        % Replace the location and value of the fifth point
%        F.X(5,:) = [0.1, 0.1];
%        F.V(5) = 0.098;
%
%        % Remove the fourth point
%        F.X(4,:) = [];
%        F.V(4) = [];
%
%        % Replace the value of all sample points
%        vnew = 1.2*(F.V);
%        F.V(1:length(vnew)) = vnew;
% 
%    TriScatteredInterp methods:
%        TriScatteredInterp provides subscripted evaluation of the
%        interpolant. It is evaluated in the same manner as evaluating a
%        function expressed in Monge's form.
%
%        Vq = F(Xq), evaluates the interpolant at the specified query 
%        locations Xq to produce the query values Vq.
%
%        Vq = F(Xq, Yq, ...) and Vq = F(Xq, Yq, Zq, ...) allow the query
%        points to be specified in alternative column vector format when
%        working in 2D and 3D. 
%
%
%    TriScatteredInterp properties:
%        X      - Defines the locations of the scattered data points
%        V      - Defines the value associated with each data point
%        Method - Defines the method used to interpolate the data
%
%    See also  DelaunayTri, interp1, interp2, interp3, meshgrid.

%   Copyright 2008-2015 The MathWorks, Inc.
%   Built-in function.

%{
properties
    %X - Defines the locations of the scattered data points 
    %    The dimension of X is mpts-by-ndim, where mpts is the number of 
    %    data points and ndim is the dimension of the space where the 
    %    points reside 2 <= ndim <= 3. 
    %    If column vectors of X,Y or X,Y,Z coordinates are used to construct
    %    the interpolant, the data is consolidated into a single matrix X.
    X;    

    %V - Defines the value associated with each data point
    %    V is a column vector of length mpts where mpts is the number of
    %    scattered data points.
    V;

    %Method - Defines the method used to interpolate the data
    %    The Method is one of the following; 
    %           'natural'   Natural neighbor interpolation
    %           'linear'    Linear interpolation (default)
    %           'nearest'   Nearest neighbor interpolation
    %    The 'natural' method is C1 continuous except at the scattered data 
    %    locations. The 'linear' method is C0 continuous, and the 'nearest' 
    %    method is discontinuous.
    Method;
end
%}
