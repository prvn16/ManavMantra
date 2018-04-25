classdef MessageType
    % MessageType the type of HTTP message, request or response
    %   This enumeration has the value Request or Response, depending on the type
    %   of message.
    
    % Copyright 2015-2016 The MathWorks, Inc.
    enumeration
        Request
        Response
    end
    
    methods (Static)
        function obj = fromMessage(message)
            import matlab.net.http.MessageType;
            if isa(message, 'matlab.net.http.RequestMessage')
                obj = MessageType.Request;
            elseif isa(message, 'matlab.net.http.ResponseMessage')
                obj = MessageType.Response;
            else
                validateattributes(message, {'matlab.net.http.RequestMessage' ...
                    'matlab.net.http.ResponseMessage'}, {}, mfilename);
            end
        end
    end
end
                
                