function c = mtimes(a,b)
%MTIMES Matrix multiplication for calendar durations.
%   B = A * N scales and sums the rows of the calendar duration array A by
%   the columns of N. B = N * A scales and sums the columns of A by the
%   rows of N. N is a numeric array containing integer values. A and N must
%   have the compatible sizes, or either can be a scalar.
%  
%   MTIMES(A,N) is called for the syntax 'A * N'.
%
%   See also PLUS, MINUS, TIMES, CALENDARDURATION.

%   Copyright 2014-2017 The MathWorks, Inc.

try
    [c,scale,right] = parseMultiplicationInputs(a,b);
    
    % Apply multiplication
    c_components = c.components;
    [c_components.months,isPlaceholderMonths] = applyScale(c_components.months,scale,right);
    [c_components.days,isPlaceholderDays]   = applyScale(c_components.days,scale,right);
    [c_components.millis,isPlaceholderMillis] = applyScale(c_components.millis,scale,right);
    
    % A scalar zero has components that all look like placeholders, but at least
    % one has to be treated as an actual zero.
    if (isPlaceholderMonths && isPlaceholderDays && isPlaceholderMillis)
        c_components.days = scale .* 0; % ~isfinite(scale); % set to zero, or to non-finite scale
    end
    
    c.components = c_components;
catch ME
    throwAsCaller(ME);
end


function [result,isPlaceholder] = applyScale(component,scale,right)
% Switch between applying left and right multiplication
isPlaceholder = isequal(component,0);
if isPlaceholder
    % Preserve a scalar zero placeholder where present.
    result = 0;
elseif right
    result = component * scale;
else
    result = scale * component;
end
