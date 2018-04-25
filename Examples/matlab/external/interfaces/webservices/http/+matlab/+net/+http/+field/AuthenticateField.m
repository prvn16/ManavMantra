classdef (Sealed) AuthenticateField < matlab.net.http.HeaderField
% AuthenticateField A WWW-Authenticate or Proxy-Authenticate HTTP header field
%   An AuthenticateField appears in a ResponseMessage from a server or proxy. It
%   contains one or more challenges asking for authentication information. These
%   challenges are in the form of an array of AuthInfo objects. To get these
%   challenges, use convert.
%
%   Under most conditions when send a RequestMessage to a server or through a proxy
%   that requires authentication, MATLAB will automatically try to authenticate to
%   the server or proxy if you leave HTTPOptions.Authenticate set to true (default)
%   and set HTTPOptions.Credentials to contain the necessary name(s) and password(s).
%   If authentication is successful, the ResponseMessage will have an OK status and
%   will not contain an AuthenticateField. 
%
%   You will only see one of these header fields in a ResponseMesasge if you disabled
%   authentication or authentication failed for some reason. In those case the
%   StatusCode of the ResponseMessage will be either 401 (StatusCode.Unauthorized) or
%   407 (StatusCode.ProxyAuthenticationRequired). You can then examine the AuthInfo
%   and respond by adding the appropriate AuthorizationField to the RequestMessage
%   containing your credentials, or you can try again by inserting the correct
%   Credentials in HTTOptions.
%
%   If the server or proxy requires an authentication scheme that MATLAB does not
%   support, your only choice is to implement the authentication protocol yourself
%   and respond with the appropriate credentials and other information.
%
%   AuthenticateField properties:
%      Name    - either 'WWW-Authenticate' or 'Proxy-Authenticate'
%      Value   - a comma-separated list of challenges. For the format of these, see
%                <a href="https://tools.ietf.org/html/rfc7235">RFC 7235</a> and (for Basic and Digest authentication) <a href="https://tools.ietf.org/html/rfc2617">RFC 2617</a>.
%                If you use the convert method to parse this field, you do not need
%                to understand these formats.
%
%   AuthenticateField methods:
%      AuthenticateField - constructor
%      convert           - return contents as vector of AuthInfo, one per challenge
%
% See also matlab.net.http.AuthInfo, AuthorizationField,
% matlab.net.http.RequestMessage, matlab.net.http.ResponseMessage,
% matlab.net.http.HTTPOptions, matlab.net.http.Credentials,
% matlab.net.http.StatusCode

% Copyright 2015-2017 The MathWorks, Inc.
    methods (Static, Hidden)
        function names = getSupportedNames()
        % Returns field names this class supports: just 'WWW-Authenticate' and
        % 'Proxy-Authenticate'
            names = ["WWW-Authenticate" "Proxy-Authenticate"];
        end
    end
    
    methods
        function obj = AuthenticateField(varargin)
        % AuthenticateField constructs an AuthenticateField
        %   FIELD = AuthenticateField(NAME,VALUE) constructs a field with the
        %   specified name and value. The NAME must be either 'WWW-Authenticate' or
        %   'Proxy-Authenticate' and the VALUE must be a string that conforms to the
        %   syntax of these fields as specified in RFC 7235, <a href="https://tools.ietf.org/html/rfc7235#section-4.1">section 4.1</a>.
        %
        %   You do not normally construct one of these fields, as this field appears
        %   in a ResponseMessage created by the server. This constructor is provided
        %   for test purposes.
        %
        % See also matlab.net.http.ResponseMessage
            obj = obj@matlab.net.http.HeaderField(varargin{:});
        end
    end
    
    methods (Sealed)
        function value = convert(obj)
        % convert Convert header field to AuthInfo array
        %   AUTHINFO = convert(FIELD) returns a vector of AuthInfo objects, one for
        %   each challenge, in the order they appear in AuthorizationField FIELD. The
        %   'realm' parameter in each AuthInfo typically contains a string that helps
        %   you determine the context of each challenge. For example, you would
        %   display this string to the user if you are creating a username/password
        %   prompt for credentials. The 'realm' parameter appears in each AUTHINFO,
        %   but with an empty value, if the corresponding challenge did not contain a
        %   realm parameter.
        %
        %   If input is an vector of AuthorizationField, returns 
        %
        % See also matlab.net.http.AuthenticationScheme, matlab.net.URI,
        % matlab.net.http.AuthInfo
        
            import matlab.net.http.AuthenticationScheme
            import matlab.net.http.AuthInfo
            
            if ~isscalar(obj)
                if isempty(obj)
                    value = AuthInfo.empty;
                else
                    value = arrayfun(@convert, obj, 'UniformOutput', false);
                    value = [value{:}];
                end
                return
            end
            
            % Parse field, where comma separates array elements and within those,
            % space separates struct fields. This does work we don't need, but
            % simplifies subsequent processing.
            value = obj.parse('Scheme', 'MemberDelimiters', '\s', '_custom', true);
            
            % The challenge grammar uses commas for separating challenge parameters
            % as well as the challenges themselves, which is quite unlike the syntax
            % of other header fields. The only way we can distinguish where a new
            % challenge starts is when a new scheme is named (namely, we find a token
            % not followed by an = sign). For example, in:
            %   Newauth realm="apps", type=1, title="Login to \"apps\"", Basic realm="simple"
            % there are two schemes, Newauth and Basic. The call to parse above
            % generates a struct for each common-separated portion. It treats
            % 'Newauth realm="apps"' as one struct with two fields, Scheme and realm.
            % The value array contains a union of all the struct fields.
            %
            %             (1)       (2)                (3)     (4)
            %   Scheme:   Newauth   []                 []      Basic
            %   realm:    apps      []                 []      simple
            %   title:    []        Login to "apps"    []      []
            %   type:     []        []                 1       []
            %
            % which we then merge into two AuthInfo objects:
            %
            %             AuthInfo(1)      AuthInfo(2) 
            %   Scheme:   Newauth          Basic
            %   realm:    apps             simple
            %   title:    Login to "apps"  
            %   type:     1                
            %
            % and then remove the unspecified title and type parameters from (2).
            
            % Make sure there is a Scheme and realm value in each entry
            haveScheme = isfield(value,'Scheme'); % remember whether there was one
            if ~haveScheme
                [value.Scheme] = deal(''); % insure Scheme is always a string
            end
            if ~isfield(value,'realm')
                value(1).realm = []; 
            end
            
            % res is result: vector of AuthInfos
            res(length(value)) = AuthInfo();  % preallocate for max size
            resIndex = 0;

            % Loop through each struct. One that has a nonempty Scheme is the
            % first struct for the challenge, and all the subsequent ones with
            % empty Scheme are to be coalesced into that first struct.
            for i = 1 : length(value) + 1
                done = i > length(value);
                if ~done
                    thisValue = value(i);
                    if ~isempty(thisValue.Scheme)
                        % Try to convert each Scheme string to an
                        % AuthenticationScheme. If it fails, leave it a string.
                        try
                            thisValue.Scheme = AuthenticationScheme(thisValue.Scheme);
                        catch
                        end
                    end
                end
                % A proper header will always name a Scheme in the 1st struct (i==1).
                % But if it's not there (e.g., if the "Newauth" above is missing),
                % treat it as if it had a Scheme anyway.
                if i > 1 && ~done && haveScheme && isempty(thisValue.Scheme)
                    % Come here when a struct has an empty Scheme, implying that it
                    % belongs to the previous AuthInfo in thisRes. Set all of this
                    % struct's nonempty fields thisRes. This could overwrite values
                    % already there, for example:
                    %   Newauth realm="apps", type=1, type=2 
                    % would use just the last value of type in the res whose
                    % Scheme is 'Newauth'.
                    thisRes = thisRes.setParams(thisValue);
                else 
                    % Come here at the beginning of each new set of structs (i.e.,
                    % the first one and any one that has a Scheme) and after the end
                    % of all the structs.
                    if i ~= 1
                        resIndex = resIndex + 1;
                        res(resIndex) = thisRes; % store previous AuthInfo
                    end
                    if ~done
                        % start a new Authinfo
                        thisRes = AuthInfo(thisValue,true);
                    end
                end
            end
            value = res(1:resIndex);
        end
    end
    
    methods (Access=protected)
        function exc = getStringException(~, ~) 
            % Allow anything rather then spending effort trying to parse the string.
            % This field always comes from server so we don't expect the user will
            % ever create one, so just assume it's valid. The logic in convert()
            % will do something (not necessarily sensible) and not error out, even if
            % the field has invalid syntax, so we're safe to let anything go.
            exc = [];
        end
        
        function str = scalarToString(~, value, varargin)
        % Allow only AuthInfo or strings
            if isa(value, 'matlab.net.http.AuthInfo')
                str = string(value);
            else
                validateattributes(value, {'AuthInfo','string','char'}, {}, mfilename, 'value');
                str = matlab.net.internal.getString(value, mfilename, 'value');
            end
        end
    end
        
    methods (Sealed, Static, Access=protected)
        function tf = allowsArray()
            tf = true;
        end

        function tf = allowsStruct()
            tf = true;
        end
        
        function str = quoteValue(token, ~)
        % Overridden because nothing in this field should be quoted
            str = token;
        end
    end
end




