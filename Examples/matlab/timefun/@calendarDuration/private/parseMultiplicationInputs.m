function [c, scale, right] = parseMultiplicationInputs(a,b)
%PARSEMULTIPLICATIONINPUTS Parses inputs for calendarDuration times and mtimes.

%   Copyright 2016-2017 The MathWorks, Inc.
    
    if isa(a,'calendarDuration') % Numeric input interpreted as a scale factor.
        c = a;
        scale = b;
        right = true;
    else
        c = b;
        scale = a;
        right = false;
    end
    
    if isa(scale,'calendarDuration')
        error(message('MATLAB:calendarDuration:CalendarDurationMultiplicationNotDefined'));
    elseif ~isa(scale,'double') && ~islogical(scale)
        % Multiplication between arrays of different numeric types is not allowed.
        error(message('MATLAB:calendarDuration:MultiplicationNotDefined',class(c),class(scale)));
    end
    
    % calendarDuration multiplication is supported only as scaling by integer
    % values and non-finites (and logicals treats as integers). Multiplying by
    % non-integers is not allowed.
    isFiniteScale = isfinite(scale(:));
    if isnumeric(scale) && isreal(scale)
        if any(isFiniteScale & (round(scale(:)) ~= scale(:)))
            error(message('MATLAB:calendarDuration:NonIntegerMultiplier'));
        end
    elseif ~islogical(scale)
        error(message('MATLAB:calendarDuration:NonIntegerMultiplier'));
    end
end
