classdef (Sealed) ContentLocationField < matlab.net.http.field.URIReferenceField
    % ContentLocationField A Content-Location HTTP header field
    %   A ContentLocationField contains just a single value, a URI. You do not
    %   normally create one of these, as it is normally inserted by the server in a
    %   ResponseMessage. The field provides identifying information for the returned
    %   contents.
    %
    %   ContentLocationField methods:
    %     ContentLocationField - constructor
    %     convert              - return contents as URI
    %
    % See also matlab.net.URI, URIReferenceField
    
    % Copyright 2015-2017 The MathWorks, Inc.
    methods
        function obj = ContentLocationField(varargin)
        % ContentLocationField creates an HTTP ContentLocationField header field
        %   FIELD = ContentLocationField(VALUE) creates a field with the Name
        %   'Content-Location' and specified VALUE. VALUE may be a URI or an
        %   already-encoded string acceptable to the URI constructor. The URI must
        %   not contain a Fragment.
           obj = obj@matlab.net.http.field.URIReferenceField("Content-Location", ...
                                                             varargin{:});
        end
    end
    
    methods (Access=protected, Hidden)
        function exc = getStringException(obj,value)
            % superclass returns exc if invalid URI or the valid uri contains a fragment
            [exc, uri] = getStringException@matlab.net.http.field.URIReferenceField(obj, value);
            if isempty(exc) && ~isempty(uri.Fragment)
                % fragment not allowed, even if empty string
                exc = MException(message('MATLAB:http:BadContentLocation', ...
                                         char(uri), uri.Fragment));
            end
        end
    end
    
    methods (Static, Hidden)
        function names = getSupportedNames()
            names = "Content-Location";
        end
    end
end
