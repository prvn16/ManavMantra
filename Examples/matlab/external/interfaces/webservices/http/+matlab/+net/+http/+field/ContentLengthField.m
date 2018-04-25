classdef (Sealed) ContentLengthField < matlab.net.http.field.IntegerField
% ContentLengthField A Content-Length HTTP header field
%   The ContentLengthField is an HTTP header field in a RequestMessage or
%   ResponseMessage that specifies the length of the payload in bytes.  MATLAB
%   requires all outbound messages with a payload to contain a ContentLengthField: if
%   you don't specify such a field in a message that contains a nonempty body, one
%   will be added based on the length of the data.  For more information about the
%   meaning of this field, see RFC 7231, <a
%  href="http://tools.ietf.org/html/rfc7230#section-3.3.2">section 3.3.2</a>.
%
%   ContentLengthField methods:
%     ContentLengthField   - constructor
%     convert              - return the length as a number
%
% See also matlab.net.http.RequestMessage, matlab.net.http.ResponseMessage

% Copywrite 2015-2017 The MathWorks, Inc

    methods (Static)
        function names = getSupportedNames
            names = "Content-Length";
        end
    end
    
    methods
        function obj = ContentLengthField(value)
        % ContentLengthField construct a Content-Length field
        %   The value must be an non-negative integer or string that evaluates to
        %   one.
            if nargin == 0
                value = [];
            end
            obj = obj@matlab.net.http.field.IntegerField("Content-Length", value);
        end
        
    end
end
    


