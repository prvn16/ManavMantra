classdef (Sealed) CookieInfo < matlab.mixin.CustomDisplay
% CookieInfo Information about HTTP Cookies
%   This object contains a Cookie object plus information about the Cookie that you
%   can use for cookie management. You do not normally construct one of these
%   objects. Instead, you obtain one by calling the convert method of a
%   SetCookieField in an HTTP ResponseMessage. Unlike browsers, MATLAB does not
%   provide an automatic "cookie store": you must save cookies on your own and send
%   them back to servers as needed.
%
%   CookieInfo properties:
%      The following properties have values taken from the Cookie and its attributes
%      in the SetCookieField in the ResponseMessage. If the SetCookieField does not
%      contain an attribute, the value is empty.
%
%      Cookie         - matlab.net.http.Cookie
%      Expires        - datetime; NaT if Expires attribute could not be parsed
%      MaxAge         - duration; NaN if Max-Age attribute could not be parsed
%      Domain         - string (set to Host in request URI if attribute missing)
%      Path           - string (set to "default-path" in request URI if missing)
%      Secure         - logical; true if present; false if not
%      HttpOnly       - logical; true if present; false if not
%      Extensions     - values of extension-av attributes
%
%      The following properties provide additional information that may be convenient
%      if you want to manage cookies.
%
%      HostOnly       - true if there was a Domain attribute; false if not
%      ExpirationTime - datetime of cookie expiration
%      CreationTime   - creation time of this CookieInfo
%
%   If the server has inserted any additional attributes in the Set-Cookie header
%   field not listed above, those will be added to the Extensions vector. For
%   more information on these fields, see <a href="http://tools.ietf.org/html/rfc6265">RFC 6265</a>.
%
%   CookieInfo methods:
%     CookieInfo     - constructor
%     collectFromLog - (static) get all the CookieInfos from a transaction history
%
% See also ResponseMessage, matlab.net.http.field.SetCookieField, Cookie, datetime,
% duration

% Copyright 2015-2016 The MathWorks, Inc.

    properties 
        % Cookie - a Cookie object
        %   Once you decide this cookie is relevant for a particular request based on
        %   its attributes (properties of this CookieInfo object), you can insert it
        %   into a CookieField of a RequestMessage.
        %
        % See also Cookie, matlab.net.http.field.CookieField, RequestMessage
        Cookie matlab.net.http.Cookie     
        
        % Secure - true if the Secure attribute is specified in the SetCookieField
        %
        % See also matlab.net.http.field.SetCookieField
        Secure logical = false
        
        % Expires - datetime value of the Expires attribute in the SetCookieField
        %   Value is [] if there was no such attribute, or NaT if the attribute
        %   value could not be parsed.
        %
        % See also matlab.net.http.field.SetCookieField
        Expires datetime
        
        % MaxAge - value of the MaxAge attribute in the SetCookieField as a duration
        %   Value is [] if there was no such attribute, or NaN if the attribute value
        %   could not be parsed.
        % See also matlab.net.http.field.SetCookieField
        MaxAge duration
        
        % HttpOnly - true if the HttpOnly attribute is specified in the SetCookieField
        %
        % See also matlab.net.http.field.SetCookieField
        HttpOnly logical = false
        
        % Domain - a string containing the Domain attribute of this cookie
        %   As per RFC 6265, <a href="http://tools.ietf.org/html/rfc6265#section-5.2.3">section 5.2.3</a>, any leading '.' appearing in this 
        %   attribute in the SetCookieField is removed from this property. If the
        %   SetCookieField did not specify a domain attribute, this is set to the Host
        %   property of the request URI (specified in the call to
        %   SetCookieField.convert) and HostOnly is set to true. Otherwise it is set
        %   to the Domain attribute in the SetCookieField. If neither was specified,
        %   this is empty. This string never begins with a '.'.
        %
        % See also matlab.net.http.field.SetCookieField.convert, matlab.net.URI, HostOnly
        Domain string
        
        % Path - a string containing the Path attribute of this cookie
        %   This is the value of the Path attribute in the SetCookieField. If the
        %   field did not contain a Path attribute, this is set to the "default-path"
        %   based on the Path in the request URI (specified in the call to 
        %   SetCookieField.convert). See RFC 6265, <a href="http://tools.ietf.org/html/rfc6265#section-5.1.4">section 5.1.4</a> for a
        %   description of the default-path. This string always begins with a '/'.
        %
        % See also HasPath, matlab.net.URI, matlab.net.http.field.SetCookieField
        Path string
        
        % HasPath - true if Path was specified in SetCookieField
        %   If true, Path contains the value of the Path attribute in the
        %   SetCookieField. If false, Path contains the "default-path" obtained from
        %   the request URI provided to SetCookieField.convert.
        %
        % See also Path, matlab.net.http.field.SetCookieField.convert
        HasPath logical = false
        
        % HostOnly - true if this cookie is only for the host named in Domain
        %   A logical that is true if the SetCookieField from which this CookieInfo
        %   was derived did not specify a Domain attribute. In that case the Domain
        %   property of this CookieInfo specifies the host for the cookie.
        %
        % See also Domain, matlab.net.http.field.SetCookieField
        HostOnly logical = true
    
        % Extensions - vector of extension-av attributes in the SetCookieField. The
        %   values are strings. The entire attribute is included here as a single
        %   string, even if its syntax is of the form "name=value".
        %
        % See also matlab.net.http.field.SetCookieField
        Extensions string
        
        % Expiration - datetime of cookie expiration
        %   The SetCookieField.convert method computes this property from Expires and
        %   MaxAge if either of those attributes appears in the SetCookieField. It
        %   will be datetime('Inf') if neither appears, which means "retain the
        %   cookie until the current session is over".
        %
        % See also CookieInfo, datetime, matlab.net.http.field.SetCookieField
        ExpirationTime datetime = datetime('Inf') 
        
        % CreationTime - datetime this CookieInfo was created
        %   This property is not specified in a SetCookieField: it is set when this
        %   object is created (i.e., when you call SetCookieField.convert) so you can
        %   properly manage cookies. If you are saving CookieInfo objects in order
        %   to reuse Cookies later, then when getting a new CookieInfo whose
        %   Cookie.Name, Domain and Path (if specified) match those of an existing
        %   one, you should replace the old one with the new one, while retaining the
        %   CreationTime of the old one. This behavior is specified in RFC 6265, 
        %   <a href="http://tools.ietf.org/html/rfc6265#section-5.3">section 5.3</a>, step 11.3.
        %
        % See also matlab.net.http.field.SetCookieField, Cookie
        CreationTime datetime
    end
    
    methods 
        function obj = CookieInfo(varargin)
        % CookieInfo Create a CookieInfo object
        %   INFO = CookieInfo(NAME,VALUE) creates a CookieInfo object, filling in the
        %   properties of this object with the specified values. This constructor is
        %   provided for testing. You normally obtain a CookieInfo object by calling
        %   SetCookieField.convert.
        %
        % See also matlab.net.http.field.SetCookieField.convert, collectFromLog,
        % Cookie
            obj = matlab.net.internal.copyParamsToProps(obj, varargin);
            if isempty(obj.CreationTime)
                obj.CreationTime = datetime('now');
            end
        end
        
        function obj = set.ExpirationTime(obj, time)
            obj.ExpirationTime = matlab.net.http.internal.HTTPDatetime.getDatetime(time);
        end
        
        function obj = set.CreationTime(obj, time)
            obj.CreationTime = matlab.net.http.internal.HTTPDatetime.getDatetime(time);
        end
        
        function str = string(obj)
        % string - return CookieInfo as a string
        %   This method reconstructs the CookieInfo as a string as it may appear in a
        %   SetCookieField. This string may not exactly match the string that
        %   appeared in the field from which this CookieInfo was created, but it
        %   should have the same semantic meaning.
        %
        % See also matlab.net.http.field.SetCookieField.convert
            str = strings(size(obj));
            for j = 1 : numel(obj)
                ci = obj(j);
                res = string(ci.Cookie);
                if ~isempty(ci.Expires) && ~isnat(ci.Expires)
                    res = addAttr(res, 'Expires', char(ci.Expires));
                end
                if ~isempty(ci.MaxAge)
                    res = addAttr(res, 'MaxAge', char(seconds(ci.MaxAge)));
                end
                if ~isempty(ci.Domain) && ~ci.HostOnly
                    % use Domain only if HostOnly not set
                    res = addAttr(res, 'Domain', ci.Domain);
                end
                if ~isempty(ci.Path) && ci.HasPath
                    res = addAttr(res, 'Path', ci.Path);
                end
                if ci.Secure
                    res = addAttr(res, 'Secure');
                end
                if ci.HttpOnly
                    res = addAttr(res, 'HttpOnly');
                end
                for i = 1 : length(ci.Extensions)
                    res = addAttr(res, ci.Extensions(i));
                end
                str(j) = res;
            end
        end
        
        function str = char(obj)
        % char - return CookieInfo as a character vector
        %   For information, see string.
        %
        % See also string
            str = char(string(obj));
        end
        
        function tf = eq(obj,other)
        % Compare two scalar CookieInfos for equality. Ignores CreationTime.
            tf = isscalar(obj) && isscalar(other);
            if tf
                obj.CreationTime = datetime.empty;
                other.CreationTime = datetime.empty;
                tf = isequal(obj,other);
            end
        end
    end
    
    methods (Static)
        function res = collectFromLog(history)
        % collectFromLog Get the latest CookieInfos from history
        %   INFOS = collectFromLog(HISTORY) - Given a HISTORY as a vector of
        %   LogRecord, returns CookieInfo objects for all the valid cookies found in
        %   Set-Cookie header fields in ResponseMessages in that history. This is
        %   useful for obtaining the latest cookies from a history of messages, such
        %   as those exchanged during a transaction involving authentication or
        %   redirection. Servers will sometimes send multiple versions of the same
        %   cookie: this method returns only the most recent. This method also
        %   eliminates cookies that might not be valid for the URI of the server
        %   (i.e., whose Domain is inconsistent with the request URI).
        %
        %   In this example the hypthetical server redirector.com, redirects a request 
		%   that does not contain cookies, to another server that returns the necessary 
		%   cookies, which then redirects back to the original server which the
		%   requester is expected to contact with the provided cookies. By default
		%   MATLAB provides those cookies after a series of redirects.
        %
        %    import matlab.net.http.*
        %    r = RequestMessage;
        %    [resp, ~, history] = r.send('http://www.redirector.com');
        %    % Note that 4 messages were exchanged
        %    disp(length(history));
        %         4
        %    cookieInfos = CookieInfo.collectFromLog(history);
        %    if ~isempty(cookieInfos)
        %        cookies = [cookieInfos.Cookie];
        %    end
        %    % Apply the cookies to the next request
        %    r = RequestMessage([], CookieField(cookies));
        %    [resp, ~, history] = r.send('http://www.redirector.com');
        %    % Now just 1 message is needed
        %    disp(length(history));
        %        1
        %
        % See also LogRecord, ResponseMessage, matlab.net.http.RequestMessage.send,
        % matlab.net.http.field.CookieField
            validateattributes(history, {'matlab.net.http.LogRecord'}, {'vector'}, ...
                               mfilename, 'history');
            infos = arrayfun(@getInfos, history, 'UniformOutput', false);
            infos = [infos{:}];
            % Now purge any duplicate entries from infos. A duplicate must match in
            % Name, Domain and Path. If we find a duplicate, retain the latest.
            res = matlab.net.http.CookieInfo.empty;
            used = zeros(1,length(infos)); % marks used entries in infos
            % This purge is a simple n^2 lookup algorithm. We don't expect to have
            % large numbers of these in any one call, because history is expected to
            % contain just the messages for a sequence of redirects and/or
            % authentications.
            for i = 1 : length(infos)
                if ~used(i)
                    res(end+1) = infos(i); %#ok<AGROW>
                    lastInfo = res(end);
                    for j = i : length(infos)
                        info = infos(j);
                        if ~used(j) && ...
                                lastInfo.Cookie.Name == info.Cookie.Name && ...
                                lastInfo.Domain == info.Domain && ...
                                matchPaths(lastInfo, info)
                            % the info matches lastInfo, so replace lastInfo with
                            % this one in the result array, but use the old one's
                            % CreationTime, as per RFC 6265, section 5.3, step 11.3.
                            res(end) = info;
                            res(end).CreationTime = lastInfo.CreationTime;
                            used(j) = true;
                        end
                    end
                end
            end
        end
    end
    
    methods (Access = protected)
        function group = getPropertyGroups(obj)
        % Implemented just to make empty fields look like []
            group = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            if isscalar(obj)
                names = fieldnames(group.PropertyList);
                for i = 1 : length(names)
                    name = names{i};
                    if isempty(group.PropertyList.(name))
                        group.PropertyList.(name) = [];
                    end
                end
            end
        end
    end
    
end

function tf = matchPaths(a,b)
% Match the Path in two CookieInfos. A missing Path is treated same as an empty
% one.
    if ~isprop(a,'Path')
        ap = [];
    else
        ap = a.Path;
    end
    if ~isprop(b,'Path')
        bp = [];
    else
        bp = b.Path;
    end
    tf = isequal(ap,bp);
end

function infos = getInfos(logRecord)
% Get the CookieInfos from the logRecord.Response, using logRecord.URI
% may return [] if none
    infos = [];
    if ~isempty(logRecord.Response)
        fields = logRecord.Response.getFields('Set-Cookie');
        if ~isempty(fields)
            infos = fields.convert(logRecord.URI);
        end
    end
end

function str = addAttr(str, name, value)
% Add '; name=value' to str, or just '; name' if value is missing
    if nargin == 2
        str = str + '; ' + name;
    else
        str = str + '; ' + name + '=' + value;
    end
end