classdef StatusClass < uint16
% StatusClass Class of a status code in an HTTP response
%   This is an enumeration of HTTP status classes, which are based on the first
%   digit of the 3-digit status code.  It can be used as an integer in the range
%   100-999, or you can get the meaning as a string.
%
%   StatusClass members:
%
%     Informational (100)
%     Successful    (200)
%     Redirection   (300)
%     ClientError   (400)
%     ServerError   (500)
%
%   See also StatusCode

% Copyright 2015-2016 The MathWorks, Inc.
    enumeration
        Informational (100)
        Successful    (200)
        Redirection   (300)
        ClientError   (400)
        ServerError   (500)
    end
    
    methods
        function meaning = getReasonPhrase(obj)
        % getReasonPhrase Return the meaning of a StatusClass as an English phrase
        %   STR = getReasonPhrase(CLS) returns a string that represents the name of
        %   this status class with spaces between words.
            meaning = strrep(char(obj), 'Error', ' Error');
        end
    end
end

