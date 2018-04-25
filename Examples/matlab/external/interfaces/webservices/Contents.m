% MATLAB Web Services Interfaces.
%
% RESTful interface.
%   weboptions - Specify parameters for RESTful web service.
%   webread    - Read content from RESTful web service.
%   websave    - Save content from RESTful web service to file.
%   webwrite   - Write data to RESTful web service.
%
% HTTP interface.
%   Main classes:
%     matlab.net.URI                    - An Internet Uniform Resource Identifier
%     matlab.net.QueryParameter         - A query parameter in a URI
%     matlab.net.ArrayFormat            - Enumeration of array formats for QueryParameter
%     matlab.net.http.RequestMessage    - An HTTP request message
%     matlab.net.http.ResponseMessage   - An HTTP response message
%     matlab.net.http.Message           - Base class of HTTP messages
%     matlab.net.http.HTTPOptions       - Options for sending an HTTP request
%     matlab.net.http.MessageBody       - Body of an HTTP request
%     matlab.net.http.HeaderField       - Base class of HTTP header fields
%
%   HTTP message header field classes             HTTP header field names supported by class
%     matlab.net.http.field.AcceptField          - Accept 
%     matlab.net.http.field.AuthenticateField    - WWW-Authenticate, Proxy-Authenticate
%     matlab.net.http.field.AuthenticationInfoField - Authentication-Info, Proxy-Authentication-Info
%     matlab.net.http.field.AuthorizationField   - Authorization, Proxy-Authorization   
%     matlab.net.http.field.ConnectionField      - Connection
%     matlab.net.http.field.ContentLengthField   - Content-Length
%     matlab.net.http.field.ContentLocationField - Content-Location
%     matlab.net.http.field.ContentTypeField     - Content-Type 
%     matlab.net.http.field.CookieField          - Cookie
%     matlab.net.http.field.DateField            - Date
%     matlab.net.http.field.GenericField         - A HeaderField that does not validate contents
%     matlab.net.http.field.HostField            - Host
%     matlab.net.http.field.HTTPDateField        - Certain header fields that contain a date
%     matlab.net.http.field.IntegerField         - Any integer-valued header field
%     matlab.net.http.field.LocationField        - Location
%     matlab.net.http.field.MediaRangeField      - Base class of AcceptField and ContentTypeField
%     matlab.net.http.field.SetCookieField       - Set-Cookie
%     matlab.net.http.field.URIReferenceField    - Any header field that contains a URI
%
%   Support classes and functions:
%     matlab.net.http.AuthenticationScheme - Enumeration of authentication schemes
%     matlab.net.http.AuthInfo             - Authentication or authorization information
%     matlab.net.http.Cookie               - Cookie
%     matlab.net.http.CookieInfo           - Information about a received cookie
%     matlab.net.http.Credentials          - Credentials for authentication
%     matlab.net.http.Disposition          - Enumeration of LogRecord dispositions
%     matlab.net.http.HTTPException        - Exception thrown on message processing error
%     matlab.net.http.LogRecord            - History record for HTTP exchange
%     matlab.net.http.MediaType            - Internet media type
%     matlab.net.http.MessageType          - Enumeration of Request, Response
%     matlab.net.http.ProgressMonitor      - Abstract class for progress reporting
%     matlab.net.http.ProtocolVersion      - Protocol version
%     matlab.net.http.RequestLine          - First line of RequestMessage
%     matlab.net.http.RequestMethod        - Enumeration of request methods
%     matlab.net.http.StartLine            - Base class of RequestLine and StatusLine
%     matlab.net.http.StatusClass          - Enumeration of StatusCode classes
%     matlab.net.http.StatusCode           - Enumeration of HTTP status codes
%     matlab.net.http.StatusLine           - First line of ResponseMessage
%     matlab.net.base64encode              - Encode data as Base 64
%     matlab.net.base64decode              - Decode Base 64 data
%
%   ContentProvider classes for sending streamed data and special conversions:
%     matlab.net.http.io.ContentProvider   - Base class for providers
%     matlab.net.http.io.GenericProvider   - Provider for user-specified function
%     matlab.net.http.io.FileProvider      - Provider that sends a file
%     matlab.net.http.io.FormProvider      - Provider that sends form-encoded data
%     matlab.net.http.io.ImageProvider     - Provider that sends image data
%     matlab.net.http.io.JSONProvider      - Provider that sends JSON data
%     matlab.net.http.io.MultipartProvider - Provider that creates a multipart message
%     matlab.net.http.io.StringProvider    - Provider that sends string
%
%   ContentConsumer classes for reading streamed data and special conversions:
%     matlab.net.http.io.ContentConsumer   - Base class for consumers
%     matlab.net.http.io.FileConsumer      - Consumer that stores data in a file
%     matlab.net.http.io.GenericConsumer   - Consumer that delegates to multiple types
%     matlab.net.http.io.ImageConsumer     - Consumer that reads image data
%     matlab.net.http.io.JSONConsumer      - Consumer that reads JSON data
%     matlab.net.http.io.MultipartConsumer - Conumser that reads a multipart message
%
% WSDL interface.
%   matlab.wsdl.createWSDLClient - Generate interface to SOAP-based web service.
%   matlab.wsdl.setWSDLToolPath  - Specify pathnames of WSDL support tools.

%   Copyright 2018 The MathWorks, Inc.
