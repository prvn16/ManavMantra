classdef (Sealed) SetCookieField < matlab.net.http.HeaderField
    %SetCookieField a Set-Cookie HTTP header field
    %   This field appears in a ResponseMessage created by the server. There may be
    %   one or more SetCookieFields in a message. The value in each field may be
    %   extracted as a CookieInfo object using the convert method.
    %
    %   Example of obtaining CookieInfos from all Set-Cookie fields in a message:
    %
	%     % This URI tells httpbin.org to send 2 Set-Cookie fields in the response
    %     uri = matlab.net.URI('http://httpbin.org/cookies/set?foo=bar&abc=def');
    %     opts = matlab.net.http.HTTPOptions('MaxRedirects',0); % ignore redirects
    %     resp = matlab.net.http.RequestMessage().send(uri);
    %     setCookieFields = resp.getFields('Set-Cookie');
    %     if ~isempty(setCookieFields)
    %        cookieInfos = setCookieFields.convert(uri);
    %     end   
    %
    %   SetCookieField methods:
    %     convert   - return CookieInfo object
    %
    % See also matlab.net.http.Cookie, matlab.net.http.CookieInfo,
    % matlab.net.http.ResponseMessage, datetime, convert
    
    % Copyright 2015-2017 The MathWorks, Inc.
    methods (Static)
        function names = getSupportedNames
            names = "Set-Cookie";
        end
    end
    
    methods
        function obj = SetCookieField(value)
        % SetCookieField creates an HTTP Set-Cookie header field
        %   This constructor is provided for test purposes only. You normally obtain
        %   a SetCookieField from a ResponseMessage created by the server, so you
        %   would not create one of these for use in a message. Use the CookieField
        %   constructor to insert a Cookie field in a RequestMessage.
        %
        %   This constructor accepts either a string or a CookieInfo object. It does
        %   not validate that the string has valid syntax for a Set-Cookie field.
        %
        % See also matlab.net.http.ResponseMessage, CookieField,
        % matlab.net.http.RequestMessage, matlab.net.http.CookieInfo
            if nargin == 0
                value = [];
            end
            obj = obj@matlab.net.http.HeaderField("Set-Cookie", value);
        end
        
        function value = convert(obj, uri)
        % convert returns CookieInfo objects for a vector of SetCookieFields
        %   VALUE = convert(FIELDS, URI) where FIELDS is a SetCookieField vector and
        %   URI is an optional URI.
        %
        %   A SetCookieField contains information about just one cookie. If the
        %   server sends multiple cookies, there are multiple SetCookieFields. This
        %   function returns a vector of CookieInfo objects corresponding to the
        %   SetCookieFields in vector FIELDS. 
        %
        %   The URI is that of the request, used to compare against or initialize the
        %   Domain property of the CookieInfos. If a SetCookieField contains no
        %   Domain attribute, the Domain property of its CookieInfo is set to
        %   URI.Host. If there is a Domain attribute, its value must "domain-match"
        %   the URI.Host or no CookieInfo is returned for that SetCookieField. If it
        %   matches, the Domain property is set to the Domain attribute. For more
        %   information on domain matching, see RFC 6265 <a href="http://tools.ietf.org/html/rfc6265#section-5.1.3">section 5.1.3</a>
        %   and <a href="http://tools.ietf.org/html/rfc6265#section-5.3">section 5.3</a>, step 6.
        %
        %   If you do not specify a URI, then the CookieInfo is always returned with the
        %   Domain attribute neither set nor checked. This is acceptable if you do
        %   not intend to use the Domain attribute to manage your cookie store.
        %
        % See also matlab.net.http.Cookie, matlab.net.http.CookieInfo, CookieField,
        % matlab.net.URI
        
            if isempty(obj)
                value = matlab.net.http.CookieInfo.empty;
            else
                if nargin < 2
                    uri = matlab.net.URI.empty;
                else
                    validateattributes(uri, {'matlab.net.URI'}, {'scalar'}, 'CookieField.convert');
                    if isempty(uri.Host)
                        error(message('MATLAB:http:URIMustNameHost', char(uri)));
                    end
                end
                value = arrayfun(@(o)convertScalar(o,uri), obj, 'UniformOutput',false);
                value = [value{:}];
                if nargin > 1
                    value = value(arrayfun(@(d) domainMatch(uri.Host, d), [value.Domain]));
                end
            end
        end
        
    end
    
    methods (Static, Access=protected, Hidden)
        function tf = allowsArray()
            tf = false;
        end
        
        function tokens = getTokenExtents(~, ~, ~)
        % Overridden not to do any escape or quote processing, because strings we get
        % are always the stringified result of CookieInfo which has already done
        % this, or have been validated by CookieInfo.
            tokens = [];
        end
    end
    
    methods (Access=protected, Hidden)
        function str = scalarToString(~, value, varargin)
        % Allow only CookieInfo or strings
            if isa(value, 'matlab.net.http.CookieInfo')
                str = string(value);
            else
                validateattributes(value, {'CookieInfo','string','char'}, {}, mfilename, 'value');
                str = matlab.net.internal.getString(value, mfilename, 'value');
            end
        end
    end                
    
    methods (Access=private)
        function info = convertScalar(obj, uri)
        % Parse the field and return CookieInfo object
        % uri is empty if user didn't specify a URI. This says we don't use any
        % information in the uri to set the CookieInfo properties.
        % Use RFC 6265 parsing rules for each of the attributes
            if isempty(obj.Value) 
                info = [];
                return;
            end
            % The cookie name=value must be first
            cookieName = '^\s*([^\x00-\x1f\x7f()<>@,;:\\"/\[\]?={} \x09]*)';
            cookieOctets ='[\x21\x23-\x2b\x2d-\x3a\x3c-\x5b\x5d-\x7e]*';
            cookieValue = ['(' cookieOctets '|"' cookieOctets '")'];
            anyNonCtl = '[^\x00-\x1f\x7f;]';
            % The other name=value fields appear in any order, but each has its own
            % syntax.
            % Path can be any non-control characters
            pathValue = ['(' anyNonCtl '+)'];
            % A rather loose description of a date, but we'll parse it later. Note
            % it can contain spaces.
            date = '([-\w ,:]+\w)';
            % generic attribute value
            attrValue = ['(' anyNonCtl '*)'];
            extensionAv = ['\s*(' anyNonCtl '+)'];
            % This is the ; separator between attributes, except after the last
            sep = '(?:;\s*|$)|';
            % In this expression, res{i} contains a 1- or 2-element cell containing
            % name and optional value of each attribute. First one is cookie.
            str = [cookieName '=' cookieValue sep ...
                '(Expires)=' date sep ...
                '(Domain)=\.?([-a-zA-Z_0-9./]+)' sep ... % note leading '.' ignored, if present; we allow / even though RFC disallows
                '(Path)=' pathValue sep ... 
                '(Max-Age)=' attrValue sep ...
                '(Secure)' sep '(HttpOnly)' sep extensionAv sep];
            res = regexpi(obj.Value, str, 'tokens');
            if isempty(res)
                % Return empty CookieInfo object if above parse returns nothing
                info = matlab.net.http.CookieInfo;
                return;
            end
            cookieName = '';
            cookieValue = '';
            if ~isempty(res)
                cookieData = res{1};
                if ~isempty(cookieData)
                    cookieName = cookieData{1};
                    if length(cookieData) > 1
                        cookieValue = cookieData{2};
                    end
                end
            end
            % The first token contains the cookie name and value
            % Get the rest of the tokens as name and optional value
            names = cell(1,length(res)); % preallocate
            values = cell(1,length(res));
            names{1} = 'Cookie';
            values{1} = matlab.net.http.Cookie(cookieName, cookieValue);
            % Loren's conditional if
            iif = @(varargin) varargin{2*find([varargin{1:2:end}], 1)}();
            % First element of each res{i} is the name
            names(2:end) = cellfun(@(r) r{1}, res(2:end), ...
                                   'UniformOutput', false);
            % Second element of each res{i} is the value, if present, or []
            values(2:end) = cellfun(@(r) iif(length(r) < 2, [], true, @()r{2}), ... 
                                    res(2:end), 'UniformOutput', false);
            % Normalize known attribute names
            names(2:end) = regexprep(names(2:end), ...
                {'expires','max-age','domain','path','secure','httponly'}, ...
                {'Expires','MaxAge', 'Domain','Path','Secure','HttpOnly'}, 'ignorecase');
            % names has an array of all the attribute names we know about, plus the
            % contents of any extension-av attributes
            % values has the values of all the attributes we know about, but if 
            % values{i} is [] then names{i} is an extension-av
            info = matlab.net.http.CookieInfo;
            import matlab.net.http.internal.HTTPDatetime
            for i = 1 : length(names)
                name = names{i};
                value = values{i};
                if isempty(value) && isnumeric(value)
                    % value is [] means name is extension-av
                    info.Extensions(end+1) = name;
                else
                    % If the same attribute appears more than once, this saves the
                    % last one. This is consistent with RFC 6265, section 5.3 that
                    % says to use the last value for known attributes.
                    switch name
                        case 'Expires'
                            % Expires attribute field is set by servers to an
                            % rfc1123-date (RFC 2616 section 3.3.1) as documented in
                            % RFC 6265, section 4.1.1, but clients must implement
                            % more liberal parsing as per RFC 6265, section 5.1.1 for
                            % backwards compatibility.
                            tv = HTTPDatetime.getDatetime(value);
                            if isempty(tv)
                                % TBD: The above only allows a date in the exact
                                % format of an rfc-1123-date. We try some alternate
                                % parsings here, but this still doesn't implement
                                % fully the formats allowed by 5.1.1 of RFC 6265. To
                                % do that requires "manual" parsing rather than using
                                % datetime. Hopefully these cover reasonable
                                % options; mathworks.com implements the 1st one.
                                % (g1352119)
                                formats = {'e, d-M-y H:m:s z' 'e d-M-y H:m:s z' ...
                                           'd-M-y H:m:s z' 'd M y H:m:s z'};
                                for j = 1 : length(formats)
                                    try
                                        tv = datetime(value, 'TimeZone', 'GMT', ...
                                            'InputFormat', formats{j}, 'Format', ...
                                            HTTPDatetime.Format, 'Locale', HTTPDatetime.Locale);
                                        break;
                                    catch
                                        if j == length(formats)
                                            tv = NaT;
                                        end
                                    end
                                end
                            end
                            value = tv;
                        case 'MaxAge'
                            value = str2double(value);
                            value = duration(0,0,value); % could be NaN
                        case {'Secure','HttpOnly'}
                            value = true;
                    end
                    info.(name) = value;
                end
            end
            
            % Always set the ExpirationTime based on the Expires and MaxAge
            % attributes.
            age = info.MaxAge;
            if ~isempty(age) && ~isnan(age)
                % If MaxAge appears, use it instead of Expires
                info.ExpirationTime = datetime('now') + age;
            else
                % Otherwise ExpirationTime is same as Expires
                info.ExpirationTime = datetime('Inf'); % default if neither appear
                if ~isempty(info.Expires) 
                    % RFC says use Expires first
                    info.ExpirationTime = info.Expires;
                end
            end
            
            % Set HostOnly and Domain as per RFC 6265, section 5.3, step 6.
            % Also normalize Domain to lowercase
            info.HostOnly = isempty(info.Domain);
            if info.HostOnly && ~isempty(uri)
                % get Domain from uri.Host if uri and HostOnly specified
                info.Domain = lower(uri.Host);
            else
                info.Domain = lower(info.Domain);
            end
            
            % If Path not specified or doesn't begin with '/', use default-path,
            % which is Path from URI minus any trailing segment, as per 5.1.4 of RFC
            % 6265.
            if isempty(info.Path)
                % Ignore if URI is empty. This means convert was invoked without
                % a URI, so we don't know what Path to put in.
                if ~isempty(uri) && ...
                   (strlength(info.Path) == 0 || ~startsWith(info.Path,'/'))
                    info.Path = regexprep(uri.EncodedPath, '/[^/]*$', '');
                    if strlength(info.Path) == 0 || ~startsWith(info.Path,'/')
                        info.Path = '/';
                    end
                end
            else
                info.HasPath = true;
            end
        end
    end
    
end

function tf = domainMatch(str, domain)
% Implement RFC 6265 section 5.1.3 Domain Matching
    tf = str == domain || str.endsWith('.' + domain);
end
        



