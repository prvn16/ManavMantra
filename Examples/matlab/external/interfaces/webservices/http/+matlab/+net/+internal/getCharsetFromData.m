function charset = getCharsetFromData(data)
% Heuristically try to determine the minimal charset needed to convert the string
% data to bytes.  If all are ASCII, use that.  If not, try MATLAB's default
% encoding.  If that's not reversible, then use utf-8.
%
% data may be a char vector, cellstr, or string vector
%
% This function is for internal use only, for classes in the matlab.net
% packages.  It may change in a future release.

% Copyright 2015-2017 The MathWorks, Inc.

    if iscellstr(data) || (isstring(data) && ~isscalar(data))
        data = strjoin(data,''); % join cellstr or string array
    end
    % data is now a single string or a char array of some dimension
    chars = char(data);
    nonASCII = chars > 127;
    if any(nonASCII)
        % It's not ASCII.  If the default platform encoding is reversible, use that;
        % else use UTF-8.  TBD: it would be nice to have a more efficient implementation
        % of this test.
        if strcmp(native2unicode(unicode2native(chars)), chars)
            charset = feature('DefaultCharacterSet');
        else
            charset = 'utf-8';
        end
    else
        charset = 'us-ascii';
    end
end
            
        