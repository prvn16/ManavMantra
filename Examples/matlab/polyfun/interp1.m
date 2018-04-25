function Vout = interp1(varargin)
%INTERP1 1-D interpolation (table lookup)
%
%   Vq = INTERP1(X,V,Xq) interpolates to find Vq, the values of the
%   underlying function V=F(X) at the query points Xq. 
%
%   X must be a vector. The length of X is equal to N.
%   If V is a vector, V must have length N, and Vq is the same size as Xq.
%   If V is an array of size [N,D1,D2,...,Dk], then the interpolation is
%   performed for each D1-by-D2-by-...-Dk value in V(i,:,:,...,:). If Xq
%   is a vector of length M, then Vq has size [M,D1,D2,...,Dk]. If Xq is 
%   an array of size [M1,M2,...,Mj], then Vq is of size
%   [M1,M2,...,Mj,D1,D2,...,Dk].
%
%   Vq = INTERP1(V,Xq) assumes X = 1:N, where N is LENGTH(V)
%   for vector V or SIZE(V,1) for array V.
%
%   Interpolation is the same operation as "table lookup".  Described in
%   "table lookup" terms, the "table" is [X,V] and INTERP1 "looks-up"
%   the elements of Xq in X, and, based upon their location, returns
%   values Vq interpolated within the elements of V.
%
%   Vq = INTERP1(X,V,Xq,METHOD) specifies the interpolation method.
%   The available methods are:
%
%     'linear'   - (default) linear interpolation
%     'nearest'  - nearest neighbor interpolation
%     'next'     - next neighbor interpolation
%     'previous' - previous neighbor interpolation
%     'spline'   - piecewise cubic spline interpolation (SPLINE)
%     'pchip'    - shape-preserving piecewise cubic interpolation
%     'cubic'    - same as 'pchip'
%     'v5cubic'  - the cubic interpolation from MATLAB 5, which does not
%                  extrapolate and uses 'spline' if X is not equally
%                  spaced.
%     'makima'   - modified Akima cubic interpolation
%
%   Vq = INTERP1(X,V,Xq,METHOD,'extrap') uses the interpolation algorithm
%   specified by METHOD to perform extrapolation for elements of Xq outside
%   the interval spanned by X.
%
%   Vq = INTERP1(X,V,Xq,METHOD,EXTRAPVAL) replaces the values outside of
%   the interval spanned by X with EXTRAPVAL.  NaN and 0 are often used for
%   EXTRAPVAL.  The default extrapolation behavior with four input
%   arguments is 'extrap' for 'spline', 'pchip' and 'makima', and
%   EXTRAPVAL = NaN (NaN+NaN*1i for complex values) for the other methods.
%
%   PP = INTERP1(X,V,METHOD,'pp') is not recommended. Use
%   griddedInterpolant instead.
%   PP = INTERP1(X,V,METHOD,'pp') uses the interpolation algorithm
%   specified by METHOD to generate the ppform (piecewise polynomial form)
%   of V. The method may be any of the above METHOD except for 'v5cubic'
%   and 'makima'. PP may then be evaluated via PPVAL. PPVAL(PP,Xq) is the
%   same as INTERP1(X,V,Xq,METHOD,'extrap').
%
%   For example, generate a coarse sine curve and interpolate over a
%   finer abscissa:
%       X = 0:10; V = sin(X); Xq = 0:.25:10;
%       Vq = interp1(X,V,Xq); plot(X,V,'o',Xq,Vq,':.')
%
%   For a multi-dimensional example, we construct a table of functional
%   values:
%       X = [1:10]'; V = [ X.^2, X.^3, X.^4 ];
%       Xq = [ 1.5, 1.75; 7.5, 7.75]; Vq = interp1(X,V,Xq);
%
%   creates 2-by-2 matrices of interpolated function values, one matrix for
%   each of the 3 functions. Vq will be of size 2-by-2-by-3.
%
%   Class support for inputs X, V, Xq, EXTRAPVAL:
%      float: double, single
%
%   See also INTERPFT, SPLINE, PCHIP, INTERP2, INTERP3, INTERPN, PPVAL,
%            griddedInterpolant, scatteredInterpolant.

%   Copyright 1984-2017 The MathWorks, Inc.

narginchk(2,5);
[method,extrapval,ndataarg,pp] = parseinputs(varargin{:});

% PP = INTERP1(X,V,METHOD,'pp')
if ~isempty(pp)
    Vout = pp;
    return
end

if ndataarg == 2
    % INTERP1(V,Xq)
    [V,orig_size_v] = reshapeValuesV(varargin{1});
    X =(1:size(V,1))';
    Xq = varargin{2};
elseif ndataarg == 3
    % INTERP1(X,V,Xq)
    [X,V,orig_size_v] = reshapeAndSortXandV(varargin{1},varargin{2});
    Xq = varargin{3};
else
    error(message('MATLAB:interp1:nargin'));
end

if size(V,1) == 1 && isempty(Xq) && ~issparse(Xq)
    % INTERP1(scalarV,[]), INTERP1(x,scalarV,[])
    Vout = cast(zeros(size(Xq)),superiorfloat(V,Xq));
    return
end

if isvector(V)% V is a vector so size(Vq) == size(Xq)
    siz_vq = size(Xq);
else
    if isvector(Xq)% V is not a vector but Xq is. Batch evaluation.
        siz_vq = [length(Xq) orig_size_v(2:end)];
    else% Both V and Xq are non-vectors
        siz_vq = [size(Xq) orig_size_v(2:end)];
    end
end

if ~isempty(extrapval)
    if ~isempty(Xq) && isfloat(Xq) && isreal(Xq)
        % Impose the extrap val; this is independent of method
        extptids = Xq < X(1) | Xq > X(end);
        if any(extptids(:))
            Xq = Xq(~extptids);
        else
            extrapval = [];
        end
    else
        extrapval = [];
    end
end

Xqcol = Xq(:);
num_vals = size(V,2);
if any(~isfinite(V(:))) ...
      || (num_vals > 1 && any(strcmpi(method,{'pchip','next','previous'}))) ...
      || (num_vals == 2 && strcmpi(method,'cubic'))
    F = griddedInterpolant(X,V(:,1),method);
    if any(strcmpi(F.Method,{'spline','pchip','makima'})) && any(isnan(V(:)))
        VqLite = Interp1DStripNaN(X,V,Xq,F.Method);
    else
        VqLite = zeros(numel(Xqcol),num_vals);
        VqLite(:,1) = F(Xqcol);
        for iv = 2:num_vals
            F.Values = V(:,iv);
            VqLite(:,iv) = F(Xqcol);
        end
    end
else % can use ND
    if (num_vals > 1)
        Xext = {cast(X,'double'),(1:num_vals)'};
        F = griddedInterpolant(Xext,V,method);
        VqLite = F({cast(Xqcol,class(Xext{1})),Xext{2:end}});
    else
        F = griddedInterpolant(X,V,method);
        VqLite = F(Xqcol);
    end
end

if ~isempty(extrapval)
    if ischar(extrapval) || (isstring(extrapval) && isscalar(extrapval))
        if ~isreal(V)
            extrapval = NaN + 1i*NaN;
        else
            extrapval = NaN;
        end
    end
    % Vq is too small since elems of Xq were removed.
    sizeVqLite = size(VqLite);
    Vq = zeros([siz_vq(1) sizeVqLite(2:end)],superiorfloat(X,V,Xq));
    Vq(~extptids,:) = VqLite;
    Vq(extptids,:)  = extrapval;
    % Reshape result, possibly to an ND array
    Vout = reshape(Vq,siz_vq);
else
    VqLite = reshape(VqLite,siz_vq);
    Vout = cast(VqLite,superiorfloat(X,V,Xq));
end

end % INTERP1

%-------------------------------------------------------------------------%
function Vq = Interp1DStripNaN(X,V,Xq,method)

Xqcol = Xq(:);
num_value_sets = 1;
numXq = numel(Xqcol);
if ~isvector(V)
    num_value_sets = size(V,2);
end

% Allocate Vq
Vq = zeros(numXq,num_value_sets);
nans_stripped = false;
for i = 1:num_value_sets
    numvbefore = numel(V(:,i));
    [xi, vi] = stripnansforspline(X,V(:,i));
    numvafter = numel(vi);
    if numvbefore > numvafter
        nans_stripped = true;
    end
    F = griddedInterpolant(xi,vi,method);
    if isempty(Xq)
        Vq(:,i) = Xqcol;
    else
        Vq(:,i) = F(Xqcol);
    end
end
if nans_stripped
    warning(message('MATLAB:interp1:NaNstrip'));
end
end

%-------------------------------------------------------------------------%
%     'nearest'  - nearest neighbor interpolation
%     'next'     - next neighbor interpolation
%     'previous' - previous neighbor interpolation
%     'linear'   - linear interpolation
%     'spline'   - piecewise cubic spline interpolation (SPLINE)
%     'pchip'    - shape-preserving piecewise cubic interpolation
%     'cubic'    - same as 'pchip'
%     'v5cubic'  - the cubic interpolation from MATLAB 5
%     'makima'   - modified Akima cubic interpolation
function methodname = sanitycheckmethod(method_in)
method = char(method_in); %string support
if isempty(method)
    methodname = 'linear';
else
    if method(1) == '*'
        method(1) = [];
    end
    switch lower(method(1))
        case 'n'
            if strncmpi(method,'nex',3)
                methodname = 'next';
            else
                methodname = 'nearest';
            end
        case 'l'
            methodname = 'linear';
        case 's'
            methodname = 'spline';
        case 'c'
            methodname = 'pchip';
            warning(message('MATLAB:interp1:UsePCHIP'));
        case 'p'
            if strncmpi(method,'pr',2)
                methodname = 'previous';
            else
                methodname = 'pchip';
            end
        case 'v'  % 'v5cubic'
            methodname = 'cubic';
        case 'm'
            methodname = 'makima';
        otherwise
            error(message('MATLAB:interp1:InvalidMethod'));
    end
end
end

%-------------------------------------------------------------------------%
function pp = ppinterp(X,V, orig_size_v, method)
%PPINTERP ppform interpretation.
n = size(V,1);
ds = 1;
prodDs = 1;
if ~isvector(V)
    ds = orig_size_v(2:end);
    prodDs = size(V,2);
end

switch method(1)
    case 'n' % next and nearest
        if strcmpi(method(3), 'x')
            error(message('MATLAB:interp1:ppGriddedInterpolantNext'));
        else
            breaks = [X(1); (X(1:end-1)+X(2:end))/2; X(end)].';
            coefs = V.';
            pp = mkpp(breaks,coefs,ds);
        end
    case 'l' % linear
        breaks = X.';
        page1 = (diff(V)./repmat(diff(X),[1, prodDs])).';
        page2 = (reshape(V(1:end-1,:),[n-1, prodDs])).';
        coefs = cat(3,page1,page2);
        pp = mkpp(breaks,coefs,ds);
    case 'p' % previous, pchip and cubic
        if strcmpi(method(2), 'r')
			error(message('MATLAB:interp1:ppGriddedInterpolantPrevious'));
        else
            pp = pchip(X.',reshape(V.',[ds, n]));
        end
    case 's' % spline
        pp = spline(X.',reshape(V.',[ds, n]));
    case 'c' % v5cubic
        b = diff(X);
        if norm(diff(b),Inf) <= eps(norm(X,Inf))
            % data are equally spaced
            a = repmat(b,[1 prodDs]).';
            yReorg = [3*V(1,:)-3*V(2,:)+V(3,:); ...
                V; ...
                3*V(n,:)-3*V(n-1,:)+V(n-2,:)];
            y1 = yReorg(1:end-3,:).';
            y2 = yReorg(2:end-2,:).';
            y3 = yReorg(3:end-1,:).';
            y4 = yReorg(4:end,:).';
            breaks = X.';
            page1 = (-y1+3*y2-3*y3+y4)./(2*a.^3);
            page2 = (2*y1-5*y2+4*y3-y4)./(2*a.^2);
            page3 = (-y1+y3)./(2*a);
            page4 = y2;
            coefs = cat(3,page1,page2,page3,page4);
            pp = mkpp(breaks,coefs,ds);
        else
            % data are not equally spaced
            pp = spline(X.',reshape(V.',[ds, n]));
        end
end

% Even if method is 'spline' or 'pchip', we still need to record that the
% input data V was oriented according to INTERP1's rules.
% Thus PPVAL will return Vq oriented according to INTERP1's rules and
% Vq = INTERP1(X,Y,Xq,METHOD) will be the same as
% Vq = PPVAL(INTERP1(X,Y,METHOD,'pp'),Xq)
pp.orient = 'first';

end % PPINTERP
%-------------------------------------------------------------------------%
function [method,extrapval,ndataarg,pp] = parseinputs(varargin)
% Determine input arguments.
% Work backwards parsing from the end argument.

% Set up the defaults
method = 'linear';
extrapval = 'default';
pp = [];
ndataarg = nargin; % Number of X,V,Xq args. Init to nargin and reduce.
if nargin == 2 && isfloat(varargin{2})
    return
end
if nargin == 3 && isfloat(varargin{3})
    if ischar(varargin{2}) || (isstring(varargin{2}) && isscalar(varargin{2}))
        error(message('MATLAB:interp1:nargin'));
    end
    return
end
if ischar(varargin{end}) || (isstring(varargin{end}) && isscalar(varargin{end}))
    if strcmp(varargin{end},'pp')
        if (nargin ~= 4)
            error(message('MATLAB:interp1:ppOutput'))
        end
        method = sanitycheckmethod(varargin{end-1});
        if strcmp(method,'makima')
            error(message('MATLAB:interp1:ppAkima'));
        end
        [X,V,orig_size_v] = reshapeAndSortXandV(varargin{1},varargin{2});
        % Use griddedInterpolant constructor for remaining error checks
        griddedInterpolant(X,V(:,1));
        pp = ppinterp(X, V, orig_size_v, method);
        return
    elseif strcmp(varargin{end},'extrap')
        if (nargin ~= 4 && nargin ~= 5)
            error(message('MATLAB:interp1:nargin'));
        end
        if ~(isempty(varargin{end-1}) || ischar(varargin{end-1}) || (isstring(varargin{end-1}) && isscalar(varargin{end-1})))
            error(message('MATLAB:interp1:ExtrapNoMethod'));
        end
        method = sanitycheckmethod(varargin{end-1});
        ndataarg = nargin-2;
        extrapval = [];
        if(strcmp(method,'cubic'))
            extrapval = 'default';
            warning(message('MATLAB:interp1:NoExtrapForV5cubic'))
        end  
    else
        if ischar(varargin{end-1}) || (isstring(varargin{end-1}) && isscalar(varargin{end-1}))
            error(message('MATLAB:interp1:InvalidSpecPPExtrap'))
        end
        method = sanitycheckmethod(varargin{end});
        needextrapval = ~any(strcmpi(method,{'spline','pchip','makima'}));
        if ~needextrapval
            extrapval = [];
        end
        ndataarg = nargin-1;
    end
    return
end
endisscalar = isscalar(varargin{end});
if endisscalar && (ischar(varargin{end-1}) || (isstring(varargin{end-1}) && isscalar(varargin{end-1})))
    extrapval = varargin{end};
    ndataarg = nargin-2;
    method = sanitycheckmethod(varargin{end-1});
    return 
end
if endisscalar && isempty(varargin{end-1}) && (nargin == 4 || nargin == 5)
    % default method via []
    extrapval = varargin{end};
    ndataarg = nargin-2;
    return 
end
if isempty(varargin{end})
    % This is potentially ambiguous, the assumed intent is case I
    % I)    X, V, []   Empty query
    % II)   V, [], [] Empty query and empty method,
    % III)  V, Xq, [] Empty method
    if nargin ~= 3
        ndataarg = nargin-1;
    end
    return
end
end
%-------------------------------------------------------------------------%
function [x,V,orig_size_v] = reshapeAndSortXandV(x,V)
% Reshape and sort x and V. Minimal error checking. The rest of the error
% checking is done later in the griddedInterpolant constructor.
if ~isfloat(x)
    error(message('MATLAB:interp1:Xnumeric'));
end
if ~isvector(x) % also catches empty x
    error(message('MATLAB:interp1:Xvector'));
end
[V,orig_size_v] = reshapeValuesV(V);
% Reshape x and V
x = x(:);
if numel(x) ~= size(V,1)
    if isvector(V)
        error(message('MATLAB:interp1:YVectorInvalidNumRows'))
    else
        error(message('MATLAB:interp1:YInvalidNumRows'));
    end
end
% We can now safely index into V
if ~issorted(x)
    [x,idx] = sort(x);
    V = V(idx,:);
end
end
%-------------------------------------------------------------------------%
function [V, orig_size_v] = reshapeValuesV(V)
% Reshapes V into a matrix so that we can interpolate down each column
if ~isfloat(V)
    error(message('MATLAB:interp1:NonFloatValues'));
end
orig_size_v = size(V);
if isvector(V)
    V = V(:);
elseif ~ismatrix(V)
    nrows = orig_size_v(1);
    ncols = prod(orig_size_v(2:end));
    V = reshape(V,[nrows ncols]);
end
end
