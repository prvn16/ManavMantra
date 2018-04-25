classdef (Sealed) CookieField < matlab.net.http.HeaderField
    %CookieField Cookie HTTP header field
    %   Include a CookieField in a RequestMessage in order to send cookies (received
    %   previously in a SetCookieField) to a server. For more information on
    %   cookies, see RFC 6265, <a href="http://tools.ietf.org/html/rfc6265">RFC 6265</a>
    %
    %   Example of sending all received Cookies back to a server:
    %
    %     resp = matlab.net.http.RequestMessage().send('http://www.mathworks.com');
    %     setCookieFields = resp.getFields('Set-Cookie');
    %     if ~isempty(setCookieFields)
    %        % fetch all CookieInfos from Set-Cookie fields and add to request
    %        cookieInfos = setCookieFields.convert;
    %        r = r.addFields(matlab.net.http.field.CookieField([cookieInfos.Cookie]);
    %     end   
    %     resp = r.send('http://www.mathworks.com');
    %
    %   This example is simplified: in reality you should only send unexpired
    %   CookieInfo objects only send unexpired cookies back to the server, and the
    %   cookies you send would be chosen by comparing the request URI to the Domain
    %   and Path attributes in the CookieInfos. For more information on choosing 
    %   cookies, see RFC 6265, <a href="http://tools.ietf.org/html/rfc6265#section-5.4">section 5.4.</a>
    %
    %   In addition, if the initial exchange above multiple message messages for
    %   authentication and redirection, you may want to obtain the CookieInfos from
    %   the history containing all these message. For more information on this, see
    %   CookieInfo.collectFromLog.
    %
    %   CookieField methods:
    %     CookieField - constructor
    %     convert     - return contents as vector of Cookies
    %
    % See also matlab.net.http.Cookie, SetCookieField, matlab.net.http.CookieInfo,
    % matlab.net.http.ResponseMessage, datetime, convert
    
    % Copyright 2015-2016 The MathWorks, Inc.
    methods (Static)
        function names = getSupportedNames
            names = 'Cookie';
        end
    end
    
    methods
        function obj = CookieField(value)
        % CookieField creates an HTTP Cookie header field
        %   The value is a vector of Cookie objects, obtained from a SetCookieField
        %   in a ResponseMessage, or a string containing all the cookies. While
        %   there may be multiple SetCookieFields in a ResponseMessage, one per
        %   cookie, a RequestMessage message should contain only a single CookieField
        %   containing all the cookies.
        %
        % See also matlab.net.http.ResponseMessage, SetCookieField, matlab.net.http.RequestMessage
            if nargin == 0
                value = [];
            end
            obj = obj@matlab.net.http.HeaderField('Cookie', value);
        end
        
        function value = convert(obj)
        % convert returns all Cookies in the CookieField
        %   The result is a vector of Cookie objects.
        %
        % See also matlab.net.http.Cookie
        
            % Cookies in this field are separated by semicolons, not commas as in
            % other header fields
            if isempty(obj)
                value = matlab.net.http.Cookie.empty;
            else
                value = parseField(obj, ';', @parser);
            end
        end
    end
    
    methods (Access=protected, Hidden)
        function str = valueToString(obj, value, ~)
        % Overridden to use ';' as the delimiter instead of ',' to separate cookie-pairs.
        % This is looser than RFC 6265 section 4.2.1 because the RFC doesn't allow
        % consecutive ';' and requires exactly one space between the ';' and the
        % next cookie-pair.
            str = valueToString@matlab.net.http.HeaderField(obj, value, '; ');
        end
        
        function exc = getStringException(~, ~)
        % Return false to let scalarToString validate the string
            exc = false;
        end
        
        function str = scalarToString(~, value, varargin)
            if isa(value, 'matlab.net.http.Cookie')
                str = string(value);
            elseif isstring(value) || ischar(value)
                % Enforce valid syntax of a cookie-pair as per RFC 6265 section 4.1.1: 
                %    cookie-name=cookie-value
                % where cookie-name is a token and cookie-value is a sequence of
                % optionally quoted cookie-octets
                octets = '[\x21\x23-\x2b\x2d-\x3a\x3c-\x5b\x5d-\x7e]+';
                res = regexp(value, '^[' + matlab.net.http.HeaderField.TokenChars + ...
                                    ']+=(' + octets + '|"' + octets + '")$', 'once');
                if isempty(res)
                    str = []; % causes HeaderField to throw a generic error
                else
                    str = value;
                end
            else
                validateattributes(value, {'matlab.net.http.Cookie','string','char'}, mfilename, 'value');
            end
        end
                
    end
    
    methods (Static, Access=protected, Hidden)
        function tf = allowsStruct()
            tf = false;
        end
        
        function str = quoteValue(token, ~)
        % Overridden because quotes around cookie-octets are optional, so we'll never insert them
            str = token;
        end
    end
    
end

function value = parser(str)
% Called to convert an array element of the field to a Cookie object. Returns [] if
% the field could not be parsed.
    % The name is everything up to the first '=', and the value is everything else
    tokens = regexp(str, '^(.*?)=(.*)$', 'tokens');
    if isempty(tokens)
        value = [];
    else
        value = matlab.net.http.Cookie(tokens{1}{1}, tokens{1}{2});
    end
end
    


