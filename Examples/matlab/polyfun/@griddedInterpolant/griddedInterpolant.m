%griddedInterpolant   Gridded data interpolant
%   F = griddedInterpolant creates an empty gridded data interpolant.
%
%   F = griddedInterpolant(x,v) creates a 1-D interpolant F from a vector
%   of sample points x and a vector of values v. F satisfies v = F(x).
%
%   F = griddedInterpolant(X1,X2,...,Xn,V) creates an N-D interpolant using
%   a grid of sample points specified by n N-D arrays Xi created from grid
%   vectors xig using [X1,X2,...,Xn] = NDGRID(x1g,x2g,...,xng). V must have
%   the same size as the Xi arrays. F satisfies V = F(X1,X2,...,Xn).
%
%   F = griddedInterpolant({x1g,x2g,...,xng},V) specifies a grid in compact
%   form using grid vectors xig. LENGTH(xig) must equal SIZE(V,i). Use this
%   syntax to conserve memory when the sample points form a large grid.
%   The interpolant F satisfies V = F({x1g,x2g,...,xng}).
%
%   F = griddedInterpolant(V) uses an implicit grid formed by the grid
%   vectors xig = [1 2 3 ... SIZE(V,i)] and the corresponding values V.
%
%   F = griddedInterpolant(...,METHOD) specifies the interpolation method:
%     'linear'   - (default) linear, bilinear, trilinear,... interpolation
%     'nearest'  - nearest neighbor interpolation
%     'next'     - next neighbor interpolation (1-D only)
%     'previous' - previous neighbor interpolation (1-D only)
%     'spline'   - spline interpolation
%     'pchip'    - shape-preserving piecewise cubic interpolation (1-D only)
%     'cubic'    - cubic, bicubic, tricubic,... for uniformly spaced data only
%     'makima'   - modified Akima cubic interpolation
%
%   F = griddedInterpolant(...,METHOD,EXTRAPOLATIONMETHOD) also specifies
%   the extrapolation method. EXTRAPOLATIONMETHOD has the same options as
%   METHOD in addition to the following:
%     'none'     - Removes support for extrapolation; queries outside the
%                  domain of the grid return NaN.
%   If EXTRAPOLATIONMETHOD is not specified, EXTRAPOLATIONMETHOD = METHOD.
%
%   Example:
%     % Construct a 2-D griddedInterpolant F from gridded data X,Y,V
%       [X,Y] = ndgrid(1:20,1:20);
%       V = (X-5).^2 + Y.^2;
%       F = griddedInterpolant(X,Y,V)
%     % Evaluate F at gridded query points Xq_gridded,Yq_gridded
%       [Xq_gridded,Yq_gridded] = ndgrid(1.5:1:19.5,1.5:1:19.5);
%       Vq = F(Xq_gridded,Yq_gridded);
%     % Plot the gridded data X,Y,V and the interpolated values Vq
%       mesh(X,Y,V,'Marker','.','EdgeColor','b'), hold on
%       plot3(Xq_gridded(:),Yq_gridded(:),Vq(:),'r.')
%       legend('gridded sample data','gridded queries','location','best')
%     % Evaluate F at scattered query points and plot the interpolation result
%       xyq = 2 + 18*gallery('uniformdata',[400 2],0);
%       xq_scattered = xyq(:,1);
%       yq_scattered = xyq(:,2);
%       vq_scattered = F(xq_scattered,yq_scattered);
%       figure
%       mesh(X,Y,V,'Marker','.','EdgeColor','b'), hold on
%       plot3(xq_scattered,yq_scattered,vq_scattered,'r.')
%       legend('gridded sample data','scattered queries','location','best')
%
%   Example:
%     % Construct a 1-D griddedInterpolant F
%       x = 1:10;
%       v = exp(-0.1*x).*sin(2*x);
%       F = griddedInterpolant(x,v)
%     % Perform linear interpolation at query points xq
%       xq = 1:0.1:10;
%       vq_linear = F(xq);
%     % Change the interpolation method to spline
%       F.Method = 'spline'
%     % Perform spline interpolation at the same query points xq
%       vq_spline = F(xq);
%     % Plot the linear and spline interpolation results
%       plot(x,v,'o',xq,vq_linear,':.',xq,vq_spline,':.')
%       legend('sample data','linear interpolation','spline interpolation')
%
%   griddedInterpolant properties:
%       GridVectors         - Cell array with grid vectors of sample points
%       Values              - Values associated with each grid point
%       Method              - Method used to interpolate at query points
%       ExtrapolationMethod - Extrapolation method used outside the grid
%
%   griddedInterpolant methods:
%       vq = F(Xq) evaluates the griddedInterpolant F at scattered query
%       points Xq and returns a column vector of interpolated values vq.
%       Each row of Xq contains the coodinates of one query point.
%
%       vq = F(xq1,xq2,...,xqn) also allows the scattered query points to
%       be specified as column vectors of coordinates.
%
%       Vq = F(Xq1,Xq2,...,Xqn) evaluates F at gridded query points
%       specified in full grid format as n N-D arrays Xqi created from grid
%       vectors xqig using [Xq1,Xq2,...,Xqn] = NDGRID(xq1g,xq2g,...,xqng).
%
%       Vq = F({xq1g,xq2g,...,xqng}) also allows a grid of query points to
%       be specified in compact form as grid vectors xqig. Use this syntax
%       to conserve memory when the query points form a large grid. The
%       array of interpolated values Vq has the same size as the grid:
%       LENGTH(xq1g)-by-LENGTH(xq2g)-by-...-by-LENGTH(xqng).
%
%    See also scatteredInterpolant, ndgrid, interp1, interp2, interp3, interpn

%   Copyright 2012-2017 The MathWorks, Inc.
%   Built-in function.

%{
properties
    %GridVectors - A cell array containing the vectors that define the grid
    %	An N-D interpolant contains n grid vectors. The grid vectors are a
    %   compact representation of the grid. The fully expanded grid can be
    %   generated as [X1,X2,X3,...,Xn] = NDGRID(GridVectors{:});
    GridVectors;

    %Values - Defines the value associated with each grid point
    %   The array of values has the same dimensions as the underlying grid
    %   that is implicitly defined by GridVectors.
    Values;

    %Method - Defines the method used to interpolate the data
    %   The Method is one of the following:
    %     'linear'   - (default) linear, bilinear, trilinear,... interpolation
    %     'nearest'  - nearest neighbor interpolation
    %     'next'     - next neighbor interpolation (1-D only)
    %     'previous' - previous neighbor interpolation (1-D only)
    %     'spline'   - spline interpolation
    %     'pchip'    - shape-preserving piecewise cubic interpolation (1-D only)
    %     'cubic'    - cubic, bicubic, tricubic,... for uniformly spaced data only
    %     'makima'   - modified Akima cubic interpolation
    Method;

    %ExtrapolationMethod - Defines the method used to extrapolate the data
    %   Extrapolation is used for the query points falling outside of the
    %   domain defined by the grid vectors. ExtrapolationMethod must be:
    %     'linear'   - (default) linear, bilinear, trilinear,... extrapolation
    %     'nearest'  - nearest neighbor extrapolation
    %     'next'     - next neighbor extrapolation (1-D only)
    %     'previous' - previous neighbor extrapolation (1-D only)
    %     'spline'   - spline extrapolation
    %     'pchip'    - shape-preserving piecewise cubic extrapolation (1-D only)
    %     'cubic'    - cubic, bicubic, tricubic,... for uniformly spaced data only
    %     'makima'   - modified Akima cubic interpolation
    %     'none'     - Removes support for extrapolation; queries outside the
    %                  domain of the grid return NaN.
    ExtrapolationMethod;
end
%}
