classdef (AllowedSubclasses=?matlab.net.http.field.ContentLengthField) ...
        IntegerField < matlab.net.http.HeaderField
% IntegerField Base class for HeaderFields that contain non-negative integers
%   You may use this class to construct any header field whose value is an integer,
%   for which there is no existing class in the matlab.net.http.field package.
%
%   IntegerField properties:
%     Name      - Any name not reserved for use by another custom field
%     Value     - The integer value as a string; may be set to any real numeric type
%
%   IntegerField methods:
%     IntegerField    - constructor
%     convert         - return numeric value of field
%
% See also ContentLengthField

% Copyright 2015-2016 The MathWorks, Inc.
    
    methods (Static, Hidden)
        function names = getSupportedNames
            names = [];
        end
    end
    
    methods
        function obj = IntegerField(varargin)
        % IntegerField Constructor for a field whose value is an integer
        %   IntegerField(NAME,VALUE) - both arguments are optional.  NAME is the name
        %   of the field and VALUE is a non-negative integer or a string that
        %   evaluates to one.  This constructor places no restrictions on the NAME,
        %   as long as it is not reserved for use by another class in
        %   matlab.net.http.field.
            narginchk(0,2);
            obj = obj@matlab.net.http.HeaderField(varargin{:});
        end
        
        function value = convert(obj)
        % Convert Return value as a number.  It will be an integer of type double.
            if isscalar(obj)
                value = str2double(obj.Value); 
            elseif isempty(obj)
                value = double.empty;
            else
                value = arrayfun(@str2double, [obj.Value]);
            end
        end
    end
    
    methods (Access=protected, Hidden)
        function exc = getStringException(obj,value)
        % Determine if the string is a valid field value
            chars = char(strtrim(value));
            % our only requirement is all digits
            if any((chars < '0') | (chars > '9'))
                exc = obj.getValueError('MATLAB:http:ExpectedInteger', chars);
            else
                exc = []; % OK; prevents scalarToString from being called
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
        function str = scalarToString(obj, value, varargin)
        % Called to convert values other than string.  We allow only real numeric
        % positive integers.
            str = scalarToString@matlab.net.http.HeaderField(obj, value, varargin{:});
            validateattributes(value, {'numeric'}, {'real','integer','nonnegative'}, class(obj), 'Value');
        end
    end
end
    


