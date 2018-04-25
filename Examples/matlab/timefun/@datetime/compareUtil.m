function [aData,bData,prototype] = compareUtil(a,b)

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datatypes.isCharStrings

try

    % Two datetime inputs must either have or not have a time zone.
    if isa(a,'datetime') && isa(b,'datetime')
        if isempty(a.tz) ~= isempty(b.tz)
            error(message('MATLAB:datetime:IncompatibleTZ'));
        elseif ~isempty(a.tz)
            if strcmp(a.tz,datetime.UTCLeapSecsZoneID) ~= strcmp(b.tz,datetime.UTCLeapSecsZoneID)
                error(message('MATLAB:datetime:IncompatibleTZLeapSeconds'));
            end
        end

    % Convert date strings to datetime, letting conversion errors happen. If
    % either a or b converts to a duration, give a specific error.
    elseif (isstring(a) && isscalar(a)) || isCharStrings(a)
        a = autoConvertStrings(a,b); % b must have been a datetime
        if isa(a,'duration')
            error(message('MATLAB:datetime:CompareTimeOfDay'));
        end
    elseif (isstring(b) && isscalar(b)) || isCharStrings(b)
        b = autoConvertStrings(b,a); % a must have been a datetime
        if isa(b,'duration')
            error(message('MATLAB:datetime:CompareTimeOfDay'));
        end
        
    elseif isa(a,'duration') || isa(b,'duration')
        % If either a or b was passed in as a duration, give a specific error.
        error(message('MATLAB:datetime:CompareTimeOfDay'));
    else
        error(message('MATLAB:datetime:InvalidComparison',class(a),class(b)));
    end
    
    % Both inputs must (by now) be datetime.
    aData = a.data;
    bData = b.data;

catch ME
    throwAsCaller(ME);
end

if nargout > 2
    prototype = a;
end
