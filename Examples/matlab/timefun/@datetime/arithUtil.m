function [a,b] = arithUtil(a,b)

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datatypes.isCharStrings

try

    if isa(a,'datetime') && isa(b,'datetime')
        if isempty(a.tz) ~= isempty(b.tz)
            error(message('MATLAB:datetime:IncompatibleTZ'));
        elseif ~isempty(a.tz)
            if strcmp(a.tz,datetime.UTCLeapSecsZoneID) ~= strcmp(b.tz,datetime.UTCLeapSecsZoneID)
                error(message('MATLAB:datetime:IncompatibleTZLeapSeconds'));
            end
        end

    % Convert date strings to datetime, letting conversion errors happen. If the
    % strings are converted to durations, the caller will handle as if they had
    % been duration values.
    elseif (isstring(a) && isscalar(a)) || isCharStrings(a)
        a = autoConvertStrings(a,b); % b must have been a datetime
    elseif (isstring(b) && isscalar(b)) || isCharStrings(b)
        b = autoConvertStrings(b,a); % a must have been a datetime
    end
    
    % Inputs that are not datetimes or strings pass through to the caller
    % and are handled there.

catch ME
    throwAsCaller(ME);
end
