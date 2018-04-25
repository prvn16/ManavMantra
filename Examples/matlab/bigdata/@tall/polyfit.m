function [p,S,mu] = polyfit(x,y,n)
%POLYFIT Fit polynomial to data.
%   P = POLYFIT(X,Y,N)
%   [P,S] = POLYFIT(X,Y,N)
%   [P,S,MU] = POLYFIT(X,Y,N)
%
%   Limitations:
%   X and Y must be tall column vectors.
%
%   See also POLYFIT, POLYVAL, TALL.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(3,3);
tall.checkNotTall(upper(mfilename), 2, n);

% X and Y must both be tall floating-point columns with matching size
x = iValidateTallColumn(1, x, 'MATLAB:bigdata:array:PolyfitInputMustBeColumn');
y = iValidateTallColumn(2, y, 'MATLAB:bigdata:array:PolyfitInputMustBeColumn');
[x, y] = validateSameTallSize(x, y);
[x, y] = tall.validateType(x, y, mfilename, {'single', 'double'}, 1:2);
iValidateN(n);

if nargout > 2
    mn = mean(x, 1);
    st = std(x, 1);
    
    % Convention for MU is [mean;std] so must combine on client
    mu = clientfun(@vertcat, mn, st);
    mu.Adaptor = setKnownSize(mu.Adaptor, [2 1]);
    
    % Normalize input
    x = (x - mn)./st;
end

% Construct Vandermonde matrix.
V = iVander(x, n+1);

% Solve least squares problem.
[R,p] = qrLeftSolve(V, y);

% Maybe warn about poor conditioning
[R,p] = clientfun( @iCondCheck, R, p, nargout>1);


% Build extra outputs
if nargout > 1
    residual = iGetResidual(y,V,p);
    % S is a structure containing three elements: the triangular factor from a
    % QR decomposition of the Vandermonde matrix, the degrees of freedom and
    % the norm of the residuals.
    S.R = R;
    S.df = max(0, length(y)-(n+1));
    S.normr = norm(residual);
end

% Polynomial coefficients are row vectors by convention, so transpose on client
p = clientfun(@transpose, p);
p.Adaptor = setKnownSize(p.Adaptor, [1 n+1]);
end


function arg = iValidateTallColumn(idx, arg, errID)
try
    tall.checkIsTall(upper(mfilename), idx, arg);
    arg = tall.validateColumn(arg, errID);
catch err
    throwAsCaller(err)
end
end

function iValidateN(n)
% Check that N is a valid polynomial order.

% Simply call standard POLYFIT to avoid duplicating the checks, ignoring
% warnings about polynomial degree.
S = warning('off', 'MATLAB:polyfit:PolyNotUnique');
cleaner = onCleanup(@() warning(S));
try
    polyfit([1;2],[1;2],n);
catch err
    throwAsCaller(err);
end
end

function V = iVander(x,n)
% Construct Vandermonde matrix.
V = slicefun(@iVanderFcn, x, n);
V.Adaptor = setSizeInDim(x.Adaptor, 2, n); % Input is mx1, result is mxn
end

function V = iVanderFcn(x,n)
% Construct one chunk of a Vandermonde matrix
V = repmat(x(:,1), 1, n);
V(:, n) = 1;
V = cumprod(V, 2, 'reverse');
end

function res = iGetResidual(y,V,p)
% Calculate the residual (y - V*p).

% Note that p is small and can be safely broadcast to allow local matrix
% products for each slice.
res = y - slicefun(@mtimes, V, matlab.bigdata.internal.broadcast(p));

% Residual has same size and type as y
res.Adaptor = y.Adaptor;
end

function [R,p] = iCondCheck(R, p, outputRequested)
if size(R,2) > size(R,1)
   warning(message('MATLAB:polyfit:PolyNotUnique'))
else
    if warnIfLargeConditionNumber(R)
        if outputRequested
            warning(message('MATLAB:polyfit:RepeatedPoints'));
        else
            warning(message('MATLAB:polyfit:RepeatedPointsOrRescale'));
        end
    end
end
end

function flag = warnIfLargeConditionNumber(R)
if isa(R, 'double')
    flag = (condest(R) > 1e+10);
else
    flag = (condest(R) > 1e+05);
end
end
