function ctorHelper(obj, pvpairs)

%   Copyright 2014-2015 The MathWorks, Inc.

if isscalar(pvpairs)
    error(message('MATLAB:class:BadParamValuePairs'))
elseif ~isempty(pvpairs)
    set(obj, pvpairs{:});
end

end
