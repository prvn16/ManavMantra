function Vq = interp2(varargin)
%INTERP2 2-D interpolation (table lookup).
%
%   Some features of INTERP2 will be removed in a future release.
%   See the R2012a release notes for details.
%
%   Vq = INTERP2(X,Y,V,Xq,Yq) interpolates to find Vq, the values of the
%   underlying 2-D function V at the query points in matrices Xq and Yq.
%   Matrices X and Y specify the points at which the data V is given.
%
%   Xq can be a row vector, in which case it specifies a matrix with
%   constant columns. Similarly, Yq can be a column vector and it
%   specifies a matrix with constant rows.
%
%   Vq = INTERP2(V,Xq,Yq) assumes X=1:N and Y=1:M where [M,N]=SIZE(V).
%
%   Vq = INTERP2(V,K) returns the interpolated values on a refined grid
%   formed by repeatedly halving the intervals K times in each dimension.
%   This results in 2^K-1 interpolated points between sample values.
%
%   Vq = INTERP2(V) is the same as INTERP2(V,1).
%
%   Vq = INTERP2(...,METHOD) specifies alternate methods.  The default
%   is linear interpolation.  Available methods are:
%
%     'nearest' - nearest neighbor interpolation
%     'linear'  - bilinear interpolation
%     'spline'  - spline interpolation
%     'cubic'   - bicubic interpolation as long as the data is
%                 uniformly spaced, otherwise the same as 'spline'
%     'makima'  - modified Akima cubic interpolation
%
%   Vq = INTERP2(...,METHOD,EXTRAPVAL) specificies a method and a scalar
%   value for Vq outside of the domain created by X and Y.  Thus, Vq will
%   equal EXTRAPVAL for any value of Yq or Xq which is not spanned by Y
%   or X respectively. A method must be specified for EXTRAPVAL to be used,
%   the default method is 'linear'.
%
%   All the interpolation methods require that X and Y be monotonic and
%   plaid (as if they were created using MESHGRID).  If you provide two
%   monotonic vectors, interp2 changes them to a plaid internally.
%   X and Y can be non-uniformly spaced.
%
%   For example, to generate a coarse approximation of PEAKS and
%   interpolate over a finer mesh:
%       [X,Y,V] = peaks(10); [Xq,Yq] = meshgrid(-3:.1:3,-3:.1:3);
%       Vq = interp2(X,Y,V,Xq,Yq); mesh(Xq,Yq,Vq)
%
%   Class support for inputs X, Y, V, Xq, Yq:
%      float: double, single
%
%   See also INTERP1, INTERP3, INTERPN, MESHGRID,
%            griddedInterpolant, scatteredInterpolant.

%   Copyright 1984-2017 The MathWorks, Inc.

narginchk(1,7); % allowing for an ExtrapVal

if (nargin == 7 || (nargin == 5 && (ischar(varargin{end-1}) || (isstring(varargin{end-1}) && isscalar(varargin{end-1})))) ) && ...
   (~isnumeric(varargin{end}) || ~isscalar(varargin{end}))
    error(message('MATLAB:interp2:InvalidExtrapval'))
end

% Parse the method and extrap val
[narg, method, ExtrapVal] = methodandextrapval(varargin{:});

% Construct the interpolant, narg should be 2,3 or 5 at this point.
if narg ~= 1 && narg ~= 2 && narg ~= 3 && narg ~= 5
    error(message('MATLAB:interp2:nargin'));
end
stripNaNsForCubics = strcmpi(method,'spline') || strcmpi(method,'makima');
if stripNaNsForCubics 
    extrap = method;
else
    extrap = 'none';
end
origvtype = 'double';
if narg == 1 || narg == 2
    %  interp2(V,NTIMES)
    V = varargin{1};
    [nrows,ncols] = size(V);
    if narg == 1
        ntimes = 1;
    else
        ntimes = floor(varargin{2}(1));
    end
    
    if ~isscalar(ntimes) || ~isreal(ntimes)
        error(message('MATLAB:interp2:NtimesInvalid'));
    end
    
    Xq = 1:1/(2^ntimes):ncols;
    Yq = (1:1/(2^ntimes):nrows)';
    [X, Y] = meshgridvectors(V);
    V = V.';
    if stripNaNsForCubics
        [X, Y, V] = stripnanwrapper(X,Y,V); 
    end
    [V, origvtype] = convertv(V,method,Xq,Yq);
    F = makegriddedinterp({X,Y},V,method,extrap);
elseif narg == 3
    %  interp2(V,Xq,Yq)
    V = varargin{1};
    Xq = varargin{2};
    Yq = varargin{3};
    [X, Y] = meshgridvectors(V);
    V = V.';
    if stripNaNsForCubics
        [X, Y, V] = stripnanwrapper(X,Y,V);
    end
    [V, origvtype] = convertv(V,method,Xq,Yq);
    F = makegriddedinterp({X,Y},V,method,extrap);
elseif narg == 5
    %  interp2(X,Y,V,Xq,Yq)
    X = varargin{1};
    Y = varargin{2};
    V = varargin{3};
    
    Xq = varargin{4};
    Yq = varargin{5};
    if isvector(X) && isvector(Y)
        V = V.';
        [X, Y, V] = checkmonotonic(X,Y,V);
        [V, origvtype] = convertv(V,method, Xq, Yq);
        if stripNaNsForCubics
            [X, Y, V] = stripnanwrapper(X,Y,V);
        end
        F = makegriddedinterp({X, Y}, V, method,extrap);
    else
        V = V.';
        [X, Y, V] = checkmonotonic(X',Y',V);
        [V, origvtype] = convertv(V,method, Xq, Yq);
        if stripNaNsForCubics
            [X, Y, V] = stripnanwrapper(X,Y,V);          
        end
        F = makegriddedinterp(X, Y, V, method,extrap);
    end
end

if strcmpi(method,'cubic') && strcmpi(F.Method,'spline')
    % Uniformity condition not met
    gv = F.GridVectors;
    FV = F.Values;
    [X, Y, V] = stripnanwrapper(gv{:},FV);
    F = makegriddedinterp({X,Y},V,'spline');
end

% Now interpolate
iscompact = compactgridformat(Xq, Yq);
if iscompact || (isscalar(Xq) && isscalar(Yq) && strcmpi(F.Method,'spline'))
    Vq = F({Xq,Yq});
elseif isMeshGrid(Xq,Yq)
    iscompact = true;
    Xq = Xq(1,:);
    Yq = Yq(:,1);
    Vq = F({Xq,Yq});  
else
    Vq = F(Xq,Yq);
end

% impose the extrapolation value to the queries
% that lie outside the domain.
if ~isempty(ExtrapVal)
    Vq = imposeextrapval({Xq, Yq}, F.GridVectors, Vq, ExtrapVal, iscompact);
end

if  iscompact
    % Compact grid evaluation produces a NDGRID
    % Convert to MESHGRID
    Vq = Vq.';
end

if ~strcmp(origvtype,'double') && ~strcmp(origvtype,'single')
    Vq = cast(Vq,origvtype);
end
% end of interp2

% function stripnanwrapper
function [X, Y, V] = stripnanwrapper(X,Y,V)
[inan, jnan] = find(isnan(V));
ncolnan = length(unique(jnan));
nrownan = length(unique(inan));
if ncolnan == 0 && nrownan == 0
    return;
end
% Minimize loss of data. Strip rows instead of cols if there are less rows
if ncolnan > nrownan
    if isvector(X) && isvector(Y)
        % The X, Y and V are in compact NDGRID format
        [Y, X, V] = stripnansforspline(Y, X, V.'); % Swap on the way in & out
        V = V.';
    else
        [X, Y, V] = stripnansforspline(X',Y',V.');
        X = X.';
        Y = Y.';
        V = V.';
    end
else
    [X, Y, V] = stripnansforspline(X,Y,V);
end
warning(message('MATLAB:interp2:NaNstrip'));
if isempty(V) || isvector(V)
    error(message('MATLAB:interp2:NotEnoughPointsNanStrip'));
end

%function isMeshGrid
function isMG = isMeshGrid(X,Y)
if ~ismatrix(X) || isempty(X) || ~isequal(size(X),size(Y))
    isMG = false;
elseif (~isnumeric(X) && ~islogical(X)) || (~isnumeric(Y) && ~islogical(Y))
    isMG = false;    
elseif Y(1) ~= Y(1,end) || X(1) ~= X(end,1)  %quick check
    isMG = false;    
else
   isMG = norm(diff(X,[],1),1) == 0 && norm(diff(Y,[],2),1) == 0; 
end

%function convertv
function [V, origvtype] = convertv(V,method, Xq, Yq)
origvtype = class(V);
if ~isfloat(V) && (strcmpi(method,'nearest') || (isscalar(Xq) && isscalar(Yq)) )
    V = double(V);
end

%function makegriddedinterp
function F = makegriddedinterp(varargin)
try
    F = griddedInterpolant(varargin{:});
catch gime
    if iscell(varargin{1})
        method = varargin{3};
    else
        method = varargin{4};
    end
    if any(strcmp(gime.identifier,{'MATLAB:griddedInterpolant:NotNdGridErrId', ...
        'MATLAB:griddedInterpolant:NdgridNotMeshgrid2DErrId'}))
        error(message('MATLAB:interp2:InvalidMeshgrid'));
    elseif(strcmp(gime.identifier,'MATLAB:griddedInterpolant:DegenerateGridErrId') && strcmpi(method,'nearest'))
        error(message('MATLAB:interp2:DegenerateGrid'));
    else
        rethrow(gime);
    end
end
