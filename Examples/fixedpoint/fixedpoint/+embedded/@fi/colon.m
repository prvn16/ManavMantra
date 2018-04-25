function y = colon(varargin)
%: Colon operator for fi objects.
%
%   See also COLON.

%   Copyright 2011-2013 The MathWorks, Inc.
    narginchk(2,3);

    if nargin==2
        J = varargin{1};
        K = varargin{2};
        D = 1;
    else
        J = varargin{1};
        D = varargin{2};
        K = varargin{3};
    end

    [J,D,K] = validate_inputs(J,D,K);

    [Py,J,D,K] = determine_type(J,D,K);

    if isempty(J) || isempty(D) || isempty(K) || ...
            D==0 || J>K && D>0 || J<K && D<0
        y = zeros(1,0,'like',Py);
    else
        if isequal(D,1)
            n = double(K-J);
        elseif isfi(J) 
            n = double(floor(divide(numerictype(J),K-J,D)));
        else
            n = floor((K-J)/D);
        end
        % If n is too big, then 0:n will naturally hit MATLAB's
        % 'MATLAB:pmaxsize' error 'Maximum variable size allowed by the
        % program is exceeded.' 
        t = 0:n;
        if isequal(D,1)
            y = J + cast(t,'like',J);
        else
            y = J + cast(t,'like',J)*D;
        end
        y = cast(y,'like',Py);
    end
end

function [J,D,K] = validate_inputs(J,D,K)
    % From the doc: If you specify nonscalar arrays, MATLAB interprets J:D:K
    % as J(1):D(1):K(1).
    J = make_scalar(J);
    D = make_scalar(D);
    K = make_scalar(K);
    if is_fi_logical(J) || is_fi_logical(D) || is_fi_logical(K)
        warning(message('MATLAB:colon:logicalInput'));
    end
    if ~isreal(J) || ~isreal(D) || ~isreal(K)
        warning(message('MATLAB:colon:operandsNotRealScalar'));
        J = real(J);
        D = real(D);
        K = real(K);
    end
    if isfi(J) && isscaledtype(J) && ~is_scaling_binary_point(J) || ...
            isfi(D) && isscaledtype(D) && ~is_scaling_binary_point(D) || ...
            isfi(K) && isscaledtype(K) && ~is_scaling_binary_point(K)
        error(message('fixed:fi:binaryPointOnlyMath','colon'));
    end
    if ~isequal(floor(J),J) || ~isequal(floor(D),D) || ~isequal(floor(K),K)
        error(message('fixed:fi:colonOperandsMustBeIntegerValued'));
    end
end

function [Py,J,D,K] = determine_type(J,D,K)
    [Psigned, Py] = fi_colon_type_impl(J,D,K);
    % Cast to the signed type first so the comparison to low and high will
    % work for unsigned fi being compared to negative doubles
    J = cast(J,'like',Psigned);
    D = cast(D,'like',Psigned);
    K = cast(K,'like',Psigned);
    if isfi(Py)
        [lower_bound,upper_bound] = range(Py);
        if ~isfi(Psigned)
            lower_bound = double(lower_bound);
            upper_bound = double(upper_bound);
        end
        if ~isempty(J) && (J<lower_bound || J>upper_bound) || ...
                ~isempty(K) && (K<lower_bound || K>upper_bound),...
               error(message('MATLAB:colon:OutOfRange'));
        end
    elseif isa(Py,'single')
        lower_bound = -realmax('single');
        upper_bound = realmax('single');
        if J<lower_bound || J>upper_bound || K<lower_bound || K>upper_bound,...
               error(message('MATLAB:colon:OutOfRange'));
        end
    end
end

function b = is_scaling_binary_point(x)
    b = x.SlopeAdjustmentFactor==1 && x.Bias==0;
end

function b = is_fi_logical(x)
    if isfi(x) 
        b = isboolean(x);
    else
        b = isa(x, 'logical');
    end
end

function x = make_scalar(x)
    if ~isempty(x) && ~isscalar(x), 
        % Builtin colon only uses the first element of an array.
        if isfi(x)
            % Can't use @fi/subsref (e.g. x(1) ) inside J method of fi.
            % @fi/subscriptedreference uses 0-based indexing.
            x = subscriptedreference(x,0);
        else
            x = x(1);
        end
    end
end
