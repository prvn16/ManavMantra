function resp = callSoapService(endpoint,soapAction,theMessage)
%callSoapService Send a SOAP message off to an endpoint.
%   callSoapService(ENDPOINT,SOAPACTION,MESSAGE) sends the MESSAGE, a Java DOM,
%   to the SOAPACTION service at the ENDPOINT.
%    
%   Example:
%
%   message = createSoapMessage( ...
%       'urn:xmethods-delayed-quotes', ...
%       'getQuote', ...
%       {'GOOG'}, ...
%       {'symbol'}, ...
%       {'{http://www.w3.org/2001/XMLSchema}string'}, ...
%       'rpc');
%   response = callSoapService( ...
%       'http://64.124.140.30:9090/soap', ...
%       'urn:xmethods-delayed-quotes#getQuote', ...
%       message);
%   price = parseSoapResponse(response)
%
%   This function will be removed in a future release.  For non-RPC/Encoded WSDLs,
%   use matlab.wsdl.createWSDLClient instead.
%
%   See also createClassFromWsdl, createSoapService, parseSoapResponse, 
%            matlab.wsdl.createWSDLClient.

% Copyright 1984-2014 The MathWorks, Inc.

% Use inline Java to send the message.
import java.io.*;
import java.net.*;
import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

% Convert the dom to a byte stream.
toSend = serializeDOM(theMessage);
toSend = java.lang.String(toSend);
b = toSend.getBytes('UTF8');

%%%BEGIN CODE%%%
% Create the connection where we're going to send the file.
url = URL(endpoint);

% PROXY CODE BEGIN %
% Be sure the proxy settings are set.
com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings

% Get the proxy information using MathWorks facilities for unified proxy
% prefence settings.
proxy = com.mathworks.webproxy.WebproxyFactory.findProxyForURL(url);

% Open a connection to the URL.
if isempty(proxy)
    httpConn = url.openConnection;
else
    httpConn = url.openConnection(proxy);
end
% PROXY CODE END %

%%%END CODE%%% 
% Set the appropriate HTTP parameters.
httpConn.setRequestProperty('Content-Type','text/xml; charset=utf-8');
httpConn.setRequestProperty('SOAPAction',soapAction);
httpConn.setRequestMethod('POST');
httpConn.setDoOutput(true);
httpConn.setDoInput(true);

try
    % Everything's set up; send the XML that was read in to b.
    outputStream = httpConn.getOutputStream;
    outputStream.write(b);
    outputStream.close;
catch e
    exception = regexp(e.message, ...
        'Java exception occurred: \n(.*?)\s*\n','tokens','once');
    if ~isempty(exception)
        exception = exception{1};
        if strcmp(exception, ...
                'java.net.ConnectException: Connection refused: connect')
            error(message('MATLAB:callSoapService:ConnectionRefused'));
        end
        if strcmp(exception, ...
                'ice.net.URLNotFoundException: Document not found on server')
            error(message('MATLAB:callSoapService:UrlNotFoundOnServer'))
        end
        host = regexp(exception,'java.net.UnknownHostException: (.*)','tokens','once');
        if ~isempty(host)
            error(message('MATLAB:callSoapService:UnknownHost', host{ 1 }))
        end
        error('MATLAB:callSoapService:Exception',exception)
    else
        rethrow(e)
    end
end

    
try
    % Read the response.
    inputStream = httpConn.getInputStream;
    byteArrayOutputStream = java.io.ByteArrayOutputStream;
    % This StreamCopier is unsupported and may change at any time.
    isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
    isc.copyStream(inputStream,byteArrayOutputStream);
    inputStream.close;
    byteArrayOutputStream.close;
    
    % TODO: Handle attachments.
    % inputStream = httpConn.getInputStream
    % mimeHeaders = javax.xml.soap.MimeHeaders;
    % mimeHeaders.addHeader('Content-Type',httpConn.getHeaderField('Content-Type'));
    % messageFactory = javax.xml.soap.MessageFactory.newInstance;
    % message = messageFactory.createMessage(mimeHeaders,inputStream);

catch e
    % Try to chop off the Java stack trace.
    theMessage = e.message;
    t = regexp(theMessage,'java.io.IOException: (.*?)\n','tokens','once');
    if ~isempty(t)
        theMessage = t{1};
    end
    
    % Try to get more info from a SOAP Fault.
    try
        isr = InputStreamReader(httpConn.getErrorStream,'UTF-8');
        in = BufferedReader(isr);
        stringBuffer = java.lang.StringBuffer;
        while true
            inputLine = in.readLine;
            if isempty(inputLine)
                break
            end
            stringBuffer.append(inputLine);
        end
        in.close;
        resp = stringBuffer.toString;
        try
            d = org.apache.xerces.parsers.DOMParser;
            d.parse(org.xml.sax.InputSource(java.io.StringReader(resp)));
            doc = d.getDocument;
            fault = char(doc.getElementsByTagName('faultstring').item(0).getTextContent);
        catch
            % Received some text, but couldn't extract the faultstring.
            % Use whatever text we've received.
            fault = char(resp);
        end
        theMessage = message('MATLAB:callSoapService:SoapFault', fault).getString;
    catch
        % Couldn't get the fault.  Stick with what we pulled from e.message.
    end
    error(message('MATLAB:callSoapService:Fault', theMessage))
end

% Leave the response as a java.lang.String so we don't squash Unicode.
resp = byteArrayOutputStream.toString('UTF-8');

%===============================================================================
function s = serializeDOM(x)
% Serialization through transform.
domSource = javax.xml.transform.dom.DOMSource(x);
tf = javax.xml.transform.TransformerFactory.newInstance;
serializer = tf.newTransformer;
serializer.setOutputProperty(javax.xml.transform.OutputKeys.ENCODING,'utf-8');
serializer.setOutputProperty(javax.xml.transform.OutputKeys.INDENT,'yes');

stringWriter = java.io.StringWriter;
streamResult = javax.xml.transform.stream.StreamResult(stringWriter);

serializer.transform(domSource, streamResult);
s = char(stringWriter.toString);
