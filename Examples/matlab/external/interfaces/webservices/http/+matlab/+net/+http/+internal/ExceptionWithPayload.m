classdef ExceptionWithPayload < MException
%ExceptionWithPayload  Internal exception that saves payload
%  We throw this exception after receiving the payload of a ResponseMessage, when we
%  could not complete processing the payload (i.e., converting it to MATLAB data).
%  For example, we failed trying to convert a payload whose Content-Type is
%  application/json to a MATLAB structure.  
%
%  The main purpose of this exception is to preserve the payload of the received
%  message so we can insert it into the history or exception thrown from
%  RequestMessage.send().  If the content type was character data and conversion to
%  string was successful but subsequent processing of that string failed, we also
%  preserve the converted data.  This exception is designed to be intercepted by
%  internal functions that convert this information into an HTTPException, so it
%  should not be directly visible to the user.  The original exception that was
%  detected, which the user should be able see, is available in cause{1}.

%  Copyright 2015 The MathWorks, Inc.
    
    properties (SetAccess=private)
        % Payload - a uint8 vector
        Payload
        % Data - set to string if Payload was character based and successfully
        % converted to character data.  Empty if not.
        Data
        % Charset - If Data is set, this is the charset that was used to decode the
        % payload.
        Charset
    end
    
    methods
        function obj = ExceptionWithPayload(payload, cause, data, charset)
        % Create exception with specified payload.  If data is specified, charset must
        % be specified.
            obj = obj@MException(cause.identifier, '%s', cause.message);
            obj = obj.addCause(cause);
            obj.Payload = payload;
            if nargin > 2
                obj.Data = data;
                obj.Charset = charset;
            end
        end
    end
end
