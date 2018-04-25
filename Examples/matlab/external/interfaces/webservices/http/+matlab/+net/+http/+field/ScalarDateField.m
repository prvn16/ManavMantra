classdef (Hidden, AllowedSubclasses=?matlab.net.http.field.HTTPDateField) ...
        ScalarDateField < matlab.net.http.HeaderField
    % ScalarDateField Any HTTP header field that contains one date
    %   This class implements behavior that is used by header fields containing a
    %   date.  This class places no constraints on the name of the field.  You cannot
    %   instantiate one of these directly.  To craete, invoke one of the subclasses.
    %
    % See also HTTPDateField, DateField
    
    % Copyright 2015-2016 The MathWorks, Inc.

    methods (Access=protected,  Hidden)
        function obj = ScalarDateField(varargin)
        % Create a field with a specified name and value.
        %   The value may be a datetime object, or a string in a valid HTTP date
        %   format.  If a datetime object is provided without a time zone, it is
        %   assumed to be local.
            narginchk(0,2);
            obj = obj@matlab.net.http.HeaderField(varargin{:});
        end
    end
    
    methods (Static, Hidden)
        function names = getSupportedNames()
        % Allow any field
            names = [];
        end
    end
    
    methods (Access=protected, Hidden)
        function tf = getStringException(~, value)
        % Determine if the provided string is a valid HTTP date.  Only validates the
        % format: does not otherwise check the date.
            if isempty(matlab.net.http.internal.HTTPDatetime.getDatetime(value))
                tf = true;
            else
                tf = [];
            end
        end
    end

    methods (Static, Access=protected, Hidden)
        function str = scalarToString(value, varargin)
        % scalarToString Convert datetime to string
        %   This function converts a datetime value to the IMF-fixdate format as
        %   described in section 7.1.1.1 of <a
        %   href="http://tools.ietf.org/html/rfc7231#page-65>RFC 7231</a>. (The
        %   Format specifier in the datetime is ignored.)  An unzoned datetime is
        %   assumed to be local time.  
        %
        %   If the value is not a datetime, returns [] to produce a generic error
        %   message about bad field value.
            str = matlab.net.http.internal.HTTPDatetime.convertDatetime(value);
        end
        
        function tf = allowsStruct()
        % allowsStruct - returns false to indicate that structs are not allowed
            tf = false;
        end
        
        function tf = allowsArray() 
        % Overridden to disallow arrays
            tf = false;
        end
        
        function dt = getDatetime(value)
        % getDatetime return the datetime represented by the string value or datetime
        %   object as a properly zoned datetime.  Returns [] if invalid. The string
        %   must be in the format of 7.1.1.1 of RFC 7231,
        %   http://tools.ietf.org/html/rfc7231#page-65.  If invalid, returns [].
        %    
            dt = matlab.net.http.internal.HTTPDatetime.getDatetime(value);
        end
        
        function tokens = getTokenExtents(~, ~, ~)
        % Overridden because nothing should be quoted
            tokens = [];
        end
    end
    
    methods 
        function value = convert(obj)
        % convert - return the value of this field as array of datetime objects
        %   Interprets field as a comma-separated list of (quoted) HTTP dates
            if isempty(obj)
                value = datetime.empty;
            else
                value = parseField(obj, ',', @obj.getDatetime);
            end
        end
    end

end

