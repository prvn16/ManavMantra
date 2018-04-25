classdef HTTPException < MException
%HTTPException  Exception thrown by HTTP services
%  The matlab.net.http.RequestMessage.send method may throw this exception on an
%  error that occurs after message completion, that prevents it from sending the
%  message to the server, if an exception occurs after sending a message but before
%  the response could be fully received, or after receipt of a message but failure to
%  convert the received data based on its Content-Type. Examples of failures are a
%  network problem, timeout, bad URI, or bad JSON string received. This exception
%  wraps, as a cause, the MException describing the error and a history of the
%  transaction. From this history you can obtain the message that was sent and the
%  message that was received, if any.
%
%  HTTPException properties:
%
%    Request     - The completed RequestMessage
%    URI         - The destination of the request
%    History     - LogRecord vector containing history of transaction
%
%  Example:
%    In this example, assume that url points to a destination that returns a message
%    whose payload was not in a valid format for the Content-Type in the response.
%    For example, it could be an invalid JSON string for a Content-Type of
%    "application/json", or an invalid JPEG image for a Content-Type of "image/jpeg".
%
%      try
%          resp = RequestMessage().send(url);
%      catch e
%          if isa(e, 'matlab.net.http.HTTPException')
%              response = e.History(end).Response;      
%              if ~isempty(response)
%                  data = response.Body.Data;
%                  payload = resonse.Body.Payload
%              end
%          end
%      end
%
%    Upon return, payload contains the bytes that were received as a uint8 vector.
%    For Content-Types that are character-based, such as "application/json", data
%    contains the Payload converted to a MATLAB string, that could not be further
%    converted to a MATLAB object. For non-character-based Content-Types, or
%    character-based types that that could not be converted to a MATLAB string
%    (because the payload had an invalid encoding for the charset), data is empty.
%
%  This exception type is not thrown for errors detected during message completion,
%  prior to attempting to send the message. In those cases RequestMessage.send
%  throws a standard MException.
%
%  See also RequestMessage, matlab.net.URI, MException.cause, LogRecord

%  Copyright 2015-2016 The MathWorks, Inc.
    
    properties (SetAccess=private)
        % Request - The RequestMessage that was or would have been sent
        %   This contains the last message that was sent or would have been sent. If
        %   this message header was successfully sent, it is the same as the last
        %   entry in History.Request. Otherwise the last entry in History does not
        %   reflect the attempted send of this messsage.
        %   
        % See also RequestMessage
        Request
        % URI - The URI for the last message that send attempted to send.
        %
        % See also matlab.net.http.RequestMessage.send, matlab.net.URI
        URI
        % History - History of the transaction
        %   This is a vector of LogRecord containing all messages sent and received.
        %   It only contains those messages whose headers were completely sent or
        %   received. If an exception occurred during transmission or receipt of a
        %   message header, it does not contain that message. If an error occurs
        %   during transmission or receipt of the payload, or converting the data to
        %   or from the payload, either the Payload, Data or both may not be set in
        %   the MessageBody.
        %
        % See also LogRecord
        History
    end
    
    methods (Access={?matlab.net.http.RequestMessage,?matlab.net.http.internal.HTTPConnector})
        function obj = HTTPException(uri, request, history, exc)
        % Create an HTTP Exception whose identifier and message are the same as the
        % MException exc, but which contains the specified history including the
        % request. If the cause itself has a cause, add it as the cause of this
        % exception.
            obj = obj@MException(exc.identifier, '%s', exc.message);
            thisID = string(obj.identifier);
            if ~thisID.startsWith(["MATLAB:webservices" "MATLAB:http"])
                % Within the send function, we only expect webservices or http
                % exceptions. If we get anything else, add it as a cause, as this
                % indicates that it is a unexpected bug in our code (or a bug in a
                % user callback) and we would like to capture its stack.
                obj = obj.addCause(exc);
            else
                % It's one of our exceptions, but it may have a cause as well.
                if isempty(exc.cause)
                    obj = obj.addCause(exc);
                else
                    obj = obj.addCause(exc.cause{1});
                end
            end
            obj.Request = request;
            obj.URI = uri;
            obj.History = history;
        end
    end
    
    methods
        function report = getReport(obj, varargin)
        % Augmented to print the stack trace of the cause, if there is one.
            report = getReport@MException(obj, varargin{:});
            if ~isempty(obj.cause)
                report = sprintf('%s\n%s', report, obj.cause{1}.getReport());
            end
        end
    end
end
