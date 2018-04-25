classdef (Sealed) ContentTypeField < matlab.net.http.field.MediaRangeField
% ContentTypeField Content-Type HTTP header field    
%   The ContentTypeField is an HTTP header field in a RequestMessage or
%   ResponseMessage that contains a single media type specification indicating
%   the type of content in the body of the message. In a RequestMessage that
%   contains a nonempty Body, if you don't explicitly add such a field, one
%   will be automatically added based on the type of data you insert in the
%   body.  If you specify a ContentTypeField, this will determine how your
%   outbound data is converted.  For more information on this conversion
%   see the description of MessageBody.Data.
%
%   For more information on the meaning of this field, see RFC 7231, 
%   <a href="http://tools.ietf.org/html/rfc7231#section-3.1.1.5">section 3.1.1.5</a>.
%
%   ContentTypeField properties:
%     Name      - Always "Content-Type"
%     Value     - A media-type string; can be set to a MediaType object
%
%   ContentTypeField methods:
%     ContentTypeField  - constructor
%     convert           - return contents as a MediaType
%
% See also matlab.net.http.MediaType, matlab.net.http.RequestMessage,
% matlab.net.http.ResponseMessage, matlab.net.http.MessageBody.Data

% Copyright 2015-2016, The MathWorks, Inc.

    methods (Static, Hidden)
        function names = getSupportedNames
            names = 'Content-Type'; 
        end
    end
    
    methods
        function obj = ContentTypeField(value)
        % ContentTypeField creates an HTTP ContentType header field
        %   The value is a single MediaType or string acceptable to the MediaType
        %   constructor.  It must not have a quality ('q') parameter.
        %
        % See also convert, matlab.net.http.MediaType
            if nargin == 0
                value = [];
            end
            obj = obj@matlab.net.http.field.MediaRangeField('Content-Type', value);
            
        end
    end
    
    methods (Access=protected, Hidden)
        function tf = allowsQuality(~)
        % False says don't expect a quality ('q') parameter
            tf = false;
        end
    end
    
    methods (Static, Access=protected)
        function tf = allowsArray()
        % Allow only a single media type specification
            tf = false;
        end
    end
end