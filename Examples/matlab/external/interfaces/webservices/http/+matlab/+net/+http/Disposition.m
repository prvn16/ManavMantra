classdef Disposition
% Disposition Enumeration of results in an HTTP LogRecord
%
% Disposition properties:
%
%   Done              - a request and response were successfully sent and received
%   TransmissionError - an error occurred sending or receiving the message
%   Interrupt         - the user interrupted the operation
%   ConversionError   - an error occurred converting the response payload
%
% See also LogRecord

% Copyright 2015-2017 The MathWorks, Inc.
    
    enumeration
        % Done - a request and response were sucessfully sent and received. 
        %   This indicates the log record contains both the RequestMessage and
        %   ResponseMessage. It does not imply anything about the StatusCode in the
        %   response.
        %
        % See also LogRecord, RequestMessage, ResponseMessage, StatusCode
        Done
        
        % TransmissionError - an error occurred sending or receiving the message.
        %   It could be due to an I/O error or failure in a ContentProvider or
        %   ContentConsumer. LogRecord.Exception contains the exception that occurred.
        %
        %   If it occurred sending the request, LogRecord.Request contains the
        %   completed RequestMessage and LogRecord.Response is empty.
        %
        %   If it occurred receiving the response, LogRecord.Response may be empty if
        %   complete headers could not be received. If headers were received but the
        %   payload could not be read, the ResponseMessage will contain only the
        %   headers.
        %
        % See also LogRecord, RequestMessage, ResponseMessage
        TransmissionError
        
        % Interrupt - the operation was interrupted by the user (e.g., Ctrl+C)
        %   A LogRecord with this Disposition appears only if the operation was
        %   interrupted after transmission of the RequestMessage has begun.
        %   LogRecord.Exception is empty in this case. LogRecord may be only partially
        %   populated, depending on when the interrupt occurred. If the interrupt
        %   occurred after receipt of a response header, LogRecord.Response will
        %   contain the header, and may also contain any partial data processed during
        %   receipt of the payload, depending on the particular data converter or
        %   ContentConsumer that was being used.
        %
        % See also LogRecord, RequestMessage, ResponseMessage, ContentConsumer
        Interrupt
        
        % ConversionError - an error occurred converting the data of the response.
        %   The request was properly received (StatusCode is likely OK), but there was
        %   an error trying to automatically convert the payload of the response. This
        %   is an indication that MessageBody.Payload of LogRecord.Response contains the
        %   raw payload (even if HTTPOptions.SavePayload was not requested) and
        %   MessageBody.Data is empty. The LogRecord.Exception contains the exception.
        %
        %   This error does not occur if a ContentConsumer was involved.
        %
        % See also StatusCode, MessageBody, LogRecord,
        % matlab.net.http.HTTPOptions.SavePayload
        ConversionError
    end
    
end

