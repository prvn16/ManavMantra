function [amillis,bmillis,template] = compareUtil(a,b)

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datatypes.replaceException
try
    % Convert to seconds.  Numeric input interpreted as a number of days.
    if isa(a,'duration')
        template = a;
        [amillis,bmillis] = convert(template,b);
    else % b must have been a duration
        template = b;
        [bmillis,amillis] = convert(template,a);
    end
catch ME
    % Rethrow invalid comparison with arguments in the right order. However,
    % MATLAB:duration:AutoConvertString is left alone.
    throwAsCaller(replaceException(ME,...
        {'MATLAB:duration:InvalidComparison','MATLAB:datetime:DurationConversion'},... 
        message('MATLAB:duration:InvalidComparison',class(a),class(b))));
end
end

function [amillis,bmillis] = convert(template,b)
amillis = template.millis;
if isa(b,'duration')
    bmillis = b.millis;
elseif isnumeric(b) || islogical(b)
    bmillis = matlab.internal.datetime.datenumToMillis(b);
else
    bmillis = detectFormatFromData(b,template);
end
end

