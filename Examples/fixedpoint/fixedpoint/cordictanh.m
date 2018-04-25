function t = cordictanh(theta, varargin) %#codegen
% CORDICTANH CORDIC-based approximation of the hyperbolic tangent
%    T = CORDICTANH(THETA) computes TANH(THETA) using the CORDIC
%    approximation algorithm.
%
%    THETA can be a real scalar, vector, matrix, or N-dimensional array
%    containing the angle values in hyperbolic radians.
%
%    NITERS specifies the number of CORDIC kernel iterations. This is an
%    optional argument. More iterations may produce more accurate results
%    at the expense of more computation/latency. When you specify NITERS
%    as a numeric value, it must be a positive integer-valued scalar. If
%    you do not specify NITERS, or specify it as empty or non-finite, the
%    algorithm uses a maximum value. For fixed-point operations, the
%    maximum number of iterations is one less than the word length of
%    THETA. For floating-point operations, the maximum value is 52 for
%    double or 23 for single.
%
%    EXAMPLE: Compare the accuracy of CORDIC-based TANH results with the MATLAB TANH function.
%
%    wrdLn = 8;
%    theta = fi(pi/2, 1, wrdLn);
%    fprintf('\n\nNITERS\t\t (TANH)\t ERROR\t LSBs\n');
%    fprintf('------\t\t-------\t ------\t ----\n');
%    for niters = 1:(wrdLn - 1)
%        t      = cordictanh(theta, niters);
%        fl     = t.FractionLength;
%        t_dbl  = double(t);
%        t_err  = abs(t_dbl - tanh(double(theta)));
%        fprintf('  %d\t\t\t%1.4f\t %1.4f\t %1.1f\n', niters, t_dbl,...
%                                               t_err, (t_err * pow2(fl)));
%    end
%    fprintf('\n');

% Copyright 2017-2018 The MathWorks, Inc.
    
    %----------------------------MAIN FUNCTION-----------------------------

    % Ensure the user doesn't pass more than two arguments.
    narginchk(1,2);

    % We first validate the argument passed. THETA should be a non-boolean,
    % finite and real number. Any arguments not meeting the requirements
    % will cause an error.
    check_argument(theta);

    % We get the datatype of the output, the number of iterations and the
    % original input with a fimath object attached.
    [datatype, niters, new_theta] = get_cordic_types(theta, varargin{:});

    % Now we call some sub-functions to use the variables above to compute
    % tanh.
    t = zeros(size(new_theta), 'like', datatype.tanh);
    a = hyperbolic_angular_increments(niters, datatype);
    for i = 1:numel(new_theta)
        x = cast(1, 'like', datatype.tanh);
        y = cast(0, 'like', datatype.tanh);
        q = floor(new_theta(i)); % Integer
        r = new_theta(i) - q;    % Fractional remainder
        z = r;
        [c, s] = cordic_hyperbolic_kernel(x, y, z, a, niters);
        p = sinh_over_cosh(q, datatype, niters);
        t(i) = cordic_divide_kernel((c + p*s), (s + p*c),...
            cast(0, 'like', datatype.tanh), niters);
    end
    t = removefimath(t);
end

%--------------------------------SUB-FUNCTIONS-----------------------------

function check_argument(theta)
% This function validates the input passed to the cordictanh function. The
% error checking is broken down into separate clauses to make it easier
% to understand and debug.

    % Check if boolean
    coder.internal.errorIf(isfi(theta) && isboolean(theta),...
        'fixed:fi:unsupportedDataType', 'Boolean');

    % Check if non-numeric, complex, empty, NaN or inf
    coder.internal.errorIf(~isnumeric(theta) ||...
                           ~isreal(theta) || ...
                           isempty(theta) || ...
                           any(isnan(theta(:))) ||...
                           any(isinf(theta(:))),...
        'fixed:cordic:invalidHyperbolicArgument','cordictanh');

    % Check if it's something else...
    coder.internal.errorIf(isfi(theta) && ...
        ~(isscalingbinarypoint(theta) || isdouble(theta)...
          || issingle(theta)),...
        'fixed:fi:inputsMustBeFixPtBPSOrFloatSameDTMode');
end

function [datatype, niters, new_theta] = get_cordic_types(theta, varargin)
% This function decides the type and number of iterations to be used
% throughout the function based on the input theta.
    if isfi(theta)
        F = fimath('RoundingMethod', 'Nearest', ...
            'OverflowAction', 'Wrap', ...
            'ProductMode', 'SpecifyPrecision', ...
            'ProductWordLength', theta.WordLength,...
            'ProductFractionLength', theta.WordLength-2,...
            'SumMode', 'SpecifyPrecision',...
            'SumWordLength', theta.WordLength,...
            'SumFractionLength', theta.WordLength-3);
        % This is the minimum wordlength that we impose on the input.
        if theta.WordLength < 8
            wl = 8;
        else
            wl = theta.WordLength;
        end
        datatype.tanh = fi([], 1, wl, wl-2, F, 'DataType', theta.DataType);
        maxNITERS = int16(datatype.tanh.WordLength-1);
        new_theta = setfimath(theta, F);
    else
        datatype.tanh = cast([], 'like', theta);
        if isa(theta, 'single')
            maxNITERS = int16(23);
        else
            maxNITERS = int16(52);
        end
        new_theta = theta;
    end

    % If the user passed in niters, then respect it unless it's greater
    % than maxNITERS. If the user hasn't passed niters, just set it to
    % maxNITERS.
    coder.internal.prefer_const(maxNITERS, varargin{:});
    niters = maxNITERS;
    if (nargin == 2)
        % Check if the user has passed in the right-type of argument for
        % niters. This is the same check that's used in eml_check_niters,
        % but it can't be used under this scope with codegen.
        niters = varargin{1};
        coder.internal.assert(coder.internal.isConst(niters),...
            'fixed:cordic:nitersConstCodeGen');
        coder.internal.assert(~isempty(niters) &&...
                               isscalar(niters) &&...
                               isnumeric(niters) &&... 
                               isreal(niters) &&...
                               isfinite(niters) &&...
                               niters > 0 &&...
                               floor(niters) == niters,...
                               'fixed:cordic:invalidNiters', 'cordictanh');
        niters = min(maxNITERS, int16(varargin{1}));
    end
end

function a = hyperbolic_angular_increments(N, T)
% This function takes a table of constants and returns 'N' entries of
% type 'T'
    a = cast(atanh(2 .^ -(1:double(N))'),'like', T.tanh);
end

function [x, y] = cordic_hyperbolic_kernel(x, y, z, a, N)
% This is the heart of the CORDIC algorithm and performs 'rotations'.
    assert(isscalar(x) && isscalar(y));
    
    k = cast(4, 'like', N); % Used for the repeated (3*k + 1) iterations
    
    for n = 1:N
        [x, y, z] = hyperbolic_kernel(x, y, z, a, n);
        if n == k
            [x, y, z] = hyperbolic_kernel(x, y, z, a, n);
            k = 3*k + 1;
        end
    end
    
end

function [x ,y, z] = hyperbolic_kernel(x, y, z, a, n)
% This function shifts the input arguments x and y (that represent sinh and
% cosh) based on the value of z (i.e, it decides which direction to
% 'rotate' in.
    xn = bitsra(x, n);
    yn = bitsra(y, n);
    if z < 0
        x(:) = x - yn;
        y(:) = y - xn;
        z(:) = z + a(n);
    else
        x(:) = x + yn;
        y(:) = y + xn;
        z(:) = z - a(n);
    end
end

function p = sinh_over_cosh(q, T, N)
% This function decides the sign of the final answer based on the values of
% the actual tanh function (turned into a const)
    q = int32(q);
    tanh_table = cast(sinh(1:double(N))./cosh(1:double(N)), 'like', T.tanh);
    if q == 0
        p = cast(0, 'like', T.tanh);
    elseif q < -N
        p = cast(-1, 'like', T.tanh);
    elseif q > N
        p = cast(1, 'like', T.tanh);
    elseif q > 0
        % 0 < q <= 16
        p = tanh_table(q);
    else
        % -16 <= q < 0
        p = -tanh_table(-q);
    end
    
end

function z = cordic_divide_kernel(x, y, z, N)
% This function performs a pseudo division to find the final value of tanh
% using x & y. Note that x and y do not represent sinh and cosh. At the end
% of the final iteration, z = approx(x/y)
    one = cast(1, 'like', x);
    assert(isscalar(x) && isscalar(y) && isscalar(z));
    for n = 1:N-1
        if y < 0
            y(:) = y + bitsra(x,n);
            z(:) = z - bitsra(one,n);
        else
            y(:) = y - bitsra(x,n);
            z(:) = z + bitsra(one,n);
        end
    end
end