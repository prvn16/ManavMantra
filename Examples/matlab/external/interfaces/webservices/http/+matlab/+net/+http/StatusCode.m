classdef StatusCode < uint16
    % StatusCode Status code in an HTTP response
    %   This is an enumeration of HTTP status codes.  It can be used as an integer 
    %   in the range 100-999, or you can get the meaning as a string.  To see a
    %   list of all possible values, type:
    %      enumeration matlab.net.http.StatusCode
    %
    %   StatusCode methods:
    %     getReasonPhrase    - return the meaning as a string 
    %     getClass           - return the class as a matlab.net.http.StatusClass
    %     string             - return the 3-digit value as a string
    %     fromValue (static) - create a StatusCode object from string or number
    %  
    %   Method defined for all enumerations:
    %     char               - return the name of the enumeration member as a
    %                          character vector
    %     
    %   Because this enumeration derives from uint16, you can use this enumeration in
    %   any context that requires a number.
    %
    %   See also ResponseMessage, StatusClass
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    % This list is from the 2015-05-19 version of the IANA HTTP Status Code registry.
    % http://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
    enumeration
        Continue                    (100) 
        SwitchingProtocols          (101)
        Processing                  (102)
        OK                          (200)
        Created                     (201)
        Accepted                    (202)
        NonAuthoritativeInformation (203)
        NoContent                   (204)
        ResetContent                (205)
        PartialContent              (206)
        MultiStatus                 (207)
        AlreadyReported             (208)
        IMUsed                      (226)
        MultipleChoices             (300)
        MovedPermanently            (301)
        Found                       (302)
        SeeOther                    (303)
        NotModified                 (304)
        UseProxy                    (305)
        SwitchProxy                 (306)
        TemporaryRedirect           (307)
        PermanentRedirect           (308)
        BadRequest                  (400)
        Unauthorized                (401)
        PaymentRequired             (402)
        Forbidden                   (403)
        NotFound                    (404)
        MethodNotAllowed            (405)
        NotAcceptable               (406)
        ProxyAuthenticationRequired (407)
        RequestTimeout              (408)
        Conflict                    (409)
        Gone                        (410)
        LengthRequired              (411)
        PreconditionFailed          (412)
        PayloadTooLarge             (413)
        URITooLong                  (414)
        UnsupportedMediaType        (415)
        RangeNotSatisfiable         (416)
        ExpectationFailed           (417)
        MisdirectedRequest          (421)
        UnprocessableEntity         (422)
        Locked                      (423)
        FailedDependency            (424)
        UpgradeRequired             (426)
        PreconditionRequired        (428)
        TooManyRequests             (429)   
        RequestHeaderFieldsTooLarge (431)
        InternalServerError         (500)
        NotImplemented              (501)
        BadGateway                  (502)
        ServiceUnavailable          (503)
        GatewayTimeout              (504)
        HTTPVersionNotSupported     (505)
        VariantAlsoNegotiates       (506)
        InsufficientStorage         (507)
        LoopDetected                (508)
        Unassigned                  (509)
        NotExtended                 (510)
        NetworkAuthenticationRequired (511)
    end
    
    methods
        function meaning = getReasonPhrase(obj)
        % getReasonPhrase Get the reason phrase
        %   Returns the phrase as a string (English only).  This is similar to the
        %   char method that returns the name of the enumeration, but with
        %   punctuation and spacing added.  Note this value is based only on the
        %   numeric code, and is not necessarily the same as the ReasonPhrase that
        %   the server has inserted in the StatusLine of a ResponseMessage.
        %
        % See also matlab.net.http.StatusLine.ReasonPhrase, ResponseMessage

            % For the vast majority, can just parse the name, inserting
            % spaces between the words.  Switch statement deals only with exceptions.
            switch(obj)
                case 203, meaning = 'Non-Authoritative Information';
                case 207, meaning = 'Multi-Status';
                otherwise
                    tokens = regexp(char(obj), '([A-Z][a-z]+|[A-Z]+(?=[^a-z]|$))', 'tokens');
                    meaning = strjoin([tokens{:}]);
            end
        end
        
        function class = getClass(obj)
        % getClass Return the StatusClass for this StatusCode
        %   CLS = getClass(CODE) returns the StatusClass for this StatusCode.  The
        %   StatusClass is a value based on the first digit of the 3-digit StatusCode
        %   value.
        %
        % See also StatusClass
            class = matlab.net.http.StatusClass(uint16(obj/100)*100);
        end
        
        function str = string(obj)
        % string Convert StatusCode to string
        %   STR = string(CODE) returns the numeric value of the StatusCode in the
        %   form of a string.  Note that char(CODE) will return the name of the
        %   StatusCode as a character vector.
            str = string(num2str(obj));
        end
    end
    
    methods (Static)
        function res = fromValue(value)
        % fromValue Create a StatusCode from a number or string
        %   CODE = StatusCode.fromValue(NUM) returns a StatusCode given a number or a
        %   string that represents a number.  The number must be one of the values
        %   defined for the StatusCode enumeration.
            if ischar(value) || isstring(value)
                res = matlab.net.http.StatusCode(...
                    str2double(matlab.net.internal.getString(value,mfilename,'code'))); 
            else
                res = matlab.net.http.StatusCode(value);
            end
        end
    end
end

