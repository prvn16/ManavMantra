classdef (Sealed) ConnectionField < matlab.net.http.field.CaseInsensitiveStringField
%ConnectionField A Connection header field
%  This field allows the comma-separated list of strings.
%
%  ConnectionField methods:
%    ConnectionField   - constructor
%    convert           - return contents as vector of lowercase strings

% Copyright 2016, The MathWorks, Inc.
    
     methods (Static)
        function names = getSupportedNames
            names = 'Connection'; 
        end
    end

    methods
        function obj = ConnectionField(value)
        % ConnectionField create an HTTP Connection header field
        %   FIELD = ConnectionField(VALUE) creates a header field with
        %   the specified VALUE.  The VALUE must be a string vector, or character
        %   vector or cell array of character vectors.  The Value property will
        %   be a comma-separated list of these strings.
            if nargin == 0
                value = [];
            end
            obj = obj@matlab.net.http.field.CaseInsensitiveStringField('Connection',value);
        end
    end
end