%matlab.internal.webservices.HTTPConnector HTTP connector handle object
%
%   FOR INTERNAL USE ONLY -- This class is intentionally undocumented and
%   is intended for use only within the scope of functions and classes in
%   toolbox/matlab/external/interfaces/webservices/restful. Its behavior
%   may change, or the class itself may be removed in a future release.
%
%   matlab.internal.webservices.HTTPConnector properties (read-only):
%      URL          - URL string
%      CharacterSet - Connection charset value
%      ContentType  - Connection content type
%
%   matlab.internal.webservices.HTTPConnector properties:
%      Username - User identifier
%      Password - User authentication password
%      KeyName - Name of key
%      KeyValue - Value of key
%      HeaderFields - n-by-2 string matrix or cellstr of header names and values
%      UserAgent - User agent identification
%      Timeout - Connection timeout
%      RequestMethod - Name of HTTP request method (GET or POST)
%      PostData - String data to post to service
%      MediaType - Media type of data to post to service
%      Debug - Print debug information
%
%   matlab.internal.webservices.HTTPConnector methods:
%      HTTPConnector - Constructor
%      closeConnection - Close HTTP connection
%      copyContentToByteArray - Copy content to byte array
%      copyContentToFile - Copy content to file
%      delete - Delete object
%      openConnection - Open HTTP connection

% Copyright 2014-2017 The MathWorks, Inc.

classdef HTTPConnector < handle
  
    properties (SetAccess = 'protected', Dependent)
        URL
    end
     
    properties (SetAccess = 'protected')
        CharacterSet = ''
        ContentType = ''
    end  
    
    properties
        Username = ''
        Password = ''
        KeyName = ''
        KeyValue = ''
        HeaderFields = []
        UserAgent = ''
        Timeout = []
        RequestMethod = 'GET'
        PostData = ''
        MediaType = 'application/x-www-form-urlencoded'
        CharacterEncoding
    end
    
    properties (Hidden)
        Debug = false
    end
    
    properties (Dependent)
        CertificateFilename = ''
    end

    properties (Hidden, Access = 'protected')
        Connection = [] % matlab.internal.webservices.HTTPConnectionAdapter (C++)
        ConnectionIsOpen = false
        Proxy = []
        Protocol = ''
        OptionsContentType = ''
        NumberOfRedirects = 0
        MaximumRedirects = 20
        
        % Reference: http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
        StatusCode = struct( ...
            'MovedPermanently', 301, ...
            'Found', 302, ...
            'SeeOther',  303, ...
            'TemporaryRedirect', 307, ...
            'Unauthorized', 401, ...
            'ProxyAuthenticationRequired', 407)    
        
        NumberOfUnauthorizedAttempts = 0
        MaximumNumberOfUnauthorizedAttempts = 1
    end
    
    properties (Access = 'private')
        pURL
        pCertificateFilename
        
        % The DefaultCertificateFilename is the location of the generated
        % file containing root certificates. If set, then the certificate
        % from the HTTP server is validated against the certificates in the
        % PEM file. The verification validates the host domain against the
        % domain in the certificate and also issues an error if the
        % certificate in the PEM file has expired. Since the current
        % version of rootcerts.pem does have an expired certificate, set
        % the property value to ''. Even with an empty root certificate
        % file, the domain verification is still performed.
        % DefaultCertificateFilename = fullfile(matlabroot,'sys','certificates','ca','rootcerts.pem');
        DefaultCertificateFilename = ''
        MessageCount = 0  % used in log
    end
        
    methods
        
        function connector = HTTPConnector(url, options, connection)
        % Constructor for HTTPConnector class.
        
            % Create a connection object, if not passed as an argument.
            if ~exist('connection', 'var')
                connection = matlab.internal.webservices.HTTPConnectionAdapter;
            end
            connector.Connection = connection;
            
            % Set the CertificateFilename property.
            connector.CertificateFilename = connector.DefaultCertificateFilename;
            
            % Set the URL property value.
            connector.URL = url;
            
            % Set the HTTPConnector request properties.
            if ~exist('options', 'var')
                options = weboptions;                
            end
            connector = setProperties(connector, options);
            connector.OptionsContentType = options.ContentType;            
        end
        
        %------------------------------------------------------------------
        
        function openConnection(connector)
        % Open the URL connection and set request properties. Follow URL
        % redirects.
            
            if ~connector.ConnectionIsOpen
                try
                    connection = connector.Connection;
                    
                    % Set timeout.
                    milliseconds = secondsToMilliseconds(connector.Timeout);
                    connection.TimeoutInMilliseconds = milliseconds;
                    
                    % Set Username and Password property values. (Allow
                    % an empty password to be passed to the server, but not
                    % an empty username).
                    [username, password] = ...
                        checkRequestProperty(connector, 'Username', 'Password');
                    if ~isempty(username)
                        connection.Username = username;
                        connection.Password = password;
                    end
                                        
                    % Open the connection to the URL.
                    if isempty(connector.Proxy.Host)
                        connection.openConnection();
                    else
                        connection.openProxyConnection(connector.Proxy);
                    end
                    
                    % Set the request properties.
                    setRequestProperties(connector);
                    
                    if isa(connection, 'matlab.internal.webservices.HTTPJavaConnectionAdapter')
                        % The Java adapter needs properties finalized before we post any data
                        setRequestProperties(connection);
                        if ~isempty(connection.PostData)
                            connection.sendPostData();
                        end
                    end
                                              
                    % Set the connection properties.
                    setConnectionProperties(connector);
                    
                    % Check if redirecting.
                    if any(strcmpi(connector.Protocol, {'http', 'https'}))
                        if isRedirecting(connector) && ...
                                connector.NumberOfRedirects < connector.MaximumRedirects
                            if connector.Debug
                                % For purposes of logging the body of the redirect
                                % message, assume native encoding.  We should really be
                                % looking at the charset in the Content-Type header.
                                try
                                    bytes = copyContentToByteArray(connector.Connection, true);
                                catch 
                                    % a redirect likely just throws an error in
                                    % RESTful mode, so copy no bytes
                                    bytes = '';
                                end
                                connector.log(native2unicode(bytes));
                            end
                            % Follow redirects. Increase count to prevent
                            % indefinite recursion.
                            connector.NumberOfRedirects = connector.NumberOfRedirects + 1;
                            
                            % Redirecting to a different URL.
                            openRedirectConnection(connector);
                        end
                    end
                    
                    % Determine if compression input stream needs to be used. If
                    % so, set the property on the connection.
                    connection.Encoding = getEncoding(connector);
                    
                    % If an unauthorized code is returned by the server,
                    % the request method is 'get', and the JVM is running,
                    % then try again using the HTTPJavaConnectionAdapter.
                    % This adapter uses Java to communicate to the server
                    % and Java supports NTLM authentication (on Windows).
                    % Do not attempt more times than allowed by
                    % MaximumNumberOfUnauthorizedAttempts.
                    if (connector.Connection.ResponseCode == connector.StatusCode.Unauthorized || ...
                        connector.Connection.ResponseCode == connector.StatusCode.ProxyAuthenticationRequired) && ...
                            usejava('jvm') && ...
                            connector.NumberOfUnauthorizedAttempts < connector.MaximumNumberOfUnauthorizedAttempts
                        connector.NumberOfUnauthorizedAttempts = connector.NumberOfUnauthorizedAttempts + 1;
                        if connector.Debug
                            try
                                % Try to grab data from the unauthorized message.  Need to pretend connection
                                % is open to avoid trying to open it again.
                                oldOpen = connector.ConnectionIsOpen;
                                connector.ConnectionIsOpen = true;
                                clean = onCleanup(@()connector.ConnectionIsOpen(oldOpen));
                                bytes = connector.copyContentToByteArray();
                            catch
                                bytes = '';
                            end
                            connector.log(char(bytes)');
                        end
                        connector.Connection = matlab.internal.webservices.HTTPJavaConnectionAdapter(connector.URL);
                        % connector.Connection.Debug = connector.Debug; % not supported yet
                        connector.Connection.Encoding = connection.Encoding;
                        openConnection(connector);
                    end
                                                    
                    % Connection is open.
                    connector.ConnectionIsOpen = true;
                catch e
                    throwAsCaller(e)
                end
            end
        end
        
        %------------------------------------------------------------------
        
        function res = log(obj, responseData)
        % Return a log of the request and response messages, including the 
        % data.  If no return value, print it.  
            
            connection = obj.Connection;
            if isa(connection, 'matlab.internal.webservices.HTTPConnectionAdapter')
                % We use functions in the http package to reconstruct request and response
                % messages, which are able to pretty-print their contents.
                import matlab.net.http.*
                import matlab.net.*
                uri = connection.getRequestURI();
                method = connection.getRequestMethod();
                requestLine = RequestLine(method, URI(uri,'literal'), ProtocolVersion('HTTP/1.1'));
                requestMessage = RequestMessage(requestLine);
                requestMessage = ...
                    requestMessage.addFieldsNoCheck(connection.getRequestFields());
                % get the raw payload that was sent, as uint8 vector, and insert it into
                % MessageBody
                payload = connection.PostDataConverted;
                charset = '';
                if ~isempty(payload)
                    body = MessageBody();
                    body.Payload = payload;
                    requestMessage.Body = body;
                    % The set method for Body in the line above copied any Content-Type from the
                    % requestMessage into Body.ContentType, as a MediaType object, so fetch it and
                    % save any specified or implied charset.
                    ct = requestMessage.Body.ContentType;
                    if ~isempty(ct)
                        charset = matlab.net.internal.getCharsetForMediaType(ct);
                    end
                end
                requestMessage.Completed = true;
                [version, status, reason] = connection.getStatusLine();
                response = ResponseMessage(StatusLine(version, status, reason));
                response = response.addFieldsNoCheck(connection.getResponseFields());
                obj.MessageCount = obj.MessageCount + 1;
                res = sprintf('\nREQUEST %d to %s\n\n%s\n', obj.MessageCount, ...
                              obj.URL,  char(requestMessage));
                % If request payload is text (has a known charset), print it as a string
                if charset ~= ""
                    payload = native2unicode(payload, char(charset));
                    res = [res sprintf('%s\n\n', payload)];
                end
                    
                res = [res sprintf('RESPONSE\n\n%s\n', char(response))];
                if ~ischar(responseData)
                    responseData = evalc('disp(responseData)');
                end
                if length(responseData) > 1000
                    res = [res sprintf('<<%d bytes of data>>\n', length(responseData))];
                else
                    res = [res sprintf('%s\n', responseData)];
                end
                res = [res sprintf('----------------------------\n')];
            else
                res = sprintf('\nUsing Java\n');
            end
            if nargout == 0
                fprintf('%s',res);
            end
        end
    
        %------------------------------------------------------------------
 
        function closeConnection(connector)
        % Close the connection.
            
            connection = connector.Connection;
            if ~isempty(connection) && ismethod(connection, 'closeConnection')
                connection.closeConnection;
            end
            connector.ConnectionIsOpen = false;
        end
        
        %------------------------------------------------------------------
        
        function delete(connector)
        % Close the connection when deleting the object.
        
            closeConnection(connector)
        end
                       
        %------------------------------------------------------------------
        
        function byteArray = copyContentToByteArray(connector)
        % Copy the content from the Web service to a byte (uint8) array.
            
            openConnection(connector);    
            closeObj = onCleanup(@()closeConnection(connector));
            try                
                byteArray = copyContentToByteArray(connector.Connection, true);
            catch e
                code = connector.Connection.ResponseCode;
                e = convertCopyContentToDataStreamException(e,code);
                throwAsCaller(e);
            end
        end
    
        %------------------------------------------------------------------
        
        function copyContentToFile(connector, filename)
         % Copy the content from the Web service to a file.
            
            openConnection(connector);  
            closeObj = onCleanup(@()closeConnection(connector));
            try
                copyContentToFile(connector.Connection, filename);
            catch e
                code = connector.Connection.ResponseCode;
                e = convertCopyContentToDataStreamException(e,code);
                throwAsCaller(e);
            end
        end
        
        %------------------------- set/get methods ------------------------
        
        function set.URL(connector, url)
        % Set the URL property value by storing the value in the private
        % copy. Set the Protocol, and Proxy property values.
        
            % Set private copy.
            connector.pURL = url;
            connector.Connection.URL = url;
            
            % Get the protocol (before the ":") from the URL.
            connector.Protocol = getProtocolFromURL(url);
            
            % Get the proxy information using the MATLAB proxy API
            % and set the property.
            connector.Proxy = getProxySettings(url);             
        end
                
        function url = get.URL(connector)
            url = connector.pURL;
        end   
        
        function set.CertificateFilename(connector, filename)
            filename = matlab.net.internal.validateCertificateFile(filename);
            connector.pCertificateFilename = filename;
            connector.Connection.CertificateFilename = filename;
        end
        
        function filename = get.CertificateFilename(connector)
        % Get CertificateFilename from private copy.
            filename = connector.pCertificateFilename;
        end
    end
    
    methods (Access = 'protected')
        
        function tf = isRedirecting(connector)
        % Return true if the connection indicates that the URL is being
        % redirected by examining the response code.
            
            try
                % For all requests, redirect the same request on Found, MovedPermanently and
                % TemporaryRedirect. For GET, also redirect on SeeOther: the response may not
                % be what the user expects, but there will at least be a response.  Not
                % appropriate to redirect SeeOther for other request methods.  (RFC 7231,
                % 6.4.4)
                code = connector.Connection.ResponseCode;
                tf = any(code == [ ...
                        connector.StatusCode.Found ...
                        connector.StatusCode.MovedPermanently ...
                        connector.StatusCode.TemporaryRedirect]) || ...
                    (strcmpi(connector.RequestMethod, 'GET') && ...
                     code == connector.StatusCode.SeeOther);
            catch
                tf = false;
            end
        end
        
        %------------------------------------------------------------------
        
        function contentType = getConnectionContentType(connector)
        % Get the content type from the connection. Return unknown if any
        % error occurs. Empty may be returned if content type cannot be
        % determined. Invoking this function causes content to be
        % downloaded from the server.
        
            try
                contentType = connector.Connection.ContentType;
            catch e
                throwAsCaller(e)
            end
            
            if isempty(contentType)
            % Some servers may not have the mime types setup for
            % spreadsheet data. Check the URL extension to see if a
            % match is found.
                tableExtensions = {'.xls' '.xlsx' '.xlsb' '.xlsm' '.xltm' '.xltx' '.ods'};
                url = connector.URL;
                [~,~,ext] = fileparts(url);
                if any(strcmpi(ext, tableExtensions))
                   contentType = 'spreadsheet';
                end
            end
        end
        
        %------------------------------------------------------------------
        
        function setConnectionProperties(connector)
        % Set connection properties. These properties must be set after the
        % connection is established and will initiate data transfer from
        % the server.
        
            connection = connector.Connection;
            if ~isempty(connection)
                contentType = getConnectionContentType(connector);
                
                % Set ContentType and CharacterSet properties.
                connector.ContentType  = getContentTypeFromConnection(contentType);
                connector.CharacterSet = getCharacterSetFromConnection(contentType);
            end
        end    
        
        %------------------------------------------------------------------
        
        function setRequestProperty(connector, name, value)
        % Set connection request property if name and value are not empty.
            connection = connector.Connection;
            if ~isempty(name) && ~isempty(connection) && strlength(value) ~= 0
                connection.setRequestProperty(name, value);
            end
        end   
        
        %------------------------------------------------------------------
        
        function setDefaultRequestProperty(connector, name, value)
        % Set connection request property if it is not in the list of
        % connector.HeaderField that the user added.  Value may be empty.
            connection = connector.Connection;
            if ~isempty(name) && ~isempty(connection) && ...
                    (isempty(connector.HeaderFields) || ~any(strcmpi(connector.HeaderFields(:,1), name)))
                connection.setRequestProperty(name, value);
            end
        end
        
        %------------------------------------------------------------------
        
        function setRequestProperties(connector)
        % Set the connector property values on the connection. 
        
            % The set order is important. Certain property manipulations
            % will invoke the connect method of the connection. After
            % connection, setting certain properties, such as Accept, can
            % cause an exception.
        
            % Assign a local variable for the connection.
            connection = connector.Connection;
                            
            % Set Request method.
            if any(strcmpi(connector.Protocol, ["http", "https"]))
                connection.RequestMethod = upper(connector.RequestMethod);
                
                % Set PostData and MediaType if RequestMethod is POST, PUT or PATCH 
                 if any(strcmpi(connector.RequestMethod, ["POST", "PUT", "PATCH"]))
                   connection.PostData = connector.PostData;
                    
                    % If CharacterEncoding has been specified and the
                    % MediaType is not application/x-www-form-urlencoded,
                    % then add a "charset=" parameter to MediaType with the
                    % value set to the value of CharacterEncoding. charset
                    % values are not needed for form-encoded data since the
                    % data is already encoded.
                    if isempty(connector.CharacterEncoding) || ...
                            strcmp('auto',connector.CharacterEncoding) || ...
                            strcmp('application/x-www-form-urlencoded',connector.MediaType)
                        mediaType = connector.MediaType;
                    else
                        mediaType = [ ...
                            connector.MediaType '; charset=' connector.CharacterEncoding];
                    end
                    connection.MediaType = mediaType;
                end
            end

            % Set User-Agent, if not empty.
            userAgent = connector.UserAgent;
            if ~isempty(userAgent)
                setDefaultRequestProperty(connector, 'User-Agent', userAgent);
            end
            
            % Set Accept-Encoding field
            setDefaultRequestProperty(connector, 'Accept-Encoding', 'gzip');
            
            % Obtain KeyName and KeyValue values.
            [keyName, keyValue] = ...
                checkRequestProperty(connector, 'KeyName', 'KeyValue');
            
            % Set the Accept request property if options.ContentType is
            % xmldom or json and KeyName is not Accept.
            if ~strcmp(keyName, 'Accept')
                setAcceptRequestProperty(connector);
            end
            
            % Set Key name and value, if KeyName is not empty. (Allow an
            % empty KeyValue to be passed to the server.) The key
            % name/value pair may override the Authorization value, if set.
            if ~isempty(keyName)
                if ~ischar(keyValue)
                    keyValue = num2str(keyValue);
                end
                setDefaultRequestProperty(connector, keyName, keyValue);
            end
            
            % HeaderFields was already verified by weboptions to be an n-by-2 cellstr
            % or string matrix, so calling cellstr converts them to a cellstr.  These fields
            % will replace any similarly-named fields we already added.
            if ~isempty(connector.HeaderFields)
                headers = cellstr(connector.HeaderFields);
                cellfun(@(n,v)setRequestProperty(connector, n, v), ...
                         headers(:,1), headers(:,2));
            end
        end
        
        %------------------------------------------------------------------
        
        function setAcceptRequestProperty(connector)
        % Set the Accept request property if options.ContentType is xmldom
        % or json.
            
            % Some RESTful Web servers send either XML or JSON responses.
            % Set the Accept header property, if either of these content
            % types are requested.            
            optionsContentType = connector.OptionsContentType;
            index = strcmp(optionsContentType, {'auto', 'json', 'xmldom'});
            if any(index)
                if index(1) || index(2)
                    % JSON is requested, set the Accept header property to
                    % application/json.
                    contentType = 'application/json';
                else
                    % XML is requested, set the Accept header property to
                    % text/xml
                    contentType = 'text/xml';
                end
                
                % Add all others as secondary types.
                contentType = [contentType ', */*'];
                
                % Set the request property.
                try
                    setDefaultRequestProperty(connector, 'Accept', contentType);
                catch
                    % Ignore this error. We are only trying to assist in
                    % specifying the Accept value. In most cases, it is not
                    % needed anyway.                
                end
            end
        end
        
        %------------------------------------------------------------------
        
        function openRedirectConnection(connector)
        % Open redirect connection if the redirect URL is valid.
            
            url = connector.Connection.RedirectURL;
            if ~isempty(url)
                % Reset URL to new location.  Just in case the url contains non-ASCII
                % characters, process it using URI to get the encoded version.
                url = matlab.net.URI(url,'literal');
                connector.URL = char(url);
                
                % Redirecting to a different URL. 
                % Ensure connection is closed.
                closeConnection(connector);
                
                % Try again to open URL connection.
                openConnection(connector);
            else
                % Close the redirection attempt since the redirect URL is
                % not valid.
                connector.NumberOfRedirects = connector.MaximumRedirects + 1;
            end
        end
                
        %------------------------------------------------------------------
        
        function encoding = getEncoding(connector)            
            contentEncoding = connector.Connection.ContentEncoding;
            encoding = 0;
            if ~strcmp('binary', connector.OptionsContentType)
                switch lower(contentEncoding)
                    case 'gzip'
                        encoding = 1;
                    case 'deflate'
                        encoding = 2;
                end
            end
        end
    end
end

%--------------------------------------------------------------------------

function obj = setProperties(obj, options)
% Generic function that sets the public property values of obj with the
% matching properties of options only if obj and options are non-empty and
% scalar objects.

if isobject(obj) && isscalar(obj) && isobject(options) && isscalar(options)
    names = properties(options);
    mc = metaclass(obj);
    index = strcmp('public', {mc.PropertyList.SetAccess});
    props = {mc.PropertyList.Name};
    props = props(index);
    for k = 1:length(names)
        prop = find(strcmpi(names{k}, props),1);
        if ~isempty(prop)
            obj.(props{prop}) = options.(names{k});
        end
    end
    % this property is hidden, so copy explicitly
    obj.Debug = options.Debug;
end
end

%--------------------------------------------------------------------------

function proxy = getProxySettings(url)
% Get proxy settings from MATLAB preferences panel.

proxy = struct( ...
    'Host', '', ...
    'Port', [], ...
    'Username', '', ...
    'Password', '');

if usejava('jvm')
    % Get the proxy information using the MATLAB proxy API.
    % Ensure the Java proxy settings are set.
    com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings

    % Obtain the proxy information.
    url = java.net.URL(url);
    % This function goes to MATLAB's preference panel or (if not set and on
    % Windows) the system preferences.
    javaProxy = com.mathworks.webproxy.WebproxyFactory.findProxyForURL(url);
    if ~isempty(javaProxy) 
        address = javaProxy.address;
        if isa(address,'java.net.InetSocketAddress') && ...
            javaProxy.type == javaMethod('valueOf','java.net.Proxy$Type','HTTP')
            proxy.Host = char(address.getHostName());
            proxy.Port = address.getPort();
                % If proxy information came from MATLAB settings, also get the
                % username and password.  If not, we can only talk to unauthenticated
                % proxies.
            mwt = com.mathworks.net.transport.MWTransportClientPropertiesFactory.create();
            if ~isempty(mwt.getProxyHost())
                proxy.Username = char(mwt.getProxyUser());
                proxy.Password = char(mwt.getProxyPassword());
            end
        end
    end
else
    % The Java JVM is not running. The MATLAB proxy information is obtained
    % from the MATLAB preferences using Java. Return the default structure
    % containing empty values.
end
end

%--------------------------------------------------------------------------

function protocol = getProtocolFromURL(url)
% Get protocol (http or https) from URL.

protocol = url(1:find(url == ':', 1) -1);
end

%--------------------------------------------------------------------------

function contentType = getContentTypeFromConnection(connectionContentType)
% Get content type from connection content type. The connection content
% type may include the character set.

index = find(connectionContentType == ';', 1) - 1;
if ~isempty(index)
    index = index(1);
else
    index = length(connectionContentType);
end
contentType = connectionContentType(1:index);
end

%--------------------------------------------------------------------------

function charSet = getCharacterSetFromConnection(connectionContentType)
% Get character set from connection content type. The default value if not
% found is left as empty.

defaultCharacterSet = '';
index = find(connectionContentType == ';', 1) + 1;
if isempty(index)
    charSet = defaultCharacterSet;
else
    charSet = connectionContentType(index:end);
    if ~isempty(charSet) && ~all(isspace(charSet))
        charsetMatch = regexpi(charSet,'charset=([a-z0-9\-\.:_])*','tokens','once');
        if ~isempty(charsetMatch)
            charSet = charsetMatch{1};
        else
            % The sub-string "charset=" was not found in connectionContentType.
            charSet = '';
        end
    end
end
end

%--------------------------------------------------------------------------

function milliseconds = secondsToMilliseconds(seconds)
% Convert to milliseconds.  No upper bound.  Input may be empty but must not be
% negative.
if ~isempty(seconds) 
    % Use ceil to prevent the calculation from reaching 0.
    secondsToMilliseconds = 1000;
    milliseconds = round(ceil(seconds*secondsToMilliseconds));
else
    % The value is empty, set to the minimum.
    milliseconds = 1;
end
end

%--------------------------------------------------------------------------

function [name, value] = checkRequestProperty(connector, propName, propValue)
% Ensure that if propName is set, then propValue may be set or empty.
% If propValue is set, then propName must also be set.

name  = connector.(propName);
value = connector.(propValue);

% If propValue is set, then propName must be set.
propValueIsSet = ~isempty(value);
if propValueIsSet && isempty(name)
    id = 'MATLAB:webservices:ExpectedNonempty';
    error(message(id, ['options.' propName]));
end
end

%--------------------------------------------------------------------------

function e = convertCopyContentToDataStreamException(e, responseCode)
% Convert an MException with CopyContentToDataStream ID to an exception 
% with an ID that contains the HTTP status code.

id = 'MATLAB:webservices:StatusError';
if strcmp(e.identifier, id) && ~isempty(responseCode)
    responseCode = num2str(responseCode);
    id = ['MATLAB:webservices:HTTP' responseCode 'StatusCodeError'];
    e = MException(id, '%s', e.message);
end
end

