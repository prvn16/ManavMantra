classdef (Sealed) LogRecord 
% LogRecord record of a single HTTP request and response
%   A vector of these represents a history of request-response messages
%   exchanged between client and server during an HTTP operation such as
%   RequestMessage.send. You can get a history by specifying the 3rd return
%   argument to RequestMessage.send, or from an HTTPException thrown by
%   RequestMessage.send.  Use the history for debugging or analyzing your HTTP
%   traffic.
%
%   LogRecord properties:
%
%     URI           - the URI to which the request was sent
%     Request       - the RequestMessage
%     RequestTime   - start and end times the request was sent
%     Response      - the ResponseMessage
%     ResponseTime  - start and end times the response was received
%     Disposition   - result of exchange
%     Exception     - any MException that occurred during the exchange
%
%   LogRecord methods:
%     
%     show          - return/display LogRecord vector as a string
%
% See also RequestMessage.send, ResponseMessage, matlab.net.URI, StartLine,
% Message.Body, HTTPOptions.SavePayload

% Copyright 2015-2016 The MathWorks, Inc.

    properties (SetAccess={?matlab.net.http.RequestMessage,...
                           ?matlab.net.http.internal.HTTPConnector})
        % URI - the URI to which the request was sent
        %
        % See also matlab.net.URI
        URI matlab.net.URI
        
        % Request - the RequestMessage that was sent
        %   This property contains a value if MATLAB has completed the RequestMessage
        %   and has attempted to send it, even if an exception occurred in the process
        %   of sending.  It may not contain a value if the header could not be
        %   completed, or if MessageBody.Data could not be converted to payload.  In
        %   the case of an exception, Exception will contain the MException.
        %
        %   The Request.Body is always set to the body of the request message, if
        %   any.  The Request.Body.Payload is set only if you specify SavePayload in
        %   HTTPOptions.
        %
        % See also RequestMessage, Disposition, Exception, MException, MessageBody,
        % matlab.net.http.HTTPOptions.SavePayload
        Request matlab.net.http.RequestMessage
        
        % RequestTime - start and end times of request message
        %   This is a pair of datetimes indicating the approximate time when first
        %   and last bytes of the request (including the payload) were sent.  If an
        %   exception occurred during transmission, the second time will be the time
        %   of the exception (and Exception will indicate the MException).  This
        %   property is set only if Request is set.
        %
        % See also Request, datetime, RequestMessage, Disposition, Exception,
        % MException
        RequestTime datetime

        % Response - the ResponseMessage that was sent
        %   This property contains a value only if the complete header of the response
        %   was received successfully, even if an exception occurred receiving the
        %   payload.  It may be empty if an exception occurred trying to send the
        %   request or during receipt of the response header.  In the case of an
        %   exception, Exception will contain the MException.
        %
        %   Response.Body is not set unless you specify SavePayload in HTTPOptions
        %   and the response has a payload, or if the payload was received but an
        %   exception occurred converting the paylaod to Response.Body.Data.
        %
        % See also ResponseMessage, Disposition, Exception, MessageBody, HTTPOptions
        Response matlab.net.http.ResponseMessage
        
        % ResponseTime - start and end times of response message
        %   This is a pair of datetimes indicating the approximate time when the
        %   first and last bytes of the response were received.  If an exception
        %   occurred during receipt, the second time will be the time of the
        %   exception (and Exception will indicate the MException).  This property
        %   is set only if Response is set.
        %
        % See also Response, datetime, ResponseMessage, Disposition, Exception,
        % MException
        ResponseTime datetime
        
        % Disposition - Disposition of the exchange
        %   This is a Disposition enumeration indicating the result of the exchange.
        %   If Disposition.Done, Exception is empty and all fields of this LogRecord
        %   are fully filled in with their final values.
        %
        %   Some values of Disposition imply that an exception was saved in
        %   Exception.  If an exception occurred, the Response and/or Request may not
        %   be set, depending on whether the exception occurred before or during
        %   transmission of headers or the payload.
        %
        % See also Exception, Request, Response
        Disposition matlab.net.http.Disposition
        
        % Exception - the MException that occured during processing of this exchange
        %   If an error occurred during transmission, receipt, or processing the
        %   response, this is the MException containing the exception.
        %   The value of Disposition determines whether this property is set.
        %
        % See also Disposition, MException, Request, Response
        Exception MException
    end
    
    methods
        function str = show(obj, varargin)
        % show Return or display a human-readable version a vector of LogRecords
        %   show(RECORDS) displays the entire contents of the RECORDS array.
        %
        %   show(RECORDS, LEN) displays at most LEN characters of message bodies.
        %
        %   STRS = show(___) returns a string array containing the information,
        %   instead of displaying it.  STRS contains one string for each LogRecord in
        %   RECORDS.
        
            noarg = nargout == 0;
            if ~noarg
                str = strings(1,length(obj)); % preallocate
            end
            for i = 1 : length(obj)
                if i > 1 && noarg
                    fprintf('---------------------------------------------------\n');
                end
                r = obj(i);
                disp = char(r.Disposition);
                if ~isempty(r.Request)
                    if length(r.RequestTime) == 2
                        t = num2str(seconds(r.RequestTime(2) - r.RequestTime(1)), '%.3f');
                        printit(message('MATLAB:http:LogRequestDuration', i, char(r.URI), ...
                            char(r.RequestTime(1)), char(r.RequestTime(2)), t, disp));
                     else
                        printit(message('MATLAB:http:LogRequest', i, ...
                                char(r.URI), char(r.RequestTime), disp));
                    end
                    printit('\n%s\n', r.Request.show(varargin{:}));
                end
                if ~isempty(r.Response)
                    if length(r.ResponseTime) == 2
                        t = num2str(seconds(r.ResponseTime(2) - r.ResponseTime(1)), '%.3f');
                        printit(message('MATLAB:http:LogResponseDuration', i, ...
                                char(r.ResponseTime(1)), char(r.ResponseTime(2)), t));
                    else
                        printit(message('MATLAB:http:LogResponse', i, char(r.ResponseTime)));
                    end
                    printit('\n%s', r.Response.show(varargin{:}));
                end
                if ~isempty(r.Exception)
                    msg = message('MATLAB:http:LogException');
                    printit('%s\n%s\n', msg.getString(), r.Exception.getReport);
                end
           end
            
            function printit(varargin)
                if isa(varargin{1}, 'message')
                    msg = varargin{1}.getString;
                else 
                    msg = sprintf(varargin{:});
                end
                if noarg
                    fprintf('%s', msg);
                else
                    str(i) = str(i) + msg;
                end
            end
        end
    end
end