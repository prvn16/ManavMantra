classdef HTTPDatetime
% HTTPDatetime contains static methods for working with HTTP dates and times
%   This function is for internal use and may change in a future release.

% Copyright 2015-2016 The MathWorks, Inc.

    properties (Constant)
        % Format - Preferred HTTP date-time format, as per IMF-fixdate format as
        %   described in section 7.1.1.1 of <a
        %   href="http://tools.ietf.org/html/rfc7231#page-65>RFC 7231</a>. 
        Format = 'eee, dd MMM yyyy HH:mm:ss ''GMT''';
        % Locale - The locale setting for datetime strings in HTTP messages. 
        Locale = 'en_US';
    end
    
    methods (Static)

        function dt = getDatetime(value)
        % getDatetime Parse the value string as an HTTP date-time and return datetime
        %   dt = getDatetime(value) parses the value as per section 7.1.1.1 of RFC
        %   7231, http://tools.ietf.org/html/rfc7231#page-65 and returns a datetime
        %   object.  Returns [] if it could not be parsed.  Parsing requires a string
        %   that exactly matches the format: the resulting datetime, when converted
        %   back to a string using the format that was used to create it, must
        %   exactly match the original string.
        %
        %   If the value is already a datetime, just returns the value converted to
        %   the GMT time zone, assuming it was originally local time zone, if it had
        %   none.
        %
        %   The Format property of the returned datetime is set to the value of the
        %   Format property in this class, regardless of the format of the original
        %   string.  To obtain the datetime as a string as it would appear in an HTTP
        %   message, use convertDateTime.
        %
        % See also Format, convertDateTime
           import matlab.net.http.internal.HTTPDatetime
           dt = [];
           if ischar(value) || isstring(value)
                % Try each of the allowed formats, in order of preference
                formats = {HTTPDatetime.Format, ...
                           'eeee, dd-MMM-yy HH:mm:ss ''GMT''', ...
                           'eee MMM d HH:mm:ss yyyy'};
                value = char(value);
                for i = 1 : length(formats)
                    format = formats{i};
                    try
                        dt = datetime(value, 'InputFormat', format, 'Format', format, 'Locale', HTTPDatetime.Locale);
                        % conversion worked, but accept it only if it converts back
                        % to exactly the same string.  This is because datetime is
                        % too liberal about what it accepts for the string (e.g.,
                        % 'now' works) while we need it to be exact.
                        if ~strcmp(char(dt, format, HTTPDatetime.Locale), value)
                            dt = []; 
                        end
                        break;
                    catch
                        % just try next format on error
                    end
                end
            elseif isdatetime(value)
                % if it has no time zone, assume local
                dt = value;
                if isnan(tzoffset(dt))
                    dt.TimeZone = 'local';
                end
            end

            if ~isempty(dt) 
                if isnat(dt)
                    dt = [];
                else
                    % adjust time zone to GMT and set format
                    dt.TimeZone = 'GMT';
                    dt.Format = HTTPDatetime.Format;
                end
            end
        end
        
        function str = convertDatetime(dt)
        % convertDatetime - Convert the datetime to an HTTP date-time string
        %   This always converts the value to the IMF-fixdate format, ignoring any
        %   Format specifier in the datetime object.  An unzoned datetime is assumed
        %   to be local time.
        %
        %   If the value is not a datetime, returns [].
        %
        % See also Format
            import matlab.net.http.internal.HTTPDatetime
            if isa(dt,'datetime')
                if isnan(tzoffset(dt))
                    dt.TimeZone = 'local';
                end
                % force the time to GMT and format accordingly
                dt.TimeZone = 'GMT';
                str = char(dt, HTTPDatetime.Format, HTTPDatetime.Locale);
                str = string(str);
            else
                str = [];
            end
        end
    end
end