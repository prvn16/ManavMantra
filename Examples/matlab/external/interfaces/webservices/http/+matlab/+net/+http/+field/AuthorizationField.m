classdef (Sealed) AuthorizationField < matlab.net.http.HeaderField
% AuthorizationField An Authorization or Proxy-Authorization HTTP header field
%   An AuthorizationField contains credentials in a RequestMessage in response to a
%   challenge from a server in an AuthenticateField. The credentials are in the form
%   of an AuthInfo object. For a description of these fields, see RFC 7235, sections
%   <a href="https://tools.ietf.org/html/rfc7235#section-4.2">4.2</a> and <a href="https://tools.ietf.org/html/rfc7235#section-4.4">4.4</a>.
%
%   This field is normally created automatically when you send a message, provided
%   HTTPOptions.Authenticate is set (default), you have specified appropriate
%   Credentials in HTTPOptions.Credentials, and the AuthenticationScheme requested by
%   the server is supported by MATLAB. 
%
%   You would only create this field explicitly if you disabled automatic
%   authentication or needed to implement an unsupported authentication protocol. If
%   you create this field explicitly, set the Value property to a valid authorization
%   string or AuthInfo object.
%
%   When authentication is automatic, you can see the AuthorizationField that was
%   sent to the server by examining the completed request returned by
%   RequestMessage.send or the returned history. 
%
%   Example to view the AuthorizationField credentials in a request:
%      import matlab.net.http.*
%      creds = Credentials('Username','MyName','Password','MyPassword');
%      options = HTTPOptions('Credentials', creds);
%      [response, request] = RequestMessage().send('http://myhost.com',options);
%      authorizationField = request.getFields('Authorization');
%      authInfo = authorizationField.convert;
%      disp(string(authInfo));
%
%   Note that the RequestMessage.complete method does not create an
%   AuthorizationField, because it cannot usually know what credentials to include in
%   the message without first contacting the server.
%
%   AuthorizationField properties:
%      Name      - "Authorization" or "Proxy-Authorization"
%      Value     - Authorization string: may be set using an AuthInfo object
%
%   AuthorizationField methods:
%      AuthorizationField - constructor
%      convert            - return Value as an AuthInfo
%
% See also matlab.net.http.RequestMessage, AuthenticateField,
% matlab.net.http.AuthInfo, matlab.net.http.HTTPOptions,
% matlab.net.http.AuthenticationScheme

% Copyright 2015-2016 The MathWorks, Inc.

    methods (Static, Hidden)
        function names = getSupportedNames()
        % Returns field names this class supports: just 'Authorization' and
        % 'Proxy-Authorization'
            names = ["Authorization" "Proxy-Authorization"];
        end
    end
    
    methods
        function obj = AuthorizationField(varargin)
        % AuthorizationField Construct an AuthorizationField
        %   FIELD = AuthorizationField(NAME) construct an AuthorizationField with no
        %      value.
        %   FIELD = AuthorizationField(NAME,VALUE) constructs an AuthorizationField
        %      with a NAME and VALUE.
        %   The NAME must be 'Authorization' or 'Proxy-Authorization' and the VALUE,
        %   if present, must be an AuthInfo or string acceptable to the AuthInfo
        %   constructor.
        %
        % See also matlab.net.http.AuthInfo
            obj = obj@matlab.net.http.HeaderField(varargin{:});
        end
    end
    
    methods (Sealed)
        function value = convert(obj)
        % convert returns an AuthInfo object for the AuthorizationField
        %   There is only one AuthInfo in an AuthorizationField. If given a vector
        %   of AuthorizationFields, returns an equal-size vector of AuthInfo.
        %
        %   The parameters in the AuthInfo correspond to parameters of the credentials
        %   in the AuthorizationField. The set of parameters varies depending on the
        %   AuthInfo.Scheme (the first token in the field).
        %
        % See also matlab.net.http.AuthenticationScheme, matlab.net.http.AuthInfo
        
            % The field has one of these syntaxes:
            %    Basic  encoded
            %    Digest name1=value, name2=value, ...
            % but we don't actually care what the Scheme value is.
            if isscalar(obj)
                value = matlab.net.http.AuthInfo(obj.Value);
            elseif isempty(obj)
                value = matlab.net.http.AuthInfo.empty;
            else
                value = arrayfun(@convert, obj, 'UniformOutput', false);
                value = [value{:}];
            end
        end
    end
    
    methods (Access=protected, Hidden)
        function exc = getStringException(~, str) 
        % Determine whether str is a valid AuthorizationField string. We simply
        % parse it to make sure it follows the correct syntax for credentials as per
        % RFC 7235, section 2.1:
        %       credentials = auth-scheme [ 1*SP ( token68 / #auth-param ) ]
            exc = [];
            try
                % parse string into a struct and see if it's acceptable to AuthInfo
                matlab.net.http.AuthInfo(str);
            catch exc
            end
        end
        
        function str = scalarToString(~, value, exc, varargin)
        % Allow only AuthInfo or strings
            if isa(value, 'matlab.net.http.AuthInfo')
                str = string(value);
            elseif ~isempty(exc)
                throw(exc);
            else
                validateattributes(value, {'AuthInfo','string','char'}, {}, mfilename, 'value');
                str = matlab.net.internal.getString(value, mfilename, 'value');
            end
        end                
    end
    
    methods (Sealed, Static, Access=protected)
        function tf = allowsArray()
            tf = false;
        end

        function tf = allowsStruct()
            tf = true;
        end
        
        function tokens = getTokenExtents(~, ~, ~)
        % Overridden because nothing should be quoted
            tokens = [];
        end
    end
end

