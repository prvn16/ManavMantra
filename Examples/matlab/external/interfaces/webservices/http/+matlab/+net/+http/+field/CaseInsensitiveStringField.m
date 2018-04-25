classdef (Abstract, Hidden, AllowedSubclasses={?matlab.net.http.field.ConnectionField}) ...
          CaseInsensitiveStringField < matlab.net.http.HeaderField
%CaseInsensitiveStringField A header field whose value is case-insensitive
%  This field allows the comma-separated list of strings.
%
%  CaseInsensitiveStringField methods:
%    CaseInsensitiveStringField   - constructor
%    convert                      - return the canonical value

% Copyright 2016, The MathWorks, Inc.
    
    methods (Hidden, Access=protected)
        function obj = CaseInsensitiveStringField(varargin)
        % CaseInsensitiveStringField Create a header field
        %   FIELD = CaseInsensitiveStringField(NAME,VALUE) creates a header field with
        %   the specified NAME and VALUE. The VALUE must be a string vector,
        %   character vector or cell array of character vectors. The Value property
        %   will be a comma-separated list of these strings.
            narginchk(0,2);
            obj = obj@matlab.net.http.HeaderField(varargin{:});
        end
    end
    
    methods (Sealed)
        function value = convert(obj)
        % convert Return the canonical value
        %   VALUE = convert(FIELDS) returns a vector of strings representing the
        %   comma-separated strings in FIELDS, with all characters lowercase. This
        %   makes comparisons more predictable.
            value = lower(parseField(obj));
        end
    end
    
    methods (Static, Access=protected, Hidden)
        function tf = allowsStruct()
            tf = false;
        end
    end
end