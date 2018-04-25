%matlab.net.http.internal.HTTPConnector HTTP connector handle object
%
%   FOR INTERNAL USE ONLY -- This class is intentionally undocumented and
%   is intended for use only within the scope of functions and classes in
%   toolbox/matlab/external/interfaces/net/http. Its behavior
%   may change, or the class itself may be removed in a future release.
%
%   Usage is:
%      connector = HTTPConnector(uri, httpOptions, [], header);
%      connector.Consumer = consumer;
%      connector.RequestMethod = method;
%      connector.Payload = payload;
%      ...set other connector properties
%      [resp, history] = connector.sendRequest(credInfo, history);
%      request = connector.getRequest();   % original request
%      response = connector.getResponse(); % response message with headers only
%      ...examine other connector properties
%      connector.useConsumer(request, response); % if consumer specified
%      [data, len, payload, charset] = readContentFromWebService(connector, ...
%                                                            debug, convert, raw);
%
%   matlab.net.http.internal.HTTPConnector properties (read-only):
%      URI          - URI object
%
%   matlab.net.http.internal.HTTPConnector properties:
%      UserAgent      - User agent identification
%      ConnectTimeout - Connection timeout
%      RequestMethod  - Name of HTTP request method
%      Payload        - raw uint8 vector to send in message, already converted from
%                       user data based on MediaType.  Not used if Provider is set.
%      MediaType      - Media type of data to send to service
%      ContentType    - Content-Type of received message (string).  May be empty.
%      Header         - Header of request
%      MaxRedirects   - maximum number of redirects
%      ProxyCredentialInfo  - proxy's credentials
%      ProxyURI       - proxy to use (URI object)
%      Decoded        - true if OK; false if content needs decoding based on Content-Encoding
%      CertificateFilename - name of certficate file or ''
%      Consumer       - ContentConsumer
%      Provider       - ContentProvider.  If set, Payload ignored.
%      UseChunked     - Use chunked transfer coding to send request
%      ConvertResponse - Convert responses in redirect messages
%
%   matlab.net.http.internal.HTTPConnector methods:
%      HTTPConnector          - Constructor
%      close                  - Close HTTP connection
%      copyContentToByteArray - Copy content to byte array
%      copyContentToFile      - Copy content to file
%      delete                 - Delete object
%      open                   - Open HTTP connection

% Copyright 2014-2017 The MathWorks, Inc.

classdef HTTPConnector < handle
  
    properties (SetAccess = 'protected', Dependent)
        URI  matlab.net.URI
    end
     
    properties
        UserAgent string = ''
        ConnectTimeout double = []
        RequestMethod string = 'GET'
        Payload uint8 = [] % uint8 vector to send
        MediaType string = 'application/x-www-form-urlencoded'
        Header = []  % array of struct {Name, Value}
        MaxRedirects uint64 % number of redirects to follow
        % ProxyCredentialInfo - matlab.net.http.internal.CredentialInfo
        % Set this when you want to authenticate to a proxy.  
        ProxyCredentialInfo = [] % matlab.net.http.internal.CredentialInfo can't use typed property because constructor has access restrictions
        % Proxy - URI of proxy.  Set automatically by constructor from HTTPOptions,
        % but could be overridden.
        ProxyURI matlab.net.URI
        ProgressMonitor % user's ProgressMonitor
        % These two set by caller as needed, as specified by user
        ProxyUsername string
        ProxyPassword string
        Consumer        % user's ContentConsumer or (initially) function handle
        Provider        % user's ContentProvider
        UseChunked      % use chunked transfer coding to send request
        ConvertResponse % convert the response payload (applies to redirect messages only)
    end
    
    properties (Dependent)
        CertificateFilename = ''
    end
    
    properties (Hidden, Dependent)
        Sent % true if request was successfully sent
    end
    
    properties (Hidden)
        Debug = false;
    end
        

    properties (Hidden, Access = 'protected')
        Connection = []             % HTTPConnectionAdapter
        ConnectionIsOpen = false    % true if OK to read data from connection
        ConnectionAttempted = false
        Protocol = ''
        NumberOfRedirects = 0
       
        NumberOfUnauthorizedAttempts uint32 = 0
        MaximumNumberOfUnauthorizedAttempts uint32 = 1
        Authenticate = false
        Credentials = []  % Set from HTTPOptions
    end
    
    properties (Access = 'private')
        pURI matlab.net.URI
        pCertificateFilename char
        
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
        DefaultCertificateFilename char = ''
        MessageCount = 0  % used in log
        SavePayload logical = false % true says save payload of incoming and outgoing messages
        DecodePayload logical = true % false says don't unzip payload
        VerifyServerName logical = true % false says don't verify server name in certificate
    end
    
    properties (SetAccess = 'private')
        ContentType % string, from received response; could be empty
        Decoded     % true if content returned by the copyContentTo functions
                    % will be decoded or didn't need decoding.  If false, content
                    % received from web will be remain encoded according to
                    % Content-Encoding and will be unsuitable for conversion based on
                    % Content-Type.
    end
        
    methods
        function obj = HTTPConnector(uri, options, connection, header)
        % Constructor for HTTPConnector class.
        
        % Create a connection object, if not passed as an argument.
            if ~exist('connection', 'var') || isempty(connection)
                connection = matlab.internal.webservices.HTTPConnectionAdapter(true);
            end
            obj.Connection = connection;
            
            % Set the CertificateFilename property.
            obj.CertificateFilename = obj.DefaultCertificateFilename;
            
            % Set the URL property value.
            obj.URI = uri;
            
            % Copy the fields into the Fields array, making then Name/Value structs
            s = warning('off','MATLAB:structOnObject');
            obj.Header = header;
            warning(s.state, s.identifier);
            obj = obj.setProperties(options);
            obj.Connection.VerifyServerName = obj.VerifyServerName;
        end
        
        %------------------------------------------------------------------
        
        function useConsumer(obj, request, response)
        % Called after receipt of response header to set up obj.Consumer to be applied
        % to a subsequent readContentFromWebService(connector,...).  No effect if
        % obj.Consumer is not set.  Instantiates obj.Consumer, initializes it, and
        % passes it to HTTPConnectionAdapter.  If obj.Consumer was a function handle,
        % replaces it with an instance.  
        %
        % Do not call this until sendRequest() returns and you have decided to read
        % the payload using the consumer.
        %
        % If the consumer's initialize() method rejects this response, then no
        % consumer is used.
        %
        % A subsequent call to getConsumer() returns the consumer if it was willing to
        % accept this response, or [] if not.
           consumer = obj.Consumer;
           if ~isempty(consumer) && hasContent(request,response)
               if ~isa(consumer, 'matlab.net.http.io.ContentConsumer')
                    % if not an instance of ContentConsumer, it must be a function
                    % returning one, so call it
                    consumer = consumer(); 
                    validateattributes(consumer, {'matlab.net.http.io.ContentConsumer'}, ...
                        {'scalar'}, 'RequestMessage', 'CONSUMER');
                end 
                % Initialize the consumer with header information
                % TBD: 8192 should be the same as the buffer size in
                % InterruptibleStreamCopier.  Find a better way to make these numbers the
                % same.
                consumer.setProperties(8192, obj.URI, request, response, response.Header, obj.SavePayload);
                obj.Consumer = consumer;
                ok = consumer.initializeInternal();
                if ~ok
                    % if consumer rejects content, proceed as if no consumer
                    ct = "";
                    if response.StatusCode == matlab.net.http.StatusCode.OK 
                        % if not a redirect message, this case should warn
                        if ~isempty(response.Header)
                            ctf = response.Header.getFields('Content-Type');
                            if ~isempty(ctf)
                                ct = ctf(1).convertLike('Content-Type');
                                if ~isempty(ct)
                                    ct = string(ct);
                                end
                            end
                        end
                        warning(message('MATLAB:http:ConsumerRejects', class(consumer), ct));
                    end
                    consumer = [];
                    obj.Consumer = [];
                end
               % set consumer in the adapter
               obj.Connection.Consumer = consumer; 
           else
               obj.Connection.Consumer = [];
           end
        end
        
        %------------------------------------------------------------------
        
        function useProvider(obj)
        % Called prior to sendRequest to set up obj.Provider for providing the payload.
        % No effect if obj.Provider is not set.
            provider = obj.Provider;
            if ~isempty(provider)
                obj.Connection.Provider = provider;
                obj.Connection.ProviderBufferSize = provider.preferredBufferSizeInternal();
                obj.Connection.Chunked = obj.UseChunked;
            end
        end
        
        %------------------------------------------------------------------
        
        function consumer = getConsumer(obj)
        % Return the consumer currently set to receive following payload.  Must be
        % called only after useConsumer() was invoked for current response.  Returns
        % [] if consumer has rejected response.
        
            % get consumer from the adapter
            consumer = obj.Connection.Consumer;
        end
        
        %------------------------------------------------------------------
        
        function [response, history] = sendRequest(obj, credInfo, history, redirecting)
        % sendRequest sends a request with optional credentials
        %   Multiple requests may to the same URI be sent on the same obj.  When
        %   called internally from this class, a request to a new URI can be made
        %   after calling close().  If credInfo specified, use it for authentication
        %   to the server.  This may update its contents.
        %   
        %   This function may throw an exception if it could not send the message or
        %   receive the response.
        %
        %   history     - vector of LogRecord
        %   redirecting - true if redirecting
        %   response    - ResponseMessage including StatusLine and Header, but no Body
        
            import matlab.net.http.*
            connection = obj.Connection;
            
            if nargin < 4
                redirecting = false;
            end
            
            % Set timeout.
            milliseconds = secondsToMilliseconds(obj.ConnectTimeout);
            connection.TimeoutInMilliseconds = milliseconds;

            history(end+1) = LogRecord;
            history(end).RequestTime = datetime('now');
            
            % Open the connection to the URI.
            if isempty(obj.ProxyURI) 
                history(end).URI = obj.URI;
                connection.openConnection();
            else
                history(end).URI = obj.ProxyURI;
                % In the case of https with proxy authentication, if the proxy credentials come
                % from the preference panel (ProxyCredentialInfo is set), plug in the username
                % and password from the panel, because POCO does its own authentication to the
                % proxy when setting up the https connection--it will never return a normal 407
                % response message to give us a 2nd chance to supply credentials.
                if strcmpi(obj.URI.Scheme,'https') && ~isempty(obj.ProxyCredentialInfo)
                    if isempty(obj.ProxyUsername)
                        obj.ProxyUsername = obj.ProxyCredentialInfo.Username;
                    end
                    if isempty(obj.ProxyPassword)
                        obj.ProxyPassword = obj.ProxyCredentialInfo.Password;
                    end
                end
                connection.openProxyConnection(...
                  struct('Host',char(obj.ProxyURI.EncodedHost), 'Port', obj.ProxyURI.Port, ...
                        'Username', char(obj.ProxyUsername), 'Password', char(obj.ProxyPassword)));
            end

            % Set the request properties.
            obj.setRequestProperties(redirecting);

            % Set credentials for server and proxy
            if nargin > 1 && ~isempty(credInfo)
                connection.setCredentials(credInfo.HTTPCredentials, false);
            end

            if ~isempty(obj.ProxyCredentialInfo)
                connection.setCredentials(obj.ProxyCredentialInfo.HTTPCredentials, true);
            end
            
            progressReporter = connection.ProgressReporter;
            if ~isempty(progressReporter)
                progressReporter.Direction = MessageType.Request;
                if ~isempty(obj.Provider)
                    progressReporter.Maximum = obj.Provider.ExpectedLength;
                else
                    progressReporter.Maximum = length(obj.Payload);
                end
            end
            
            % Send the message, and get the response header
            obj.ContentType = connection.ContentType; % may be empty if no Content-Type
            history(end).RequestTime(2) = datetime('now');
            % TBD these times are not quite right (g1343112)
            history(end).ResponseTime = datetime('now');
            request = obj.getRequest();
            history(end).Request = request;
            % note this response has no body, as we have only read the header so far
            response = obj.getResponse();
            if ~isempty(progressReporter)
                clf = response.Header.getValidField('Content-Length');
                if ~isempty(clf)
                    progressReporter.Maximum = clf.convert();
                else
                    progressReporter.Maximum = [];
                end
                progressReporter.Direction = MessageType.Response;
            end
            history(end).Response = response;
            disposition = Disposition.Done;

            obj.ConnectionAttempted = true;

            % Check if redirecting.
            if any(strcmpi(obj.Protocol, {'http', 'https'})) && ...
               obj.isRedirecting() && obj.NumberOfRedirects < obj.MaxRedirects
                % if redirecting and debugging or SavePayload set, read the body of
                % the redirect response
                if obj.Debug || obj.SavePayload
                    % To avoid assertion in readContentFromWebService, must
                    % temporarily set ConnectionIsOpen. But we don't really want to
                    % consider it open until all redirects are done.
                    obj.ConnectionIsOpen = true;
                    cleanup = onCleanup(@() obj.unopen);
                    import matlab.net.http.internal.readContentFromWebService
                    e = [];
                    try
                        % Ready the consumer to accept redirect body, if needed
                        obj.useConsumer(request, response);
                        % Log the response payload and convert the data or pass it to
                        % consumer.  This might throw on a conversion error. 
                        [data, ~, payload] = readContentFromWebService(obj, obj.Debug, obj.ConvertResponse);
                        disposition = Disposition.Done;
                    catch e
                        % Couldn't read the response payload, or we read it but
                        % couldn't convert the data.  We'll keep redirecting, but
                        % first fix up the log.
                        data = [];
                        if isa(e, 'matlab.net.http.internal.ExceptionWithPayload')
                            % We got response payload but couldn't convert it.  We
                            % don't consider this an error since the user wanted us
                            % to redirect regardless, so just save payload.
                            payload = e.Payload;
                            disposition = Disposition.ConversionError;
                            e = e.cause{1};
                        else
                            % We couldn't read response payload.  Consider this a 
                            % failure, so set disposition in history and clear
                            % payload.
                            disposition = Disposition.TransmissionError;
                            payload = [];
                        end
                        history(end).Request = obj.getRequest();
                        history(end).Exception = e;
                    end
                    clear cleanup
                    % complete the history record with redirect payload, if
                    % SavePayload was set
                    if obj.SavePayload
                        body = MessageBody(data);
                        if obj.ConvertResponse
                            ctf = history(end).Response.getFields('Content-Type');
                            if ~isempty(ctf)
                                body.ContentType = ctf(1).convertLike('Content-Type');
                            end
                        end
                        body.PayloadInt = payload;
                        body.PayloadLength = length(payload);
                        history(end).Response.Body = body;
                    end
                    history(end).Disposition = disposition;
                    if ~isempty(e)
                        throw(matlab.net.http.HTTPException(history(end).URI, history(end).Request, history, e));
                    end
                end
                
                % Follow redirects. Increase count to prevent indefinite
                % redirects.
                obj.NumberOfRedirects = obj.NumberOfRedirects + 1;
                history(end).ResponseTime(2) = datetime('now');
                history(end).Disposition = disposition;

                % Redirecting to a different URL.
                try
                    now = datetime('now');
                    [resp, history] = obj.openRedirectConnection(credInfo, history);
                    if ~isempty(resp)
                        response = resp;
                    end
                catch e
                    % Exception on redirect; throw HTTPException with history and cause
                    % Add a new LogRecord with the request that failed, and possibly a response as
                    % well, because the exception prevented the record from being added.
                    % TBD Note this logic is identical to what RequestMessage.sendOneRequest does
                    % when an exception occurs before the response header is received.
                    history(end+1) = LogRecord;
                    history(end).URI = obj.URI;
                    history(end).RequestTime = now;
                    history(end).Request = obj.getRequest();
                    if (obj.Sent)
                        % If request was successfully sent, the exception likely
                        % occurred during or after receipt of response (or there was
                        % a timeout), so add any response to the history, if there
                        % was one, but mark it not completed
                        history(end).Response = obj.getResponse();
                        if ~isempty(history(end).Response)
                            history(end).Response.Completed = false;
                        end
                    end
                    history(end).Disposition = Disposition.TransmissionError;
                    history(end).Exception = e;
                    throw(matlab.net.http.HTTPException(history(end).URI, history(end).Request, history, e));
                end
            end

            % Determine if the content needs to be decoded
            encoding = char(getEncoding(obj));
            if ~isempty(encoding)
                % needs decoding
                obj.Decoded = false;
                if obj.DecodePayload
                    switch lower(encoding)
                        % These constants are defined for HTTPConnectionAdapter.Encoding
                        case 'gzip'
                            connection.Encoding = uint8(1);
                            obj.Decoded = true;
                        case 'deflate'
                            connection.Encoding = uint8(2);
                            obj.Decoded = true;
                    end
                end
                % if needs decoding but we weren't asked to do so, or it's an
                % encoding method we don't support, leave it unencoded
            else
                % doesn't need decoding
                obj.Decoded = true;
            end

%{
            % If an unauthorized code is returned by the server,
            % the request method is 'get', and the JVM is running,
            % then try again using the HTTPJavaConnectionAdapter.
            % This adapter uses Java to communicate to the server
            % and Java supports NTLM authentication (on Windows).
            % Do not attempt more times than allowed by
            % MaximumNumberOfUnauthorizedAttempts.
            % TBD test if NTLM explicitly g1355580
            TBD this code makes sense, but only if we test for NTLM requested
            first
            if obj.Connection.ResponseCode == StatusCode.Unauthorized && ...
                    usejava('jvm') && ...
                    strcmpi(obj.RequestMethod, 'get') && ...
                    obj.NumberOfUnauthorizedAttempts < obj.MaximumNumberOfUnauthorizedAttempts
                if obj.Debug
                    bytes = obj.copyContentToByteArray();
                    obj.log(char(bytes)');
                end
                obj.NumberOfUnauthorizedAttempts = obj.NumberOfUnauthorizedAttempts + 1;
                obj.Connection = matlab.internal.webservices.HTTPJavaConnectionAdapter(obj.URL);
                obj.Connection.RequiresGzip = connection.RequiresGzip;
                obj.open();
            end
%}
            % Connection is open.
            obj.ConnectionIsOpen = true;
        end
        
        %---------------------------------------------------------------------------
        
        function request = getRequest(obj)
        % Reconstruct the RequestMessage that was sent.  This is a way to see what
        % was actually sent, and to get the request even if an exception has
        % occurred.  If Debug or SavePayload is set, and there was a Payload, create
        % MessageBody containing that Payload.  Set Completed if we created a
        % MessageBody or there was no Payload.  If there was a payload but we're not
        % saving it, message in history is not Compelted.
        %
        % We don't set MessageBody.Data, as we don't have access to the original
        % (unconverted) data -- caller must set that to truly completed the message.
        
            import matlab.net.http.*;
            request = RequestMessage(obj.getRequestLine(), [], []);
            request = request.addFieldsNoCheck(obj.getRequestFields());
            if obj.SavePayload || obj.Debug || isempty(obj.Payload)
                % Debug or SavePayload or there was no payload; always set completed. Get
                % payload from either provider (if it saved any) or the payload we saved.
                if ~isempty(obj.Provider) 
                    payload = obj.Provider.Payload;
                else
                    payload = obj.Payload;
                end
                if ~isempty(payload)
                    % if there was a Payload, create a MessageBody 
                    if isempty(request.Body)
                        request.Body = MessageBody();
                    end
                    request.Body.PayloadInt = payload;
                    request.Body.PayloadLength = length(payload);
                end
                request.Completed = true;
            end
        end
        
        %---------------------------------------------------------------------------
        
        function response = getResponse(obj)
        % Reconstruct the header of the ResponseMessage that was received.  If an
        % exception occurred before the header was completely received, this may not
        % return a useful message.
            import matlab.net.http.*;
            response = ResponseMessage(obj.getStatusLine(), [], []);
            response = response.addFieldsNoCheck(obj.getResponseFields());
            response.Completed = true;
        end
        
        %------------------------------------------------------------------
        
        function close(obj)
        % Close the connection.
            
            connection = obj.Connection;
            if ~isempty(connection) && ismethod(connection, 'closeConnection')
                connection.closeConnection;
            end
            obj.ConnectionIsOpen = false;
        end
        
        %------------------------------------------------------------------
        
        function unopen(obj)
        % Reset the ConnectionIsOpen flag, but don't close the connection
            obj.ConnectionIsOpen = false;
        end
        
        %------------------------------------------------------------------
        
        function delete(obj)
        % Close the connection when deleting the object.
        
            obj.close()
            if ~isempty(obj.Connection.ProgressReporter)
                obj.Connection.ProgressReporter.delete();
            end
            delete@handle(obj);
        end
                       
        %------------------------------------------------------------------
        
        function byteArray = copyContentToByteArray(obj)
        % Read content from the web service and copy it to:
        %   byteArray    if obj.Consumer is unset or obj.SavePayload is true
        %   obj.Consumer if specified 
        % In other words, if obj.Consumer is set and obj.SavePayload is true, both
        % consumer and byteArray get the data. 
        %
        % This may throw an exception if copy fails.
            
            assert(obj.ConnectionIsOpen);  
            savePayload = obj.SavePayload || isempty(obj.Consumer); 
            % the consumer was already specified to the HTTPConnectionAdapter in the
            % sendRequest() method
            byteArray = copyContentToByteArray(obj.Connection, savePayload);
        end
        
        %------------------------------------------------------------------
        
        function copyContentToFile(obj, filename)
        % Copy the content from the Web service to a file.  This is used for content
        % types which can only be converted using MATLAB functions that read data
        % from files.  This may throw an exception if copy fails.
            
            assert(obj.ConnectionIsOpen)
            copyContentToFile(obj.Connection, filename);
        end
        
        %------------------------------------------------------------------
        function res = log(obj, data, payload)
        % Return string that is a log of the request and response messages, including
        % the response data.  If no return value, print it instead.
        %   data    the converted response data (multiple types)
        %   payload the raw (unconverted) response data (uint8 vector)
            connection = obj.Connection;
            if isa(connection, 'matlab.internal.webservices.HTTPConnectionAdapter')
                import matlab.net.http.*
                request = obj.getRequest();
                response = obj.getResponse();
                response.Body.DataInt = data;
                response.Body.PayloadInt = payload;
                response.Body.PayloadLength = length(payload);
                obj.MessageCount = obj.MessageCount + 1;
                if ~isempty(obj.ProxyURI) 
                    uri = obj.ProxyURI;
                else
                    uri = obj.URI;
                end
                res = sprintf('\nREQUEST %d to %s\n\n%s\n', obj.MessageCount, ...
                              uri,  request.show(200));
                res = [res sprintf('RESPONSE\n\n%s\n', response.show(200))];
                res = [res sprintf('----------------------------\n')];
            else
                res = sprintf('\nUsing Java\n');
            end
            if nargout == 0
                fprintf('%s',res);
            end
        end
    
        %------------------------------------------------------------------
        
        function fields = getRequestFields(obj)
        % Return vector of struct{Name,Value} for all the fields in the request
        %   message that were actually sent
            fields = obj.Connection.getRequestFields();
        end
        
        function fields = getResponseFields(obj)
        % Return vector of struct{Name,Value} for all fields in the response message
            fields = obj.Connection.getResponseFields();
        end
        
        function statusLine = getStatusLine(obj)
            [version, status, reason] = obj.Connection.getStatusLine();
            statusLine = matlab.net.http.StatusLine(version, status, reason);
        end
        
        function requestLine = getRequestLine(obj)
            [method, target, version] = obj.Connection.getRequestLine();
            requestLine = matlab.net.http.RequestLine(method, ...
                matlab.net.URI(target,'literal'), version);
        end
        
        %------------------------- set/get methods ------------------------
        
        function set.URI(obj, uri)
        % Set the URL property value by storing the value in the private
        % copy. Set the Protocol, and Proxy property values.
        
            % Set private copy.
            obj.pURI = uri;
            obj.Connection.URL = char(uri);
            
            % Get the protocol (before the ":") from the URL.
            obj.Protocol = uri.Scheme;
            
        end
                
        function url = get.URI(obj)
            url = obj.pURI;
        end   
        
        function set.CertificateFilename(obj, filename)
            filename = matlab.net.internal.validateCertificateFile(filename);
            obj.pCertificateFilename = filename;
            obj.Connection.CertificateFilename = filename;
        end
        
        function filename = get.CertificateFilename(obj)
        % Get CertificateFilename from private copy.
            filename = obj.pCertificateFilename;
        end
        
        function sent = get.Sent(obj)
            sent = obj.Connection.Sent;
        end
      
    end
    
    methods (Access = 'protected')
        
        function tf = isRedirecting(obj)
        % Return true if the connection indicates that the URL is being
        % redirected by examining the response code.
            import matlab.net.http.*;
            try
                code = obj.Connection.ResponseCode;
                tf = any(code == [StatusCode.Found ...
                                  StatusCode.MovedPermanently ...
                                  StatusCode.TemporaryRedirect]);
            catch
                tf = false;
            end
        end
        
        %------------------------------------------------------------------
        
        function setRequestProperty(obj, name, value)
        % Set connection request property if name is not empty.
        
            connection = obj.Connection;
            if ~isempty(name) && ~isempty(connection)
                connection.setRequestProperty(name, value);
            end
        end   
        
        %------------------------------------------------------------------
        
        function setRequestProperties(obj, redirecting)
        % Set the obj property values on the connection. 
        
            % The set order is important. Certain property manipulations
            % will invoke the connect method of the connection. After
            % connection, setting certain properties, such as Accept, can
            % cause an exception.
        
            % Assign a local variable for the connection.
            connection = obj.Connection;
                            
            % Set Request method.
            if any(strcmpi(obj.Protocol, {'http', 'https'}))
                connection.RequestMethod = char(upper(obj.RequestMethod));
                
                if ~redirecting && ~isempty(obj.Payload)
                    % Set any data in request message; don't do it again on a redirect
                    connection.MediaType = char(obj.MediaType);
                    connection.Payload = obj.Payload;
                end
            end

            if ~isempty(obj.Header)
                % Convert HeaderFields to structs for setFields API.  We need to repeat this
                % on each redirect because the call to openClientSession deletes the previous
                % RequestMessage header.  TBD: Probably should improve this, but it requires a
                % rework of the native HTTPConnection.
                structs = arrayfun(@(x) struct('Name',char(x.Name),'Value',char(x.Value)), ...
                                   obj.Header);
                connection.setFields(structs);
            end    
            
            if ~isempty(obj.ProgressMonitor ) && isempty(connection.ProgressReporter)
                % Instantiate a new ProgressReporter unless the connection already
                % has one (as would be the case if we came here recursively from a
                % redirect or authentication response).
                connection.ProgressReporter = ...
                    matlab.net.http.internal.ProgressReporter(obj.ProgressMonitor);
            end
        end
        
        %------------------------------------------------------------------
        
        function [response, history] = openRedirectConnection(obj, credInfo, history)
        % Open redirect connection if the redirect URL is valid.  Returns empty
        % response if not valid.
            
            % TBD code simplification: we should just be looking at the Location
            % field of the last response (which is what RedirectURL does anyway)
            uristr = obj.Connection.RedirectURL;
            if ~isempty(uristr)
                uri = matlab.net.URI(uristr, 'literal');
                % Reset URL to new location.
                obj.URI = uri;
                
                % Redirecting to a different URL. 
                % Ensure connection is closed.
                obj.close();
                
                % Remove any Host field we may have added, since the redirect may require us
                % to go to a different host.
                obj.Connection.removeField('Host');
                obj.Header(strcmpi('Host', [obj.Header.Name])) = [];

                % Try again to open URL connection; true says it's a redirect
                [response, history] = obj.sendRequest(credInfo, history, true);
            else
                % Close the redirection attempt since the redirect URL is
                % not valid.
                obj.NumberOfRedirects = obj.MaxRedirects + 1;
                response = [];
            end
        end
                
        %------------------------------------------------------------------
        
        function encoding = getEncoding(obj)
        % Return the name of the encoding we should use for this response, based on
        % Content-Encoding header.  Returns encoding as string object:
        %   'gzip'     if it ends in 'gzip'
        %   []         if it is 'identity' or '' or missing
        % If not one of above, returns value of the Content-Encoding field
            encoding = string(obj.Connection.ContentEncoding);
            if isempty(encoding) || strlength(encoding) == 0 || strcmpi(encoding,'identity')
                encoding = [];
            else
                if encoding.endsWith('gzip','IgnoreCase',true)
                    encoding = 'gzip';
                end
            end
        end
        
        %--------------------------------------------------------------------------

        function [username,password] = getCredentials(obj, statusCode)
        % Return the username and password to authenticate this request, using the
        % information in the WWW-Authenticate or Proxy-Authenticate field to
        % determine which Credentials object to use.  Called only if obj.Authenticate
        % is set.
            import matlab.net.http.*
            import matlab.net.http.field.*
            
            if isempty(obj.Credentials)
                username = [];
                password = [];
            else
                switch statusCode
                    case StatusCode.Unauthorized
                        field = 'WWW-Authenticate';
                    case StatusCode.ProxyAuthenticationRequired
                        field = 'Proxy-Authenticate';
                end

                value = obj.Connection.getResponseField(field);
                hf = AuthenticateField(field, value);
                authInfo = hf.convert();
                [username,password] = obj.getCredentials(obj.URI, authInfo);
            end
        end
        
        %--------------------------------------------------------------------------

        function obj = setProperties(obj, options)
        % Copy properties from HTTPOptions to HTTPConnector
            obj.MaxRedirects = options.MaxRedirects;
            obj.ConnectTimeout = options.ConnectTimeout;
            obj.Debug = options.Debug;
            obj.Authenticate = options.Authenticate;
            obj.Credentials = options.Credentials;
            obj.SavePayload = options.SavePayload;
            obj.DecodePayload = options.DecodeResponse;
            obj.CertificateFilename = options.CertificateFilename;
            obj.VerifyServerName = options.VerifyServerName;
            obj.ConvertResponse = options.ConvertResponse;
            if options.UseProxy
                obj.ProxyURI = options.ProxyURI;
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


function tf = hasContent(~,response)
% Try to anticipate whether the response will contain a payload
   clf = response.Header.getValidField('Content-Length');
   tf = isempty(clf) || clf.convert() ~= 0;
  %  TBD more cases: response to HEAD, status code 2xx in response to CONNECT, or
  %  status codes 1xx, 204 and 304.
  % It might be much more reliable to issue a peek of the input stream to
  % determine if there is data.
end
