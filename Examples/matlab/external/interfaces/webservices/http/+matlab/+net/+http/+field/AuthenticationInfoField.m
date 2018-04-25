classdef (Sealed) AuthenticationInfoField < matlab.net.http.HeaderField
% AuthenticationInfoField An AuthenticationInfo HTTP header field
%   An AuthenticateInfoField appears in a ResponseMessage from a server or proxy that
%   conveys information about a successful Digest authentication. 
%
%   If you are taking advantage of automatic authentication provided by MATLAB when
%   you specify Credentials in HTTPOptions, you do not need to access this field.
%   Use this field only if you are implementing your own authentication protocol or
%   one that MATLAB does not automatically support. Since this field appears only in
%   ResponseMessages, you do no normally create one of these. 
%
%   For more information on this field, see <a href="https://tools.ietf.org/html/rfc7615">RFC 7615</a>.
%
%   AuthenticationInfoField properties:
%      Name    - 'Authentication-Info' or 'Proxy-Authentication-Info'
%      Value   - a comma-separated list of token=value strings. 
%
%   AuthenticateField methods:
%      AuthenticationInfoField - constructor
%      convert                 - returns an AuthInfo containing the tokens and values
%
% See also matlab.net.http.AuthInfo, AuthorizationField,
% matlab.net.http.ResponseMessage, matlab.net.http.HTTPOptions,
% matlab.net.http.Credentials, matlab.net.http.StatusCode

% Copyright 2015-2017 The MathWorks, Inc.
    methods (Static, Hidden)
        function names = getSupportedNames()
        % Returns field names this class supports: just 'WWW-Authenticate' and
        % 'Proxy-Authenticate'
            names = ["Authentication-Info" "Proxy-Authentication-Info"];
        end
    end
    
    methods
        function obj = AuthenticationInfoField(varargin)
        % AuthenticationInfoField constructs an AuthenticationInfoField
        %   FIELD = AuthenticationInfoField(NAME) construct a field with no value
        %   FIELD = AuthenticationInfoField(NAME,VALUE) construct a field with the
        %   specified NAME and VALUE. The NAME must be either 'Authentication-Info'
        %   or 'Proxy-Authentication-Info' and the VALUE, if present must be an
        %   AuthInfo object or a string that conforms to the syntax of these fields
        %   as specified in <a href="https://tools.ietf.org/html/rfc7615">RFC 7615</a>.
        %
        %   You do not normally construct one of these fields, as this field appears
        %   in a ResponseMessage created by the server. This constructor is provided
        %   for test purposes.
        %
        % See also matlab.net.http.ResponseMessage, matlab.net.http.AuthInfo
            obj = obj@matlab.net.http.HeaderField(varargin{:});
        end
    end
    
    methods (Sealed)
        function value = convert(obj)
        % convert Convert contents of AuthentcationInfoField to an AuthInfo
        %   AUTHINFOS = convert(FIELDS) returns a vector of AuthInfo corresponding
        %   to the vector of AuthenticationInfoFields FIELDS.
        %
        % See also matlab.net.http.AuthInfo
            if isempty(obj)
                value = matlab.net.http.AuthInfo.empty;
            elseif isscalar(obj)
                value = matlab.net.http.AuthInfo(obj.Value);
            else
                value = arrayfun(@convert, obj, 'UniformOutput', false);
                value = [value{:}];
            end
        end
    end
    
    methods (Access=protected, Hidden)
        function exc = getStringException(~, ~) 
            % Allow anything rather then spending effort trying to parse the value.
            % This field always comes from server so we don't expect the user will
            % ever create one, so just assume it's valid. The logic in convert()
            % will do something (not necessarily sensible) and not error out, even if
            % the field has invalid syntax, so we're safe to let anything go.
            exc = [];
        end
        
        function str = scalarToString(~, value, varargin)
        % Allow only AuthInfo or string
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
            tf = false;
        end

        function tf = allowsStruct()
            tf = false;
        end
        
        function tokens = getTokenExtents(~, ~, ~)
        % Overridden because nothing should be quoted
            tokens = [];
        end
    end
end




