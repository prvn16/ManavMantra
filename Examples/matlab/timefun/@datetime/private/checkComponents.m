function componentNums = checkComponents(components)

%   Copyright 2014 The MathWorks, Inc.
import matlab.internal.datatypes.stringToLegacyText

try
    components = matlab.internal.datatypes.stringToLegacyText(components);
    
    [tf,components] = matlab.internal.datatypes.isCharStrings(components);
    if ~tf
        error(message('MATLAB:datetime:InvalidComponents'));
    end
    
    componentNames = {'years' 'quarters' 'months' 'weeks' 'days' 'time'};
    componentNums = zeros(size(components));
    for i = 1:length(components)
        str = components{i};
        tf = strncmpi(str,componentNames,max(length(str),1));
        if any(tf)
            componentNums(i) = find(tf,1);
        else
            error(message('MATLAB:datetime:InvalidComponent'));
        end
    end

catch ME
    throwAsCaller(ME);
end
