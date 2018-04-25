classdef (Sealed) LocationField < matlab.net.http.field.URIReferenceField
    % LocationField An HTTP Location header field
    %   A LocationField contains just a single value, a URI.  You do not
    %   normally create one of these, as it is normally inserted by the server in a
    %   ResponseMessage.  The field is most often used in redirect messages to
    %   identify the new resource.  Its interpretation depends on the StatusCode of
    %   the response.
    %
    %   LocationField methods:
    %     LocationField     - constructor
    %     convert           - return URI
    %
    % See also matlab.net.URI, URIReferenceField
    
    % Copyright 2015-2017 The MathWorks, Inc. 
    
    methods
        function obj = LocationField(varargin)
        % LocationField creates an HTTP Location header field
        %   FIELD = LocationField(VALUE) creates a field with the Name 'Location' and
        %   specified VALUE.  VALUE may be a URI or an already-encoded string
        %   acceptable to the URI constructor.
           obj = obj@matlab.net.http.field.URIReferenceField("Location", varargin{:});
        end
    end
    
    methods (Static, Hidden)
        function names = getSupportedNames()
            names = "Location";
        end
    end
end
