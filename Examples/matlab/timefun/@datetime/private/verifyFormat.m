function [fmt,isDateOnly] = verifyFormat(fmt,tz,warnForConflicts,acceptDefaultStr)

%   Copyright 2014-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString
import matlab.internal.datatypes.throwInstead
import matlab.internal.datatypes.stringToLegacyText

try
    % tz is never string, only need to convert fmt for shallow string adoption.
    fmt = stringToLegacyText(fmt);
    
    isDateOnly = false;
    if isCharString(fmt)
        if nargin > 3 && acceptDefaultStr && ...
                (strcmpi(fmt,'default') || strcmpi(fmt,'defaultDate'))
            isDateOnly = strcmpi(fmt,'defaultDate');
            fmt = '';
        else
            % The error and warning check are done in the verifyFormat
            % builtin. 
            if nargin > 2          
                matlab.internal.datetime.verifyFormat(fmt, warnForConflicts);
            else
                matlab.internal.datetime.verifyFormat(fmt);
            end
            
            try % Try out the format, ignore any return value
                matlab.internal.datetime.formatAsString(0,fmt,tz,false);
            catch ME
                throwInstead(ME,'MATLAB:datetime:mexErrors:FormatError',message('MATLAB:datetime:UnrecognizedFormat',fmt,getString(message('MATLAB:datetime:LinkToFormatDoc'))));
            end
        end
    else
        error(message('MATLAB:datetime:InvalidFormat'));
    end

catch ME
    throwAsCaller(ME);
end

