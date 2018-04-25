classdef (AllowedSubclasses=?matlab.net.http.field.ContentDispositionField) ...
    GenericParameterizedField < matlab.net.http.field.GenericField
% GenericParameterizedField
%   This is a version of GenericField that supports the parameterized syntax:
%
%      Type; param1=value1; param2=value2; param3=value3; ...
%
%   where Type is some token and each param=value pair represents the name and
%   value of a parameter. Type is optional, though subclasses can require it.
%   Unlike GenericField, this field only supports a single set of parameters
%   (collectively called an "element") as above, not a comma-separated list of
%   elements. 
%
%   An example of a GenericParameterizedField is the ContentDispositionField.
%
%   The Type and individual parameters may be set and read using the Type
%   property and the setParameter and getParameter methods. Alternatively, the
%   entire value of this field may be set (through the Value property) or read
%   (using the convert method) as an Nx2 string matrix, one row for each
%   parameter, where the first column is the name and the second column is the
%   value. The value of the Type property is in a row with an empty name.
%
%   GenericParameterizedField methods:
%       GenericParameterizedField - constructor
%       convert                   - return parameters as Nx2 string matrix
%       setParameter              - set a parameter
%       getParameter              - get a parameter
%       removeParameter           - remove a parameter
%
%   GenericParameterizedField properties:
%       Type  - the Type value
%       Name  - the name of the field
%       Value - the value of the field
%
% See also matlab.net.http.HeaderField, GenericField, Type,
% ContentDispositionField

% Copyright 2017 The MathWorks, Inc.

    properties (Dependent)
        % Type - The Type property of the field
        %   This is a dependent property whose value is a string equal to any
        %   token in the field's value that is not part of a name=value pair. If there
        %   is more than one, this is a string array containing all such tokens. There
        %   is normally exactly one such token at the start of the value that is
        %   considered the "type" of the value.
        %
        %   For example, in:
        %      MYTYPE; foo=bar; abc=def; hij=klm
        %   this property's value is "MYTYPE".  In the following:
        %      foo=bar; abc=def; hij=klm
        %   there is no Type, so this property is "".
        %
        %   You can also access this property using getParameter and setParameter by
        %   specifying a zero-length string as the parameter name.
        %
        %   To remove all unnamed tokens, set this to an empty array or an empty string.
        %
        % See also setParameter, getParameter
        Type string
    end
 
    methods
        function obj = GenericParameterizedField(varargin)
        % GenericParameterizedField construct a GenericParameterizedField
        %   FIELD = GenericParameterizedField(NAME,VALUE) constructs a field with the
        %   name NAME and contents of VALUE. If VALUE is a string or character vector,
        %   the VALUE is used as is. Otherwise an attempt will be made to convert it to
        %   a string. VALUE should contain a type and semicolon or space-separated list
        %   of parameters in the form:
        %      type; param1=value1; param2=value2; param3=value3; ...
        %      type param1=value1 param2=value2 param3=value3 ...
        %   where type will become the value of the Type property and each param and
        %   value defines a parameter. However MATLAB does not enforce any particular
        %   syntax of VALUE.
        %
        %   If VALUE is an Nx2 string matrix, each row of the matrix represents a
        %   param=value parameter of the field, in the form:
        %        ""     type
        %        param1 value1
        %        param2 value2
        %   Any row with an empty name will appear in the field as simply a value
        %   without a name. Normally the first row is called the Type parameter whose
        %   name is empty, as shown above. When using this form of the constructor
        %   MATLAB checks that the param names and the type are legal tokens. For
        %   param=value pairs, MATLAB quotes values that contain reserved characters, if
        %   they are not already quoted, and escapes double-quotes.
        %
        %   The Type parameter (the one with an empty name) is optional. If not set, it
        %   can be set later using the Type property or calling the method
        %   setParameter(FIELD,"",type).
        %
        %   When constructed using an Nx2 string matrix, the resulting Value property of
        %   the field will contain the parameters separated by semicolons.
        %
        %   FIELD = GenericParameterizedField(NAME,TYPE,PARAM1,VALUE1,PARAM2,VALUE2,...)
        %   constructs a field with the specified TYPE and parameters.
        %   This is roughly the same as specifying a string matrix argument:
        %     FIELD = GenericParameterizedField(NAME, ["" TYPE; PARAM1 VALUE1; PARAM2 VALUE2; ...]
        %    
        % See also Type, setParameter, getParameter
            if nargin ~= 0
                obj.Name = varargin{1};
                if nargin > 2 
                    % TYPE,PARAM1,VALUE1,... with at least one PARAM.  This expects paired
                    % PARAM,VALUE inputs
                    obj.Type = varargin{2};
                    for i = 3 : 2 : length(varargin)
                        if i == length(varargin)
                            error(message('MATLAB:http:MissingValueForParam',string(varargin{i})));
                        end
                        obj = obj.setParameter(varargin{i}, varargin{i+1});
                    end
                elseif nargin == 2
                    % TYPE or Nx2 string matrix; just set directly
                    % the valueToString method will be called to convert it
                    arg2 = varargin{2};
                    obj.Value = arg2;
                end
            end
        end
        
        function obj = set.Type(obj, value)
            if isempty(value) || (isstring(value) && isscalar(value) && value == "")
                obj = obj.removeParameter('');
            else
                validateattributes(value, {'char' 'string'}, {'scalartext'}, mfilename, 'Type');
                obj.throwOnInvalidToken(value);
                obj = obj.setParameter('', value);
            end
        end
        
        function value = get.Type(obj)
            value = obj.getParameter('');
        end
        
        function value = convert(obj)
        % convert - return parameters as an Nx2 string array
        %   Column 1 of the array contains the name of the parameter and column 2 is its
        %   value. For unnamed parameter (i.e., the Type property), column 1 contains
        %   "".
        
            % We specify _custom to cause the parser to use our useStringMatrix() and
            % allowsArray() to control the parsing, rather than default values. This gives
            % us a string array instead of a struct array, and it's Nx2 instead of 1xNx2.
            value = obj.parse('_custom',true);
        end
        
    end
    
    methods (Static, Hidden)
        function names = getSupportedNames()
            names = [];
        end
    end
    
    methods (Static, Access=protected)
        function tf = useStringMatrix()
        % Overridden to use an Nx2 string array for the value instead of a struct
            tf = true;
        end
        
        function tf = allowsArray()
        % Don't allow arrays (i.e., comma-separated list).  This causes result of
        % convert to be an Nx2 matrix instead of 1xNx2.
            tf = false;
        end
    end
end

           
            
                
            