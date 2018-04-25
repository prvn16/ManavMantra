function out = strcmpCommon(fcn, s1, s2, varargin)
%STRCMPCOMMON Common implementation details for STRCMP family.

%   Copyright 2015-2016 The MathWorks, Inc.

% Both inputs must be valid single strings or tall arrays of strings
fcnName = upper(func2str(fcn));
try
    s1 = validateAndMaybeWrap(s1, 1, fcnName);
    s2 = validateAndMaybeWrap(s2, 2, fcnName);
catch E
    throwAsCaller(E);
end
out = elementfun(@(a,b) fcn(a, b, varargin{:}), s1, s2);
out = setKnownType(out, 'logical');
end


function str = validateAndMaybeWrap(str, argIdx, fcn)
% Check a string input to make sure it is valid for STRCMP-style functions.
%
% Tall arrays must satisfy isValidStringArray
% Non-tall must satisfy isValidString and char arrays will be converted to strings.

if istall(str)
    % Tall inputs must be arrays of strings - no char arrays allowed
    str = tall.validateType(str, fcn, {'string', 'cellstr'}, argIdx);
else
    % Non-tall must first be validString...
    if ~isValidString(str)
        error(message('MATLAB:bigdata:array:InvalidStringInput', fcn));
    end
    
    % ... and char inputs must be row vectors (or '')
    if ischar(str)
        if ~isequal(str, '') && ~isrow(str)
            error(message('MATLAB:bigdata:array:CharArrayNotRow', fcn));
        end
        % We must treat char arrays as a single string, so wrap it
        str = string(str);
    end
end
end
