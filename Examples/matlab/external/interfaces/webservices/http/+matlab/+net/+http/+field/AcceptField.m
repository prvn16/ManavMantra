classdef (Sealed) AcceptField < matlab.net.http.field.MediaRangeField
%AcceptField An Accept HTTP header field
%  The AcceptField is an HTTP header field in a RequestMessage that contains one more
%  more media type specifications indicating the type of content acceptable to the
%  client along with weighted preferences. For more information on the meaning of
%  this field, see RFC 7231, <a href="http://tools.ietf.org/html/rfc7231#section-5.3.2">section 5.3.2</a>.
%
%  You should specify an AcceptField for any request such as a GET that is expected
%  to return a ResponseMessage with data if there is a possibility that the server
%  has a choice of MediaTypes types to return and you only want to receive certain
%  types. If you do not specify a type, it is assumed you are willing to receive any
%  type.
%
%  AcceptField methods:
%    AcceptField   - constructor
%    convert       - return contents as a vector of MediaType
%
%  See also matlab.net.http.MediaType, matlab.net.http.RequestMessage,
%  matlab.net.http.ResponseMessage

% Copyright 2015-2017, The MathWorks, Inc.
    
    methods (Static)
        function names = getSupportedNames
            names = 'Accept'; 
        end
    end
    
    methods
        function obj = AcceptField(value)
        % AcceptField create an HTTP Accept header field
        %   FIELD = AcceptField(VALUE) creates an Accept header field. The VALUE is a
        %     cell array of character vectors or vector of strings or MediaType
        %     objects, each representing a media type containing an optional quality
        %     ('q') parameter. All strings must be acceptable to the MediaType
        %     constructor. The Value property of the field will be comma-separated
        %     list of the MediaTypes converted to strings.
        %
        %   See also convert, Value, matlab.net.http.MediaType
            if nargin == 0
                value = [];
            end
            obj = obj@matlab.net.http.field.MediaRangeField('Accept', value);
        end
    end
    
    methods (Access=protected)
        function tf = isValidQuality(~, quality)
            num = str2double(quality);
            tf = ~isnan(num) && num >= 0 && num <= 1;
        end
    end
end
