%matlab.internal.webservices.HTTPJavaConnectionAdapter HTTP connector handle object
%
%   FOR INTERNAL USE ONLY -- This class is intentionally undocumented and
%   is intended for use only within the scope of functions and classes in
%   toolbox/matlab/external/interfaces/webservices/restful. Its behavior
%   may change, or the class itself may be removed in a future release.
%
%   matlab.internal.webservices.HTTPJavaConnectionAdapter properties (read-only):
%      URL - URL string
%      ContentType - Connection content type
%      ContentEncoding - Encoding of content
%      ResponseCode - HTTP response code
%      RedirectURL - Redirection URL
%
%   matlab.internal.webservices.HTTPJavaConnectionAdapter properties:
%      RequestMethod - Name of request method
%      TimeoutInMilliseconds - Connection timeout in milliseconds
%
%   matlab.internal.webservices.HTTPJavaConnectionAdapter methods:
%      HTTPJavaConnectionAdapter - Constructor
%      closeConnection - Close HTTP connection
%      copyContentToByteArray - Copy content to byte array
%      copyContentToFile - Copy content to file
%      delete - Delete object
%      openConnection - Open HTTP connection
%      setRequestProperty - Set HTTP request property

% Copyright 2014-2018 The MathWorks, Inc.

classdef HTTPJavaConnectionAdapter < handle
  
    properties (Dependent)
        URL
        ContentType
        ContentEncoding
        ResponseCode
        RedirectURL
    end
        
    properties
        Username
        Password
        RequestMethod = 'GET'
        TimeoutInMilliseconds = 0
        Encoding = 0
        CertificateFilename = ''
        HeaderFields = []
        PostData = ''
        MediaType
    end
    
    properties (Hidden, Access = 'protected')
        ConnectionIsOpen = false
        Proxy = []
        Protocol = ''
        JavaURL = ''
        HttpURLConnection = []
    end
    
    properties (Access = 'private')
        pURL
    end
        
    methods
        
        function adapter = HTTPJavaConnectionAdapter(varargin)
        % Constructor for HTTPJavaConnectionAdapter class
        
            if isscalar(varargin)
                adapter.URL = varargin{1};
            end
        end
        
        %------------------------------------------------------------------
        
        function openConnection(adapter, varargin)
        % Open URL connection
            
            if ~adapter.ConnectionIsOpen
                url = adapter.JavaURL;
                if isscalar(varargin) && ~isempty(varargin{1})
                    proxy = varargin{1};
                    adapter.HttpURLConnection = url.openConnection(proxy);
                else
                    adapter.HttpURLConnection = url.openConnection;
                end
                adapter.ConnectionIsOpen = true;
            end
        end
        
        %------------------------------------------------------------------
        
        function setRequestProperties(adapter)
            urlConnection = adapter.HttpURLConnection;

            if any(strcmpi(adapter.Protocol, {'http', 'https'}))
               urlConnection.setFollowRedirects(true);
            end
            setConnectionTimeout(adapter);

            if ~isempty(adapter.Username)
                authorization = getBasicAuthorizationString( ...
                    adapter.Username, adapter.Password);
                setRequestProperty(adapter, 'Authorization', authorization);
            end
            
            if strcmpi(adapter.RequestMethod, 'auto')
                if isempty(adapter.PostData)
                    adapter.RequestMethod = 'GET';
                else
                    adapter.RequestMethod = 'POST';
                end
            end
			if ~isempty(adapter.MediaType)
                setRequestProperty(adapter, 'Content-Type', adapter.MediaType);
            end
            urlConnection.setRequestMethod(adapter.RequestMethod);
        end
        
        %------------------------------------------------------------------
        
        function openProxyConnection(adapter, ~)
        % Open proxy URL connection
            
            proxy = adapter.Proxy;
            openConnection(adapter, proxy);
        end
        
        %------------------------------------------------------------------
        
        function closeConnection(adapter)
        % Close connection
            
            if ~isempty(adapter.HttpURLConnection) ...
                    && isjava(adapter.HttpURLConnection)
                try
                    adapter.HttpURLConnection.disconnect;
                catch
                end               
                adapter.HttpURLConnection = [];
                adapter.ConnectionIsOpen = false;
            end
        end
        
        %------------------------------------------------------------------
        
        function delete(adapter)
        % Delete object
        
            % Ensure connection is closed.
            closeConnection(adapter)
        end
                         
        %------------------------------------------------------------------
        
        function byteArray = copyContentToByteArray(adapter,~)
        % Copy content from Web service to byte (uint8) array
            
            try
                % Get the input stream.
                inputStream = getConnectionInputStream(adapter);
                
                % Construct an output stream.
                outputStream = java.io.ByteArrayOutputStream;
                
                % Copy the data from the connection to the output stream.
                copyStream(adapter, inputStream, outputStream);
                
                % Convert the stream to a uint8 array.
                % Use typecast rather than casting to uint8 otherwise
                % certain values are truncated.
                byteArray = typecast(outputStream.toByteArray,'uint8');
                closeConnection(adapter);
            catch e
                throwAsCaller(e);
            end
        end

        %------------------------------------------------------------------

        function sendPostData(adapter)
            adapter.HttpURLConnection.setDoOutput(true);
            copyByteArrayToContent(adapter, adapter.PostData);
        end
        
    
        %------------------------------------------------------------------
        
        function copyByteArrayToContent(adapter, postData)
        % Copy postData (uint8 array) to Web service
            
            try
                byteArray = uint8(postData);
                inputStream = java.io.ByteArrayInputStream(byteArray);
                copyStream(adapter, inputStream, adapter.HttpURLConnection.getOutputStream());
            catch e
                throwAsCaller(e);
            end
        end
   
        %------------------------------------------------------------------
        
        function copyContentToFile(adapter, filename)
        % Copy content from Web service to file
            
            try
                % Get the input stream.
                inputStream = getConnectionInputStream(adapter);
                
                % Get an output stream for the file.
                outputStream = getFileOutputStream(filename);
                
                % Copy the data from the connection to the file.
                copyStream(adapter, inputStream, outputStream);
                closeConnection(adapter);
            catch e
                throwAsCaller(e);
            end
        end
                
        %------------------------------------------------------------------
        
        function setRequestProperty(adapter, name, value)
        % Set connection request property if name is not empty.  Replaces property if it
        % already exists.  Unlike HTTPConnector.setRequestProperty, does not
        % remove fields.
        
            urlConnection = adapter.HttpURLConnection;
            if ~isempty(name) && ~isempty(urlConnection)
                try
                    % The setRequestProperty Java method can issue an error
                    % and should be invoked from within a try/catch to
                    % prevent a Java error from propagating to the user.
                    urlConnection.setRequestProperty(name, value);
                catch e
                    throwAsCaller(e);
                end
            end
        end
        
        %------------------------- set/get methods ------------------------
        
        function set.URL(adapter, url)
        % Set URL property value and update JavaURL, Protocol, and Proxy 
        % property values.
        
            % Store the URL property value in the private copy.
            adapter.pURL = url;
            
            % Construct and set JavaURL and Protocol.
            [adapter.JavaURL, adapter.Protocol] = constructURL(url); 
            
            % Get the proxy information using the MATLAB proxy API
            % and set the property.
            adapter.Proxy = getProxySettings(adapter.JavaURL);             
        end
           
        %------------------------------------------------------------------
        
        function url = get.URL(adapter)
            url = adapter.pURL;
        end
        
        %------------------------------------------------------------------
        
        function contentType = get.ContentType(adapter)
            if adapter.ConnectionIsOpen
                contentType = char(adapter.HttpURLConnection.getContentType());
            else
                contentType = '';
            end
        end
        
        %------------------------------------------------------------------
        
        function contentEncoding = get.ContentEncoding(adapter)
            if adapter.ConnectionIsOpen
                contentEncoding = char(adapter.HttpURLConnection.getContentEncoding());
            else
                contentEncoding = '';
            end
        end
        
        %------------------------------------------------------------------
        
        function code = get.ResponseCode(adapter)
            if adapter.ConnectionIsOpen
                try
                    code = adapter.HttpURLConnection.getResponseCode();
                catch
                    code = 400;
                end
            else
                code = 400;
            end
        end
        
        %------------------------------------------------------------------
        
        function url = get.RedirectURL(adapter)
            url = '';
            if adapter.ConnectionIsOpen
                try
                    url = adapter.HttpURLConnection.getHeaderField('Location');
                    url = char(url.toString);
                catch
                    url = '';
                end
            end
        end
    end
    
    methods (Access = 'protected')
        
        function setConnectionTimeout(adapter)            
            milliseconds = int32(adapter.TimeoutInMilliseconds);
            urlConnection = adapter.HttpURLConnection;
            urlConnection.setConnectTimeout(milliseconds);
            urlConnection.setReadTimeout(milliseconds);
        end
        
        %------------------------------------------------------------------
        
        function inputStream = getConnectionInputStream(adapter)
        % Obtain input stream from connection
            
            % Ensure the connection is open.
            openConnection(adapter, adapter.Proxy);
            
            % Get the input stream from the connection.
            try
                inputStream = adapter.HttpURLConnection.getInputStream;
            catch e
                % Construct an MException and include the HTTP response
                % code and message.
                e = constructResponseException(adapter, e);
                throwAsCaller(e);
            end
            
            switch adapter.Encoding
                case 1
                    inputStream = getGzipInputStream(inputStream);
                case 2
                    inputStream = getDeflaterInputStream(inputStream);
            end
        end
             
        %------------------------------------------------------------------
        
        function copyStream(adapter, inputStream, outputStream)
        % Copy data from inputStream to outputStream
            
            % Read the data from the connection and copy it to outputStream.
            % Use the InterruptibleStreamCopier to add ability to cntrl-c
            % the copy operation.
            copier = com.mathworks.mlwidgets.io.InterruptibleStreamCopier.getInterruptibleStreamCopier;
            closeObj = onCleanup(@()closeStreams(inputStream, outputStream));
            try
                copier.copyStream(inputStream, outputStream);
            catch e
                e = MException('MATLAB:webservices:CopyContentToDataStreamError', e.message, adapter.URL);
                throwAsCaller(e);
            end
        end
        
        %------------------------------------------------------------------
        
        function e = constructResponseException(adapter, e)
        % Construct an MException consisting of the URL, response code and
        % message
            
            url = adapter.URL;
            if strcmp(adapter.Protocol, 'file')
                % file protocol.
                % Parse the error message provided.
                timeout = connectionTimeoutInSeconds(adapter);
                [msg, id] = parseErrorMessage(e, url, timeout, adapter.ResponseCode);
            else
                % http, https protocol
                % Parse the response message.
                [msg, id] = parseResponseMessage(adapter, e, url);
            end
            
            % Construct an MException from the message string.
            % Avoid sprintf issues by using '%s'.
            msg = msg.getString();
            e = MException(id, '%s', msg);
        end
        
        %------------------------------------------------------------------
        
        function [msg, id] = parseResponseMessage(adapter, e, url)
        % Construct a message and message id consisting of the URL,
        % response code and message
            
            connection = adapter.HttpURLConnection;
            try
                % Get the server response to be included in the error message.
                response = char(connection.getResponseMessage);
                if strcmp(response, 'OK')
                    % The response message in this case does not contain
                    % any error information. Use the message in the
                    % ExceptionObject instead.
                    response = getLocalizedMessage(e);
                end
                
                % Get the numeric response code and convert to char to
                % include in the message body and use the response code as
                % part of the message ID. If the code is less than 0
                % (typically -1) (the response is not valid HTTP), then set
                % to 'Unknown'. Use the getResponseCode() method of the
                % Java connection object (rather than adapter.ResponseCode)
                % to ensure that the code is valid. If not, an error is
                % issued, and caught below. 
                responseCode = connection.getResponseCode();
                if responseCode >= 0
                    responseCodeString = responseCode;
                else
                    responseCodeString = adapter.ResponseCode;
                end
                
                % Construct a message with the response code and response.
                % Use CopyContentToDataStreamError ID to obtain the correct
                % message catalog entry.
                id = 'MATLAB:webservices:StatusError';
                msg = message(id, responseCodeString, response, url);
                
                % Reset ID to include HTTP status code.
                id = ['MATLAB:webservices:HTTP' num2str(responseCodeString) 'StatusCodeError'];
            catch e2
                if ~isa(e2,'matlab.exception.JavaException')
                    % The new exception does not contain a Java exception
                    % object. Use the original MException object.
                    e2 = e;
                end
                % Parse the exception to obtain a meaningful message.
                timeout = connectionTimeoutInSeconds(adapter);
                [msg, id] = parseErrorMessage(e2, url, timeout, adapter.ResponseCode);
            end
        end
        
        %------------------------------------------------------------------
        
        function seconds = connectionTimeoutInSeconds(adapter)
        % Return connection value in seconds, empty if unknown
        
            connection = adapter.HttpURLConnection;
            if ~isempty(connection) && isjava(connection)
                milliseconds = adapter.HttpURLConnection.getConnectTimeout;
                seconds = milliseconds / 1000;
            else
                seconds = [];
            end
        end
    end
end

%--------------------------------------------------------------------------

function [jurl, protocol] = constructURL(url)
% Construct a java.net.URL given a URL string and its protocol

% Get the protocol (before the ":") from the URL.
protocol = getProtocolFromURL(url);

% Get the handler.
handler = getProtocolHandler(protocol);

try
    jurl = java.net.URL([], url, handler);
catch
    try
        jurl = java.net.URL(url);
    catch
        error(message('MATLAB:webservices:MalformedURL', url))
    end
end
end

%--------------------------------------------------------------------------

function handler = getProtocolHandler(protocol)
% Get handler based on protocol

if strcmp('https', protocol)
    handler = sun.net.www.protocol.https.Handler;
elseif strcmp('http', protocol)
    handler = sun.net.www.protocol.http.Handler;
else
    handler = [];
end
end

%--------------------------------------------------------------------------

function proxy = getProxySettings(jurl)
% Get proxy information for a Java URL

% Set the default authenticator to null to fix g999501
java.net.Authenticator.setDefault([]);
            
% Get the proxy information using the MATLAB proxy API.
% Be sure the proxy settings are set.
com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings

% Get the proxy settings.
proxy = com.mathworks.webproxy.WebproxyFactory.findProxyForURL(jurl);

end

%--------------------------------------------------------------------------

function protocol = getProtocolFromURL(url)
% Get protocol (http or https) from URL

protocol = url(1:find(url == ':', 1) -1);
end

%--------------------------------------------------------------------------

function inputStream = getGzipInputStream(inputStream)
% Obtain GZIPInputStream, if available

try
    inputStream = java.util.zip.GZIPInputStream(inputStream);
catch
    % Use default inputStream
end
end

%--------------------------------------------------------------------------

function inputStream = getDeflaterInputStream(inputStream)
% Obtain DeflaterInputStream, if available

try
    inputStream = java.util.zip.InflaterInputStream(inputStream);
catch
    % Use default inputStream
end
end

%--------------------------------------------------------------------------

function [msg, id] = parseErrorMessage(e, url, timeout, code)
% Construct a meaningful string from the error message

id = 'MATLAB:webservices:';
if ~isa(e,'matlab.exception.JavaException')
    exceptionClass = 'unknown';
else
    exceptionClass = class(e.ExceptionObject);
end

switch exceptionClass
    case 'java.net.SocketTimeoutException'
        id = [id 'Timeout'];
        value = num2str(timeout);
        msg = message(id, url, value, 'options.Timeout');
        
    case 'java.net.UnknownHostException'
        host = getLocalizedMessage(e);
        id = [id 'UnknownHost'];
        msg = message(id, host);
        
    case 'java.io.FileNotFoundException'
        id = [id 'FileNotFound'];
        msg = message(id, url);
        
    case 'unknown'
        id = [id 'ConnectionFailed'];
        msg = message(id, url);
        
    otherwise
        if strfind(e.message,'java.net.Authenticator.requestPasswordAuthentication')
            id = [id 'BasicAuthenticationFailed'];
            msg = message(id, url, 'Basic', 'options.Username', 'options.Password');
        else
            response = getLocalizedMessage(e);
            id = 'MATLAB:webservices:StatusError';
            msg = message(id, code, response, url);
        end
end
end

%--------------------------------------------------------------------------

function msg = getLocalizedMessage(e)
% Obtain localized message from exception object

if isa(e,'matlab.exception.JavaException')
    msg = char(e.ExceptionObject.getLocalizedMessage);
else
    msg = e.message;
end
end

%--------------------------------------------------------------------------

function fileOutputStream = getFileOutputStream(filename)
% Construct fileOutputStream for filename

% Create a Java File object.
file = java.io.File(filename);

% Ensure it is an absolute path.
if ~file.isAbsolute
    % Specify the full path to the file.
    location = fullfile(pwd, filename);
    file = java.io.File(location);
end

try
    % Make sure the path isn't nonsense.
    file = file.getCanonicalFile;
    
    % Open the output file.
    fileOutputStream = java.io.FileOutputStream(file);
catch e
    e = MException(message('MATLAB:webservices:InvalidFilename', ...
        char(file.getAbsolutePath)));
    throwAsCaller(e);
end
end

%--------------------------------------------------------------------------

function closeStreams(inputStream, outputStream)
% Close streams

if exist('outputStream','var') && ~isempty(outputStream)
    org.apache.commons.io.IOUtils.closeQuietly(outputStream)
end
if  exist('inputStream','var') && ~isempty(inputStream)
    org.apache.commons.io.IOUtils.closeQuietly(inputStream)
end
end

%--------------------------------------------------------------------------

function authorization = getBasicAuthorizationString(username, password)
% Create a string suitable for basic authorization.

usernamePassword = [username ':' password];
usernamePasswordBytes = int8(usernamePassword)';
usernamePasswordBase64 = base64Encode(usernamePasswordBytes);
authorization = ['Basic ' usernamePasswordBase64];
end

%--------------------------------------------------------------------------

function encoded = base64Encode(value)
% Use base64 encoding to encode value.

encoded = char(org.apache.commons.codec.binary.Base64.encodeBase64(value)');
end
