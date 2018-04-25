function that = subsrefParens(this,s)

%   Copyright 2014 The MathWorks, Inc.

if ~isstruct(s), s = struct('type','()','subs',{s}); end

that = this;
theComponents = that.components;

% If the array is not a scalar zero, at least one of the fields must not be a
% scalar zero placeholder, and will have subscripting applied. Any remaining
% (scalar zero placeholder) fields can be left alone. However, if the array is a
% scalar zero, have to handle the possibility of Tony's trick, or at least throw
% an error for out of range subscripts, so apply the subscripting to (arbitrarily)
% seconds.
nonZeros = false;
if ~isequal(theComponents.months,0)
    nonZeros = true;
    theComponents.months = subsref(theComponents.months,s(1));
end
if ~isequal(theComponents.days,0)
    nonZeros = true;
    theComponents.days = subsref(theComponents.days,s(1));
end
if ~isequal(theComponents.millis,0) || (nonZeros == false)
    theComponents.millis = subsref(theComponents.millis,s(1));
end

that.components = theComponents;

if ~isscalar(s)
    switch s(2).type
    case '.'
        that = subsrefDot(that,s(2:end));
    case {'()' '{}'}
        error(message('MATLAB:calendarDuration:InvalidSubscriptExpr'));
    end
end

