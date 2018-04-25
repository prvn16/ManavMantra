classdef (AllowedSubclasses = {?matlab.net.http.field.ContentLocationField, ...
                               ?matlab.net.http.field.LocationField, ...
                               ?matlab.net.http.field.HostField}) ...
         URIReferenceField < matlab.net.http.HeaderField
% URIReferenceField an HTTP header field whose value is a single URI or portion.
%   This class allows you to specify any name for the field, as long as that
%   name is not reserved for another field in the matlab.net.http.field
%   package.  There are several subclasses implementing certain specific fields
%   that may enforce constraints on the URI.
%
%   URIReferenceField methods:
%     URIReferenceField - constructor
%     convert           - return contents as URI
%
%   URIReferenceField properties:
%     Name      - Any name allowed
%     Value     - A URI string; can be set to a URI object
%
% See also matlab.net.URI, LocationField, ContentLocationField, HostField

% Copyright 2015-2016 The MathWorks, Inc.
    
    methods (Static, Hidden)
        function names = getSupportedNames()
        % Allow any field
            names = [];
        end
    end
    
    methods
        function obj = URIReferenceField(varargin)
        % URIReferenceField creates an HTTP header field for a URI
        %   FIELD = URIReferenceField(NAME,VALUE) creates a field with the specified
        %   NAME and VALUE.  Any NAME not used by another supported field type may be
        %   used.  The VALUE may be a URI or string acceptable to the URI
        %   constructor.  If you specify a string, it must be already encoded.
        %
        % See also matlab.net.URI, LocationField, ContentLocationField
            narginchk(0,2);
            obj = obj@matlab.net.http.HeaderField(varargin{:});
        end
        
        function value = convert(obj)
        % convert returns the value of this header field as a URI. 
        
            % Subclasses may want to override this to prepare the value for suitability as
            % a URI parameter.  If you override this to return something other than
            % URI(Value,'literal'), then you should override getContentsFromURI() to
            % accept this return value to create the original Value.
            if isscalar(obj)
                value = matlab.net.URI(obj.Value, 'literal');
            elseif isempty(obj)
                value = matlab.net.URI.empty;
            else
                value = arrayfun(@convert, obj, 'UniformOutput', false);
                value = [value{:}];
            end
        end
    end
    
    methods (Static, Access=protected, Hidden)
        function tf = allowsArray()
            tf = false;
        end
        
        function tf = allowsStruct()
            tf = false;
        end
        
        function tokens = getTokenExtents(~, ~, ~)
        % Overridden because nothing should be quoted
            tokens = [];
        end
    end

    methods (Access=protected, Hidden)
        function [exc, uri] = getStringException(~,value)
        % Determine if the string is a valid URI and return it.  If you simply want to
        % validate the URI but not change how it's converted on input or output,
        % override this.
            try
                uri = matlab.net.URI(value, 'literal'); 
                exc = [];
            catch exc
                uri = [];
            end
        end
        
        function str = scalarToString(obj, value, exc, varargin)
        % Allow only URIs or strings, and returns the string representation of the URI.  Subclasses can override getContentsFromURI to
            if isa(value, 'matlab.net.URI')
                str = obj.getContentsFromURI(value);
            elseif ~isempty(exc)
                % if we had a string that returned an exception (in getStringException),
                % then call superclass to throw it
                str = scalarToString@matlab.net.http.HeaderField(obj, value, exc, varargin{:});
            else
                validateattributes(value, {'URI','string','char'}, {}, mfilename, 'value');
                str = matlab.net.internal.getString(value, mfilename, 'value');
            end
        end
        
        function str = getContentsFromURI(~, uri)
        % Convert the URI to a string for this field.  Subclasses may want to overried
        % this if they want to special-case conversion of the URI to a string.  If
        % overriding this and you also want to validate the provided URI, you don't
        % need to override getStringException: you can throw exceptions for invalid
        % URI content from here.  If overriding this then you must override convert()
        % to process this return string to recreate the same URI, in order to preserve
        % the round trip:   string(field(str)) == str
            str = string(uri);
        end
        
    end
end
