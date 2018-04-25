function [xx,yy,zz] = meshgrid(x,y,z)
%MESHGRID   Cartesian grid in 2-D/3-D space
%   [X,Y] = MESHGRID(xgv,ygv) replicates the grid vectors xgv and ygv to 
%   produce the coordinates of a rectangular grid (X, Y). The grid vector
%   xgv is replicated numel(ygv) times to form the columns of X. The grid 
%   vector ygv is replicated numel(xgv) times to form the rows of Y.
%
%   [X,Y,Z] = MESHGRID(xgv,ygv,zgv) replicates the grid vectors xgv, ygv, zgv 
%   to produce the coordinates of a 3D rectangular grid (X, Y, Z). The grid 
%   vectors xgv,ygv,zgv form the columns of X, rows of Y, and pages of Z 
%   respectively. (X,Y,Z) are of size numel(ygv)-by-numel(xgv)-by(numel(zgv).
%
%   [X,Y] = MESHGRID(gv) is equivalent to [X,Y] = MESHGRID(gv,gv).
%   [X,Y,Z] = MESHGRID(gv) is equivalent to [X,Y,Z] = MESHGRID(gv,gv,gv).
%
%   The coordinate arrays are typically used for the evaluation of functions 
%   of two or three variables and for surface and volumetric plots.
%
%   MESHGRID and NDGRID are similar, though MESHGRID is restricted to 2-D 
%   and 3-D while NDGRID supports 1-D to N-D. In 2-D and 3-D the coordinates 
%   output by each function are the same, the difference is the shape of the 
%   output arrays. For grid vectors xgv, ygv and zgv of length M, N and P 
%   respectively, NDGRID(xgv, ygv) will output arrays of size M-by-N while 
%   MESHGRID(xgv, ygv) outputs arrays of size N-by-M. Similarly, 
%   NDGRID(xgv, ygv, zgv) will output arrays of size M-by-N-by-P while 
%   MESHGRID(xgv, ygv, zgv) outputs arrays of size N-by-M-by-P. 
%
%   Example: Evaluate the function  x*exp(-x^2-y^2) 
%            over the range  -2 < x < 2,  -4 < y < 4,
%
%       [X,Y] = meshgrid(-2:.2:2, -4:.4:4);
%       Z = X .* exp(-X.^2 - Y.^2);
%       surf(X,Y,Z)
%
%
%   Class support for inputs xgv,ygv,zgv:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%
%   See also SURF, SLICE, NDGRID.

%   Copyright 1984-2013 The MathWorks, Inc. 

if nargin==0 || (nargin > 1 && nargout > nargin)
    error(message('MATLAB:meshgrid:NotEnoughInputs'));
end

if nargin == 2 || (nargin == 1 && nargout < 3) % 2-D array case
    if nargin == 1
        y = x;
    end
    if isempty(x) || isempty(y)
        xx = zeros(0,class(x));
        yy = zeros(0,class(y));
    else
        xrow = full(x(:)).'; % Make sure x is a full row vector.
        ycol = full(y(:));   % Make sure y is a full column vector.
        xx = repmat(xrow,size(ycol));
        yy = repmat(ycol,size(xrow));
    end
else  % 3-D array case
    if nargin == 1
        y = x;
        z = x;
    end
    if isempty(x) || isempty(y) || isempty(z)
        xx = zeros(0,class(x));
        yy = zeros(0,class(y));
        zz = zeros(0,class(z));
    else
        nx = numel(x);
        ny = numel(y);
        nz = numel(z);
        xx = reshape(full(x),[1 nx 1]); % Make sure x is a full row vector.
        yy = reshape(full(y),[ny 1 1]); % Make sure y is a full column vector.
        zz = reshape(full(z),[1 1 nz]); % Make sure z is a full page vector.
        xx = repmat(xx, ny, 1, nz);
        yy = repmat(yy, 1, nx, nz);
        zz = repmat(zz, ny, nx, 1);
    end
end
