function scale = checkUnit(unit)

%   Copyright 2014-2015 The MathWorks, Inc.

try
    
    unit = find(strncmpi(unit,{'seconds' 'minutes' 'hours' 'days' 'years'},max(length(unit),1)));
    if ~isscalar(unit)
        if isempty(unit)
            error(message('MATLAB:duration:units:InvalidUnit'));
        else
            error(message('MATLAB:duration:units:AmbiguousUnit',unit));
        end
    end

    scale = [1000 60000 3600000 86400000 31556952000]; % "standard" units expressed in ms
    scale = scale(unit);
    
catch ME
    throwAsCaller(ME);
end
