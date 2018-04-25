classdef (Sealed) Cookie
% Cookie An HTTP Cookie
%   You obtain a Cookie from a CookieInfo object returned in a SetCookieField in a
%   ResponseMessage. You send the Cookie back to the server in a CookieField in a
%   RequestMessage. For information on obtaining the necessary cookies from a series
%   of messages, see CookieInfo.collectFromLog.
%
%   Cookie properties:
%       Name    - (read-only) Name of the cookie
%       Value   - (read-only) Value of the cookie
%
%   Cookie methods:
%       Cookie        - Constructor
%       string, char  - Obtain string or char equivalent
%
% See also CookieInfo, matlab.net.http.field.SetCookieField,
% matlab.net.http.field.CookieField, ResponseMessage, RequestMessage
    
% Copyright 2015-2016 The MathWorks, Inc.

    properties (SetAccess=private)
        % Name of the cookie, a string (read-only)
        Name string
        % Value of the cookie, a string (read-only). 
        %   You should consider this to be an opaque value, as it has meaning only to
        %   the server who sent the cookie.
        Value string
    end
    
    methods
        function obj = Cookie(name, value)
        % Cookie constructor
        %   This constructor is provided for test purposes only. You do not normally
        %   create a Cookie object. Instead, you obtain a Cookie by getting a
        %   SetCookieField from a ResponseMessage, and then calling
        %   SetCookieField.convert to obtain a CookieInfo object that contains the
        %   Cookie.
        %
        %   This constructor requires two strings as parameters, but performs no
        %   argument validation.
        %
        %  See also ResponseMessage, CookieInfo,
        %  matlab.net.http.field.SetCookieField.convert
            obj.Name = name;
            obj.Value = value;
        end
        
        function str = char(obj)
        % char Return value as a character vector
        %   CHR = char(COOKIES) returns a vector of cookies as a character vector as
        %   they would appear in a CookieField.
        %
        % See also matlab.net.http.field.CookieField
            str = char(string(obj));
        end
        
        function str = string(obj)
        % char Return value as a string
        %   STR = string(COOKIES) returns a vector of cookies as a string as they would
        %   appear in a CookieField.
        %
        % See also matlab.net.http.field.CookieField
            if isscalar(obj)
                str = obj.Name + '=' + obj.Value;
            else
                str = string(strjoin(arrayfun(@char,obj,'UniformOutput',false), '; '));
            end
        end
    end
end
