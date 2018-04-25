function [T, errid, errargs] = computeDivideType(a, b)
    %computeDivideType Compute the quotient numerictype for A/B and A./B
    %
    %    T = computeDivideType(A,B) is a helper-function for RDIVIDE (A./B)
    %    and MRDIVIDE (A/B).  The output numerictype T is a function of the
    %    numerictypes of inputs A and B.
    %
    %    If both A and B are fixed-point types, then the output word length
    %    is the maximum word length of A and B, and the output fraction
    %    length is A.FractionLength - B.FractionLength.  If either A or B
    %    is Signed, then the output will be Signed.  If both A and B are
    %    Unsigned, then the output will be Unsigned.
    %
    %    Reference: Fixed-Point Designer User's Guide > Recommendations for
    %    Arithmetic and Scaling
    %       > Division > Inherited Scaling for Speed
    %       http://www.mathworks.com/access/helpdesk/help/toolbox/fixedpoint/ug/f26557.html#f20147
    
    %    Differences between Simulink and MATLAB.
    %
    %    Simulink: If either input is floating-point, then the output is
    %    floating-point of the same type.  Double trumps over single.
    %    MATLAB: mixed arithmetic fixed point type trumps. But mixed
    %    arithmetic between fi objects is not allowed except mixing 'Fixed'
    %    and 'ScaledDouble'
    %
    %    Simulink: Fixed-point trumps over scaled-double. MATLAB:
    %    Scaled-double trumps over fixed-point.
    
    %   Thomas A. Bryan and Becky Bryan, 30 December 2008
	
    %   Copyright 2008-2016 The MathWorks, Inc.
    
    [errid, errargs] = check_valid_numerictype(a,b);
    
    if isempty(errid)
        if ~(isfi(a) && isfi(b))
            % One of the inputs must be fi objects since computeDivideType
            % is a fi method.
            [T,errid,errargs] = divide_builtin_and_fi(a,b);
        else
            % both are fi objects
            [T,errid,errargs] = divide_two_fi(a,b);
        end
    else
        T = [];
    end
    
    % Return the error id and message if those outputs are defined.
    % Otherwise, throw the error here.
    if nargout<2 && ~isempty(errid)
        error(message(errid, errargs{:}));
    end
    
end

function [errid, errargs] = check_valid_numerictype(x,y)
    % check whether x and y are valid fi numeric types
    if ~(isnumeric(x) && isnumeric(y))
        error(message('fixed:fi:InvalidInputNotNumeric'));
    end
    
    if ~isreal(y)
        error(message('fixed:fi:divideDenominatorNotReal'));
    end
    
    if fixed.internal.utility.isSlopeBiasFi(x) || fixed.internal.utility.isSlopeBiasFi(y)
        % Error if slope-bias
        errid = 'fixed:fi:unsupportedSlopeBias';
        errargs = {'divide'};
    elseif fixed.internal.utility.isBooleanFi(x) || fixed.internal.utility.isBooleanFi(y)
        % Error if boolean type
        errid = 'fixed:fi:unsupportedBooleanMath';
        errargs = {};
    else
        errid = '';
        errargs = {};
    end
    
end

function [T,errid,errargs] = divide_integer_and_scaled_fi(x,y)
    % handles division between builtin integer and fi object
    if isinteger(x)
        [x,errid,errargs] = fixed.internal.utility.integerToFi(x, y);
    else
        [y,errid,errargs] = fixed.internal.utility.integerToFi(y, x);
    end
    
    if isempty(errid)
        [T,errid,errargs] = divide_two_fi(x,y);
    else
        T = [];
    end
end

function [T,errid,errargs] = divide_builtin_and_fi(x,y)
    % handles division between builtin numeric and fi object
    
    if (isfi(x) && isscaledtype(x) && isinteger(y))...
            || (isfi(y) && isscaledtype(y) && isinteger(x))
        % divide between scaled type and integer
        [T,errid,errargs] = divide_integer_and_scaled_fi(x,y);
    elseif isfi(x)
        % a is fi, b is not, so take the numerictype of a
        % or if a is not scaled type but b is integer, take the
        % numerictype of a
        T = numerictype(x);
        errid = '';
        errargs = {};
    else
        % b is fi, a is not, so take the numerictype of b
        % or if b is not scaled type but a is integer, take the
        % numerictype of b
        T = numerictype(y);
        errid = '';
        errargs = {};
    end
end

function [T,errid,errargs] = divide_two_fi(x,y)
    % handles division between two fi object
    
    if ~((isscaledtype(x) && isscaledtype(y)) || ...
            isequal(x.DataType, y.DataType))
        T = [];
        errid = 'fixed:fi:unsupportedMixedMath';
        errargs = {'divide'};
        % a,b must be either same type or both scaled type from here on
    elseif isscaledtype(x)
        % Both are fixed-point or scaled-double.
        T = numerictype(x);
        T.Signed = x.Signed || y.Signed;
        T.WordLength = max(x.WordLength, y.WordLength);
        T.FractionLength = x.FractionLength - y.FractionLength;
        if isscaleddouble(x) || isscaleddouble(y)
            % Propagate scaled double
            T.DataType = 'ScaledDouble';
        end
        errid = '';
        errargs = {};
    elseif isdouble(x) || issingle(x)
        % If both are double, return double
        % If both are single, return single
        T = numerictype(x);
        errid = '';
        errargs = {};
    else
        % In case other data types are added that are not covered in the above
        % cases.
        T = [];
        errid = 'fixed:fi:divideUnhandledOutputType';
        errargs = {};
    end
end


% LocalWords:  ug
