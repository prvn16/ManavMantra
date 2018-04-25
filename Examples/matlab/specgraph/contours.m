function [CS, msg] = contours(varargin)
% This undocumented function may be removed in a future release.

%CONTOURS Contouring over non-rectangular surface.
%   CONTOURS computes the contour matrix C for use by CONTOUR,
%       CONTOUR3, or CONTOURF to draw the actual contour plot.
%
%   CONTOURS(...) is the same as CONTOURC except CONTOURS(X, Y, Z, ...)
%       allows the specification of parametric surfaces (as for SURF).
%
%   C = CONTOURS(Z) computes the contour matrix for a contour plot
%      of matrix Z treating the values in Z as heights above a plane.
%      A contour plot is the set of level curves of Z for some values
%      V.  The values V are chosen automatically.
%
%   C = CONTOURS(X, Y, Z), where X and Y are vectors, specifies the X-
%      and Y-axes limits for Z.  X and Y can also be matrices of the
%      same size as Z, in which case they specify a surface as for SURF.
%
%   CONTOURS(Z, N) and CONTOURS(X, Y, Z, N) compute N contour lines,
%      overriding the automatic value.
%
%   CONTOURS(Z, V) and CONTOURS(X, Y, Z, V) compute LENGTH(V) contour
%      lines at the values specified in vector V.  Use
%      CONTOURS(Z, [v, v]) or CONTOURS(X, Y, Z, [v, v]) to compute a
%      single contour at the level v.
%
%   The contour matrix C is a two row matrix of contour lines. Each
%   contiguous drawing segment contains the value of the contour,
%   the number of (x, y) drawing pairs, and the pairs themselves.
%   The segments are appended end-to-end as
%
%       C = [level1 x1 x2 x3 ... level2 x2 x2 x3 ...;
%            pairs1 y1 y2 y3 ... pairs2 y2 y2 y3 ...]
%
%   See also CONTOUR, CONTOUR3 and CONTOURF.

%   Copyright 1984-2014 The MathWorks, Inc.

% Author: R. Pawlowicz (IOS) rich@ios.bc.ca
%         12/12/94

    if (nargout == 2)
        warning(message('MATLAB:contours:EmptyErrorOutputArgument', upper( mfilename )));
    end

    msg = [];
    narginchk(1,4);
    
    % Check input args
    for i = 1 : nargin
        arg = varargin{i};
        % Change to double if possible
        if ~isa(arg, 'double')
            varargin{i} = double(arg);
        end
        % sparse, complex, and ndims > 2 are errors
        if issparse(arg)
            error(message('MATLAB:contours:InputsMustBeFull'));
        end
        if ~isreal(arg)
            error(message('MATLAB:contours:InputsMustBeReal'));
        end
        if ndims(arg) > 2
            error(message('MATLAB:contours:InputsMustHaveAtMost2Dimensions'));
        end
    end
    
    haveXY = nargin > 2;
    if haveXY
        % C = CONTOURS(X, Y, Z)
        % C = CONTOURS(X, Y, Z, N)
        % C = CONTOURS(X, Y, Z, V)
        
        argIndices = 3 : nargin;
        
        x = varargin{1};
        y = varargin{2};
        z = varargin{3};
        
        if isscalar(x)
            error(message('MATLAB:contours:XMustBeVectorOrMatrix'));
        end
        
        if isscalar(y)
            error(message('MATLAB:contours:YMustBeVectorOrMatrix'));
        end
        
        msg = xyzchk(x, y, z);
        if ~isempty(msg)
            error(msg);
        end
    else
        % C = CONTOURS(Z)
        % C = CONTOURS(Z, N)
        % C = CONTOURS(Z, V)
        
        argIndices = 1 : nargin;
        
        z = varargin{1};
    end
    
    CS = contourc(varargin{argIndices});
    
    % If c is empty, we are done.
    if isempty(CS)
        return;
    end
    
    % Now we know that c and z are both non-empty.
    cMatLen = size(CS, 2);
    [mz, nz] = size(z);
    
    % Loop over all contour segments, reversing the orientation of any
    % closed contours so that the high side is always on the right.
    
    % isXYCoord will be true for all columns of c that contain actual XY
    % coordinates.  Recall that each contiguous drawing segment of c
    % contains one column that contains the value of the contour and the
    % number of XY coordinates, followed by the XY pairs themselves.
    isXYCoord = true(1, cMatLen);
    
    i = 1;
    while (i < cMatLen)
        zLevel = CS(1, i);
        nPoints = CS(2, i);
        
        iBegin = i + 1;
        iNext = iBegin + nPoints;
        iEnd = iNext - 1;
        
        % Now this is a little bit of magic needed to make the filled contours
        % work. Essentially I draw the *closed* contours so that the "high" side is
        % always on the right. To test this, I take the cross product of a segment
        % of the contour with a vector to a corner point and test the sign
        % against the elevation change. The hard part is choosing the corner.
        % There are several special cases:
        % (1) If the contour line goes through a grid point (which happen when -Infs
        % are around), and (2) when the contour level equals the level on the high
        % side (this always seems to happen in 'simple test' cases!). We take
        % care of (1) by choosing other points, and we take care of (2) by adding
        % eps to the data before comparing with the contour data.
        % The loops are over the possible corners and over the segments in the
        % contour level. Once we find a "good corner" we exit both loops. The
        % closest corner to a segment is chosen first because it will give the
        % most accurate elevation comparison.
        
        if (all(CS(:, iBegin) == CS(:, iEnd)) && nPoints > 1)
            found = false;
            for corner = 0 : 3
                for i1 = iBegin : iEnd - 1
                    i2 = i1 + 1;
                    x1 = CS(1, i1);
                    y1 = CS(2, i1);
                    x2 = CS(1, i2);
                    y2 = CS(2, i2);
                    vx1 = x2 - x1;
                    vy1 = y2 - y1;
                    cpx = round(x1);
                    cpy = round(y1);
                    if corner > 0
                        [cpx, cpy] = rotatecorner(x1, y1, x2, y2, cpx, cpy, corner);
                    end
                    vx2 = cpx - x1;
                    vy2 = cpy - y1;
                    crossprod = vx1 * vy2 - vx2 * vy1;
                    if abs(crossprod) > sqrt(eps) && ...
                            (cpx < nz) && ...
                            (cpy < mz) && ...
                            ~isnan(z(cpy, cpx))
                        if (sign(z(cpy, cpx) - zLevel + eps(z(cpy, cpx))) == sign(crossprod))
                            CS(:, iBegin : iEnd) = fliplr(CS(:, iBegin : iEnd));
                        end
                        found = true;
                        break % stop looping since we have found a good point
                    end
                end
                if found
                    break
                end
            end
        end
        
        isXYCoord(i) = 0;
        i = iNext;
    end
    
    % If X and Y were not specified by the caller, we are done.
    if ~haveXY
        return;
    end
    
    % If X and Y were specified by the caller, then we must transform X and
    % Y data from integer coords (assumed by contourc) to data coords.
    
    % There are two cases
    % (1) Matrix X / Y
    % (2) Vector X / Y
    
    % Since z is non-empty, we know that x and y are non-empty.  We have
    % also determined that x and y are non-scalar.
    
    if isvector(x)
        X = CS(1, isXYCoord);
        Y = CS(2, isXYCoord);
        cX = ceil(X);
        fX = floor(X);
        cY = ceil(Y);
        fY = floor(Y);
        
        dy = cY - Y;
        dx = X - fX;
        
        if (size(x, 2) == 1)
            CS(1, isXYCoord) = x(fX)' .* (1 - dx) + x(cX)' .* dx;
        else
            CS(1, isXYCoord) = x(fX) .* (1 - dx) + x(cX) .* dx;
        end
        
        if (size(y, 2) == 1)
            CS(2, isXYCoord) = y(fY)' .* dy + y(cY)' .* (1 - dy);
        else
            CS(2, isXYCoord) = y(fY) .* dy + y(cY) .* (1 - dy);
        end
    else
        X = CS(1, isXYCoord)';
        Y = CS(2, isXYCoord)';
        cX = ceil(X);
        fX = floor(X);
        cY = ceil(Y);
        fY = floor(Y);
        
        Ibl = cY + (fX - 1) * mz;
        Itl = fY + (fX - 1) * mz;
        Itr = fY + (cX - 1) * mz;
        Ibr = cY + (cX - 1) * mz;
        
        dy = cY - Y;
        dx = X - fX;
        
        CS(1, isXYCoord) = (x(Ibl) .* (1 - dx) .* (1 - dy) + x(Itl) .* (1 - dx) .* dy + ...
            x(Itr) .* dx .* dy + x(Ibr) .* dx .* (1 - dy))';
        CS(2, isXYCoord) = (y(Ibl) .* (1 - dx) .* (1 - dy) + y(Itl) .* (1 - dx) .* dy + ...
            y(Itr) .* dx .* dy + y(Ibr) .* dx .* (1 - dy))';
    end
end

function [cpx, cpy] = rotatecorner(x1, y1, x2, y2, cpx, cpy, corner)
    % choose the closest corner first (corner 0) and rotate to other
    % corners as the corner input goes from 1 to 3.
    xi = floor(.5 * (x1 + x2)) + .5;
    yi = floor(.5 * (y1 + y2)) + .5;
    v = ((cpx - xi) + (cpy - yi) * 1i) * 1i ^ corner;
    cpx = real(v) + xi;
    cpy = imag(v) + yi;
end
