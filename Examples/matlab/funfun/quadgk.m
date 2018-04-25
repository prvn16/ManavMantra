function [q,errbnd] = quadgk(FUN,a,b,varargin)
%QUADGK  Numerically evaluate integral, adaptive Gauss-Kronrod quadrature.
%   Q = QUADGK(FUN,A,B) attempts to approximate the integral of
%   scalar-valued function FUN from A to B using high order global adaptive
%   quadrature and default error tolerances. The function Y=FUN(X) should
%   accept a vector argument X and return a vector result Y, the integrand
%   evaluated at each element of X. FUN must be a function handle. A and B
%   can be -Inf or Inf. If both are finite, they can be complex. If at
%   least one is complex, the integral is approximated over a straight line
%   path from A to B in the complex plane.
%
%   [Q,ERRBND] = QUADGK(...). ERRBND is an approximate upper bound on the
%   absolute error, |Q - I|, where I denotes the exact value of the
%   integral.
%
%   [Q,ERRBND] = QUADGK(FUN,A,B,PARAM1,VAL1,PARAM2,VAL2,...) performs
%   the integration with specified values of optional parameters. The
%   available parameters are
%
%   'AbsTol', absolute error tolerance
%   'RelTol', relative error tolerance
%
%       QUADGK attempts to satisfy ERRBND <= max(AbsTol,RelTol*|Q|). This
%       is absolute error control when |Q| is sufficiently small and
%       relative error control when |Q| is larger. A default tolerance
%       value is used when a tolerance is not specified. The default value
%       of 'AbsTol' is 1.e-10 (double), 1.e-5 (single). The default value
%       of 'RelTol' is 1.e-6 (double), 1.e-4 (single). For pure absolute
%       error control use
%         Q = quadgk(FUN,A,B,'AbsTol',ATOL,'RelTol',0)
%       where ATOL > 0. For pure relative error control use
%         Q = quadgk(FUN,A,B,'RelTol',RTOL,'AbsTol',0)
%       Except when using pure absolute error control, the minimum relative
%       tolerance is 100*eps(class(Q)).
%
%   'Waypoints', vector of integration waypoints
%
%       If FUN(X) has discontinuities in the interval of integration, the
%       locations should be supplied as a 'Waypoints' vector. When A, B,
%       and the waypoints are all real, only the waypoints between A and B
%       are used, and they are used in sorted order.  Note that waypoints
%       are not intended for singularities in FUN(X). Singular points
%       should be handled by making them endpoints of separate integrations
%       and adding the results.
%
%       If A, B, or any entry of the waypoints vector is complex, the
%       integration is performed over a sequence of straight line paths in
%       the complex plane, from A to the first waypoint, from the first
%       waypoint to the second, and so forth, and finally from the last
%       waypoint to B.
%
%   'MaxIntervalCount', maximum number of intervals allowed
%
%       The 'MaxIntervalCount' parameter limits the number of intervals
%       that QUADGK will use at any one time after the first iteration. A
%       warning is issued if QUADGK returns early because of this limit.
%       The default value is 650. Increasing this value is not recommended,
%       but it may be appropriate when ERRBND is small enough that the
%       desired accuracy has nearly been achieved.
%
%   Consider using INTEGRAL instead of QUADGK. INTEGRAL uses the same
%   method as QUADGK and also supports vector-valued integrands.
%
%   Example:
%   Integrate f(x) = exp(-x^2)*log(x)^2 from 0 to infinity:
%      f = @(x) exp(-x.^2).*log(x).^2
%      Q = quadgk(f,0,Inf)
%
%   Example:
%   To use a parameter in the integrand:
%      f = @(x,c) 1./(x.^3-2*x-c);
%      Q = quadgk(@(x)f(x,5),0,2);
%
%   Example:
%   Integrate f(z) = 1/(2z-1) in the complex plane over the triangular
%   path from 0 to 1+1i to 1-1i to 0:
%      Q = quadgk(@(z)1./(2*z-1),0,0,'Waypoints',[1+1i,1-1i])
%
%   Class support for inputs A, B, and the output of FUN:
%      float: double, single
%
%   See also INTEGRAL, INTEGRAL2, INTEGRAL3, QUAD, QUADL, QUADV, QUAD2D,
%   DBLQUAD, TRIPLEQUAD, FUNCTION_HANDLE

%   Based on "quadva" by Lawrence F. Shampine.
%   Ref: L.F. Shampine, "Vectorized Adaptive Quadrature in Matlab",
%   Journal of Computational and Applied Mathematics 211, 2008, pp.131-140.

%   Copyright 2007-2015 The MathWorks, Inc.

% Variable names in all caps are referenced in nested functions.

% Validate the first three inputs.
narginchk(3,inf);
if ~isa(FUN,'function_handle')
    error(message('MATLAB:quadgk:funArgNotHandle'));
end
if ~(isscalar(a) && isfloat(a) && isscalar(b) && isfloat(b))
    error(message('MATLAB:quadgk:invalidEndpoint'));
end

% Gauss-Kronrod (7,15) pair. Use symmetry in defining nodes and weights.
pnodes = [ ...
    0.2077849550078985; 0.4058451513773972; 0.5860872354676911; ...
    0.7415311855993944; 0.8648644233597691; 0.9491079123427585; ...
    0.9914553711208126];
pwt = [ ...
    0.2044329400752989, 0.1903505780647854, 0.1690047266392679, ...
    0.1406532597155259, 0.1047900103222502, 0.06309209262997855, ...
    0.02293532201052922];
pwt7 = [0,0.3818300505051189,0,0.2797053914892767,0,0.1294849661688697,0];
NODES = [-pnodes(end:-1:1); 0; pnodes];
WT = [pwt(end:-1:1), 0.2094821410847278, pwt];
EWT = WT - [pwt7(end:-1:1), 0.4179591836734694, pwt7];

% Fixed parameters.
DEFAULT_DOUBLE_ABSTOL = 1.e-10;
DEFAULT_SINGLE_ABSTOL = 1.e-5;
DEFAULT_DOUBLE_RELTOL = 1.e-6;
DEFAULT_SINGLE_RELTOL = 1.e-4;
MININTERVALCOUNT = 10; % Minimum number subintervals to start.

% Process optional input.
p = inputParser;
p.addParamValue('AbsTol',[],@validateAbsTol);
p.addParamValue('RelTol',[],@validateRelTol);
p.addParamValue('MaxIntervalCount',650,@validateMaxIntervalCount);
p.addParamValue('Waypoints',[],@validateWaypoints);
p.parse(varargin{:});
optionStruct = p.Results;
ATOL = optionStruct.AbsTol;
RTOL = optionStruct.RelTol;
MAXINTERVALCOUNT = optionStruct.MaxIntervalCount;
WAYPOINTS = optionStruct.Waypoints(:).';

% Initialize the FIRSTFUNEVAL variable.  Some checks will be done just
% after the first evaluation.
FIRSTFUNEVAL = true;

% Handle contour integration.
if ~(isreal(a) && isreal(b) && isreal(WAYPOINTS))
    tinterval = [a,WAYPOINTS,b];
    if any(~isfinite(tinterval))
        error(message('MATLAB:quadgk:nonFiniteContourError'));
    end
    % A and B should not be needed, so we do not define them here.
    % Perform the contour integration.
    [q,errbnd] = vadapt(@evalFun,tinterval);
    return
end

% Define A and B and note the direction of integration on real axis.
if b < a
    % Integrate left to right and change sign at the end.
    reversedir = true;
    A = b;
    B = a;
else
    reversedir = false;
    A = a;
    B = b;
end

% Trim and sort the waypoints vector.
WAYPOINTS = sort(WAYPOINTS(WAYPOINTS>A & WAYPOINTS<B));

% Construct interval vector with waypoints.
interval = [A, WAYPOINTS, B];
% Extract A and B from interval vector to regularize possible mixed
% single/double inputs.
A = interval(1);
B = interval(end);

% Identify the task and perform the integration.
if A == B
    % Handles both finite and infinite cases.
    % Return zero or nan of the appropriate class.
    q = midpArea(@evalFun,A,B);
    errbnd = q;
elseif isfinite(A) && isfinite(B)
    if numel(interval) > 2
        % Analytical transformation suggested by K.L. Metlov:
        alpha = 2*sin( asin((A + B - 2*interval(2:end-1))/(A - B))/3 );
        interval = [-1,alpha,1];
    else
        interval = [-1,1];
    end
    [q,errbnd] = vadapt(@f1,interval);
elseif isfinite(A) && isinf(B)
    if numel(interval) > 2
        alpha = sqrt(interval(2:end-1) - A);
        interval = [0,alpha./(1+alpha),1];
    else
        interval = [0,1];
    end
    [q,errbnd] = vadapt(@f2,interval);
elseif isinf(A) && isfinite(B)
    if numel(interval) > 2
        alpha = sqrt(B - interval(2:end-1));
        interval = [-1,-alpha./(1+alpha),0];
    else
        interval = [-1,0];
    end
    [q,errbnd] = vadapt(@f3,interval);
elseif isinf(A) && isinf(B)
    if numel(interval) > 2
        % Analytical transformation suggested by K.L. Metlov:
        alpha = tanh( asinh(2*interval(2:end-1))/2 );
        interval = [-1,alpha,1];
    else
        interval = [-1,1];
    end
    [q,errbnd] = vadapt(@f4,interval);
else % i.e., if isnan(a) || isnan(b)
    q = midpArea(@evalFun,A,B);
    errbnd = q;
end
% Account for integration direction.
if reversedir
    q = -q;
end

%==Nested functions=========================================================

    function [q,errbnd] = vadapt(f,tinterval)
        % Iterative routine to perform the integration.
        % Compute the path length and split tinterval if needed.
        [tinterval,pathlen] = split(tinterval,MININTERVALCOUNT);
        if pathlen == 0
            % Test case: quadgk(@(x)x,1+1i,1+1i);
            q = midpArea(f,tinterval(1),tinterval(end));
            errbnd = q;
            return
        end
        % Initialize array of subintervals of [a,b].
        subs = [tinterval(1:end-1);tinterval(2:end)];
        % Initialize partial sums.
        q_ok = 0;
        err_ok = 0;
        % Initialize main loop
        while true
            % SUBS contains subintervals of [a,b] where the integral is not
            % sufficiently accurate. The first row of SUBS holds the left end
            % points and the second row, the corresponding right endpoints.
            midpt = sum(subs)/2;   % midpoints of the subintervals
            halfh = diff(subs)/2;  % half the lengths of the subintervals
            x = NODES*halfh + midpt;
            x = reshape(x,1,[]);   % function f expects a row vector
            [fx,too_close] = f(x);
            % Quit if mesh points are too close.
            if too_close
                break
            end
            fx = reshape(fx,numel(WT),[]);
            % Quantities for subintervals.
            qsubs = (WT*fx) .* halfh;
            errsubs = (EWT*fx) .* halfh;
            % Calculate current values of q and tol.
            q = sum(qsubs) + q_ok;
            tol = max(ATOL,RTOL*abs(q));
            % Locate subintervals where the approximate integrals are
            % sufficiently accurate and use them to update the partial
            % error sum.
            ndx = find(abs(errsubs) <= (2*tol/pathlen)*abs(halfh));
            err_ok = err_ok + sum(errsubs(ndx));
            % Remove errsubs entries for subintervals with accurate
            % approximations.
            errsubs(ndx) = [];
            % The approximate error bound is constructed by adding the
            % approximate error bounds for the subintervals with accurate
            % approximations to the 1-norm of the approximate error bounds
            % for the remaining subintervals.  This guards against
            % excessive cancellation of the errors of the remaining
            % subintervals.
            errbnd = abs(err_ok) + norm(errsubs,1);
            % Check for nonfinites.
            if ~(isfinite(q) && isfinite(errbnd))
                warning(message('MATLAB:quadgk:NonFiniteValue'));
                break
            end
            % Test for convergence.
            if errbnd <= tol
                break
            end
            % Remove subintervals with accurate approximations.
            subs(:,ndx) = [];
            if isempty(subs)
                break
            end
            % Update the partial sum for the integral.
            q_ok = q_ok + sum(qsubs(ndx));
            % Split the remaining subintervals in half. Quit if splitting
            % results in too many subintervals.
            nsubs = 2*size(subs,2);
            if nsubs > MAXINTERVALCOUNT
                warning(message('MATLAB:quadgk:MaxIntervalCountReached',sprintf('%9.1e',errbnd),nsubs));
                break
            end
            midpt(ndx) = []; % Remove unneeded midpoints.
            subs = reshape([subs(1,:); midpt; midpt; subs(2,:)],2,[]);
        end
    end % vadapt

%--------------------------------------------------------------------------

    function q = midpArea(f,a,b)
        % Return q = (b-a)*f((a+b)/2). Although formally correct as a low
        % order quadrature formula, this function is only used to return
        % nan or zero of the appropriate class when a == b, isnan(a), or
        % isnan(b).
        x = (a+b)/2;
        if isfinite(a) && isfinite(b) && ~isfinite(x)
            % Treat overflow, e.g. when finite a and b > realmax/2
            x = a/2 + b/2;
        end
        fx = f(x);
        if ~isfinite(fx)
            warning(message('MATLAB:quadgk:NonFiniteValue'));
        end
        q = (b-a)*fx;
    end % midpArea

%--------------------------------------------------------------------------

    function [fx,too_close] = evalFun(x)
        % Evaluate the integrand.
        if FIRSTFUNEVAL
            % Don't check the closeness of the mesh on the first iteration.
            too_close = false;
            fx = FUN(x);
            finalInputChecks(x,fx);
            FIRSTFUNEVAL = false;
        else
            too_close = checkSpacing(x);
            if too_close
                fx = [];
            else
                fx = FUN(x);
            end
        end
    end % evalFun

%--------------------------------------------------------------------------

    function [y,too_close] = f1(t)
        % Transform to weaken singularities at both ends: [a,b] -> [-1,1]
        tt = 0.25*(B-A)*t.*(3 - t.^2) + 0.5*(B+A);
        [y,too_close] = evalFun(tt);
        if ~too_close
            y = 0.75*(B-A)*y.*(1 - t.^2);
        end
    end % f1

%--------------------------------------------------------------------------

    function [y,too_close] = f2(t)
        % Transform to weaken singularity at left end: [a,Inf) -> [0,Inf).
        % Then transform to finite interval: [0,Inf) -> [0,1].
        tt = t ./ (1 - t);
        t2t = A + tt.^2;
        [y,too_close] = evalFun(t2t);
        if ~too_close
            y =  2*tt .* y ./ (1 - t).^2;
        end
    end % f2

%--------------------------------------------------------------------------

    function [y,too_close] = f3(t)
        % Transform to weaken singularity at right end: (-Inf,b] -> (-Inf,b].
        % Then transform to finite interval: (-Inf,b] -> (-1,0].
        tt = t ./ (1 + t);
        t2t = B - tt.^2;
        [y,too_close] = evalFun(t2t);
        if ~too_close
            y = -2*tt .* y ./ (1 + t).^2;
        end
    end % f3

%--------------------------------------------------------------------------

    function [y,too_close] = f4(t)
        % Transform to finite interval: (-Inf,Inf) -> (-1,1).
        tt = t ./ (1 - t.^2);
        [y,too_close] = evalFun(tt);
        if ~too_close
            y = y .* (1 + t.^2) ./ (1 - t.^2).^2;
        end
    end % f4

%--------------------------------------------------------------------------

    function too_close = checkSpacing(x)
        ax = abs(x);
        tcidx = find(abs(diff(x)) <= 100*eps(class(x))*max(ax(1:end-1),ax(2:end)),1);
        too_close = ~isempty(tcidx);
        if too_close
            warning(message('MATLAB:quadgk:MinStepSize',num2str(x(tcidx),6)));
        end
    end % checkSpacing

%--------------------------------------------------------------------------

    function [x,pathlen] = split(x,minsubs)
        % Split subintervals in the interval vector X so that, to working
        % precision, no subinterval is longer than 1/MINSUBS times the
        % total path length. Removes subintervals of zero length, except
        % that the resulting X will always has at least two elements on
        % return, i.e., if the total path length is zero, X will be
        % collapsed into a single interval of zero length.  Also returns
        % the integration path length.
        absdx = abs(diff(x));
        if isreal(x)
            pathlen = x(end) - x(1);
        else
            pathlen = sum(absdx);
        end
        if pathlen > 0
            udelta = minsubs/pathlen;
            nnew = ceil(absdx*udelta) - 1;
            idxnew = find(nnew > 0);
            nnew = nnew(idxnew);
            for j = numel(idxnew):-1:1
                k = idxnew(j);
                nnj = nnew(j);
                % Calculate new points.
                newpts = x(k) + (1:nnj)./(nnj+1)*(x(k+1)-x(k));
                % Insert the new points.
                x = [x(1:k),newpts,x(k+1:end)];
            end
        end
        % Remove useless subintervals.
        x(abs(diff(x))==0) = [];
        if isscalar(x)
            % Return at least two elements.
            x = [x(1),x(1)];
        end
    end % split

%--------------------------------------------------------------------------

    function finalInputChecks(x,fx)
        % Do final input validation with sample input and outputs to the
        % integrand function.
        % Check classes.
        if ~(isfloat(x) && isfloat(fx))
            error(message('MATLAB:quadgk:UnsupportedClass'));
        end
        % Check sizes.
        if ~isequal(size(x),size(fx))
            error(message('MATLAB:quadgk:FxNotSameSizeAsX'));
        end
        outcls = superiorfloat(x,fx);
        outdbl = strcmp(outcls,'double');
        % Validate tolerances and apply defaults.
        if isempty(RTOL)
            if outdbl
                RTOL = DEFAULT_DOUBLE_RELTOL;
            else
                RTOL = DEFAULT_SINGLE_RELTOL;
            end
        end
        if isempty(ATOL)
            if outdbl
                ATOL = DEFAULT_DOUBLE_ABSTOL;
            else
                ATOL = DEFAULT_SINGLE_ABSTOL;
            end
        end
        % Make sure that RTOL >= 100*eps(outcls) except when
        % using pure absolute error control (ATOL>0 && RTOL==0).
        if ~(ATOL > 0 && RTOL == 0) && RTOL < 100*eps(outcls)
            RTOL = 100*eps(outcls);
            warning(message('MATLAB:quadgk:increasedRelTol', outcls, sprintf( '%g', RTOL )));
        end
        if outdbl
            % Single RTOL or ATOL should not force any single precision
            % computations.
            RTOL = double(RTOL);
            ATOL = double(ATOL);
        end
    end % finalInputChecks

%==========================================================================

end % quadgk

%--------------------------------------------------------------------------

function p = validateAbsTol(x)
if ~(isfloat(x) && isscalar(x) && isreal(x) && x >= 0)
    error(message('MATLAB:quadgk:invalidAbsTol'));
end
p = true;
end

%--------------------------------------------------------------------------

function p = validateRelTol(x)
if ~(isfloat(x) && isscalar(x) && isreal(x) && x >= 0)
    error(message('MATLAB:quadgk:invalidRelTol'));
end
p = true;
end

%--------------------------------------------------------------------------

function p = validateWaypoints(x)
if ~(isvector(x) || isequal(x,[]))
    error(message('MATLAB:quadgk:WaypointsNotVector'));
elseif any(~isfinite(x))
    error(message('MATLAB:quadgk:WaypointsNotFinite'));
end
p = true;
end

%--------------------------------------------------------------------------

function p = validateMaxIntervalCount(x)
if ~(isscalar(x) && isreal(x) && x > 0 && floor(x) == x)
    error(message('MATLAB:quadgk:invalidMaxIntervalCount'));
end
p = true;
end

%--------------------------------------------------------------------------
