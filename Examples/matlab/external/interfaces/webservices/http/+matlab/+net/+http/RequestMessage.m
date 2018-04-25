classdef (Sealed) RequestMessage < matlab.net.http.Message & matlab.mixin.CustomDisplay
% RequestMessage An HTTP request message
%   To prepare a message, construct a RequestMessage and specify optional
%   Method, Header and Body properties. You can then use send to SEND the
%   message, or COMPLETE to validate the message prior to sending. These
%   functions will fill in any necessary Header fields and other properties of
%   the message that you have not set.
%
%   RequestMessage methods:
%     RequestMessage - constructor
%     send           - send a message and receive a response
%     complete       - validate and complete a message
%     string         - return the contents of the message as a string
%     char           - return the contents of the message as a character vector
%     show           - return/display contents with optional maximum length
%
%   RequestMessage properties:
%     RequestLine - Request line of the message
%     Method      - Same as RequestLine.Method
%     Header      - Header of the message
%     Body        - Body of the message
%     Completed   - true if message was completed
%
%   Examples:
%     import matlab.net.http.RequestMessage
%     req = RequestMessage;
%     resp = req.send('https://www.mathworks.com');
%     html = resp.Body.Data;  % returns HTML text 
%
%     Note that for the simple case above, which issues a GET request with no special
%     headers, it is easier to use webread.
%
%     req = RequestMessage('delete'); 
%     resp = req.send('https://www.mathworks.com')
%
%     resp = 
%
%       ResponseMessage with properties:
% 
%         StatusLine: 'HTTP/1.1 405 Http method DELETE is not supported by this URL'
%         StatusCode: MethodNotAllowed
%             Header: [1x9 matlab.net.http.HeaderField]
%               Body: [1x1 matlab.net.http.MessageBody]
%          Completed: 0
%
% See also ResponseMessage, webread

% Copyright 2015-2017 The MathWorks, Inc.

    properties (Dependent)
        % Method - a matlab.net.http.RequestMethod
        %   This is a dependent property equal to RequestLine.Method. Default is
        %   RequestMethod.GET. If you are sending data to a server (i.e., the Body
        %   is not empty) you would specify a method such as RequestMethod.PUT or
        %   RequestMethod.POST. If you set this property to a string, it will be
        %   converted to a RequestMethod.
        %
        % See also RequestMethod, RequestLine, send, complete, Body
        Method % RequestMethod or empty

        % RequestLine - first line of an HTTP message
        %   This is a matlab.net.http.RequestLine that contains the method, target
        %   and protocol version. This line is automatically created when you send a
        %   message based on the method and URI you specify, but if you set this
        %   explicitly then its contents will be used as the request line. The value
        %   may be set to a RequestLine object or a string, which is parsed and
        %   converted to a RequestLine object.
        %   
        % See also matlab.net.http.RequestLine
        RequestLine
    end
    
    properties (Access=private)
        Consumer   % a ContentConsumer, handle to function returning one, or []
        UseChunked logical = false % true if message to be sent chunked
        MinLength  % numeric value of Content-Length field, after complete or []
    end
    
    properties (Constant, Access=private)
        Properties = {'matlab.net.http.RequestMethod', 'Method', ...
                      'matlab.net.http.Header', 'Header', 'matlab.net.http.Body', 'Body'}
        % TBD this should be much longer, but it's of no big consequence really
        DisallowedFields = {'Location','Retry-After','Vary','Etag',...
            'Last-Modified','Set-Cookie','Accept-Ranges','Allow','Server',...
            'WWW-Authenticate','Proxy-Authenticate','Authentication-Info'}
    end
    
    methods
        function obj = set.Method(obj, value)
            if isempty(obj.RequestLine)
                obj.RequestLine = matlab.net.http.RequestLine();
            end 
            if isempty(value)
                value = matlab.net.http.RequestMethod.empty;
            end
            obj.RequestLine.Method = value;
        end
        
        function value = get.Method(obj)
            if isempty(obj.RequestLine)
                value = [];
            else
                value = obj.RequestLine.Method;
            end
        end
        
        function obj = set.RequestLine(obj, value)
            if isempty(value)
                obj.StartLine = [];
            else
                validateattributes(value, {'matlab.net.http.RequestLine'}, {'scalar'}, mfilename, 'RequestLine');
                obj.StartLine = value;
            end
        end
        
        function value = get.RequestLine(obj)
            value = obj.StartLine;
        end
        
        function obj = RequestMessage(method, header, body)
        % RequestMessage creates an HTTP request message
        %   REQUEST = RequestMessage(METHOD,HEADER,BODY) creates a RequestMessage 
        %   with the specified properties. All parameters are optional and [] may be
        %   for placeholders.
        %
        %     METHOD  The request method or request line:
        %               matlab.net.http.RequestLine - the entire request line
        %               matlab.net.http.RequestMethod or string - the request method
        %             This sets the RequestLine or Method properties.
        % 
        %             In most cases you need only specify the request method, which
        %             is part of the request line, but you may want to specify the
        %             entire request line if you need control over its contents. For
        %             example, to explicitly send a message to a proxy that should be
        %             forwarded to a server, instead of letting MATLAB choose the
        %             proxy based on your proxy settings, you need to set the
        %             RequestTarget property in the RequestLine to the full URI,
        %             because the send method would normally set it to just the Path
        %             portion of the URI.
        %
        %             When you send or complete a message, the deault METHOD is
        %             RequestMethod.GET.
        %
        %     HEADER  The header fields: vector of HeaderField. This sets the Header
        %             property. Default is an empty header, but several header fields
        %             are created by default when you send or complete a message.
        %   
        %     BODY    The message body: MessageBody, any data acceptable to the 
        %             MessageBody constructor, or ContentProvider. This sets the Body
        %             property. Normally a RequestMessage with a Body uses a method such
        %             as 'PUT' or 'POST', not the default 'GET', though this is not
        %             enforced.
        %
        %  See also RequestLine, RequestMethod, MessageBody, Method, Header, Body,
        %  HeaderField, send, complete, matlab.net.http.io.ContentProvider
            import matlab.net.internal.*;
            obj@matlab.net.http.Message();
            if nargin > 0
                if ~isempty(method)
                    if ischar(method)
                        obj.Method = matlab.net.http.RequestMethod.( ...
                                char(upper(getString(method, mfilename, 'method'))));
                    elseif isa(method, 'matlab.net.http.RequestMethod')
                        obj.Method = method;
                    else
                        validateattributes(method, {'matlab.net.http.RequestLine', ...
                            'matlab.net.http.RequestMethod', 'char', 'string'}, ...
                            {'scalar'}, mfilename, 'METHOD');
                        obj.RequestLine = method;
                    end
                end
                if nargin > 1
                    if  ~isempty(header)
                        validateattributes(header, {'matlab.net.http.HeaderField'}, ...
                            {'vector'}, mfilename, 'HEADER');
                        obj.Header = header;
                    end
                    if nargin > 2
                        if ~isempty(body)
                            obj.Body = body;
                        end
                    end
                end
            end
        end
        
        function [response, request, history] = send(obj, uri, options, consumer) 
        % SEND  Send an HTTP request
        %   [RESPONSE, COMPLETEDREQUEST, HISTORY] = SEND(REQUEST, URI, OPTIONS)
        %     sends the REQUEST to the Web service specified by URI and returns the
        %     response (if any) as RESPONSE. The OPTIONS argument is optional.
        %
        %     REQUEST   RequestMessage to be sent.
        %
        %     URI       matlab.net.URI or string acceptable to the URI constructor,
        %               identifying the destination of the request. If it is a URI, it
        %               must name a Host. If a string, and it does not mention a
        %               Scheme, 'http' is assumed; for example 'www.google.com' and
        %               '//www.google.com' are both treated as 'http://www.google.com'. 
        %
        %     OPTIONS   (optional) HTTPOptions object specifying additional options
        %               for processing the request and response. If not specified, or
        %               if the value is empty, SEND uses default options.
        %
        %     RESPONSE  The final ResponseMessage received from the server. There may
        %               be intermediate requests and responses exchanged between MATLAB
        %               and the proxy or server if redirections and/or authentications
        %               are involved.
        %
        %     COMPLETEDREQUEST 
        %               The request that was sent prior to receiving the RESPONSE, after
        %               "completion" by SEND and augmented with any authentication
        %               information or redirection information. If REQUEST.Body is a
        %               ContentProvider, COMPLETEDREQUEST.Body will normally be empty,
        %               because ContentProvider payloads are not saved. However, if
        %               OPTIONS.SavePayload is true, then the COMPLETEDREQUEST.Body will
        %               be a MessageBody whose Payload has the data sent from the
        %               provider as a uint8 vector. In some cases, when the
        %               Content-Type of the request indicates it is character-based (for
        %               example, any type with a charset parameter), the MessageBody's
        %               Data property will contain the payload represented as a string.
        %
        %     HISTORY   A LogRecord vector containing a log of the request and 
        %               response messages that were exchanged to satisfy this send
        %               request. In the normal case where there is just a single
        %               request and response, this contains one record. There may be
        %               multiple LogRecords in this history in the case of an
        %               authentication containing multiple messages and for each
        %               redirection. One use of this history, in addition to
        %               debugging, is to obtain all the Set-Cookie headers from
        %               response messages, which you may need to send back in
        %               subsequent requests. When this function returns normally, the
        %               last record in this history always contains the same value as
        %               COMPLETEDREQUEST and RESPONSE (headers only). In general a
        %               LogRecord contains only headers. To log message bodies,
        %               specify OPTIONS.SavePayload.
        %   
        %   [RESPONSE, COMPLETEDREQUEST, HISTORY] = SEND(REQUEST, URI, OPTIONS, CONSUMER)
        %      sends the REQUEST and uses a CONSUMER to process the payload. Parameters
        %      are the same as above, plus:
        %
        %     CONSUMER  ContentConsumer to process the returned payload or a handle to 
        %               a function that returns a ContentConsumer. This ContentConsumer
        %               will be invoked to process or store buffers of data in real time
        %               as the data is being received. The CONSUMER may store the data in
        %               RESPONSE.Body.Data, or handle it in some other way (e.g.,
        %               displaying it in a figure window or saving it in a file). When a
        %               consumer is specified, MATLAB does not automatically set
        %               MessageBody.Data, but it will set MessageBody.Payload to the
        %               unconverted payload if OPTIONS.SavePayload is true. For example
        %               FileConsumer saves the data to a file, not in MessageBody.Data.
        %
        %               Using a ContentConsumer may provide more flexibility in
        %               converting or storing the response data than MATLAB's default
        %               response data conversion. For a description of the default
        %               conversion of received data, see MessageBody.Data. For a list
        %               of ContentConsumer types provided by MATLAB:
        %                  mp = meta.package('matlab.net.http.io');
        %                  {mp.ClassList.Name}'
        %               In addition, software developers may create their own
        %               ContentConsumer subclasses to process data as it is being
        %               received.
        %
        %               The CONSUMER is used only if it accepts the message, based on
        %               various factors such as the Content-Type header in the RESPONSE
        %               and whether RESPONSE.StatusCode is OK. 
        %
        %               If the payload is compressed with a supported encoding, and
        %               OPTIONS is unspecified or OPTIONS.DecodePayload is true, the
        %               consumer gets the decompressed data. If payload is compressed
        %               and OPTIONS.DecodePayload is false, or the payload is
        %               compressed with an unsupported encoding, the consumer is not
        %               used and there is no default processing of the data. 
        %
        %               In all cases where the consumer is not used, the payload is
        %               processed and converted as if no CONSUMER was specified.
        %
        %               If CONSUMER is a function handle, the function will be called to
        %               instantiate a consumer only after MATLAB determines that the
        %               the response has a payload.
        %
        %               When specifying CONSUMER but no OPTIONS, specify [] as a
        %               placeholder for OPTIONS to use default options.
        %               
        %     By default, SEND verifies the semantic correctness of the headers and
        %     other parts of the message, completes the URI and fills in any additional
        %     header fields needed to create a properly formed request, and (if
        %     REQUEST.Body is a MessageBody whose Payload property is not already set)
        %     calls appropriate conversion functions to convert any REQUEST.Body.Data to
        %     a vector of bytes representing an HTTP payload to be sent, as described
        %     for MessageBody.Data. Normally a 'GET' request does not contain data, but
        %     SEND will send the Body regardless of the RequestMethod. If the server
        %     returns data in its response and no CONSUMER is specified, SEND converts
        %     that data to MATLAB data and saves it in RESPONSE.Body.Data. See
        %     MessageBody.Data for more information on data conversion.
        %
        %     If REQUEST.Body is a ContentProvider, MATLAB calls the provider to get the
        %     data to be sent.
        %
        %     If the REQUEST.Header already contains a header field that SEND would
        %     normally add, SEND verifies that the field has the expected value. This
        %     behavior can be altered in several ways:
        %
        %       1. To send a message as is without any checking or alteration of the
        %          header, set REQUEST.Completed to true prior to sending. If you
        %          used the complete method to complete the request, you should
        %          specify the same value of URI and OPTIONS that you provided to
        %          complete, or there may be unpredictable results. Even if
        %          Completed is set, unspecified fields in the RequestLine will be
        %          filled in with default values.
        %       2. To allow SEND to check and fill in the header, but to suppress
        %          adding a particular header field that SEND or a ContentProvider might
        %          add, add that field to REQUEST.Header with a value of []. For
        %          example, SEND automatically adds a User-Agent header field. If you
        %          do not want this, add HeaderField('User-Agent') to the header. Header
        %          fields with empty values are not included in the message. The Host
        %          and Connection fields cannot be suppressed.
        %       3. To override the value that SEND would add for a given header
        %          field, add your own instance of that field before sending or
        %          completing the message. However this will not override a header
        %          field that a ContentProvider might add. However, for some header
        %          field types, SEND may still reject the message if the value is not
        %          valid. To prevent any checking of the value of a given field, or to
        %          override a field that a ContentProvider would add, add a field of
        %          type matlab.http.field.GenericField to the header with the desired
        %          name and value. Neither SEND nor a ContentProvider will add any
        %          header fields with names equal to any GenericField headers and will
        %          not check their correctness.
        %       4. To send raw binary data without conversion, you can insert a uint8
        %          vector into either Body.Data or Body.Payload. The only difference is
        %          that data in Body.Data is subject to conversion based on the
        %          Content-Type field in the message, while Body.Payload is not. Note
        %          that SEND will always try to convert nonempty Body.Data if
        %          Body.Payload is empty, even if Completed is already set. See
        %          MessageBody.Data for conversion rules.
        %        
        %     SEND throws an MException if the message could not be completed because
        %     its headers are not well-formed or conversion of Body.Data fails. If
        %     the message was completed but the Web service cannot be reached, or the
        %     Web service does not respond within the timeout period specified in
        %     OPTIONS, or a conversion error occurs trying to convert the response
        %     payload to MATLAB data, SEND throws an HTTPException. If the Web
        %     service responds and returns an HTTP error status, SEND returns
        %     normally, setting the Status property of RESPONSE to indicate the error
        %     returned from the server. You should always check RESPONSE.Status to
        %     determine whether the request was accepted.
        %
        %     After SEND returns, you can examine the COMPLETEDREQUEST to see what
        %     was sent, including the converted Data in Body.Payload if
        %     OPTIONS.SavePayload is set. If multiple messages were involved in
        %     accessing the server (for example, there were redirections or an
        %     authentication exchange occurred), it will contain the last such
        %     request. To see the first, or intermediate messages, look at HISTORY.
        %
        %     Since the COMPLETEDREQUEST is the last request made after all redirections
        %     and authentications, you may need to clear RequestLine.RequestTarget and
        %     possibly some header fields if you want to send COMPLETEDREQUEST instead
        %     of REQUEST. Also, if the REQUEST.Body contained a ContentProvider,
        %     COMPLETEDREQUEST.Body will not contain that provider. A better strategy,
        %     if you plan to send the same request multiple times, is to send the result
        %     of complete(REQUEST,URI) to the TARGET returned by that method.
        %
        %     For RESPONSE, COMPLETEDREQUEST, and all messages in HISTORY, the
        %     Completed property will be set only if the message contains no body or
        %     Body.Payload contains the raw data that was sent or received. Normally
        %     the Payload is not preserved unless HTTPOptions.SavePayload is set.
        %
        %     If you need to send the same message multiple times, and it contains
        %     data that is time-consuming to convert (e.g., a very large JSON
        %     structure) you may wish to use complete to convert the data once (which
        %     converts Body.Data into Body.Payload) and send the completed request.
        %
        %   See also RequestMessage, matlab.net.URI, HTTPOptions, ResponseMessage,
        %   matlab.net.http.field.GenericField, HTTPException, MException, MessageBody,
        %   Completed, complete, LogRecord, matlab.net.http.io.ContentConsumer,
        %   StatusCode, matlab.net.http.io.ContentProvider,
        %   matlab.net.http.io.FileConsumer
       
            import matlab.net.http.*
            import matlab.net.internal.*
            import matlab.net.*
            import matlab.net.http.internal.*
            
            if nargin < 3 || isempty(options)
                options = HTTPOptions;
            else
                validateattributes(options, {'matlab.net.http.HTTPOptions'}, {'scalar'}, ...
                    mfilename, 'OPTIONS');
            end
            if nargin >= 4
                if isa(consumer, 'function_handle') && nargout(consumer) == 0
                    error(message('MATLAB:http:BadConsumerFunction'));
                end
                validateattributes(consumer, {'matlab.net.http.io.ContentConsumer' ...
                    'function_handle'}, {'scalar'}, mfilename, 'CONSUMER');
                obj.Consumer = consumer;
            end
            history = LogRecord.empty;

            if options.UseProxy 
                % if proxy is to be used and there's none in options, get proxy
                % information from preferences or the system proxy
                if isempty(options.ProxyURI)
                    [proxyURI, username, password] = getProxySettings(createURIFromInput(uri));
                    if ~isempty(proxyURI)
                        options.ProxyURI = proxyURI;
                        if ~isempty(username)
                            % If preferences contains a username and password for the
                            % proxy, we need to add that information to the
                            % Credentials array in options (or make sure it's already
                            % there), so that we'll find it when we try to access the
                            % proxy. 
                            options = updateProxyCredentials(options, proxyURI, ...
                                                             username, password);
                        end
                    end
                end
            else
                options.ProxyURI = [];
            end
            
            if obj.Completed
                if isempty(obj.Method)
                    error(message('MATLAB:http:MissingMethod'));
                end
                obj = obj.convertData(false);
                
                % If a message is already completed, then the uri should be consistent with
                % the RequestLine.RequestTarget: if the RequestTarget is absolute then assume
                % the uri is a proxy and ignore all proxy settings in options. If target is relative,
                % then assume uri is not a proxy. In this case, if there is a proxy setting,
                % then it the protocol must be https.
                [completedURI, ~] = createURIFromInput(uri);
                if ~isempty(obj.RequestLine)
                    [completedURI, proxyURI] = obj.adjustForProxy(completedURI, options.ProxyURI);
                    options.ProxyURI = proxyURI;
                    try
                        % Use RequestLine.finish to validate; this throws if the RequestLine has any
                        % filled-in fields that are not what's expected. This is the same test we make
                        % in the non-completed case (in completeInternal, but instead of erroring out,
                        % just warn).
                        obj.RequestLine.finish(completedURI, ~isempty(options.ProxyURI), ...
                                                         obj.RequestLine.Method);
                    catch e
                        % Errors in finish() above become just warnings
                        warning(message('MATLAB:http:BadRequestLineMsg', e.message));
                    end
                end
            else
                % Not completed; always convert data
                obj = obj.completeBody(uri);
                [completedURI, obj] = obj.completeInternal(uri, options);
            end

            connector = HTTPConnector(completedURI, options, [], obj.Header); 
            connector.UseChunked = obj.UseChunked;
            
            deleteTheConnector = onCleanup(@()delete(connector));
            connector.RequestMethod = char(obj.Method);
            if options.UseProgressMonitor && ~isempty(options.ProgressMonitorFcn)
                pm = options.ProgressMonitorFcn();
                connector.ProgressMonitor = pm;
                % The error is in the value that was returned by
                % HTTPOptions.ProgressMonitorFcn, so pretend it happened there.
                validateattributes(pm, ...
                    {'matlab.net.http.ProgressMonitor'}, {'scalar'}, ...
                    'HTTPOptions', 'ProgressMonitorFcn');
                endProgressMonitor = onCleanup(@pm.done);
            end
            
            % Insert the payload, if any into the connector. The call to complete()
            % above should have filled in PayloadInt, if any
            if ~isempty(obj.Body) && isa(obj.Body, 'matlab.net.http.MessageBody') && ~isempty(obj.Body.Payload)
                connector.Payload = obj.Body.Payload;
                if ~isempty(obj.MinLength) && obj.MinLength > length(obj.Body.Payload)
                    warning(message('MATLAB:http:TooFewBytesInData', obj.MinLength, length(obj.Body.Payload)));
                end
            end
            
            if (isempty(options.ProxyURI) && isempty(options.Credentials)) || ...
                    ~options.Authenticate
                % don't authenticate
                [response, request, history] = ...
                    obj.sendOneRequest(connector, options, [], ...
                                       ~isempty(options.ProxyURI), history);
            else
                % possibly authenticate
                %  TBD (g1283802): This process is flawed because, if both proxy and
                %  server require authentication, we'll ALWAYS send the first message with
                %  only the proxy credentials and then need another message to send the server
                %  credentials. This code needs to be refactored so that we only send 1
                %  message once we have all the right credentials. My guess is that his isn't
                %  a huge use case, where both the proxy and the server require authentication,
                %  expecially since, for now, we only support Basic and Digest.
                %
                %  authInfo = []
                %  proxyAuthInfo = []
                %  first = true
                %  while true
                %     look for proxy credentials based on proxyAuthInfo and proxyURI
                %        and insert/change Proxy-Authorization header
                %     look for server credentials based on authInfo and URI
                %        and insert/change Authorization header
                %     if ~first && no new credentials found
                %        break
                %     send message
                %     if ProxyAuthenticationRequired returned 
                %        proxyAuthInfo = from Proxy-Authenticate header
                %     else 
                %        authInfo = from WWW-Authenticate header
                %     else break
                %     first = false
                %  end
                
                if ~isempty(options.ProxyURI)
                    % If talking to proxy, first try to authenticate to proxy. Once
                    % we get through, authenticate to server.
                    % TBD If the server and proxy both require authentication, this
                    % will always require a 2nd message. We can optimize this by
                    % sending server credentials in the first message, if we know
                    % them, but this involves some change of logic in
                    % sendAndAuthenticate to look up credentials for both proxyURI
                    % and uri at the same time.
                    [response, request, history] = ...
                        obj.sendAndAuthenticate([], options.ProxyURI, connector, ...
                                                options, true, history);
                    % any response other than ProxyAuthenticationRequired says we
                    % either authenticated successfully to the proxy or didn't have
                    % to
                    if response.StatusCode ~= StatusCode.ProxyAuthenticationRequired
                        if response.StatusCode == StatusCode.Unauthorized
                            % got through, but still need to authenticate to server
                            [response, request, history] = ...
                                 obj.sendAndAuthenticate(response, completedURI, connector, ...
                                                           options, false, history);
                        end
                    end
                else
                    % no proxy involved, just go to server
                    [response, request, history] = ...
                             obj.sendAndAuthenticate([], completedURI, connector, options, ...
                                                    false, history);
                end
            end
            if nargout < 3
                history = [];
            end
        end
        
        function [obj, target] = complete(obj, uri, varargin)
        % COMPLETE Complete an HTTP request message
        %   [COMPLETEDREQUEST, TARGET] = COMPLETE(REQUEST, URI, OPTIONS) returns a
        %   copy of the message, performing the same validation and addition of header
        %   fields and conversion of data as the send method (throwing an MException
        %   if validation fails), but does not send the message. Use this function to
        %   determine whether the request would be valid, and to see the request that
        %   would be sent prior to sending it, including any conversion of Body.Data
        %   to Body.Payload. The returned COMPLETEDREQUEST has the Completed property
        %   set to true and is suitable for sending without further alteration or
        %   processing.
        %
        %   Even if Authenticate is set in OPTIONS (which is the default), the
        %   completed request does not include any authorization header fields that
        %   may subsequently be added for authentication to a server or proxy, since
        %   it may not be possible to determine what the server requires without
        %   sending the message. If you want to see what was finally sent in an
        %   authentication exchange, examine the COMPLETEDREQUEST or HISTORY returned
        %   by the SEND method.
        %
        %   The URI may be a matlab.net.URI or a string acceptable to the URI
        %   constructor. 
        %
        %   OPTIONS is an optional matlab.net.http.HTTPOptions object. If missing, 
        %   a default HTTPOptions is assumed. These options are needed to determine
        %   how to complete and validate the request.
        %
        %   The TARGET is a URI object that specifies where the message will be sent.
        %   If no proxy is specified in OPTIONS, this is the same as URI with
        %   appropriate properties filled in. If a proxy is specified, this is the
        %   URI of the proxy (which will contain only a Host and Port).
        %
        %   If you intend to send COMPLETEDREQUEST to avoid the cost of a repeat
        %   validation, send it to TARGET instead of URI, using the same OPTIONS. Note
        %   that time-dependent header fields added by send, such as 'Date', will not
        %   be updated when sent again using COMPLETEDREQUEST.
        %
        %   For the purpose of filling in and validating the Header and RequestLine,
        %   this method ignores the Completed property in REQUEST, so it always
        %   returns a modified COMPLETEDREQUEST, or issues errors, if the REQUEST
        %   could not be completed. You can use this to determine whether a
        %   "manually" completed request is valid.
        %
        %   If Completed is not already set, this method always converts any Data in
        %   REQUEST.Body and stores the result in COMPLETEDREQUEST.Body.Payload,
        %   overwriting any previous contents of Payload. This means that both Data
        %   and Payload in COMPLETEDREQUEST.Body will be filled in. This is different
        %   from the behavior of send which does not save the Payload unless
        %   HTTPOptions.SavePayload is set. You should take this memory usage and
        %   conversion time into account if the message contains a very large amount
        %   of data.
        %
        %   However, if REQUEST.Body contains a ContentProvider, COMPLETE does not
        %   invoke the provider to create data. COMPLETEDREQUEST.Body will contain that
        %   same ContentProvider.
        %
        %   To complete a message without converting the data, set Completed before
        %   calling COMPLETE. If Completed is already set, and REQUEST.Body is a
        %   MessageBody, this method assumes that the current value of
        %   Request.Body.Payload, even if empty, is the desired one. But note that send
        %   will always convert and send nonempty Body.Data, even if Completed is true, if
        %   Payload is empty.
        %
        %   See also send, RequestMessage, matlab.net.URI, HTTPOptions,
        %   Completed, MessageBody, Body, matlab.net.http.io.ContentConsumer

            obj = obj.completeBody(uri);
            [~, obj, target] = obj.completeInternal(uri, varargin{:});
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'complete');
        end
    end
    
    methods (Access=private)
        function obj = convertData(obj, recalculate)
        % If the message contains Data and Payload is not set, convert Data to Payload
        % based on Content-Type. If recalculate set, and there is a nonempty Data,
        % always convert Data to Payload, clearing any previous contents of Payload. The
        % recalculate flag means we came here from complete() when Completed was
        % not set, where the user might have changed the ContentType of a previously
        % Completed message to do a different conversion than was originally done.
            if ~isempty(obj.Body) && isa(obj.Body, 'matlab.net.http.MessageBody')
                if isempty(obj.Body.Data)
                    if ~isempty(obj.Body.Payload) && isempty(obj.Body.ContentType)
                        % if Payload set but not Data, and Body.ContentType isn't set,
                        % set it to the value in the header or default binary.
                        mediaType = obj.getAssumedMediaType();
                        if isempty(mediaType)
                            mediaType = matlab.net.http.MediaType('application/octet-stream');
                        end
                        obj.Body.ContentType = mediaType;
                    end
                else
                    if isempty(obj.Body.Payload) || recalculate
                        % if Payload is empty or recalculate set with a nonempty Data, convert body to
                        % payload. We don't come here if Data is empty because the user might have
                        % just set the Payload to send raw data.
                        mediaType = obj.getAssumedMediaType();
                        % This uses the ContentTypeField in the header (if the user set it)
                        % or derives the type from the data.
                        [obj.Body.PayloadInt, obj.Body.ContentType] = ...
                            matlab.net.http.internal.data2payload(obj.Body.Data, ...
                                                                          mediaType);
                        obj.Body.PayloadLength = length(obj.Body.PayloadInt);
                    else
                        % if payload is already set, leave payload alone if recalculate not
                        % specified
                    end
                end
            end
        end

        function mediaType = getAssumedMediaType(obj)
        % Return the MediaType from the ContentTypeField in the header. If Completed,
        % return the value from the first ContentTypeField found; otherwise error out
        % if there is more than one. Returns [] if there is no such field or its
        % value is empty.
            if obj.Completed
                % If Completed only look at first instance of Content-Type,
                % because we don't want to error out if there's more than one.
                contentTypeField = obj.getFields('Content-Type');
                if ~isempty(contentTypeField) 
                    contentTypeField = contentTypeField(1);
                end
            else
                % this errors out if more than one
                contentTypeField = obj.getSingleField('Content-Type');
            end
            mediaType = obj.getMediaTypeFromContentType(contentTypeField);
        end
        
        function [uri, obj, target] = completeInternal(obj, uri, options)
        % If obj specified, do all steps of complete() except filling in Body.Payload,
        % or initializing the provider, if set. If there is a payload, Body.ContentType
        % should have been set. If obj not specified, just complete the uri and don't do
        % any validation. target is the actual destination of the request, same as uri
        % or the proxy
        
            import matlab.net.http.field.*;
            import matlab.net.internal.*;
            import matlab.net.*;
            import matlab.net.http.*;
            
            persistent noBodyMethods bodyExpectedMethods
            
            if isempty(noBodyMethods)
                noBodyMethods = RequestMethod({'GET','DELETE','HEAD','CONNECT','TRACE'});
                bodyExpectedMethods = RequestMethod({'POST','PUT'});
            end
            
            if isa(obj.Body, 'matlab.net.http.io.ContentProvider')
                provider = obj.Body;
            else
                provider = [];
            end
            
            % remember what user set because some calls we make below turn this off
            wasCompleted = obj.Completed; 
            
            [uri, origURI] = createURIFromInput(uri);
            
            if nargout == 1
                return;
            end
            if nargin > 2
                validateattributes(options, {'matlab.net.http.HTTPOptions'}, ...
                                   {'scalar'}, mfilename, 'OPTIONS');
            else
                options = HTTPOptions;
            end
            
            if isempty(obj.RequestLine)
                obj.RequestLine = matlab.net.http.RequestLine();
            end
            
            % Add default method (GET) if necessary, and set Target based on URI if
            % unset
            if isempty(obj.Method)
                obj.Method = RequestMethod.GET;
            end
                        
            if options.UseProxy 
                if isempty(options.ProxyURI) 
                    % if proxy is to be used and there's none in options, get it from
                    % preferences or the system proxy
                    [proxyURI, ~, ~] = getProxySettings(uri);
                    if isempty(proxyURI)
                        target = uri;
                    else
                        target = proxyURI;
                    end
                else
                    proxyURI = options.ProxyURI;
                    target = proxyURI;
                end
            else
                proxyURI = [];
                target = uri;
            end
            
            [uri, proxyURI] = obj.adjustForProxy(uri, proxyURI);
            obj.RequestLine = obj.RequestLine.finish(uri,~isempty(proxyURI),obj.Method);

            if ~isempty(obj.Header)
                % make sure no fields have empty names 
                i = find(cellfun(@isempty, {obj.Header.Name}), 1);
                if ~isempty(i) 
                    error(message('MATLAB:http:EmptyNameForField', obj.Header(i).Value));
                end
            end
            
            % Add Host field
            obj = obj.addIfEmpty(HostField(origURI), 1);
            
            % Add User-Agent field unless there is already one
            obj = obj.addIfEmpty(HeaderField('User-Agent', ['MATLAB/' version]), 3);
            
            % Add Date field unless there's already one
            obj = obj.addIfEmpty(DateField(datetime('now')), 5);
            
            % Add Connection field or verify it's already there
            obj = obj.addOrVerify(ConnectionField('close'), 4);
            
            % Replace above line with the line below to test keep-alive connections
            %obj = obj.addIfEmpty(ConnectionField('keep-alive'),4); 
            
            % Add Accept-Encoding unless there is one
            obj = obj.addIfEmpty(HeaderField('Accept-Encoding', 'gzip'), 6);
            
            % User might have added Transfer-Encoding field to specify chunked. We never
            % add this field explicitly, but if present it will control whether the message
            % gets chunked. If not present and we decide to send the message chunked, we
            % will specify that by setting the UseChunked property in the connector.
            tef = obj.getFields('Transfer-Encoding');
            obj.UseChunked = ~isempty(tef) && contains(tef.Value, 'chunked', 'IgnoreCase', true);
            
            % If there is a payload, make sure Content-Type and Content-Length are
            % added or correct
            if isempty(obj.Body)
                payloadLength = 0;
            elseif ~isempty(provider)
                payloadLength = provider.expectedContentLengthInternal(false);
                obj.UseChunked = provider.ForceChunked;
            else
                payloadLength = length(obj.Body.Payload);
            end
            
            expectField = obj.getFields('Expect');
            if ~isempty(expectField) && strcmpi(expectField.Value,'100-continue') ...
                    && (isempty(obj.Body) || isempty(obj.Body.Data)) 
                warning(message('MATLAB:http:ExpectContinue'));
            end
            
            % the isempty(payloadLength) should only occur if provider is set
            if isempty(payloadLength) || payloadLength > 0
                % there is a payload length > 0
                assert(~isempty(provider) || ~isempty(obj.Body.ContentType)); % must be set by caller
                if ~wasCompleted && any(obj.Method == noBodyMethods)
                    % If not completed, warn for methods that don't expect bodies. This isn't
                    % illegal, but unexpected.
                    warning(message('MATLAB:http:BodyUnexpectedFor', char(obj.Method)));
                end
                if isempty(provider)
                    % if no provider, make sure Content-Type field has the body's ContentType
                    obj = obj.addOrVerify(ContentTypeField(obj.Body.ContentType), 5);
                end
                if ~obj.UseChunked
                    % If we haven't yet decided to use chunked, force chunked if we don't know the
                    % payloadLength and there is no Content-Length field. 
                    if ~isempty(payloadLength) 
                        % If we know the payloadLength, make sure it's equal to the Content-Length field
                        % in the header, or add the field.
                        obj = obj.addOrVerify(ContentLengthField(payloadLength), 6);
                    else
                        % if payloadLength is empty, provider didn't give us a length, so check
                        % for Content-Length field
                        clf = obj.getSingleField('Content-Length');
                        if isempty(clf)
                            % If no Content-Length either, use chunked to send message
                            obj.UseChunked = true;
                        end
                    end
                end
            else
                % If payload is empty or length specified as 0, expect Content-Length to be missing or zero
                clf = ContentLengthField(0);
                if ~wasCompleted && any(obj.Method == bodyExpectedMethods)
                    warning(message('MATLAB:http:BodyExpectedFor', char(obj.Method)));
                    % methods that normally expect content should have explicit 0
                    % as per RFC 7230, section 3.3.2
                    obj = obj.addOrVerify(clf);
                else
                    % methods that don't expect body should not have this field, but 
                    % if it's there, it should be zero
                    obj.verifyMissingOrEqual(clf);
                end
            end
            
            % Remove all empty-valued fields. Since the add... methods we called
            % above won't change a field that's already added, any empty-valued
            % fields has prevented them from being added.
            obj.Header(arrayfun(@(x) isempty(x.Value), obj.Header)) = [];

            % Now we only have the real fields left in the message
            
            % Make sure there is no Content-Length field if message is chunked
            if obj.UseChunked
                clf = obj.getFields('Content-Length');
                if ~isempty(clf)
                    error(message('MATLAB:http:ContentLengthUnexpected', clf(1).Value));
                end
            else
                clf = obj.Header.getValidField('Content-Length');
            end
            
            if ~isempty(clf)
                obj.MinLength = clf.getNumber();
            else
                obj.MinLength = [];
            end
            if isa(obj.Body, 'matlab.net.http.io.ContentProvider')
                obj.Body.MinLength = obj.MinLength;
            end
            
            obj.Completed = true;
        end
        
        function [uri, proxyURI] = adjustForProxy(obj, uri, proxyURI)
        % If the user specified a RequestTarget that is absolute, then assume uri is
        % that of a proxy and return that target as the uri and the uri (minus scheme)
        % as the proxyURI and ignore the input proxyURI. Otherwise just return the
        % same uri and proxyURI. This basically undoes what we did when we completed
        % the request to that proxy, so it's as if the user sent to the original
        % destination in the first place. This allows the user to send a completed
        % message to a proxy.
            if ~isempty(obj.RequestLine)
                target = obj.RequestLine.RequestTarget;
                if ~isempty(target) && target.Absolute 
                    % target absolute; assume input uri is a proxy
                    proxyURI = uri;
                    proxyURI.Scheme = [];
                    uri = target;
                end
            end
        end
        
        function obj = addIfEmpty(obj, field, where)
        % Add header field if one with the same name isn't already in the header.
            fields = obj.getFields(field.Name);
            if isempty(fields)
                if nargin > 2
                    obj = obj.addFields(where, field);
                else
                    obj = obj.addFields(field);
                end
            else
                % make sure existing fields that are non-generic have the same value
                checkForDuplicates(fields(arrayfun(@(f)~isa(f,'matlab.net.http.field.GenericField'), fields)));
            end
        end
        
        function obj = addOrVerify(obj, field, where)
        % Add field if one with the same name isn't already in the header, at the
        % index where. If any found, make sure all that aren't GenericField have the
        % same value. If field exists but with empty value, ignore.
            fields = obj.getFields(field.Name); % get all matching fields
            if isempty(fields)
                if nargin > 2
                    % None there, so add it
                    obj = obj.addFields(where, field);
                else
                    obj = obj.addFields(field);
                end
            else
                fields = getNonGeneric(fields);
                verifyEqual(fields, field);
            end
        end
        
        function obj = addOrReplace(obj, field)
        % If the field is not already in the header, add it to the end. If the field is
        % already in the header, replace it. All instances will be replaced. We still
        % replace the field if the new one has an empty value. Empty-valued fields will
        % then be automatically removed at the end of completion.
            [~, indices] = obj.getFields(field);
            if ~isempty(indices)
                obj.Header(indices) = field;
            else
                obj = obj.addFieldsPrivate(false, field);
            end
        end
        
        function obj = mergeHeader(obj, header)
        % Merge all the fields in header to this request's Header. This implements the
        % behavior documented for ContentProvider.Header that merges the provider's
        % header into our Header. Fields with no name conflicts are added to the end.
        % If there is a conflict, the one with an empty value wins (which means it is
        % ultimately removed). If both are nonempty and the one in Header is
        % GenericField, don't Header. Otherwise, replace all the ones in Header with
        % those in header.
            for i = 1 : length(header)
                field = header(i);
                oldFields = obj.getFields(field);
                % Only add if the field doesn't exist, or all instances exist with nonempty
                % values and none are GenericField. Empty value means don't add it, and
                % GenericField means don't modify it.
                if isempty(oldFields) || ...
                   all(arrayfun(@(f) ~isa(f, 'matlab.net.http.field.GenericField') && ...
                                     (~isempty(f.Value) && (~isstring(f.Value) || strlength(f.Value) ~= 0)), ...
                                oldFields))
                    
                    obj = obj.addOrReplace(header(i));
                end
            end
        end
        
        function verifyMissingOrEqual(obj, field)
        % Verify that there are no non-Generic instances of field, or that any
        % found are equal to field.
            fields = obj.getFields(field.Name);
            verifyEqual(fields, field);
        end
        
        function res = getAllFields(obj, name)
        % getAllFields(name) returns all HeaderFields matching name
        %
        %   If any one of them has an empty Value remove it unless it's the only one.
            res = obj.getFields(name);
            if length(res) > 1
                res(isempty(res.Value)) = [];
            end
        end
        
        function [response, request, history] = ...
                   sendAndAuthenticate(obj, response, uri, connector, options, ...
                                       forProxy, history)
        % Send a message and authenticate if necessary, using options.Credentials
       
            import matlab.net.http.*
            
            % In these comments the numbers refer to steps in the credentials
            % matching algorithm. We exit this code when we got a successful
            % response or unrecoverable authentication failure response.
            done = false;
            authInfos = [];
            request = obj;
            if forProxy
                creds = [options.Credentials options.ProxyCredentials];
            else
                creds = options.Credentials;
            end
            while (~done)
                % Get the most recently used CredentialInfo across all creds that
                % matches this URI, if any. First time through (authInfo empty),
                % this only returns a credInfo whose URI completely matches a prefix
                % of the uri. Later the authInfo needs to match.
                if forProxy
                    credURI = options.ProxyURI;
                else
                    credURI = uri;
                end
                [cred, credInfo] = creds.getBestCredInfo(credURI, authInfos, forProxy); % step 1
                if ~isempty(credInfo) % step 2
                    % Found a CredentialInfo, so try it proactively. This can
                    % work for Basic or Digest.
                    [response, request, done, history] = ...
                        obj.sendWithCredInfo(uri, connector, options, cred, ...
                                             credInfo, forProxy, history);
                    % If done is false, authentication failed but it's worth trying
                    % again with the modified CredentialInfo array in cred, allowing
                    % us to maybe find a different CredentialInfo in the search of
                    % step 1. If done is true, we give up or succeeded.
                    if ~done
                        authInfos = getAuthInfos(response);
                    end
                else
                    % Found no existing CredentialInfo exactly matching a prefix of
                    % this URI, which means we have no record of previously
                    % authenticating with this URI, so see if any Credentials in
                    % options applies to this URI. step 3
                    while (~done)
                        if isempty(response)
                            authInfos = [];
                        else
                            authInfos = getAuthInfos(response);
                            if isempty(authInfos)
                                % We got a response, but it didn't contain an expected challenge
                                % (WWW-Authenticate or Proxy-Authenticate) so finish without authenticating
                                return;
                            end
                        end
                        % Get best matching Credentials object. First time through,
                        % authInfos unset, so we'll pick the best one based just on
                        % uri. Next time it's set to any challenges we received so
                        % we have more information such as realm to choose one.
                        cred = creds.getCredentials(credURI, authInfos); % 3.1
                        if ~isempty(cred) % 3.2
                            if forProxy && strcmpi(connector.URI.Scheme, "https")
                                % if we authenticating to a proxy and we have proxy credentials, store the
                                % username/password in the connector. This is needed because, in the case
                                % of HTTPS, POCO wants to authenticate to the proxy all by itself, without
                                % giving us the chance to respond to a Proxy-Authenticate response.
                                connector.ProxyUsername = cred.Username;
                                connector.ProxyPassword = cred.Password;
                            end
                            if cred.Scheme == AuthenticationScheme.Basic % 3.2.1
                                % Basic is the only supported scheme for matching
                                % Credentials, so try to proactively send it
                                [response, request, done, history] = ...
                                    obj.sendWithBasic(response, connector, ...
                                      options, authInfos, ...
                                      uri, creds, cred, forProxy, history);
                                % If done set, we either failed or succeeded.
                                % If false, we loop because another Credentials
                                % object should match the authInfos in the
                                % response.
                            else
                                % A scheme other than Basic is supported by
                                % matching Credentials, so try sending without
                                % credentials if response is empty.
                                [response, request, done, history] = ...
                                   obj.sendAfterChallenge(response, connector, ...
                                   options, authInfos, uri, cred, forProxy, history);
                                % If done is false, response contains a
                                % challenge so loop and try again with new
                                % authInfos from response.
                                % If done is true, we either succeeded or failed.
                            end
                        else
                            % No credentials match; send unauthenticated request
                            % and return whatever response we get. No retries
                            % after this. This is the normal case when there are
                            % no relevant credentials. 3.3
                            % Don't send request if we already have response, as this
                            % means we already failed and trying again without
                            % credentials won't help.
                            if isempty(response)
                                [response, request, history] = obj.sendOneRequest(...
                                         connector, options, [], forProxy, history);
                            end
                            done = true;
                        end
                    end
                end
            end
        end
       
        function [response, request, history] = sendOneRequest(obj, connector, options, ...
                                                            credInfo, forProxy, history)
        % Send the request, possibly using credInfo for authentication, if set. If
        % forProxy set, credInfo applies to the proxy, not the server.

            import matlab.net.http.*
            e = [];

            if forProxy
                % We may come here first to send a request with proxy
                % authentication. Once that succeeds, this proxy credInfo remains
                % set in case we have to send again with server authentication,
                % redirects, etc.
                connector.ProxyCredentialInfo = credInfo;
                credInfo = [];
            end
            
            now = datetime('now');
            if ~isempty(connector.ProgressMonitor)
                connector.ProgressMonitor.Direction = MessageType.Request;
            end
            % Set the consumer in the connector. It will get any redirect 
            % payloads processed by connector.sendRequest(). Note this may be a function
            % handle or ContentConsumer instance.
            connector.Consumer = obj.Consumer;
            if ~isempty(obj.Consumer)
                obj.Consumer.clearProperties();
            end
            if isa(obj.Body, 'matlab.net.http.io.ContentProvider')
                provider = obj.Body;
                connector.Provider = provider;
                connector.useProvider();
                provider.SavePayload = options.SavePayload;
                provider.Payload = [];
            else
                provider = [];
            end
                
            try
                % This starts the exchange with the server and possibly updates
                % credInfo. It follows redirects and processes their payloads.
                % It returns only the header of the final response.
                [~, history] = connector.sendRequest(credInfo, history);
                % If this request has Body.Data, copy that into its copy into history.
                % connector has only included the Body.Payload.
                if ~isempty(history(end).Request)
                    % history may have multiple exchanges in case of redirects; each one should
                    % have the request Data
                    if isempty(provider) && ~isempty(obj.Body) && ~isempty(obj.Body.Data)
                        for i = 1 : length(history)
                            if isempty(history(i).Request.Body)
                                % If there was no body in the history, it's because connector wasn't asked to
                                % save the payload. In that case, we have to create one. This will mean that
                                % Completed is not set in the record.
                                history(i).Request.Body = MessageBody;
                            end
                            % Now set Body.Data using DataInt so that it doesn't clear Payload.
                            % Since this resets Request.Completed, save and restore it.
                            wasCompleted = history(i).Request.Completed;
                            history(i).Request.Body.DataInt = obj.Body.DataInt;
                            history(i).Request.Completed = wasCompleted;
                        end
                    end
                end
            catch e
                % save exception for below
            end

            if nargout > 1 || log || ~isempty(e)
                % If user wanted us to return the request, or there was an exception,
                % populate returned request with all fields that the connector
                % actually put in it, plus any Body.Data.
                try
                    try
                        request = connector.getRequest();
                    catch unexpected
                        % If above getRequest() threw an internal error and it happened
                        % after the original exception e, then it probably means the
                        % getRequest() couldn't be satisfied because the connection was
                        % never opened. In that case, use the original request (i.e.,
                        % this obj) as the best we have, and down below we'll throw an
                        % HTTPException that reports the original problem. Otherwise,
                        % throw the unexpected exception from the getRequest(), likely
                        % some other internal problem we didn't anticipate.
                        if unexpected.identifier == "MATLAB:webservices:InternalError" && ~isempty(e)
                            request = obj;
                        else
                            request = [];
                            rethrow(unexpected);
                        end
                    end
                    if ~isempty(obj.Body) && isempty(provider) 
                        % There's a body to the original request. The connector didn't
                        % have the original Data, so put that into the message of there
                        % is any.
                        if ~isempty(request.Body)
                            completed = request.Completed; % save because following line clears
                            request.Body.DataInt = obj.Body.DataInt;
                            request.Completed = completed;
                        else
                            % The connector didn't create a Body because there was a
                            % payload and we didn't tell it to save the payload, so just
                            % copy the caller's Body. In this case copy the Completed
                            % state from this message, which basically indicates whether
                            % Body.Payload was set or not (if there was Data).
                            request.Body = obj.Body;
                            request.Completed = obj.Completed;
                        end
                    else
                        if ~isempty(provider) && ~isempty(provider.Payload)
                            % if there was a provider that logged the payload return the logged payload in
                            % the Body of the request.
                            request.Body = MessageBody();
                            request.Body.PayloadInt = provider.Payload;
                            ctf = request.Header.getValidField('Content-Type');
                            if ~isempty(ctf)
                                % Even though we don't have an actual Body.Data, if there's a Content-Type in
                                % the message, we can use default conversion rules to un-convert the Payload
                                % into Data that might be more readable than a uint8 vector. This could fail
                                % for myriad reasons, so just silently ignore any failures.
                                try
                                    request.Body.DataInt = ...
                                        matlab.net.http.internal.readContentFromWebService(provider.Payload, ctf.convert(), true);
                                catch
                                end
                            end
                        end
                        % On an empty Body or if there is a provider, we can mark Completed
                        request.Completed = true;
                    end
                catch e1
                    % don't expect exception in block above; must be internal error
                    if ~isempty(e)
                        e1 = e1.addCause(e);
                    end
                    throwException(connector.URI, request, history, e1);
                end
                if ~isempty(e)
                    % This occurs if we couldn't open the connection, send the whole request, or
                    % get a whole response from the server. Need to append a history record
                    % because sendRequest didn't have a chance to do so. 
                    
                    % TBD The logic to create the last history record when an exception occurs
                    % before receiving the whole response header is already in HTTPConnector, but
                    % there it's used only in the case of an exception during a redirect. That
                    % process, and creating an HTTPException, should be in HTTPConnector in all
                    % cases.
                    %
                    % Another option is to not have HTTPConnector handle redirects at all, but
                    % have that come back to here, similarly to the way we come back here to
                    % handle authentication challenges. Then all the exception handling could be
                    % here.
                    if isa(e, 'matlab.net.http.HTTPException')
                        % If HTTPConnector threw HTTPException, it already has the whole exception, so
                        % rethrow. 
                        throwAsCaller(e);
                    end
                    history(end+1) = LogRecord;
                    history(end).URI = connector.URI;
                    history(end).RequestTime = now;
                    history(end).Request = request;
                    if (connector.Sent)
                        % If request was successfully sent, the exception likely
                        % occurred during or after receipt of response (or there was
                        % a timeout), so add any response to the history, if there
                        % was one, but mark it not completed
                        history(end).Response = connector.getResponse();
                        if ~isempty(history(end).Response)
                            history(end).Response.Completed = false;
                        end
                    end
                    history(end).Disposition = Disposition.TransmissionError;
                    history(end).Exception = e;
                    throwException(connector.URI, request, history, e);
                end
            end

            % If we get here, the server sent us a response header; time to read any
            % data
            response = history(end).Response;
            try
                consumer = [];
                import matlab.net.http.internal.readContentFromWebService
                history(end).ResponseTime(1) = datetime('now');
                savePayload = nargin > 2 && (options.Debug || options.SavePayload);
                % true if data is compressed but we shouldn't decode it (e.g., it's an unknown
                % encoding or user specified DecodeResponse=false)
                raw = ~connector.Decoded; 
                convert = options.ConvertResponse;
                try
                    consumer = obj.Consumer; 
                    if ~isempty(consumer) && convert 
                        % Get consumer ready for use with this response
                        connector.useConsumer(obj, response);
                    else
                        connector.Consumer = [];
                    end 
                    % this will be empty if consumer rejects response
                    consumer = connector.getConsumer();
                    if savePayload || raw
                        % if debugging or logging, get raw payload as well
                        % if raw set, data is empty
                        [data, payloadLength, payload, charset] = ...
                            readContentFromWebService(connector, options.Debug, ...
                                                      convert, raw);
                    else
                        % if not debugging or logging, history gets just converted data
                        [data, payloadLength, ~, charset] = ...
                            readContentFromWebService(connector, options.Debug, ...
                                                      convert, false);
                    end
                catch consexc
                    % There was an exception converting the data, or the consumer throws one, rather
                    % than just setting its Exception property.
                    if isequal(consexc.identifier,'MATLAB:webservices:OperationTerminatedByConsumer')
                        payload = consumer.Response.Body.Payload;
                        % If the consumer threw an exception, we saved it in consumer.Exception, so use
                        % that. If the consumer just returned empty from its putData() call, it means we
                        % should throw a generic exception.
                        if isempty(consumer.Exception)
                            exc = consexc;
                        else
                            exc = consumer.Exception;
                        end
                        % don't need to clean up consumer that threw us an exception
                        throw(matlab.net.http.internal.ExceptionWithPayload(...
                                      payload, exc))
                    end
                    if ~isempty(obj.Consumer)
                        % If there was a consumer and it's not OperationTerminatedByConsumer, it might
                        % be due to an error that the consumer didn't know about: tell it to end the
                        % message so that it doesn't think it's still in use.
                        obj.Consumer.putDataInternal(uint8.empty);
                    end
                    rethrow(consexc)
                end          
                
                % Success reading entire payload
                if ~isempty(consumer)
                    if savePayload
                        % If saving payload, also save it in the consumer's Response.Body
                        consumer.savePayloadInternal(payload);
                    end
                    % If a consumer was used, check for exception. Come here if consumer sets its
                    % Exception property without actually throwing anything.
                    if ~isempty(consumer.Exception)
                        payload = consumer.Response.Body.Payload;
                        throw(matlab.net.http.internal.ExceptionWithPayload(...
                                      payload, consumer.Exception))
                    end
                    % No exception; copy its response and get its body
                    response = consumer.Response;
                    history(end).Response = response;
                    body = response.Body;
                else
                    % If no consumer was used, create a MessageBody that contains the data
                    body = MessageBody(data); 
                    if convert
                        body.ContentType = response.getBodyContentType(body);
                    else
                        % charset is set when full conversion of payload to data wasn't done based on
                        % the message Content-Type, but only the conversion to Unicode. This would
                        % happen if ConvertResponse is false (~convert), the Content-Type is
                        % character-based, and any decoding was successfully applied (~raw). In this
                        % case set only that charset in the body's ContentType.
                        if ~isempty(charset)
                            m = MediaType;
                            body.ContentType = m.setParameter('charset', charset);
                        end
                    end
                    history(end).Response.Body = body;
                end
                history(end).ResponseTime(2) = datetime('now');
                if savePayload || raw
                    % Save payload if required
                    % Use PayloadInt to save payload without clearing Data
                    history(end).Response.Body.PayloadInt = payload;
                    body.PayloadInt = payload;
                    if raw
                        % If raw, there must have been a Content-Encoding field and
                        % we didn't decode it, so save the value of the field.
                        codingFields = history(end).Response.getFields('Content-Encoding');
                        if ~isempty(codingFields)
                            body.ContentCoding = codingFields.parse();
                            history(end).Response.Body.ContentCoding = body.ContentCoding;
                        end
                    end
                end
                history(end).Response.Body.PayloadLength = payloadLength;
                history(end).Response.Completed = ~raw;
                history(end).Disposition = Disposition.Done;
                response.Body = body;
            catch e
                % Header received OK, but exception reading or processing payload
                if nargin < 2
                    % need to populate request because we didn't do it above in the
                    % no exception, no log case
                    request = connector.getRequest();
                end
                if ~isempty(consumer)
                    % If consumer involved, copy its response into history. 
                    % In case the consumer just populated its response Body with partial data,  
                    % the Body's ContentType would not have been stored. This code
                    % won't be invoked for a MultipartConsumer, which stores
                    % whole ResponseMessages in its body.
                    if ~isempty(consumer.Response) && ~isempty(consumer.Response.Body)
                        consumer.Response.Body.ContentType = consumer.ContentType;
                    end
                    history(end).Response = consumer.Response;
                end
                if isa(e, 'matlab.net.http.internal.ExceptionWithPayload')
                    % An exception occurred after (or during) receipt of payload.
                    % Interrupt(ctrl/c) does not come here.
                    if isempty(consumer)
                        % If no consumer was involved, it means we already received and stored the
                        % payload in the exception. Create a Body and save payload in history. If
                        % there is Data, this would be chars converted based on the charset in
                        % Content-Type field.
                        %
                        % If a consumer was involved, we assume the consumer's Response (set above)
                        % has anything about the message we want to save, so we don't go down this
                        % path.
                        body = MessageBody(e.Data);
                        body.PayloadInt = e.Payload;
                        if ~isempty(e.Data)
                            % If there is Data, the content type was character-based and the exception
                            % occurred converting the payload to Unicode. In this case create a MediaType
                            % object containing only the charset.
                            m = MediaType;
                            body.ContentType = m.setParameter('charset',e.Charset);
                        end
                        history(end).Response.Body = body;
                    else
                        % If there was a consumer, Response.Body.Data was already stored. We just
                        % need to copy the payload into it, if any
                        history(end).Response.Body.PayloadInt = e.Payload;
                    end
                    history(end).Disposition = Disposition.ConversionError;
                    % get original cause of the processing error
                    history(end).Exception = e.cause{1};
                else
                    if isequal(e.identifier,'MATLAB:webservices:OperationTerminatedByUser')
                        history(end).Disposition = Disposition.Interrupt;
                    else
                        history(end).Disposition = Disposition.TransmissionError;
                    end
                end
                if ~isempty(history(end).Response)
                    history(end).Response.Completed = false;
                end
                history(end).ResponseTime(2) = datetime('now');
                throwException(connector.URI, request, history, e);
            end
            if options.SavePayload
                response.Body.PayloadInt = payload;
            end
            response.Body.PayloadLength = payloadLength;
            
            % At this point, since we didn't error out, Body.Data should have always have
            % the converted data if raw wasn't set and there was any payload, or be empty
            % if raw was set or there was no payload. In the case where there was no
            % payload, or if there was a payload and Data was set, mark it completed only
            % if Body.Payload was also set. 
            %
            % We only want to mark a ResponseMessage completed if it had no payload or if
            % it had a payload and both Payload and Data are set. In the latter case
            % Body.ContentType was set to the type we used to convert Payload to Data. In
            % most cases when we receive a payload that was successfully convered to Data,
            % the payload isn't being saved, so Body.Payload will be empty and we don't mark
            % it Completed. Also it should never be marked Completed if raw is set unless
            % there was no payload. In the test below, in the ~raw case, we can safely
            % assume that an empty Body.Data means there was no payload, or a nonempty
            % Payload means we have body Payload and Data.
            response.Completed = (raw && isempty(response.Body.Payload)) || ...
                (~raw && (isempty(response.Body) || (isempty(response.Body.Data) || ...
                                                     ~isempty(response.Body.Payload))));
        end
        
        function [response, request, done, history] = ...
             sendWithCredInfo(obj, uri, connector, options, cred, ...
                              credInfo, forProxy, history)
        % Send message, attempting to use a candidate CredentialInfo that we previously
        % used successfully. This is also called when we have a CredentialInfo that
        % contains some information, like username and password, but no AuthInfo, that
        % was created but never used. An example is the proxy authentication
        % information that came from preferences. If unsuccessful, maybe try to get new
        % credInfo based on information in Credentials cred and use that instead (which
        % may include calling GetCredentialsFcn). If successful add the new credInfo or
        % update the existing one so it can be used for the next message (needed for
        % Digest). If unsuccessful may remove credInfo from cred if determined to be no
        % good.
        %
        % done  if true, we succeeded or gave up. Caller should return response.
        %       if false, we modified the cred.CredentialInfo vector, so caller
        %       should try again to find another CredentialInfo.
        %
        % The response contains either the response to the request or, in the
        % unsuccessful case, the last challenge.
            done = true;
            BasicScheme = matlab.net.http.AuthenticationScheme.Basic;
            [response, request, history] = obj.sendOneRequest(connector, options, ...
                                                credInfo, forProxy, history);  % 2.1
            if authenticationSuccess(response, forProxy) % 2.2
                credInfo.LastUsed = datetime('now');
            else
                % authentication failed; we got a challenge in response 2.3.
                authInfos = getAuthInfos(response);
                if isBasicChallenge(authInfos, cred) % 2.3.1
                    % Basic is the only scheme offered by the challenge that this cred object
                    % supports. This credInfo was either not used before (in which case it has no
                    % AuthInfo) or credInfo failed, in which case either the login information
                    % changed or this URI is for a different path or that needs a different
                    % credInfo.
                    assert(isempty(credInfo.AuthInfo) || (credInfo.AuthInfo.Scheme == BasicScheme && ...
                        isscalar(credInfo.URIs))); % If AuthInfo is Basic, it should have only one URI
                    if pathCompare(uri,credInfo.URIs) % 2.3.1.1
                        % Target URI has the same path as credInfo, but either credInfo failed or wasn't
                        % used yet, so delete it from the cred and create a new one.
                        cred.delete(credInfo);  % 2.3.1.1.1
                        if isempty(credInfo.AuthInfo)
                            % If credInfo hasn't been used yet (no AuthInfo) then
                            % send again with a new credInfo that will contain an AuthInfo
                            % but copy the username/password from the old credInfo.
                            [response, request, history, done] = ...
                                obj.sendWithNewCredInfo(cred, uri, response, ...
                                   authInfos, forProxy, connector, options, ...
                                   history, true, credInfo);
                        else
                            % The credInfo was used, but didn't work, so tell caller to try
                            % another one.
                            done = false;
                        end
                    else
                        % Path is different; maybe we need new Basic credentials for
                        % this path 2.3.1.2
                        if ~isempty(cred.GetCredentialsFcn) % 2.3.1.2.1
                            % If a GetCredentialsFcn, try to get a new Basic
                            % CredentialInfo.
                            [response, request, history, done] = ...
                                obj.sendWithNewCredinfo(cred, uri, response, ...
                                   authinfos, forProxy, connector, options, ...
                                   history, true, []);
                        end
                        % Without a GetCredentialsFcn, there's nothing else to try,
                        % so give up; response contains last challenge 2.3.1.2.2.1
                    end
                else
                    % Challenge and cred allows schemes other than Basic. 2.3.2
                    % Delete the credInfo that got us here let caller try again.
                    % Exception: if this is a proxy credInfo with no AuthInfo, we
                    % haven't received a challenge yet, so need to give this another
                    % try after the challenge.
                    if ~credInfo.ForProxy || ~isempty(credInfo.AuthInfo)
                        cred.delete(credInfo); % 2.3.2.1
                    end
                    done = false;
                end
            end
        end
        
        function [response, request, done, history] = ...
                 sendAfterChallenge(obj, response, connector, options, authInfos, ...
                                    uri, cred, forProxy, history)
        % If response is empty, send the message without authentication and return
        % response and any challenge in authInfos. If response is set and contains
        % a challenge (authInfos), use cred as the candidate Credentials object that
        % satisfies this authInfos, where authInfos and cred allows for schemes other
        % than Basic.  3.2.2
        %
        % If there is no response yet from a previous try (response is []), we'll try
        % without authentication. If we get a challenge, authInfos contains the
        % authentication challenges to which we need to respond and done = false.
        % Caller should use authInfos to rescan get the Credentials array to possibly
        % find a better Credentials object maching the information in authInfos.
        %
        % If we already have a response (which contains one or more authInfos), done
        % is false, caller should try again using authInfos, with possibly new cred,
        % or give up if there aren't any.
           done = true; % if set on return, we're done (success or fail)
           if isempty(response) % 3.2.2.1
               % no challenge received yet, try without authentication
               [response, request, history] = obj.sendOneRequest(connector, ...
                                         options, [], forProxy, history); % 3.2.2.1.1
               if authenticationSuccess(response, forProxy)
                   % no authentication was required; done
                   % This is the case we'll hit every time when we have a matching
                   % Credentials object (which could include any Credentials with an
                   % empty URI and Scheme) when the server doesn't require
                   % authentication.
                   % 3.2.2.1.2.1
               else
                   % authentication needed 3.2.2.1.3.1
                   done = false; 
               end
           else
               % We already have a challenge, so send request with new CredentialInfo
               % created from a challenge. This returns done=true on success or give
               % up; done=false to try another cred with these authInfos, if possible.
               [response, request, history, done] = obj.sendWithNewCredInfo(cred, ...
                   uri, response, authInfos, forProxy, connector, ...
                   options, history, false, []);
           end
        end
        
        function [response, request, done, history] = ...
                 sendWithBasic(obj, response, connector, options, authInfos, uri, ...
                              creds, cred, forProxy, history)
        % This is called to send a message after determining that there is no
        % existing CredentialInfo whose URI exactly matches a prefix of the request
        % URI, but we found a Credentials object (cred) that is a candidate match,
        % and the only scheme supported by that Credentials object is Basic. This
        % allows us to proactively authenticate with username and password without
        % first receiving a challenge. On return, if done is set, caller should
        % finish. If done is false, we updated creds and caller should try again.
           
           import matlab.net.http.*
           
           done = true;
           % First see if any existing CredentialInfo that *shares* the same Path
           % prefix as this URI works. 3.2.1.1 This isn't the same as the *full*
           % prefix match the caller has made. This is to avoid calling the
           % GetCredentialsFcn if we have an existing CredentialInfo that might work.
           % For example, for a URI of /foo/bar/bat, a CredentialInfo of /foo/bar/baz
           % would not have been a full prefix match, but it does share a common
           % prefix of /foo/bar. In fact, any CredentialInfo with the properties up
           % to (but not necessarily) including Path is considered to match.
           
           % This should return all matching ones, sorted by longest match first
           credInfos = cred.getCommonPrefixCredInfos(uri);
           for i = 1 : length(credInfos) 
               credInfo = credInfos(i);
               % Try each one that matches until success
               [response, request, history] = obj.sendOneRequest(connector, ...
                            options, credInfo, forProxy, history); % 3.2.1.2.1
               if authenticationSuccess(response, forProxy)
                   % It works; trim the existing credInfo to contain just the common
                   % prefix
                   credInfo.chopCommonPrefix(uriURL); % 3.2.1.2.2.1
                   credInfo.LastUsed = datetime('now');
                   return;
               end
           end
           % None worked, or there was no common prefix
           % 3.2.1.3
           if ~isempty(response)
               % If we got a challenge from a previous attempt to authenticate, use
               % it to get possibly new Credentials. In this case the challenge
               % might allow for a stronger scheme than Basic
               if isempty(authInfos)
                   % bad challenge if it contains no authInfo
                   return;
               else
                   ais = lower(string({authInfos.Scheme}));
                   if all(ais == lower(string(AuthenticationScheme.Basic)))
                       % All challenges are Basic; try getting new credentials using
                       % realm from first authInfos (really, there should be only one
                       % such challenge, legally)
                       realm = authInfos(1).getParameter('realm');
                   else
                       % Challenges allow other than Basic. If we have any matching
                       % credentials that supports that scheme, loop and try again.
                       % If we don't, and if Basic still allowed, keep working on
                       % Basic 
                       % Get best matching Credentials across all challenges
                       cred = creds.getCredentials(uri, authInfos);
                       if cred.Scheme ~= AuthenticationScheme.Basic
                           % Best matching Credentials supports another scheme, so
                           % return to try again. This time, since we just
                           % determined that we do have a Credentials match to a
                           % non-Basic challenge, our caller shouldn't be invoking us
                           % a 2nd time.
                           done = false;
                           return;
                       end
                       % Our match is only for the Basic scheme, so see if challenge
                       % allows Basic
                       authInfo = getAuthInfos(response, AuthenticationScheme.Basic);
                       if isempty(authInfo)
                           % Challenge doesn't allow Basic, but Basic is the only one
                           % we have Credentials for that matches this URI, so we
                           % can't authenticate.
                           return;
                       else
                           % Challenge allows Basic. Get realm from the challenge,
                           % if any
                           realm = authInfo.getParameter('realm');
                       end
                   end
               end
           else
               realm = [];
           end
           % Create a new Basic CredentialInfo and try it
           authInfo = AuthInfo(AuthenticationScheme.Basic, 'realm', realm);
           [response, request, history, done] = obj.sendWithNewCredInfo(...
                               cred, uri, response, authInfo, forProxy, ...
                               connector, options, history, false, []);
        end
        
        function [response, request, history, done] = sendWithNewCredInfo(obj, ...
                               cred, uri, response, authInfos, forProxy, ...
                               connector, options, history, forBasic, origCredInfo)
        % Get a new CredentialInfo from Credentials object cred, based on the most
        % appropriate challenge in authInfos, and send the request with that
        % CredentialInfo. May invoke the GetCredentialsFcn in cred repeatedly, if
        % one is set. Sets done if we succeeded or should give up because we failed
        % authentication and there was no GetCredentialsFcn or the GetCredentialsFcn
        % told us to give up. Sets done to false if cred is not appropriate for any
        % authInfos, indicating that perhaps another cred should be tried. 
        %
        % If successful, conditionally add the new CredentialInfo to the Credentials 
        % object, replace an existing one, or edit an existing one to contain just
        % the common prefix.
        %
        % If forBasic is set, try only Basic authentication regardless of the
        % challenges. If successful, add the new CredentialInfo unconditionally.
           
           done = false;
           % copy obj to request because the loop below may keep updating request and
           % we want to return the latest request that was sent
           request = obj;
           credInfo = origCredInfo;
           while true
               if isempty(origCredInfo)
                   usePrev = false;
               else
                   usePrev = true;
                   origCredInfo = [];
               end
               credInfo = cred.createCredInfo(uri, request, response, authInfos, ...
                                              forProxy, credInfo, usePrev);  % 2.3.1.2.1.1, 3.2.1.3.1
               if isempty(credInfo)
                   % This cred is not appropriate for any authInfos. Tell caller
                   % to try again with possibly different Credentials.
                   break;
               elseif isnumeric(credInfo) && credInfo == 0
                   % give up, can't get new credentials
                   done = true;
                   break;
               end
               [response, request, history] = ...
                   obj.sendOneRequest(connector, options, ...
                                      credInfo, forProxy, history); % 2.3.1.2.1.2, 3.2.2.2.1, 3.2.1.3.2
               if authenticationSuccess(response, forProxy) % 2.3.1.2.1.3, 3.2.2.2.2
                   % if new CredentialInfo works, add it, even if it shares a common
                   % prefix with an existing one, unless forBasic is set
                   cred.addCredInfo(credInfo, ~forBasic); % 3.2.2.2.2.1, 3.2.1.3.3.1
                   done = true;
                   break; % 3.2.2.2.2.1, 3.2.1.3.3.2
               elseif isempty(cred.GetCredentialsFcn) % 3.2.1.3.4.1
                   % fail; give up if no GetCredentialsFcn
                   done = true;
                   break; % 3.2.2.2.3.2.1, 3.2.1.3.4.2.1
               end
               if forBasic
                   authInfos = getAuthInfos(response, matlab.net.http.AuthenticationScheme.Basic);
               else
                   authInfos = getAuthInfos(response);
               end
           end
        end
    end
    
    methods (Static, Access=protected)
        function type = getStartLineType()
            type = 'matlab.net.http.RequestLine';
        end
        
        function body = checkBody(body)
        % checkBody(body) Throw error if body is not valid for RequestMessage
        %    Caller (from superclass) invokes us for any nonempty body. If parameter is
        %    no a MessageBody or ContentProvider, try to create a MessageBody from the
        %    data. Otherwise verify that it's a MessageBody or ContentProvider.
        
        %    TBD doesn't check Body.Data. If uint8 or char, should check that it's a
        %    vector. Check other types based on some TBD list of allowed types that
        %    we know how to process, like struct for JSON and JSON object.
            if ~isa(body, 'matlab.net.http.MessageBody') && ...
                    ~isa(body, 'matlab.net.http.io.ContentProvider')
                % if it's not a MessageBody or ContentProvider, try to construct
                % a MessageBody using the argument
                body = matlab.net.http.MessageBody(body);
            else
                % nonempty result must be a scalar or empty
                if isempty(body)
                    validateattributes(body, ...
                        {'matlab.net.http.MessageBody','matlab.net.http.io.ContentProvider'}, ... 
                        {}, mfilename, 'Body');
                else
                    validateattributes(body, ...
                        {'matlab.net.http.MessageBody','matlab.net.http.io.ContentProvider'}, ... 
                        {'scalar'}, mfilename, 'Body');
                end
            end
        end
        
        function badField = getInvalidFields(fields)
        % getInvalidFields(fields) Return the first field not valid for RequestHeader.
        %   If the name is OK but the value is invalid, return the whole field.
        %   Otherwise return the field with the value empty.
        %
        %   Currently only checks field names. Could be expanded to check values, but
        %   would only need to check for valid values in fields which are allowed in
        %   both requests and responses, for which we haven't defined subclasses,
        %   where the values in requests are more constrained than those in
        %   responses. This is because the subclass already verifies valid values.
        %   An example of the latter is the Cache-Control field, which allows
        %   different directives in a request than it does in a response.
            df = matlab.net.http.RequestMessage.DisallowedFields;
            badFields = ...
                arrayfun(@(x) ~isa(x,'matlab.net.http.field.Generic') && ...
                              any(strcmpi(x.Name, df)), fields);
            idx = find(badFields, 1);
            if isempty(idx)
                badField = [];
            else
                badField = fields(idx);
                badField.Value = []; % clear because only the name is invalid
            end
        end
        
        function tf = shouldSetBodyContentType()
        % Return true to indicate that we want to set the body's ContentType whenever
        % the ContentTypeField in this message is set.
            tf = true;
        end

    end
    
    methods (Access=protected)
        function group = getPropertyGroups(obj)
        % Provide a custom display that removes StartLine (inherited from Message),
        % as it's redundant with RequestLine. Also displays RequestLine as string.
            group = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            if isscalar(obj)
                group.PropertyList = rmfield(group.PropertyList,'StartLine');
                group.PropertyList.RequestLine = char(group.PropertyList.RequestLine);
            end
        end
        
        function obj = checkHeader(obj, header)
        % Given a Header, throw error if it contains any fields invalid for a
        %   RequestMessage. Caller must verify it's a matlab.net.http.Header.
            badField = matlab.net.http.RequestMessage.getInvalidFields(header);
            if ~isempty(badField)
                if isempty(badField.Value)
                    error(message('MATLAB:http:BadFieldNameInHeader', ...
                                  badField.Name, class(obj)));
                else
                    error(message('MATLAB:http:BadFieldValueInHeader', ...
                                  badField.Name, badField.Value, class(obj)));
                end
            end
        end
    end
    
    methods (Access=?matlab.net.http.io.MultipartProvider)
        function obj = completeBody(obj, uri)
        % Complete the body of the message: if it's data and the message is not
        % completed, or its payload is empty, convert the data to payload and set
        % appropriate header field based on content type. If it's a ContentProvider,
        % tell it to complete.
        
            % if the Body is a ContentProvider, ask it to complete 
            if isa(obj.Body, 'matlab.net.http.io.ContentProvider')
                provider = obj.Body;
                provider.Request = obj;
                provider.Header = getNonGeneric(obj.Header);
                provider.completeInternal(uri);
                obj = obj.mergeHeader(provider.Header);
            else
                % If message is not completed, or if payload is empty, fill in payload of data based on
                % ContentType header or derived from the data. Sets ContentType header based
                % on the data.
                if ~obj.Completed || (obj.Completed && ~isempty(obj.Body) && isempty(obj.Body.Payload))
                    wasCompleted = obj.Completed;
                    obj = obj.convertData(true);
                    obj.Completed = wasCompleted;
                end
            end
        end
    end
end

function fields = getNonGeneric(fields)
% Return fields in array of HeaderField that are not GenericField whose values
% are not []
    fields = fields(arrayfun(@(f) ...
        ~(metaclass(f) <= ?matlab.net.http.field.GenericField) && ~isempty(f.Value), fields));
end

function verifyEqual(fields, field)
% Throw error if any of the nonempty non-GenericField fields is not equal to
% field. Compares using isequal on the whole field, which uses convert() if
% implemented.
    if ~isempty(fields) 
        fields = getNonGeneric(fields);
        if ~isempty(fields)
            bad = find(arrayfun(@(f) ~isequal(f,field), fields), 1);
            if ~isempty(bad) 
                error(message('MATLAB:http:InconsistentHeaderValue', ...
                              char(field.Name), char(fields(bad).Value), ...
                              char(field.Value)));
            end
        end
    end
end

function authInfo = getAuthInfos(response, scheme)
% getAuthInfos returns authentication challenges from the response.
%   If scheme not specified, return array of AuthInfos from
%   AuthenticateField.convert() for all AuthenticationFields in response. If scheme
%   (an AuthenticationScheme) specified, return only a single authInfo structure for
%   the first match with that scheme. Which field we look at depends on the response
%   message:
%
%      response.StatusCode          AuthenticateField
%      ---------------------------  ------------------
%      Unauthorized                 WWW-Authenticate
%      ProxyAuthenticationRequired  Proxy-Authenticate
%
%   Returns [] if there are no AuthenticateFields or no challenges match scheme.

    import matlab.net.http.*
    if response.StatusCode == StatusCode.Unauthorized
        fieldName = 'WWW-Authenticate';
    else
        assert(response.StatusCode == StatusCode.ProxyAuthenticationRequired);
        fieldName = 'Proxy-Authenticate';
    end
    fields = response.getFields(fieldName); % array of fields matching fieldName
    if isempty(fields)
        authInfo = [];
    else
        % concatenate into a single array if multiple fields
        authInfo = arrayfun(@convert, fields, 'UniformOutput', false); 
        authInfo = [authInfo{:}]; % uncellify
        if nargin > 1
            % if scheme specified, return only the first one matching scheme
            for i = 1 : length(authInfo)
                % note authInfo.Scheme could be a string or ''
                if scheme == authInfo(i).Scheme
                    authInfo = authInfo(i);
                    return;
                end
            end
            authInfo = [];
        end
    end
end

function tf = authenticationSuccess(response, forProxy)
% Test whether the response implies authentication success
    import matlab.net.http.StatusCode
    tf = (~forProxy && response.StatusCode ~= StatusCode.Unauthorized) || ...
        (forProxy && response.StatusCode ~= StatusCode.ProxyAuthenticationRequired);
end
       
function tf = isBasicChallenge(authInfos, cred)
% Test whether the authInfos and cred intersect only in Basic
    % Since an AuthInfo.Scheme may be either a string or AuthenticationScheme, the
    % [authInfo.Scheme] operation could error out if they are mixed types, so convert all to strings
    % for comparison
    basicScheme = matlab.net.http.AuthenticationScheme.Basic;
    basic = lower(string(basicScheme));
    authSchemes = lower(string({authInfos.Scheme}));
    tf = (isempty(cred.Scheme) && all(authSchemes == basic));
    if ~tf
        credSchemes = lower(string([cred.Scheme]));
        intersection = intersect(credSchemes, authSchemes);
        tf = ~isempty(intersection) && all(intersection == basic);
    end
end
    
function [proxy, username, password] = getProxySettings(uri)
% Get proxy settings from MATLAB preferences panel or the system
% Returns [] if there is no proxy setting

    username = [];
    password = [];
    proxy = [];
    if usejava('jvm')
        % Get the proxy information using the MATLAB proxy API.
        % Ensure the Java proxy settings are set.
        com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings

        % Obtain the proxy information.
        if isempty(uri.Port)
            port = -1;
        else
            port = uri.Port;
        end
        url = java.net.URL(char(uri.Scheme), char(uri.Host), port, char(uri.EncodedPath));
        % This function goes to MATLAB's preference panel or (if not set and on
        % Windows) the system preferences.
        javaProxy = com.mathworks.webproxy.WebproxyFactory.findProxyForURL(url);
        if ~isempty(javaProxy) 
            address = javaProxy.address;
            if isa(address,'java.net.InetSocketAddress') && ...
                javaProxy.type == javaMethod('valueOf','java.net.Proxy$Type','HTTP')
                proxy = matlab.net.URI();
                proxy.Host = char(address.getHostString());
                proxy.Port = address.getPort();
                if nargout > 1
                    % If proxy information came from MATLAB settings, also get the
                    % username and password. If not, any username/password required
                    % to get to the proxy will have to be set by the caller in
                    % HTTPOptions.Credentials.
                    mwt = com.mathworks.net.transport.MWTransportClientPropertiesFactory.create();
                    if ~isempty(mwt.getProxyHost())
                        username = char(mwt.getProxyUser());
                        password = char(mwt.getProxyPassword());
                    end
                end
            end
        end
    else
        % The Java JVM is not running. The MATLAB proxy information is obtained
        % from the MATLAB preferences or the system using Java. 
    end
end

function options = updateProxyCredentials(options, proxyURI, username, password)
% Check for or create a Credentials object in options that contains the username and
% password for the proxy. This is used in the case where the proxy username and
% password came from preferences (or elsewhere, not from the Credentials array
% created by the user). Normally, if the user did nothing with Credentials, we'll
% find the special ProxyCredentials that matches all proxyURIs.

    % If there is already a Credentials for this proxy in place, our use of it to
    % authenticate to this proxy may add or update a CredentialInfo within it.
    creds = [options.Credentials options.ProxyCredentials]; % never empty
    
    % First see if there's a matching CredentialInfo that we already created for this
    % proxy. If there is one, assure that its username and password are correct.
    % This means we already authenticated to the proxy before, possibly allowing us
    % to authenticate without first getting a challenge.
    [~, credInfo] = creds.getBestCredInfo(proxyURI, [], true);
    if ~isempty(credInfo) 
        credInfo.updateCreds(username, password);
    else
        % No CredentialInfo found, so see if there's a Credentials that matches this
        % proxyURI. 

        % The following is never empty because ProxyCredentials matches all URIs
        cred = creds.getCredentials(proxyURI, []); 
        
        if isscalar(cred.Scope) && cred.Scope == proxyURI
            % We got a match, and it has just one Scope that matches this proxyURI
            % exactly. Since we know it can apply only to this proxy, force its
            % username and password to be the desired one.
            cred.Username = username;
            cred.Password = password;
        elseif ~isequal(cred.Username,username) || ~isequal(cred.Password,password)
            % Its scope is empty or has more than one URI, and the username and
            % password don't both match. In this case create a new
            % CredentialInfo under this Credential that contains the needed
            % information.
            cred.addProxyCredInfo(proxyURI, username, password);
        end
    end
end

function throwException(uri, request, history, e)
% Throw an HTTPException with information from e.
    id = string(e.identifier);
    if ~any(id.startsWith(["MATLAB:webservices" "MATLAB:http"])) && ...
       ~startsWith(class(e), "matlab.net")
       % if we got some unexpected MATLAB exception rather than one related to
       % webservices, just rethrow it directly
       newe = MException('MATLAB:http:UncaughtException', '%s', ...
                         message('MATLAB:http:UncaughtException').getString());
       throw(newe.addCause(e));
    else
       if isa(e, 'matlab.net.http.internal.ExceptionWithPayload')
           % If we got an internal exception that wraps some other exception, unwrap
           % the real exception (stored as a cause) from it, because we don't want
           % the user to see the internal exception. If the internal one has more
           % than one cause, we'll only capture the first one, but we do capture any
           % causes of the real exception.
           e = e.cause{1}; 

       end
       % make it look like our caller threw this
       throwAsCaller(matlab.net.http.HTTPException(uri, request, history, e))
    end
end

function tf = pathCompare(uri,uris)
% Return true if any path in uris exactly matches path in uri
    tf = any(arrayfun(@(x) isequal(uri.Path,x.Path), uris));
end

function checkForDuplicates(fields)
% Given vector of fields with the same Name, throw error if they don't all have the
% same value.
    if ~isempty(fields) && length(fields) > 1 && ...
            any(~isequal(fields.Value,fields(1).Value))
        error(message('MATLAB:http:DuplicateHeaderFields', fields(1).Name));
    end
end

function [uri, origURI] = createURIFromInput(uri)
% Validate the uri as a URI or a string and fill in default properties. If
% uri is a string, this assumes the first token is a host. Then it fills in
% the Scheme if necessary. OrigURI is the completed URI but without a Scheme
% added (unless it already contained one). Returned uri has the Scheme.
    import matlab.net.internal.getString
    if isa(uri, 'matlab.net.URI')
        validateattributes(uri, {'matlab.net.URI','string'}, ...
                           {'scalar'}, mfilename, 'URI');
    elseif ischar(uri) || isstring(uri)
        str = getString(uri, mfilename, 'uri');
        uri = matlab.net.URI.assumeHost(str);
        if isempty(uri.Host)
            error(message('MATLAB:http:URIMustNameHost', str));
        end
    else
        validateattributes(uri, {'matlab.net.URI','string','char'}, ...
                           {'scalar'}, mfilename, 'URI');
    end
    origURI = uri;
    if isempty(uri.Scheme) 
        % allow Scheme to be missing
        uri.Scheme = 'http';
    else
        if uri.Scheme ~= 'http' && uri.Scheme ~= 'https'
            error(message('MATLAB:http:UnsupportedScheme', char(uri.Scheme)));
        end
    end
end




