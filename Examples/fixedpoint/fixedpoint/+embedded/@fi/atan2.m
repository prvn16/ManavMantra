function theta = atan2(y, x)
%ATAN2  Four quadrant inverse tangent.
%   ATAN2(Y,X) is the four quadrant arctangent of the real parts of the
%   elements of X and Y.  -pi <= ATAN2(Y,X) <= pi.
%
%   See also ATAN.

%   Copyright 2011-2012 The MathWorks, Inc.

if ~(isscalar(y) || isscalar(x))
    if ~isequal(size(x), size(y))
        error(message('fixed:fi:twoInpArgsNonScalarNotSameSize'));
    end
end

if ~isfi(x)
    error(message('fixed:fi:inputsMustBeFixPtBPSOrFloatSameDTMode'));
end

if ~isreal(y) || isboolean(y) || ~isreal(x) || isboolean(x)
    error(message('fixed:fi:realAndNumeric'));
end

if (isfixed(y) && isfixed(x)) || (isscaleddouble(y) && isscaleddouble(x))
    if (~(isscalingbinarypoint(y) && isscalingbinarypoint(x)))
        error(message('fixed:fi:inputsMustBeFixPtBPSOrFloatSameDTMode'));
    end
    
    if isscalar(y) && ~isscalar(x)
        size_of_theta = size(x);
    else
        size_of_theta = size(y);
    end

    % Initialize output array
    if issigned(y) || issigned(x)
        % SIGNED best precision output in range [-pi, pi]
        if isscaleddouble(y) || isscaleddouble(x)
            thetaNT = numerictype(...
                'Signedness',     'Signed',...
                'WordLength',     16,...
                'FractionLength', 13,...
                'DataTypeMode',   'Scaled double: binary point scaling');
        else
            thetaNT = numerictype(1, 16, 13);
        end
    else
        % UNSIGNED best precision output in range [0, pi/2]
        if isscaleddouble(y) || isscaleddouble(x)
            thetaNT = numerictype(...
                'Signedness',     'Unsigned',...
                'WordLength',     16,...
                'FractionLength', 15,...
                'DataTypeMode',   'Scaled double: binary point scaling');
        else
            thetaNT = numerictype(0, 16, 15);
        end
    end
    
    if isscaleddouble(x) || isscaleddouble(y)
        theta = embedded.fi(atan2(double(y),double(x)),thetaNT);
    else
        theta = embedded.fi(zeros(size_of_theta), thetaNT);
        % Call ATAN2_FI_LUT_PRIVATE function
        if isscalar(theta)
            % THETA, X, Y are all scalar
            setElement(theta, fixed.internal.atan2_fi_lut_private(getElement(y,1), getElement(x,1)), 1);
        elseif isscalar(y)
            % Y is scalar, X is non-scalar
            for idx = 1:numberofelements(theta)
                setElement(theta, fixed.internal.atan2_fi_lut_private(getElement(y,1), getElement(x,idx)), idx);
            end
        elseif isscalar(x)
            % X is scalar, Y is non-scalar
            for idx = 1:numberofelements(theta)
                setElement(theta, fixed.internal.atan2_fi_lut_private(getElement(y,idx), getElement(x,1)), idx);
            end
        else
            % BOTH X and Y are non-scalar
            for idx = 1:numberofelements(theta)
                setElement(theta, fixed.internal.atan2_fi_lut_private(getElement(y,idx), getElement(x,idx)), idx);
            end
        end
    end
    
elseif isdouble(y) && isdouble(x)
    % Inputs are both FI double
    theta_float = atan2(double(y), double(x)); % use MATLAB builtin ATAN2
    theta = embedded.fi(theta_float, numerictype('double'));
    
elseif issingle(y) && issingle(x)
    % Inputs are both FI single
    theta_float = atan2(single(y), single(x)); % use MATLAB builtin ATAN2
    theta = embedded.fi(theta_float, numerictype('single'));
    
else
    error(message('fixed:fi:inputsMustBeFixPtBPSOrFloatSameDTMode'));
end

theta.fimath = [];

end % function

% LocalWords:  Inp
