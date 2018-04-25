classdef (Sealed) ResponseMessage < matlab.net.http.Message & matlab.mixin.CustomDisplay
    %ResponseMessage A response message received from an HTTP server
    %  This object is created by the send() method of matlab.net.http.RequestMessage
    %  containing the response from the server.
    %
    %  ResponseMessage methods:
    %    ResponseMessage - constructor
    %    complete        - complete a message by reconverting
    %    string, char    - return contents as a string or character vector
    %    show            - return/display contents with optional maximum length
    %
    %  ResponseMessage properties:
    %    StatusLine      - status line from server
    %    StatusCode      - status code in StatusLine
    %    Header          - header of the message
    %    Body            - body of the message
    %    Completed       - true if Body is completed
    % 
    % See also RequestMessage, RequestMessage.send
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    properties (Dependent)
        % StatusLine - status line from server, a matlab.net.http.StatusLine
        StatusLine
    end
    
    properties (Dependent, SetAccess=immutable)
        % StatusCode - status code in response, same as StatusLine.StatusCode
        StatusCode
    end
    
    methods
        function obj = ResponseMessage(statusLineOrCode, header, body)
        % ResponseMessage creates an HTTP response message
        %   RESPONSE = ResponseMessage(STATUS,HEADER,BODY) creates a ResponseMessage
        %   with the specified properties.  All parameters are optional and may be []
        %   for placeholders.
        %     STATUS   The StatusCode as a string or matlab.net.http.StatusCode
        %              object, or a matlab.net.http.StatusLine
        %     HEADER   The header fields: vector of matlab.net.http.HeaderField.
        %     BODY     The message body: matlab.net.http.MessageBody or data
        %              acceptable to the MessageBody constructor.
        %
        %   You do not normally create ResponseMessages because the ResponseMessage
        %   represents data received from the web, returned by the
        %   RequestMessage.send method.  This constructor is provided for testing
        %   purposes or to create an expected ResponseMessage for comparison with
        %   a expected server response.
        %
        % See also StatusCode, StatusLine, HeaderField, Body,
        % matlab.net.http.RequestMessage.send
            obj@matlab.net.http.Message();
            if nargin > 0
                if ischar(statusLineOrCode) || isstring(statusLineOrCode) || ...
                    isa(statusLineOrCode, 'matlab.net.http.StatusCode')
                    import matlab.net.http.*;
                    obj.StatusLine = StatusLine([],statusLineOrCode);
                else
                    if isempty(statusLineOrCode)
                        obj.StatusLine = [];
                    else
                        validateattributes(statusLineOrCode, ...
                            {'matlab.net.http.StatusLine','matlab.net.http.StatusCode','string'}, {'scalar'}, ...
                            mfilename, 'STATUS');
                        if isa(statusLineOrCode, 'matlab.net.http.StatusCode')
                            obj.StatusLine = StatusLine(statusLineOrCode);
                        else
                            obj.StatusLine = statusLineOrCode;
                        end
                    end
                end
                if nargin > 1
                    obj.Header = header;
                    if nargin > 2
                        obj.Body = body;
                    end
                end
            end
            obj.Completed = false;
        end
        
        function code = get.StatusCode(obj)
            if isempty(obj.StatusLine)
                code = [];
            else
                code = obj.StatusLine.StatusCode;
            end
        end
        
        function value = get.StatusLine(obj)
            value = obj.StartLine;
        end
        
        function obj = set.StatusLine(obj, value)
            obj.StartLine = value;
        end
        
        function obj = complete(obj, consumer)
        % complete Process or reprocess the response payload Content-Type
        %   MSG = complete(MSG) returns a copy of the message, converting
        %   MSG.Body.Payload to MSG.Body.Data using the current value of the
        %   Content-Type header field in MSG.
        %
        %   MSG = complete(MSG, CONSUMER) returns a copy of the message with
        %   MSG.Body.Payload processed by a ContentConsumer.  The consumer may store its
        %   result in MSG.Body.Data or process it in some other manner.
        %
        %   You do not normally need to use this method, since received data is
        %   converted automatically.  Use this method when Body.Data was not set
        %   properly, or was left unset, because the server inserted the wrong
        %   Content-Type in the message or the Content-Type was missing, or if you set
        %   HTTPOptions.ConvertResponse to false to prevent conversion of the data when
        %   it was originally received, or if you specified the wrong ContentConsumer
        %   when sending the message.  If there was an exception processing the received
        %   message, or if you set HTTPOptions.SavePayload when you sent the request,
        %   the Body.Payload in this ResponseMessage will contain the original payload
        %   (if any).  Then you can modify the header of this message to add or correct
        %   the Content-Type field and then call complete() to process the response as
        %   if the server had inserted that Content-Type field originally, and the
        %   result will be new contents in Body.Data and/or processed by the specified
        %   CONSUMER.
        %
        %   If Body.Payload is set, this method ignores the current value of
        %   Body.Data and reprocesses that payload based on Content-Type.  This would
        %   be the case on any conversion error or if you specified SavePayload.  But
        %   if conversion of the incoming data succeeded originally, but was
        %   incorrect, Body.Data will be set and Body.Payload may be empty.  In this
        %   case you can change the ContentTypeField in the received message to the
        %   desired type and call this method.  This method will try to convert the
        %   data back to a original payload based on the original content type (saved
        %   in Body.ContentType), and then reconvert it using the new Content-Type
        %   header in the ResponseMessage.  The returned Body.Payload will always be
        %   set if Data is nonempty.
        %
        %   As an example, assume the server returned a response containing JSON
        %   string but specified a Content-Type field of 'text/plain' instead of
        %   'application/json', and you did not specify HTTPOptions.SavePayload.  In
        %   this case, conversion of payload to data would have succeeded, so
        %   Body.Payload will be empty and Body.Data will contain an ASCII string
        %   (since the default charset for 'text/plain' is us-ascii).  To reprocess
        %   this data and obtain a JSON structure instead:
        %
        %     % The following also sets response.Completed to false
        %     response = response.changeFields('Content-Type','application/json');
        %     response = response.complete();
        %     jsonData = response.Body.Data;
        %
        %   The above call to complete() will convert Body.Data to Body.Payload using
        %   us-ascii encoding, and then reconvert Body.Payload to utf-8 (the default
        %   charset for application/json) before processing it as a JSON string and
        %   storing the result in Body.Data.  This conversion will fail to resurrect
        %   any non-ASCII characters that were garbled when converting the original
        %   payload using 'text/plain', but will preserve the original data if it was
        %   all ASCII.
        %
        %   In cases where the payload had to be resurrected from the data for
        %   reconversion, the original length of the payload will be remembered, when
        %   displayed by functions such as show.
        %
        %   If you had set HTTPOptions.SavePayload when sending the message, the
        %   original payload that was preserved in Body.Payload would have been used
        %   instead, with no loss of information.
        %
        %   This method returns the original message unaltered if Completed is already
        %   set.  In a ResponseMessage that contains a payload, this property is
        %   normally set only if Body.Payload has been preserved and was converted to
        %   Body.Data without an error.
        %
        % See also Body, matlab.net.http.HTTPOptions.ConvertResponse,
        % matlab.net.http.HTTPOptions.SavePayload, Completed, show
        
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'complete');
            if obj.Completed
                return;
            else
                if ~isempty(obj.Body) && ~isempty(obj.Body.ContentCoding)
                    error(message('MATLAB:http:CannotCompleteEncodedResponse', ...
                                  char(strjoin(obj.Body.ContentCoding, ', '))));
                end
            end
            % we always complete, even if we do nothing, unless we throw exception
            obj.Completed = true;
            if isempty(obj.Body)
                return;
            else
            end
            payload = obj.Body.Payload;
            contentTypeField = obj.getSingleField('Content-Type'); % errors if >1
            if isempty(contentTypeField)
                newMediaType = [];
            else
                newMediaType = contentTypeField.convert();
            end
            oldMediaType = obj.Body.ContentType;
            if newMediaType == oldMediaType
                % contentType not changed; do nothing
                return;
            end
            % ContentType changed 
            if isempty(payload)
                % We have data but not payload.  
                data = obj.Body.Data;
                if isempty(data)
                    % No data or payload; done
                    return;
                else
                end
                if isempty(oldMediaType)
                    % If the oldMediaType was empty it means we didn't convert the payload at all,
                    % so just copy Data to Payload so we can try again.
                    assert(isa(data,'uint8'))
                    obj.Body.PayloadInt = obj.Body.DataInt;
                    payload = obj.Body.PayloadInt;
                else
                    % Payload was deleted and data was converted.  Need to unconvert data back to
                    % derive the original payload.  This doesn't reliably get us back to the actual
                    % payload, because conversions are not necessarily reversible, but it's as
                    % good as we can do.  It probably fails miserably if the conversion involves
                    % anything other than charsets.
                    payload = matlab.net.http.internal.data2payload(data, oldMediaType);
                    % If PayloadLength is set, don't change it, as it retains the length
                    % of the original payload.
                    obj.Body.PayloadInt = payload;
                end
                if isempty(obj.Body.PayloadLength)
                    obj.Body.PayloadLength = length(payload);
                end
            end
            if ~isempty(payload)
                % New we have a (possibly new) payload.  Convert it to data.
                obj.Body.DataInt = ...
                    matlab.net.http.internal.readContentFromWebService(payload, newMediaType, true);
                obj.Body.ContentType = newMediaType;
            end
            obj.Completed = true; % above resets, so need to set again
        end
    end
    
    methods (Access=protected)
        function group = getPropertyGroups(obj)
        % Provide a custom display that removes StartLine (inherited from Message),
        % as it's redundant with StatusLine.  Also displays StatusLine as string.
            group = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            if isscalar(obj)
                group.PropertyList = rmfield(group.PropertyList,'StartLine');
                group.PropertyList.StatusLine = char(group.PropertyList.StatusLine);
            end
        end
    end
            
    methods (Static, Access=protected)
        function checkHeader(~)
        end
        
        function body = checkBody(body)
            % we accept only a vector of MessageBody, possibly empty
            if isempty(body)
                validateattributes(body, ...
                    {'matlab.net.http.MessageBody' 'matlab.net.http.ResponseMessage'}, ... 
                    {}, mfilename, 'Body');
            else
                validateattributes(body, ...
                    {'matlab.net.http.MessageBody' 'matlab.net.http.ResponseMessage'}, ... 
                    {'scalar'}, mfilename, 'Body');
            end
        end
        
        function type = getStartLineType()
            type = 'matlab.net.http.StatusLine';
        end
        
        function badField = getInvalidFields(~)
        % All fields valid in Response
            badField = [];
        end
        
        function tf = shouldSetBodyContentType()
        % Return false to indicate that we don't want to set the body's ContentType
        % when the ContentTypeField in this message is set.  This is because we want
        % the body's original ContentType to be preserved so that complete() can undo
        % the original conversion before converting it to the desired type.  The
        % body's ContentType in a ResponseMessage should only be set by the
        % infrastructure when a message is originally received.
            tf = false;
        end
    end
end

