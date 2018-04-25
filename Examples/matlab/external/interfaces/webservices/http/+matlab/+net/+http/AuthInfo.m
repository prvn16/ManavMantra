classdef (Sealed) AuthInfo < matlab.mixin.CustomDisplay
    % AuthInfo Authentication or authorization information in HTTP messages
    %   This class represents one authentication challenge returned by the convert
    %   method in an AuthenticateField of an HTTP ResponseMessage, the credentials in
    %   an AuthorizationField that you can insert into an HTTP RequestMessage, or the
    %   information (auth-info) in an AuthenticationInfoField returned by a server.
    %   This information is documented in <a href="http://tools.ietf.org/html/rfc7235">RFC 7235</a> and (for Basic and
    %   Digest authentication) <a href="http://tools.ietf.org/html/rfc7">RFC 2617</a>.
    %
    %   If you are taking advantage of MATLAB's automatic handling of authentication
    %   by providing Credentials in HTTPOptions when you send a message, you do not
    %   need to use this class. This class is provided if you choose to examine
    %   authentication or specify authorization information, or you need to implement
    %   an authentication protocol that is not supported by MATLAB's HTTP services.
    %
    %   AuthInfo properties:
    %     Scheme     - An AuthInfo used in a challenge or response always has a Scheme 
    %                  that appears first in the challenge or response, which is
    %                  represented in this property as an AuthenticationScheme value
    %                  or a string. An AuthInfo that came from an
    %                  AuthenticationInfoField may have an empty Scheme.
    %     Parameters - An n-by-2 cell array of parameter names and values. Some of
    %                  parameters have special meanings and syntax, which MATLAB
    %                  enforces based on the Scheme: which ones appear depends on the
    %                  Scheme and attributes that follow the Scheme in the header
    %                  field from which the AuthInfo was created, or which you have
    %                  explicitly inserted into this object. Parameter name matching
    %                  is case-insensitive. Parameters with special meanings
    %                  interpreted by MATLAB are listed below. All other parameters
    %                  appear as strings. Access to this array is best done using
    %                  the addParameter, setParameter and removeParameter methods.
    %
    %     Scheme = matlab.net.http.AuthenticationScheme.Basic or Bearer
    %        Exactly one parameter is expected, depending on
    %        whether this AuthInfo is being used in a challenge or response:
    %
    %          In an AuthenticateField (challenge from server) from RFC 2617, <a href="http://tools.ietf.org/html/rfc2617#section-2">section 2</a>:
    %            realm    the realm specified by the server (for a user prompt), and
    %                     which we use to match up with the Realm in Credentials.
    %                     Note that AuthInfos returned by AuthenticateField.convert
    %                     always have a realm property.
    %
    %          In an AuthorizationField (credentials in response from client):
    %            Encoded  a base64-encoded sequence of characters representing the
    %                     username and password as it would appear in the header
    %                     field immediately following the Scheme. If you set this
    %                     parameter you must encode it yourself using base64encode.
    %
    %     Scheme = matlab.net.http.AuthenticationScheme.Digest
    %        Any number of parameters corresponding to name=value parameters in the
    %        header field. Typical parameters are below. All string values appear
    %        in value as double-quoted strings, unless indicated below.
    %
    %          In an AuthenticateField in ResponseMessage (challenge) from RFC
    %          2617, <a href="http://tools.ietf.org/html/rfc2617#section-3.2.1">section 3.2.1</a>:
    %            realm       string
    %            domain      vector of URI (appears as space-separated quoted string)
    %            nonce       string
    %            opaque      string
    %            stale       logical (appears as "true" or "false")
    %            algorithm   string
    %            qop         vector of string (appears as comma-separated quoted string)
    %          Note that AuthInfos returned by AuthenticateField.convert always have
    %          a realm parameter.
    %
    %         In an AuthorizationField in a RequestMessage (credentials in response
    %         from client) from RFC 2617, <a
    %         href="http://tools.ietf.org/html/rfc2617#section-3.2.2">section 3.2.2</a>:
    %            realm       string
    %            username    string
    %            nonce       string
    %            uri         URI  (the digest-uri-value), appears as unquoted string
    %            response    string
    %            algorithm   string
    %            cnonce      string
    %            opaque      string
    %            nc          uint64 (appears as unquoted 8-digit hex number)
    %            qop         string
    %
    %     Scheme = any other matlab.net.http.AuthenticationScheme or a string
    %        MATLAB does not provide any special processing for Schemes other than
    %        Basic and Digest. All parameter names and values are acceptable, as
    %        long as they can be converted to strings. A future release may
    %        implement special handing for properties of additional Schemes,
    %        consistent with Internet standards.
    %
    %   AuthInfo methods:
    %     AuthInfo        - constructor
    %     setParameter    - set or add a new parameter value
    %     getParameter    - return value of a parameter
    %     removeParameter - remove a parameter
    %     isequal, eq, == - compare two AuthInfo objects
    %     string          - return the contents of the message as a string
    %     char            - return the contents of the message as a character vector
    %
    %   When you set the value of a parameter, strings will be left as is, and values
    %   that are not strings must be convertible to strings using the string or char
    %   method. If the parameter is one of the known parameters listed above, its
    %   value will be validated, possibly for consistency with other parameters.
    %
    %   When an AuthInfo is returned by the convert method of AuthenticateField or
    %   AuthorizationField, each name=value pair in the field is converted to a
    %   parameter name and value in the Parameters property. Escape characters 
    %   and any surrounding quotes in values are removed.
    % 
    %   When you store an AuthInfo in an AuthorizationField, values will be quoted
    %   where required and escapes inserted where necessary. 
    %
    %   See also RequestMessage, ResponseMessage, AuthenticationScheme, StatusCode,
    %   matlab.net.http.field.AuthenticateField.convert,
    %   matlab.net.http.field.AuthorizationField, matlab.net.URI, dynamicprops,
    %   matlab.net.base64encode
    
    % Copyright 2015-2017 The MathWorks, Inc.
    properties (AbortSet)
        % Scheme - an AuthenticationScheme or a string
        %   In an AuthInfo created from a challenge in an AuthenticateField, this
        %   property is a string if none of the enumerations of AuthenticationScheme
        %   match the scheme in the challenge. Otherwise it is an Authentication
        %   Scheme, when this AuthInfo came from an AuthenticateField or is used in
        %   an AuthorizationField. It may be empty if this AuthInfo came from an
        %   AuthenticationInfoField.
        %
        %   See also AuthenticationScheme, matlab.net.http.field.AuthenticateField,
        %   matlab.net.http.field.AuthorizationField,
        %   matlab.net.http.field.AuthenticationInfoField
        Scheme 
    end
    
    properties (Dependent)
        % Parameters - parameters of an AuthInfo
        %   This is an n-by-2 cell array representing the parameters and their
        %   values. Parameters{i,1} is the name of the i'th parameter (always a
        %   string) and Parameters{i,2} is its value, whose type depends on the
        %   parameter. You may get or set this property directly, but for getting or
        %   setting individual parameters, it is better to use getParameter or
        %   setParameter.
        %
        % See also setParameter, getParameter, removeParameter
        Parameters
    end
    
    properties(Access=private)
        HasEncoded = false
        HasOtherProps = false
        Params = struct('Name',{},'Value',{},'Class',{})
    end
    
    methods
        function obj = AuthInfo(scheme, varargin)
        % AuthInfo creates an AuthInfo for a scheme
        %   AUTHINFO = AuthInfo(SCHEME,NAME,VALUE,...) creates an AuthInfo that
        %   includes the SCHEME, and any number of optional additional parameters.
        %   AUTHINFO = AuthInfo(NAME,VALUE,...) creates an AuthInfo with an empty
        %   Scheme.
        %
        %   The NAMEs must be strings representing parameters that will be converted
        %   to name=value parameters when this AuthInfo is converted to a string.
        %   There is no constraint on VALUE types, but values must support the string
        %   or char method to return strings. If NAME matches one of the known
        %   parameters listed in the class documentation for AuthInfo, its VALUE is
        %   validated against the expected type. Once you set a VALUE, future values
        %   set in that parameter must be instances of the same type or empty.
        %
        %   The special NAME 'Encoded' refers to the 'token68' token that appears
        %   immediately after the SCHEME name in the stringified AuthInfo, similar to
        %   that documented in RFC 7235, <a href="https://tools.ietf.org/html/rfc7235#section-2.1">section 2.1</a>. If this property appears, it must 
        %   contain the limited set of token68 characters and must be the only 
        %   property.
        %
        %   SCHEME  an AuthenticationScheme, which will set the Scheme property in
        %           the object, or a string naming the scheme. If it is a string, an
        %           attempt will be made to convert it to an AuthenticationScheme. If
        %           not, the Scheme property remains a string. 
        %
        %   AUTHINFO = AuthInfo(STRUCT) creates an AuthInfo whose parameters and
        %   values are copied from the fields of the structure STRUCT. Fields with
        %   empty values are omitted. If STRUCT is any empty array (e.g., [])
        %   returns an empty AuthInfo array.
        %
        %   AUTHINFO = AuthInfo(STR) creates an AuthInfo from the string STR. STR
        %   must obey the syntax for a credentials or challenge in RFC 7235, section
        %   2.1, or the auth-info in an Authentification-Info header as described in
        %   RFC 2617, <a href="http://tools.ietf.org/html/rfc2617#section-3.2.3">Section 3.2.3</a>, which are essentially one of:
        %          SCHEME token
        %          SCHEME param1=value1, param2=value2, ...
        %          param1=value1, param2=value2, ...
        %   where the values are optionally quoted and characters in quotes may be
        %   escaped.
        %
        % See also AuthInfo, AuthenticationScheme, matlab.net.http.field.AuthenticationInfoField
        
        % Option for internal use only:
        %   OBJ = AuthInfo(STRUCT,1) same as AuthInfo(STRUCT) but doesn't check for
        %   errors. This option is used to convert a server's challenge in a
        %   ResponseMessage. This function may be removed in a future release.
        
            if nargin > 0 && (~isempty(scheme) || nargin > 1)
                fromString = false;
                validate = ~isstruct(scheme) || nargin == 1;
                if nargin == 1 && (ischar(scheme) || isstring(scheme))
                    % if single argument is a string that doesn't look like a plain token,
                    % assume the argument is an STR and not a SCHEME with no parameters.
                    str = matlab.net.internal.getString(scheme, mfilename, 'string');
                    if ~matlab.net.http.HeaderField.isValidToken(str)
                        % This returns a struct, same as if caller used the
                        % AuthInfo(STRUCT) syntax.
                        scheme = matlab.net.http.internal.elementParser(str, ...
                            true, false, {',' '\s'}, {'Scheme' 'Encoded'});
                        obj.Scheme = matlab.net.http.AuthenticationScheme.empty;
                        fromString = true;
                    end
                end
                if isstruct(scheme)
                    % a 2nd argument in the struct case says don't error-check; used
                    % when constructing this from a message header generated by the
                    % server or infrastructure.
                    fn = fieldnames(scheme);
                    for i = 1 : length(fn)
                        n = fn{i};
                        obj = obj.setParamInternal(n, scheme.(n), validate, fromString);
                    end
                else
                    obj.Scheme = scheme;
                    if mod(length(varargin),2) > 0
                        varargin{end+1} = '';
                    else
                    end
                    for i = 1 : 2 : length(varargin)
                        obj = obj.setParamInternal(varargin{i}, varargin{i+1}, ...
                                                   true, false);
                    end
                end
            elseif nargin ~= 0
                % one empty arg
                obj = matlab.net.http.AuthInfo.empty;
            end
        end
        
        function obj = set.Scheme(obj, value)
            type = 'matlab.net.http.AuthenticationScheme';
            if isa(value, type) 
                validateattributes(value, {type}, {'scalar'}, mfilename, 'Scheme');
                obj.Scheme = value;
            else
                % Test first because we want message to name type, which getString
                % won't do.
                validateattributes(value, {'char','string',type}, ...
                    {'nonempty'}, mfilename, 'Scheme');
                str = matlab.net.internal.getString(value, mfilename, 'Scheme');
                try
                    obj.Scheme = matlab.net.http.AuthenticationScheme(str);
                catch
                    obj.Scheme = str;
                end
            end
            % Since Scheme changed, revalidate all the parameters.
            for i = 1 : length(obj.Params) %#ok<MCSUP>
                s = obj.Params(i); %#ok<MCSUP>
                obj = obj.setParamInternal(s.Name, s.Value, true, false);
            end
        end
        
        function value = get.Parameters(obj)
            value = {obj.Params.Name; obj.Params.Value}';
        end
        
        function obj = set.Parameters(obj, value)
            validateattributes(value, {'cell'}, {'ndims',2,'size',[NaN,2]}, ...
                mfilename, 'Parameters');
            obj.Params = struct('Name',{},'Value',{},'Class',{});
            for i = 1 : size(value, 1)
                obj = obj.setParameter(value{i,1}, value{i,2});
            end
        end
        
        function obj = setParameter(obj, name, value)
        % setParameter Set the value of an AuthInfo parameter
        %   NEWINFO = setParameter(AUTHINFO, NAME, VALUE) returns a copy of the
        %   AUTHINFO with the parameter NAME set to the specified VALUE, adding it if
        %   it doesn't exist. NAME must be a string or character vector and VALUE may
        %   be a string, character vector, any type that has string or char method, or
        %   a type supported by the specific NAME as documented for AuthInfo. Do not
        %   add any double-quotes to VALUE or escape any special characters in it.
        %   When you insert this AuthInfo in an AuthenticateField,
        %   AthenticationInfoField or AuthorizationField, VALUE (converted to a
        %   string) will be automatically escaped and quoted as necessary. If VALUE
        %   is an array of strings or cell array of character vectors, its members
        %   will be space-separated when converted to a string.
        %
        %   NAMEs are case-insensitive but VALUEs are case sensitive. If you specify
        %   a NAME that matches but has a different case from an existing parameter,
        %   that parameter's name will be changed to the case of the specified NAME.
        %
        %   This operation does nothing if VALUE is [] (i.e., this does not change
        %   the value of the NAME property). However it will set VALUE to an empty
        %   string if it is an empty character vector or empty string.
        %
        %   You may use this method to set the value of 'Scheme', although that will
        %   change the value of the Scheme property in this object rather than adding
        %   a Scheme parameter. You can also set the Scheme simply by writing:
        %       obj.Scheme = value
        %
        %   If you have parameter called 'Encoded', then it must be the only
        %   parameter in this object. This usage is for an AuthorizationField only.
        %
        % See also getParameter, removeParameter, Parameters, AuthInfo, Scheme,
        % matlab.net.http.field.AuthenticateField,
        % matlab.net.http.field.AuthenticationInfoField,
        % matlab.net.http.field.AuthorizationField
            obj = obj.setParamInternal(name, value, true, false);
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'setParameter');
        end
        
        function value = getParameter(obj, name)
        % getParameter Return the value of an AuthInfo parameter
        %   VALUE = getParameter(AUTHINFO, NAME) returns the VALUE of the parameter NAME
        %   in an AuthInfo. NAME is a string or character vector, and name matching is
        %   case-insensitive. VALUE may be any type that was set for the parameter.
        %   VALUE is [] if the parameter does not exist. If NAME is 'Scheme' then the
        %   value of the Scheme property is returned.
        %
        %   If AUTHINFO is a non-scalar, VALUE is a cell array of values with the same
        %   size and shape.
        %
        % See also setParameter, removeParameter, Parameters, Scheme
            if numel(obj) > 1
                value = cell(size(obj));
                for i = 1 : numel(obj)
                    value{i} = obj(i).getParamValue(name);
                end
            elseif isempty(obj)
                value = [];
            else
                value = obj.getParamValue(name);
            end
        end
        
        function obj = removeParameter(obj, name)
        % removeParameter Remove an AuthInfo parameter
        %   NEWINFO = removeParameter(AUTHINFO, NAME) returns a copy of the AUTHINFO
        %   with the parameter NAME removed. The NAME is case-insensitive. If the
        %   parameter does not exist, this method does nothing.
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'removeParameter');
            for i = 1 : numel(obj)
                index = obj(i).getParamIndex(name);
                if ~isempty(index)
                    obj(i).Params(index) = [];
                end
            end
        end
        
        function str = string(obj)
        % string Return AuthInfo as a string
        %   STR = string(AUTHINFO) returns the contents of the AUTHINFO as a string,
        %   exactly as it would appear in a header field.
            str = strings(size(obj));
            for i = 1 : numel(obj)
                if ~isempty(obj(i).Scheme)
                    str(i) = string(obj(i).Scheme);
                else
                    str(i) = '';
                end
                if ~isempty(obj(i).Params)
                    strs = arrayfun(@(s)obj(i).param2String(s), obj(i).Params, 'UniformOutput', false);
                    strs = strjoin([strs{:}], ', ');
                    if ~isempty(str)
                        str(i) = str(i) + ' ' + strs;
                    else
                        str(i) = strs;
                    end
                end
            end
        end
        
        function str = char(obj)
        % char Return AuthInfo as a character vector
        %   CHR = char(AUTHINFO) returns the AuthInfo as a character vector
        %
        %   For more information see string.
        % 
        % See also string
            str = char(string(obj));
        end
        
        function tf = isequal(a, b)
        % isequal compare two AuthInfo objects
        %   TF = isequal(INFO1,INFO2) compares two AuthInfo objects and returns true
        %   if they are functionally equal. They are considered equal if they have
        %   the same Scheme and parameter names (case-insensitive compare) and values
        %   compare equal using isequal, regardless of order of parameters. Both
        %   values must be scalars.
            tf = builtin('isequal',a,b); % first do this for efficiency
            if ~tf && isa(b,'matlab.net.http.AuthInfo')
                validateattributes(a, {'matlab.net.http.AuthInfo'}, {'scalar'}, 'AuthInfo.isequal', 'object');
                validateattributes(b, {'matlab.net.http.AuthInfo'}, {'scalar'}, 'AuthInfo.isequal', 'object');
                if length(a.Params) == length(b.Params)
                    if ~isequal(a.Scheme, b.Scheme)
                        return;
                    end
                    for i = 1 : length(b.Params)
                        param = b.Params(i);
                        if ~isequal(a.getParamValue(param.Name), param.Value)
                            return;
                        end
                    end
                    tf = true;
                else
                end
            else
            end
        end         
        
        function tf = eq(a, b)
        % == compare two AuthInfo objects
        %   This method is identical to isequal.
        %
        % See also isequal.
            tf = isequal(a,b);
        end
    end
    
    methods (Access=private)
        function str = param2String(obj, param)
        % Return a string that represents the parameter Name and Value. Note value
        % can never be [], but it can be "".
            value = param.Value;
            name = param.Name;
            if strcmpi(name,'Scheme') || strcmpi(name,'Encoded')
                % The Scheme and Encoded properties just have values, no names
                str = string(value);
            else
                if ~isempty(obj.Scheme) && ~isstring(obj.Scheme) && ...
                        obj.Scheme == matlab.net.http.AuthenticationScheme.Digest
                    % all Digest name=value parameters with special handing
                    switch lower(name)
                        case 'nc'
                            if isnumeric(value)
                                value = lower(dec2hex(value,8));
                            else
                            end
                        case 'qop'
                            value = quoteValue(value, ',');
                        otherwise
                            value = quoteValue(value, ' ');
                    end
                else
                    value = quoteValue(value, ' ');
                end
                str = string(name) + '=' + value;
            end
        end
        
        function obj = setParamInternal(obj, name, value, validate, fromString)
        % Same as setParameter with additional argument:
        %   validate  - true to throw errors on inconsistent combination of
        %   parameters or values. 
        
            import matlab.net.http.*;
            import matlab.net.internal.*;
            digest = AuthenticationScheme.Digest;
            bearer = AuthenticationScheme.Bearer;
            if ~isempty(value) || ischar(value)
                name = matlab.net.internal.getString(name, mfilename, 'name');
                if strcmpi(name,'Encoded') && validate 
                    if isempty(regexp(value, '^([-a-zA-Z_0-9.~+/])+=*$', 'once'))
                        badChar = regexp(value, '[^-a-zA-Z_0-9.~+/]', 'match', 'once');
                        error(message('MATLAB:http:IllegalCharInToken', ...
                                      char(badChar), char(value)));
                    end
                end
                charName = char(lower(name)); % TBD string when validateattributes used by getString supports string
                if strcmp(charName, 'scheme')
                    for i = 1 : numel(obj)
                        obj(i).Scheme = value;
                    end
                    return;
                end
                % Perform special processing depending on the scheme
                validated = true;
                for i = 1 : numel(obj)
                    thisObj = obj(i);
                    if isequal(thisObj.Scheme, digest)
                        % special conversions for Digest properties that aren't
                        % necessarily strings
                        switch charName
                            case 'domain'
                                % we allow a URI vector or single string
                                % value converted to URI vector
                                if ~(isa(value, 'matlab.net.URI') && isvector(value))
                                    value = parseDomain(getString(value, mfilename, charName));
                                end
                            case 'stale'
                                % we allow a logical or string
                                % value converted to logical scalar
                                if ~(islogical(value) && isscalar(value))
                                    value = lower(getString(value, mfilename, charName)) == 'true';
                                end
                            case 'qop'
                                % we allow a string with comma-separated list of tokens
                                % or string vector 
                                % value converted to string vector
                                if (isstring(value) && isscalar(value)) || ...
                                        (ischar(value) && isvector(value))
                                    value = getString(value, mfilename, charName);
                                    value = strsplit(value, ',\s*', ...
                                                  'DelimiterType', 'RegularExpression'); 
                                else
                                    value = getStringVector(value, mfilename, charName);
                                end
                            case 'nc'
                                % we allow a positive integer or a hex string that
                                % evaluates to one
                                if ischar(value) || isstring(value)
                                    try
                                        nc = hex2dec(char(getString(value, mfilename, charName))); % TBD string
                                    catch
                                        if validate
                                            error(message('MATLAB:http:ncMustBeNumber',value));
                                        else
                                            nc = value;
                                        end
                                    end
                                elseif isnumeric(value)
                                    validateattributes(value, {'numeric'}, ...
                                        {'positive','integer','real'}, mfilename, charName);
                                    nc = value;
                                else
                                    % this always throws, since we checked all allowed
                                    % cases above. 2nd argument is just for message.
                                    validateattributes(value, {'char','string','numeric'}, ...
                                        {}, mfilename, charName);
                                end
                                if isnumeric(nc)
                                    value = uint64(nc);
                                else
                                end
                            case 'uri'
                                % we allow a scalar URI or string
                                if ~(isa(value, 'matlab.net.URI') && isscalar(value))
                                    value = matlab.net.URI(value);
                                    validateattributes(value, {'matlab.net.URI'}, {'scalar'}, ...
                                        mfilename, charName);
                                else
                                end
                            otherwise
                                validated = ~validate;
                        end
                    else
                        % for other schemes, accept any parameter
                        validated = ~validate;
                    end
                    index = thisObj.getParamIndex(name);
                    if isempty(index)
                        isEncoded = strcmpi(name, 'encoded');
                        if validate && ...
                          ((isEncoded && ...
                             (thisObj.HasOtherProps || isequal(thisObj.Scheme,digest))) || ...
                           (~isEncoded && thisObj.HasEncoded))
                            if fromString
                                if isEncoded
                                    e = value;
                                else
                                    e = thisObj.getParameter('Encoded');
                                end
                                error(message('MATLAB:http:EncodedWithOtherProps', ...
                                              char(e)));
                            else
                                error(message('MATLAB:http:EncodedCannotHaveOtherProps'));
                            end
                        else
                        end
                        thisObj.HasEncoded = isEncoded;
                        thisObj.HasOtherProps = ~isEncoded;
                        obj(i) = thisObj.addParam(name, value);
                    else
                        obj(i) = thisObj.setParam(index, name, value, ~validated);
                    end
                end
            end
        end
        
        function obj = setParam(obj, index, name, value, validate)
        % Set the name and value of the parameter. If validate set, verifies that the
        % new value is the same type, or subclass of, the existing value. This
        % function should be called after setParamInternal, which validates the value
        % for known parameters.
            if ischar(value)
                value = string(value);
            end
            if (validate)
                validateattributes(value, {obj.Params(index).Class}, {}, ...
                                   mfilename, char(name));
            end
            obj.Params(index).Name = name;
            obj.Params(index).Value = value;
        end
        
        function obj = addParam(obj, name, value)
        % Add the parameter to this object. The parameter must not already exist.
        % Verifies nothing about it. This function should be called
        % after setParamInternal, which validates the value for known parameters.
            if ischar(value)
                value = string(value);
            end
            obj.Params(end+1) = ...
                struct('Name',name,'Value',value,'Class',class(value));
        end
        
        function index = getParamIndex(obj, name)
        % Returns index of named parameter, or [] if it's not found
            index = find(strcmpi(name, [obj.Params.Name]),1);            
        end
        
        function value = getParamValue(obj, name)
        % Returns value of named parameter, or [] if it's not found
            if strcmpi(name, 'Scheme')
                value = obj.Scheme;
            else
                index = getParamIndex(obj, name);
                if isempty(index)
                    value = [];
                else
                    value = obj.Params(index).Value;
                end
            end
        end
    end
            
    methods (Access=?matlab.net.http.field.AuthenticateField)
        function obj = setParams(obj, value)
        % setParams copies the nonempty fields of the structure into this object
        % without error checking
            %No validation needed as this is internal use only
            %validateattributes(value, {'struct'}, {'scalar'}, mfilename);
            fields = fieldnames(value);
            for i = 1 : length(fields)
                name = fields{i};
                obj = obj.setParamInternal(name, value.(name), false);
            end
        end
    end
    
    methods (Access=?matlab.net.http.Credentials)
        function tf = worksFor(obj, authInfo)
        % worksFor Check whether this authInfo applies to the challenge in authInfo
            tf = false;
            if isempty(authInfo)
                % empty challenge works for anything
                tf = true;
            else
                thisRealm = obj.getParameter('realm');
                otherRealm = authInfo.getParameter('realm');
                if obj.Scheme == authInfo.Scheme && ...
                   (isempty(otherRealm) || thisRealm == otherRealm)
                   % schemes match and, if present, realms match
                   thisDomains = obj.getParameter('domain');
                   otherDomains = authInfo.getParameter('domain');
                   if ~isempty(thisDomains) && ~isempth(otherDomains)
                       % if they both have domains, one must match
                       tf = false;
                       for i = 1 : length(thisDomains)
                           thisDomain = thisDomains(i);
                           for j = 1 : length(otherDomains)
                               if thisDomain == otherDomains(j)
                                   tf = true;
                                   break;
                               end
                           end
                       end
                   else
                       tf = true;
                   end
                end
            end  
        end
    end
    
    methods (Access=protected)
        function group = getPropertyGroups(obj)
        % Provide a custom display that expands Parameters
            group = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            if isscalar(obj) && ~isempty(obj.Params)
                strs = arrayfun(@(s)obj.param2String(s), obj.Params, 'UniformOutput', false);
                % Use char to get single-quotes around the output, so as not to be
                % confused with the double-quotes inside. We'd rather have no
                % surrounding quotes in the display, but that's not possible.
                group.PropertyList.Parameters = char(strjoin([strs{:}], ', '));
            end
        end
    end
end

function str = quoteValue(value, delim)
% Quote and escape string(value) and return a string. 
% If value is a vector (other than char), delim-separate the strings
    if ischar(value) 
        % by making char vector a string, it's not a 1-element vector
        value = string(value);
    end
    % quote each string; return cell (want string vector)
    strs = arrayfun(@(v) regexprep(getChar(v), '["\\]', '\\$0'), ...
                                   value, 'UniformOutput', false);
    str = '"' + strjoin([strs{:}], delim) + '"';
end

function str = getChar(value)
% Convert value to char using string or char function, whichever works, and return
% string; otherwise fail. We use this to stringify properties other than the ones we
% know how to process. Allows for adding future property types that have char or
% string methods without changing this class.
    if ~ischar(value) && ~isstring(value)
        try
            str = char(value);
        catch
            str = string(value);
        end
    else
        str = value;
    end
    if ischar(str)
        str = string(str);
    end
end

function uris = parseDomain(value)
% Parse the value (a string, contents of the domain property in a Digest challenge)
% to return a URI vector. It treats the value as a space-separated list of URIs.
% Return [] if string is empty.
    if strlength(value) == 0
        uris = [];
    else
        strs = strsplit(value); 
        % don't want cellstr so we don't use cellfun
        for i = length(strs) : -1 : 1
            uris(i) = matlab.net.URI(strs{i});
        end
    end
end

