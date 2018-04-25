function Vq = interp3(varargin)
%INTERP3 3-D interpolation (table lookup).
%
%   Some features of INTERP3 will be removed in a future release.
%   See the R2012a release notes for details.
%
%   Vq = INTERP3(X,Y,Z,V,Xq,Yq,Zq) interpolates to find Vq, the values
%   of the underlying 3-D function V at the query points in arrays Xq,Yq
%   and Zq. Xq,Yq,Zq must be arrays of the same size or vectors.
%   Vector arguments that are not the same size, and have mixed
%   orientations (i.e. with both row and column vectors) are passed
%   through MESHGRID to create the arrays. Arrays X,Y and Z specify the
%   points at which the data V is given.
%
%   Vq = INTERP3(V,Xq,Yq,Zq) assumes X=1:N, Y=1:M, Z=1:P 
%   where [M,N,P]=SIZE(V).
%
%   Vq = INTERP3(V,K) returns the interpolated values on a refined grid
%   formed by repeatedly halving the intervals K times in each dimension.
%   This results in 2^K-1 interpolated points between sample values.
%
%   Vq = INTERP3(V) is the same as INTERP3(V,1).
%
%   Vq = INTERP3(...,METHOD) specifies alternate methods.  The default
%   is linear interpolation.  Available methods are:
%
%     'nearest' - nearest neighbor interpolation
%     'linear'  - linear interpolation
%     'spline'  - spline interpolation
%     'cubic'   - cubic interpolation as long as the data is uniformly
%                 spaced, otherwise the same as 'spline'
%     'makima'  - modified Akima cubic interpolation
%
%   Vq = INTERP3(...,METHOD,EXTRAPVAL) specifies a method and a value for
%   Vq outside of the domain created by X,Y and Z.  Thus, Vq will equal
%   EXTRAPVAL for any value of Xq,Yq or Zq that is not spanned by X,Y and Z
%   respectively.  A method must be specified for EXTRAPVAL to be used, the
%   default method is 'linear'.
%
%   All the interpolation methods require that X,Y and Z be monotonic and
%   plaid (as if they were created using MESHGRID). X,Y, and Z can be
%   non-uniformly spaced.
%
%   For example, to generate a course approximation of FLOW and
%   interpolate over a finer mesh:
%       [X,Y,Z,V] = flow(10);
%       [Xq,Yq,Zq] = meshgrid(.1:.25:10,-3:.25:3,-3:.25:3);
%       Vq = interp3(X,Y,Z,V,Xq,Yq,Zq); % Vq is 25-by-40-by-25
%       slice(Xq,Yq,Zq,Vq,[6 9.5],2,[-2 .2]), shading flat
%
%   See also INTERP1, INTERP2, INTERPN, MESHGRID,
%            griddedInterpolant, scatteredInterpolant.

%   Copyright 1984-2017 The MathWorks, Inc.

narginchk(1,9); % allowing for an ExtrapVal

if nargin == 9 && (isnumeric(varargin{end})==false || isscalar(varargin{end}) ==false)
    error(message('MATLAB:interp3:InvalidExtrapval'))
elseif nargin == 6 && (ischar(varargin{end-1}) || (isstring(varargin{end-1}) && isscalar(varargin{end-1}))) && ...
        (isnumeric(varargin{end})==false || isscalar(varargin{end}) ==false)
    error(message('MATLAB:interp3:InvalidExtrapval'))
end

% Parse the method and extrap val
[narg, method, ExtrapVal] = methodandextrapval(varargin{:});
stripNaNsForCubics = strcmpi(method,'spline') || strcmpi(method,'makima');
if stripNaNsForCubics 
    extrap = method;
else
    extrap = 'none';
end
% Construct the interpolant, narg should be 2,4 or 7 at this point.

if narg ~= 1 && narg ~= 2 && narg ~= 4 && narg ~= 7
    error(message('MATLAB:interp3:nargin'));
end

p = [2 1 3];
if narg == 1 || narg == 2
    %  interp2(V,NTIMES)
    V = varargin{1};
    [nrows,ncols,npages] = size(V);
    if narg == 1
        ntimes = 1;
    else
        ntimes = floor(varargin{2}(1));
    end
    
    if ~isscalar(ntimes) || ~isreal(ntimes)
        error(message('MATLAB:interp3:NtimesInvalid'));
    end
    
    Xq = 1:1/(2^ntimes):ncols;
    Yq = (1:1/(2^ntimes):nrows)';
    Zq = (1:1/(2^ntimes):npages);
    [X, Y, Z] = meshgridvectors(V);
    V = permute(V,p);
    if stripNaNsForCubics
        [X,Y,Z, V] = stripnanwrapper(X,Y,Z,V);
    end
    [V, origvtype] = convertv(V,method, Xq, Yq,Zq);
    F = griddedInterpolant({X,Y,Z},V,method,extrap);
elseif narg == 4
    %  interp2(V,Xq,Yq,Zq)
    V =  varargin{1};
    Xq = varargin{2};
    Yq = varargin{3};
    Zq = varargin{4};
    [X, Y, Z] = meshgridvectors(V);
    V = permute(V,p);
    if stripNaNsForCubics
        [X,Y,Z, V] = stripnanwrapper(X,Y,Z,V);
    end
    [V, origvtype] = convertv(V,method, Xq, Yq,Zq);
    F = griddedInterpolant({X,Y,Z},V,method,extrap);
elseif narg == 7
    %  interp2(X,Y,Z,V,Xq,Yq,Zq)
    X = varargin{1};
    Y = varargin{2};
    Z = varargin{3};
    V = varargin{4};
    
    Xq = varargin{5};
    Yq = varargin{6};
    Zq = varargin{7};
    if isvector(X) && isvector(Y) && isvector(Z)
        V = permute(V,p);
        [X, Y, Z, V] = checkmonotonic(X,Y,Z,V);
        [V, origvtype] = convertv(V,method, Xq, Yq,Zq);
        if stripNaNsForCubics
            [X,Y,Z,V] = stripnanwrapper(X,Y,Z,V);
        end
        F = griddedInterpolant({X, Y, Z}, V, method,extrap);
    else
        X = permute(X,p);
        Y = permute(Y,p);
        Z = permute(Z,p);
        V = permute(V,p);
        [X, Y, Z, V] = checkmonotonic(X,Y,Z,V);
        [V, origvtype] = convertv(V,method, Xq, Yq,Zq);
        if stripNaNsForCubics
            [X,Y,Z,V] = stripnanwrapper(X,Y,Z,V);
        end
        try
            F = griddedInterpolant(X, Y, Z, V, method,extrap);
        catch gime
            if any(strcmp(gime.identifier,{'MATLAB:griddedInterpolant:NotNdGridErrId', ...
                'MATLAB:griddedInterpolant:NdgridNotMeshgrid3DErrId'}))
                error(message('MATLAB:interp3:InvalidMeshgrid'));
            else
                rethrow(gime);
            end
        end
    end
end

if strcmpi(method,'cubic') && strcmpi(F.Method,'spline')
    % Uniformity condition not met
    gv = F.GridVectors;
    FV = F.Values;
    [X, Y, Z, V] = stripnanwrapper(gv{:},FV);
    F = griddedInterpolant({X,Y,Z},V,'spline');
end

% Now interpolate
scopedWarnOff = warning('off', 'MATLAB:griddedInterpolant:MeshgridEval3DWarnId');
restoreWarnOff = onCleanup(@()warning(scopedWarnOff));

transposedquery = false;
iscompact = compactgridformat(Xq, Yq, Zq);
if iscompact || (strcmpi(F.Method,'spline') && isscalar(Xq) && isscalar(Yq) && isscalar(Zq))
    Vq = F({Xq,Yq,Zq});
elseif isvector(Xq)==false && isvector(Yq)==false && isvector(Zq)==false && ...
        ndims(Xq) == 3 && ndims(Yq) == 3 && ndims(Zq) == 3
    Xq = permute(Xq,p);
    Yq = permute(Yq,p);
    Zq = permute(Zq,p);
    Vq = F(Xq,Yq,Zq);  % NDGRID format gives better performance.
    transposedquery = true;
else
    Vq = F(Xq,Yq,Zq);
end

if ~isempty(ExtrapVal)
    % If ExtrapVal is provided, impose the extrapolation value to the queries
    % that lie outside the domain.
    Vq = imposeextrapval({Xq, Yq, Zq}, F.GridVectors, Vq, ExtrapVal,iscompact);
end

if iscompact ||  transposedquery
    % Compact grid evaluation produces a NDGRID
    % Convert to MESHGRID
    Vq = permute(Vq,p);
end


if ~strcmp(origvtype,'double') && ~strcmp(origvtype,'single')
    Vq = cast(Vq,origvtype);
end

    function [X, Y, Z, V] = stripnanwrapper(X,Y,Z,V)
        numvbefore = numel(V);
        [X, Y, Z, V] = stripnansforspline(X,Y,Z,V);
        if numvbefore > numel(V)
            warning(message('MATLAB:interp3:NaNstrip'));
        end
        if ismatrix(V) || isempty(V)
            error(message('MATLAB:interp3:NotEnoughPointsNanStrip'));
        end
    end

    function [V, origvtype] = convertv(V,method, Xq, Yq,Zq)
        origvtype = class(V);
        if ~isfloat(V) && (strcmpi(method,'nearest') || (isscalar(Xq) && isscalar(Yq) && isscalar(Zq)))
            V = double(V);
        end
    end
end
