classdef (Hidden) ResponseFuture < handle
    % matlab.net.http.ResponseFuture An object capturing status of an HTTP send request
    %   A ReponseFuture is returned by matlab.net.http.RequestMessage.sendAsync, or
    %   provided to the callback function when the response is received.
    %
    %   See also matlab.net.http.RequestMessage.sendAsync   
    
    % Copyright 2015 The Mathworks, Inc.
    
    properties (SetAccess=private)
        % Done - false initially; true when the complete response has been received
        %   from the server, it was canceled, or an error has occurred.
        Done
        % Canceled - true when cancel has been called.  A canceled request is always
        %   set to Done.
        Canceled
        % Error - an MException, set if there was an error in the request or problem
        %   sending it (e.g., timeout) that has prevented a response from being
        %   received.  If this is nonempty, Done is set.
        Error
        % Response - the matlab.net.http.ResponseMessage received from the server, valid
        %   only if Done is true and Canceled and Error are false.
        %
        %   See also matlab.net.http.ResponseMessage
        Response
    end
    
    methods
        function timedOut = waitForResponse(obj, timeout)
        % waitForResponse(timeout) wait for the response for this request
        %   This blocks until the request is done or timeout seconds have passed.  The
        %   return value is true if timeout seconds have passed with no response;
        %   otherwise it returns false and sets Done to indicate that the request was
        %   completed with a response (Response is set), canceled (Canceled is set),
        %   or there was an error (Error is set).  Reaching the timeout or
        %   interrupting this function does not affect progress of the request.
        end
        
        function cancel(obj)
        % cancel cancel this request
        %   This function has no effect if the request is Done.  Otherwise, if the
        %   request has not yet been sent, it is dropped.  If it has been sent or
        %   receipt of the response has begun, receipt is aborted.  Once this is
        %   called Done and Canceled properties are set, and Error and Reponse remain
        %   empty.
        end
        
    end
    
end

