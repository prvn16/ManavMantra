classdef HTTPOptions < matlab.mixin.CustomDisplay
% HTTPOptions Options for sending HTTP requests
%   An HTTPOptions object may be supplied to RequestMessage.send when sending
%   a message to control the type of processing that will be done.
%
%   HTTPOptions properties:
%
%    Authenticate        - authenticate if required  
%    CertificateFilename - filename of root certificates in PEM format
%    ConnectTimeout      - connection timeout  
%    ConvertResponse     - convert response payload to MATLAB data
%    DecodeResponse      - decode (decompress) response payload
%    Credentials         - authentication credentials
%    MaxRedirects        - maximum number of redirects
%    ProgressMonitorFcn  - progress monitor function
%    ProxyURI            - alternate proxy URI
%    SavePayload         - save raw payload of request or response message
%    UseProgressMonitor  - report progress with ProgressMonitorFcn
%    UseProxy            - use a proxy to connect
%    VerifyServerName    - verify name of server in certificate
%
%   HTTPOptions methods:
%
%    HTTPOptions          - constructor
%
%  See also matlab.net.http.RequestMessage.send


% Properties for future:
%    DataTimeout         - data timeout
%    KeepAliveTimeout    - keep-alive timeout
%    ResponseTimeout     - timeout to receive initial response

% Copyright 2015-2017 The MathWorks, Inc.
    
    properties
        % MaxRedirects - number of redirects that should be followed automatically
        %   for a given request. If nonzero, cookies received from the server in
        %   each redirect response will be copied into in the redirected message.
        %   Set to zero to disable redirections. Once this count has been reached,
        %   the next redirect message will be returned as the response message.
        %   Default is 20.
        %
        % See also ResponseMessage
        MaxRedirects uint64 = 20
        
        % ConnectTimeout - the connection timeout in seconds 
        %   This value determines how long we wait to complete a connection attempt
        %   with a server before throwing an error. This does not limit how long it
        %   may take to receive a complete response. Set the value to Inf to wait
        %   indefinitely. If this timeout is exceeded an error is thrown. The
        %   default value is 10 seconds.
        ConnectTimeout double = 10
        
        % UseProxy - if true use a proxy for connection
        %   If true, we use the proxy in ProxyURI (if set), MATLAB Web Preferences
        %   (if set), or (on Windows) the proxy in your system preferences. If
        %   false, or if true but ProxyURI is unset and no proxy settings were found
        %   in preferences or the system, all requests go directly to the destination
        %   URI. Default is true.
        %
        %   While MATLAB will automatically divert a message to a proxy when this
        %   property is set, you may wish to directly address a message through a
        %   proxy. In that case, set this property to false and use
        %   RequestMessage.complete to return a completed message that has the proper
        %   RequestLine for addressing a proxy.
        %
        % See also ProxyURI, matlab.net.URI, matlab.net.http.RequestMessage.complete
        UseProxy logical = true
        
        % ProxyURI - the URI of the proxy to use instead of MATLAB Web Preferences
        %   This value also overrides any proxy set in your system settings on
        %   Windows. This property is used only if UseProxy is set. Default is
        %   empty. You may set this to a string or a URI. If you set this to a
        %   string, it should be of the form 'host:port' or '//host:port'.
        %
        % See also UseProxy, matlab.net.URI
        ProxyURI = matlab.net.URI.empty
        
        % Authenticate - if true, authenticate
        %  If true, this implements any supported authentication method requested by
        %  the server or proxy, based on Credentials and (if set) proxy username and
        %  password in MATLAB Web Preferences, that MATLAB supports. If this is
        %  false, if no appropriate Credentials are found for this request, or if
        %  authentication fails, the server's or proxy's authentication challenge is
        %  returned as the response message. Currently MATLAB supports only Basic
        %  and Digest authentication.
        %
        % See also Credentials.
        Authenticate logical = true
        
        % Credentials - a vector of Credentials to be used for authentication
        %   This is used only if Authenticate is set. Default is empty. If you
        %   expect to be accessing the same server multiple times during a session,
        %   then for maximum performance you should specify the same Credentials
        %   vector (or the same HTTPOptions object) each time, because the Credentials
        %   vector contains cached information that speeds up subsequent
        %   authentications.
        %
        %   If you are providing Credentials for use with a proxy, and you want those
        %   Credentials to override a different username and password specified in the
        %   MATLAB Web Preferences Panel, specify the host and port of the proxy in the
        %   ProxyURI property of this HTTPOptions object or uncheck the "Use a proxy
        %   with authentication" option in the preferences panel.
        %
        % See also Authenticate, ProxyURI
        Credentials matlab.net.http.Credentials = matlab.net.http.Credentials.empty;
        
        % UseProgressMonitor - true to report progress of a transfer
        %   Progress is reported using the specified ProgressMonitorFcn. Default
        %   false.
        %
        % See also ProgressMonitorFcn
        UseProgressMonitor logical = false
        
        % SavePayload - true to save raw payload bytes
        %   Setting this saves bytes of the request message after output conversion,
        %   and bytes of the response payload prior to input conversion, in
        %   MessageBody.Payload. These are the raw bytes received from or sent to the
        %   server. This is a debugging tool, useful when the server is unable to
        %   process the body of a request, or there is a failure converting a response
        %   body to a MATLAB type. It is false by default because the payload could
        %   consume a considerable amount of memory, at least equal to the size of the
        %   converted data. If you simply want to retrieve the response payload
        %   without any conversion that would otherwise be done based on the
        %   Content-Type of the response, set ConvertResponse to false and read
        %   MessageBody.Data instead.
        %
        %   If an HTTPException occurred during message processing, the payload received
        %   up to the point of failure is in HTTPException.History(end).Response.Body.Payload.
        %
        %   If RequestMessage.Body is a ContentProvider, this option causes the
        %   provider's converted data to be saved in Body.Payload.
        %
        % See also matlab.net.http.MessageBody.Payload, Debug, ConvertResponse,
        % matlab.net.http.RequestMessage.send, matlab.net.http.io.ContentProvider,
        % RequestMessage, ResponseMessage, matlab.net.http.io.ContentConsumer,
        % HTTPException
        SavePayload logical = false
        
        % ConvertResponse - true to convert response data to MATLAB data
        %   In a typical ResponseMessage, the raw payload in MessageBody.Payload (a
        %   uint8 vector) is converted to MATLAB data based on the Content-Type in the
        %   message, and if successful, MessageBody.Payload is deleted. See
        %   documentation of MessageBody.Data for these conversion rules.
		%
		%   If a ContentConsumer is specified, the consumer is called to convert the data.
        %
        %   This property, true by default, specifies whether that conversion should
        %   occur. If false, and there is no ContentConsumer then behavior depends on
        %   whether the Content-Type specifies character data. If the Content-Type has
        %   an explicit or default charset, the payload will be converted to a string
        %   and stored in MessageBody.Data, and no futher processing of the string will
        %   be done. If Content-Type is not character data, or MATLAB cannot determine
        %   the charset from the Content-Type, then MessageBody.Data contains the raw
        %   uint8 payload.
        %
        %   In all cases, MessageBody.Payload is deleted unless you have also
        %   specified SavePayload.
        %
        %   This property only applies to the final ResponseMessage received from the
        %   server that is returned by RequestMessage.send. 
        %
        %   If no ContentConsumer was specified, this property is ignored if the message
        %   was encoded (i.e., compressed) and could not be decoded or decoding was
        %   suppressed by DecodeResponse.
        %
        % See also MessageBody, SavePayload, Debug, DecodeResponse,
        % matlab.net.http.field.ContentTypeField, matlab.net.http.io.ContentConsumer
        ConvertResponse logical = true
        
        % DecodeResponse - true to decode compressed response data
        %   This property, true by default, specifies whether to decompress (decode) the
        %   response payload if the server returns compressed (encoded) data, prior to
        %   converting and storing it in MessageBody.Data or passing it on to a
        %   ContentConsumer. This decoding must occur before any conversion based on
        %   Content-Type. A message is encoded when there is a Content-Encoding field
        %   that specifies a compression algorithm such as 'gzip'.
        %
        %   If this is false and the data is encoded, the raw unencoded payload is saved
        %   in MessageBody.Payload and, if no ContentConsumer is specified,
        %   MessageBody.Data remains empty and no conversion is done, regardless of the
        %   setting of ConvertResponse. Even if this is true, decoding will not occur
        %   if the Content-Encoding type is not supported by MATLAB. The only content
        %   codings supported are 'gzip', 'x-gzip', and 'deflate'. The value 'identity'
        %   means there is no encoding and is treated as if there was no
        %   Content-Encoding field.
        %
        %   Do not set this value to true for compressed responses if you are using a
        %   ContentConsumer that cannot process compressed data, unless you also set
        %   ConvertResponse to false to suppress use of the consumer. FileConsumer and
        %   BinaryConsumer are the only consumers provided by MATLAB that can process
        %   compressed data.
        %
        % See also ConvertResponse, MessageBody, matlab.net.http.io.ContentConsumer,
        % matlab.net.http.io.FileConsumer, matlab.net.http.io.BinaryConsumer
        DecodeResponse logical = true
        
        % ProgressMonitorFcn - progress monitor handler
        %   This is a handle to function returning a matlab.net.http.ProgressMonitor
        %   that MATLAB will call to report progress of a transfer when you set
        %   UseProgressMonitor. If this property is empty or UseProgressMonitor is
        %   false, no progress is reported.
        %      
        % See also ProgressMonitor, UseProgressMonitor
        ProgressMonitorFcn function_handle = function_handle.empty

        % CertificateFilename - File name of root certificates in PEM format
        %   CertificateFilename is a character vector or string denoting the location
        %   of a file containing certificates in PEM format. The location must be in
        %   the current directory, in a directory on the MATLAB path, or a full or
        %   relative path to a file. If this property is set and you request an HTTPS
        %   connection, the certificate from the server is validated against the
        %   certification authority certificates in the specified PEM file. This is
        %   used by standard https mechanisms to validate the signature on the
        %   server's certificate and the entire certificate chain. A connection is
        %   not allowed if verification fails.
        %
        %   By default, the property value is set to the certificate file that ships with
        %   MATLAB, located at:
        %       fullfile(matlabroot,'sys','certificates','ca','rootcerts.pem')
        %   If you need additional certificates, you can copy this file and add your
        %   certificates to it. MATLAB provides no tools for managing certificates or
        %   certificate files, but there are various third party tools that can do so
        %   using PEM files. PEM files are ASCII files and can be simply
        %   concatenated. Since security of HTTPS connections depend on integrity of
        %   this file, you should protect it appropriately.
        %
        %   If you specify the value 'default' the above certificate filename will be
        %   used. 
        %
        %   If you set this to empty, the signature on the server certificate is always
        %   trusted and not validated against any CA certificates. Set this to empty
        %   only if you are having trouble establishing a connection due to a missing or
        %   expired certificate in the default PEM file and you do not have any
        %   alternative certificates.
        %
        %   Whether or not this property is empty, MATLAB will verify that the name in
        %   the server certificate matches the host name of the server and that it has
        %   not expired. This check can be disabled using VerifyServerName.
        %
        % See also VerifyServerName
        CertificateFilename string = matlab.net.http.HTTPOptions.DefaultCertificateFilename
        
        % VerifyServerName - true to verify server name matches certificate
        %   In a secure connection (one using https) MATLAB normally verifies that the
        %   name of the server in the server's certificate matches the Host in the URI
        %   of the request, or in the URI of the latest redirect request. This is
        %   necessary to insure that you are communicating with the intended server. In
        %   certain cases the server's certificate may not match the URI used to access
        %   it, for example if you are accessing the server using an IP address or
        %   "localhost". In these cases, if you are confident that you are
        %   communicating directly with the intended server, you can set this property
        %   to false to disable this verification.
        %
        % See also CertificateFilename
        VerifyServerName logical = true
    end
    
    properties (Constant, Access=private)
        DefaultCertificateFilename = fullfile(matlabroot,'sys','certificates','ca','rootcerts.pem')
    end
    
    properties (Access=private)
        % These properties reserved for future implementation
        
        % DataTimeout - the timeout in seconds between packets on the network
        %   This timeout is enforced during a connection once an initial connection
        %   has been established. If this timeout is exceeded while waiting to send
        %   or receive the next expected packet, the connection is closed and an
        %   error is thrown. Default is Inf (no timeout).
        DataTimeout double = Inf
        
        % ResponseTimeout - timeout to recieve initial response
        %   This is the amount of time in seconds we wait between sending the last
        %   packet of a request and the header of the response. If this timeout is
        %   exceeded the connection is closed and an error is thrown. Default is Inf
        %   (no timeout).
        ResponseTimeout double = Inf
        
        % KeepAliveTimeout - connection keep-alive timeout
        %   This is how long in seconds we keep the connection to the server open
        %   after an initial connect. A nonzero value of sufficient length enables
        %   persistent connections, avoiding the overhead of establishing a new
        %   connection on every message. Note, however that this is simply a
        %   suggestion: the server may choose to close the connection at any time.
        %   This value has no effect on success of an operation, as we always keep
        %   the connection open long enough to get the expected response from the
        %   server (provided no other timeouts have been exceeded) -- it merely
        %   affects performance in the case where an operation involves many short
        %   messages. Default is 0, which closes the connection after every response.
        KeepAliveTimeout double = 0
    end
    
    properties (Hidden, Transient=true)
        % Debug - print debugging information during message transfer
        %   Setting this displays every request and response in the command window.
        %   Setting this option also causes MessageBody.Payload to be saved for the
        %   payload of the transmitted or received message.
        Debug = false;
    end
    
    properties (GetAccess=?matlab.net.http.RequestMessage, ...
                SetAccess=immutable, Transient=true, Hidden)
        % ProxyCredentials - A single empty Credentials object whose CredentialInfos
        %   holds information about proxies whose URI, username and password for the
        %   proxy comes from MATLAB preferences or perhaps the system. This is
        %   logically treated as part of the Credentials array, but hidden because we
        %   create this by default and don't want it to be deleted by the user.
        ProxyCredentials;
    end
    
    methods
        function obj = HTTPOptions(varargin)
        %HTTPOptions constructor
        %  OPTIONS = HTTPOptions(Name,Value,...) constructs an HTTPOptions object
        %    with a set of options, where Name is the option name (a string or
        %    character vector) taken from the list of properties of this class, and
        %    Value is the value of the option. Unspecified options get their default
        %    values.
        
            obj = matlab.net.internal.copyParamsToProps(obj, varargin);
            % We can't use initialization for this property because Credentials is a
            % handle and we want each HTTPOptions instance to have a different
            % Credentials.
            obj.ProxyCredentials = matlab.net.http.Credentials;
        end
        
       function obj = set.MaxRedirects(obj,value)
            if ~isinf(value)
                validateattributes(value, {'numeric'}, ...
                      {'scalar','integer','nonnegative'}, mfilename, 'MaxRedirects');
            end
            obj.MaxRedirects = value;
       end
       
       function obj = set.ConnectTimeout(obj,value)
            validateattributes(value, {'numeric'}, {'scalar','real','nonnegative'}, mfilename, ...
                               'ConnectTimeout');
            obj.ConnectTimeout = value;
        end
         
        function obj = set.DataTimeout(obj,value)
            validateattributes(value, {'numeric'}, {'scalar','real','nonnegative'}, mfilename, ...
                               'DataTimeout');
            obj.DataTimeout = value;
        end
         
        function obj = set.ResponseTimeout(obj,value)
            validateattributes(value, {'numeric'}, {'scalar','real','nonnegative'}, mfilename, ...
                               'ResponseTimeout');
            obj.ResponseTimeout = value;
        end
         
        function obj = set.KeepAliveTimeout(obj,value)
            validateattributes(value, {'numeric'}, {'scalar','real','nonnegative'}, mfilename, ...
                               'KeepAliveTimeout');
            obj.KeepAliveTimeout = value;
        end
        
        function obj = set.UseProxy(obj,value)
            validateattributes(value, {'logical'}, {'scalar'}, mfilename, ...
                               'UseProxy');
            obj.UseProxy = value;
        end
        
        function obj = set.VerifyServerName(obj,value)
            validateattributes(value, {'logical'}, {'scalar'}, mfilename, ...
                               'VerifyServerName');
            obj.VerifyServerName = value;
        end
        
        function obj = set.ProxyURI(obj, value)
            if ~isa(value, 'matlab.net.URI')
                if isempty(value)
                    value = matlab.net.URI.empty;
                else
                    str = matlab.net.internal.getString(value, mfilename, 'ProxyURI');
                    value = matlab.net.URI.assumeHost(str);
                end
            end
            obj.ProxyURI = value;
            if ~isempty(value) && isempty(value.Host)
                warning(message('MATLAB:http:HostMissing', char(value), 'ProxyURI'));
            end
        end
        
        function obj = set.Authenticate(obj,value)
            validateattributes(value, {'logical'}, {'scalar'}, mfilename, ...
                               'Authenticate');
            obj.Authenticate = value;
        end
      
        function obj = set.Credentials(obj, value)
            if ~isempty(value)
                validateattributes(value, {'matlab.net.http.Credentials'}, ...
                                   {'vector'}, mfilename, 'Credentials');
            end
            obj.Credentials = value;
        end
        
        function obj = set.UseProgressMonitor(obj,value)
            validateattributes(value, {'logical'}, {'scalar'}, mfilename, ...
                               'UseProgressMonitor');
            obj.UseProgressMonitor = value;
        end
        
        function obj = set.SavePayload(obj,value)
            validateattributes(value, {'logical'}, {'scalar'}, mfilename, ...
                               'SavePayload');
            obj.SavePayload = value;
        end
        
        function obj = set.ProgressMonitorFcn(obj, value)
            if ~isempty(value) 
                validateattributes(value, {'function_handle'}, {'scalar'}, ...
                                   mfilename, 'ProgressMonitorFcn');
                               
            end
            obj.ProgressMonitorFcn = value;
        end
        
        function obj = set.CertificateFilename(obj, value)
            if ~isempty(value)
                value = matlab.net.internal.getString(value, mfilename, 'CertificateFilename');
                if strcmpi(value, 'default')
                    value = obj.DefaultCertificateFilename;
                end
            end
            obj.CertificateFilename = value;
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

