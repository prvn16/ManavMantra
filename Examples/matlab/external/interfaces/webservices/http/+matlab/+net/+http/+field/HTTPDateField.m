classdef (AllowedSubclasses=?matlab.net.http.field.DateField) ...
        HTTPDateField < matlab.net.http.field.ScalarDateField
    % HTTPDateField Any one of several specific HTTP header fields containing a date
    %   The fields implemented by this class contain a single date in standard HTTP
    %   date format.  For more information on the date format, see RFC 7231, 
    %   <a href="http://tools.ietf.org/html/rfc7231#section-7.1.1.1">section 7.1.1.1</a>.  This class supports the following field names:
    %
    %   Date, Expires, Retry-After, Accept-Datetime, Last-Modified, If-Modified-Since
    %
    %   The 'Date' header field has its own subclass, DateField.  For more
    %   information on the above fields, see RFC 7231.
    %
    %   HTTPDateField methods:
    %      HTTPDateField    - constructor
    %      convert          - return a datetime object
    %
    % See also DateField
    
    %   For internal use only: to create a date field with a name that is not one of
    %   the above, see ScalarDateField.

    % Copyright 2015-2017 The MathWorks, Inc.

    methods (Static, Hidden)
        function names = getSupportedNames()
        % Returns field names this class supports. 
            names = ["Date","Expires","Retry-After","Accept-Datetime",...
                     "Last-Modified","If-Modified-Since"];
        end
    end
    
    methods
        function obj = HTTPDateField(varargin)
        % HTTPDateField HTTP Create an HTTP header field containing a date
        %   FIELD = HTTPDateField(NAME) creates a field with the specified NAME and
        %       no value
        %   FIELD = HTTPDateField(NAME,VALUE) creates a field with the specified NAME
        %      and VALUE. 
        %   The NAME must be one of those allowed by this class (see class
        %   description).  The VALUE may be a datetime object or a string in a valid
        %   HTTP date format as documented in RFC 7231, <a href="http://tools.ietf.org/html/rfc7231#section-7.1.1.1">section 7.1.1.1</a>. 
        %
        %   If a datetime object is provided without a time zone, it is assumed to be
        %   local.
        %
        % See also HTTPDateField, datetime

            obj = obj@matlab.net.http.field.ScalarDateField(varargin{:});
        end
    end
    
end

