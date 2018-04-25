function [argsMillis,template] = isequalUtil(argsMillis)

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datatypes.replaceException

try
    for i = 1:length(argsMillis)
        if isa(argsMillis{i},'duration')
            template = argsMillis{i};
            break;
        end
    end
    for i = 1:length(argsMillis)
        argsMillis{i} = toMillisLocal(argsMillis{i},template);
    end
catch ME
    throwAsCaller(replaceException(ME,...
        {'MATLAB:datetime:DurationConversion'},...
        message('MATLAB:duration:InvalidComparison',class(argsMillis{i}),'duration')));
end
end

function millis = toMillisLocal(arg,template)
import matlab.internal.datetime.datenumToMillis
if isa(arg,'duration')
    millis = arg.millis;
elseif isa(arg, 'missing')
    millis = double(arg);
elseif isstring(arg) || ischar(arg) || iscellstr(arg)
    % Autoconvert text using the first duration as a template
    millis = duration.compareUtil(arg,template);
else
    % Numeric input treated as a multiple of 24 hours.
    millis = datenumToMillis(arg);
end
end