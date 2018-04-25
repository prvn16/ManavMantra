classdef (Sealed) DateField < matlab.net.http.field.HTTPDateField
% DateField an Date HTTP header field
%   The Date field is an optional field that represents the date and time a
%   RequestMessage or ResponseMessage was originally sent. If you do not specify a
%   DateField in a RequestMessage, one will be inserted when you send it. For more
%   information on the meaning and format of this field, see RFC 7231 <a
%   href="http://tools.ietf.org/html/rfc7231#section-7.1.1.2">Section 7.1.1.2</a>.
%
%   DateField methods:
%     DateField     - constructor
%     convert       - return a datetime object

% Copyright 2015-2017 The MathWorks, Inc.

    methods (Static, Hidden)
        function names = getSupportedNames()
        % Returns field names this class supports: just 'Date'
            names = 'Date';
        end
    end
    
    methods
        function obj = DateField(value)
        % DateField constructor for 'Date' field in HTTP header
        %   DATEFIELD = matlab.net.http.field.DateField
        %   DATEFIELD = matlab.net.http.field.DateField(DATETIME)
        %     Creates a matlab.net.http.field.DateField for the specified DATETIME,
        %     or for the current date/time if DATETIME is not specified. DATETIME
        %     must be a datetime object or a string in a valid HTTP date format, and
        %     it must not be in the future. If the timezone is missing, the local
        %     time zone is assumed. The Format property of the DATETIME is ignored
        %     when converting it to a string.
        
            if nargin == 0 || ...
                     (ischar(value) && isempty(value)) || ...
                     (isstring(value) && strlength(value) == 0)
                value = matlab.net.http.field.DateField.getDefaultValue();
            end
            % The value will be checked by the superclass, which will eventually 
            % call back to scalarToString to do further validation
            obj = obj@matlab.net.http.field.HTTPDateField('Date',value);
        end
    end

    methods (Access=protected, Hidden)
        function exc = getStringException(~,~) 
        % Callback from HeaderField to verify whether this string is a valid date
            % Unconditionally return false so that scalarToString will validate the
            % value and throw appropriate message
            exc = false;
        end
    end
    
    methods (Static, Access=protected, Hidden)
        function str = scalarToString(value,varargin)
        % Callback from superclass constructor to validate the datetime and return it
        % as a string. 
            % convert string or datetime object to properly zoned datetime
            import matlab.net.http.field.*;
            value = HTTPDateField.getDatetime(value);
            if isempty(value)
                str = [];  % generic error will be produced
                return
            end
            % convert back to string
            str = HTTPDateField.scalarToString(value,varargin{:});
            if ~isempty(str)
                now = DateField.getDefaultValue();
                % Error if in future. Since display won't show fractional seconds, chop those
                % off before doing comparison.
                value.Second = floor(value.Second);
                if value > now
                    now.TimeZone = 'gmt';
                    error(message('MATLAB:http:FutureDate',char(value),char(HTTPDateField.getDatetime(now))));
                end
            end
        end
        
        function value = getDefaultValue()
        % Default value
            value = datetime('now','TimeZone','local');
        end
        
    end
    
    methods (Static, Access=private)
        function tf = isValidDate(dt)
        % Check if the datetime object is in the valid range for a Date field. It
        % must not be in the future.
            tf = dt <= datetime('now');
        end
    end        

end

