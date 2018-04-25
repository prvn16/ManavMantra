classdef (AllowedSubclasses=?matlab.net.http.field.GenericParameterizedField) ...
        GenericField < matlab.net.http.HeaderField 
%GenericField  a generic HTTP header field with any name and value
%   Create one of these if you want to insert a HeaderField into a
%   RequestMessage header that contains a value that might otherwise be rejected
%   by HeaderField or one of its subclasses because the Value is not valid for
%   the desired Name. This may be useful for testing or to work around a builtin
%   restriction that may not be appropriate for your application.
%
%   For example, a Content-Length header field must contain a number. If you
%   try to do either of these:
%
%     field = matlab.net.http.HeaderField('Content-Length','abc');
%     field = matlab.net.http.field.ContentLengthField('abc');
%
%   you will get an error. If you really want to include such a field, use:
%
%     field = matlab.net.http.field.GenericField('Content-Length','abc');
%
%   MATLAB also creates a GenericField in a ResponseMessage if it receives a
%   header field from the server with a value that is not valid for the field
%   name.
%
%   In addition to supporting any name and value, this class has special methods
%   to process a parameterized syntax that is common to many HTTP header fields:
%     
%     parama1=valuea1; valuea2, paramb1=valueb1; paramb2=valueb2
%
%   In the above syntax, the field is interpreted as having 2 comma-separated
%   elements, each of which has two semicolon-separated parameters. A parameter
%   may be a simple value or of the form name=value. These parameters can be
%   accessed individually using methods below.
%
%   The convert method attempts to parse the field value as a parameterized list
%   and returns it as a structure array as described for HeaderField.parse.
%   Subclasses (such as GenericTypeParameterField) may return this information
%   in other forms, such as a string matrix.
%
%   GenericField methods:
%
%       GenericField           - constructor
%       setParameter           - set value of a parameter
%       getParameter           - get value of a parameter
%       removeParameter        - remove the parameter
%       convert                - return array of parameters
%
% See also matlab.net.http.HeaderField, ContentLengthField,
% matlab.net.http.RequestMessage, matlab.net.http.ResponseMessage,
% GenericParameterizedField

% Copyright 2015-2017 The MathWorks, Inc.

    methods
        function obj = GenericField(varargin)
        % GenericField Create a generic header field
        %   OBJ = GenericField(NAME1,VALUE1,...,NAMEn,VALUEn) creates a header field
        %   array with the specified NAMEs and VALUEs. VALUEs must be strings or
        %   convertible to strings. If a VALUE is a structure array, the array is used
        %   to create a value with a parameterized syntax as described for GenericField.
        %
        % See also GenericField
            obj@matlab.net.http.HeaderField(varargin{:});
        end
        
        function value = convert(obj)
        % convert Return contents as a structure or string matrix
        %   VALUE = convert(FIELD) returns a structure or string matrix of parameter
        %   name-value pairs. If class(FIELD) is GeneriField, this is a structure whose
        %   names and values correspond to those in the field, as documented for
        %   HeaderField's parse method. In subclasses, this method may return an Nx2
        %   string matrix, where the first column has the parameter name and the second
        %   has its value.
        %
        %   In most cases, when looking for a specific parameter in the field, use
        %   getParameter.
        %
        % See also matlab.net.http.HeaderField, getParameter
            value = obj.parseField();
            if obj.useStringMatrix() && ~obj.allowsArray() && size(value,1) == 1 && ndims(value) == 3
                % If useStringMatrix, parseField returns MxNx2 array of strings. If
                % ~allowsArray, M will always be 1, so shift it out to return just an Nx2 array.
                value = shiftdim(value,1);
            end
        end
        
        function [value, name] = getParameter(obj, name)
        % getParameter Get the value of a parameter in this field
        %   [VALUE, ACTNAME] = getParameter(FIELD, PARAM) returns the VALUE of the
        %   parameter PARAM, using a case-insensitive match, and its actual name ACTNAME.
        %   PARAM is a string or character vector and VALUE is a string. If there are
        %   multiple matches, VALUE and ACTNAME are string vectors. If there are no
        %   matches, returned values are empty string arrays. 
        %
        %   Any quotes surrounding the parameter value are removed from VALUE.
            if isempty(obj.Value)
                name = string.empty;
                value = string.empty;
            else
                name = matlab.net.internal.getString(name, mfilename, 'PARAM');
                data = matlab.net.http.internal.elementParser(obj.Value, true, true);
                matches = strcmpi(data(:,1),name);
                name = data(matches,1);
                value = data(matches,2);
            end
        end
        
        function obj = setParameter(obj, name, value)
        % setParameter Set value of a parameter in this field
        %   FIELD = setParameter(FIELD, PARAM, VALUE) sets the parameter PARAM to VALUE
        %   and returns the updated field. PARAM and VALUE must be scalar strings or
        %   character vectors. PARAM must be a valid token, containing only characters
        %   defined in RFC 7230, <a href="http://tools.ietf.org/html/rfc7230#section-3.2.6">section 3.2</a>, or may be "" or '' to set an unnamed parameter. 
        %
        %   The VALUE may contain any characters. If it contains characters not allowed
        %   in a token, and is not already quoted, it will be quoted. An empty string
        %   will be inserted as paired double-quotes ("").
        %
        %   Matching of PARAM to parameter is case-insensitive, but if the case does not
        %   match the existing parameter's name, the name will be changed to PARAM. 
        %
        %   If there are multiple matching parameters, all are changed to VALUE.
        %
        %   The returned FIELD.Value may be reformatted to remove any extraneous
        %   whitespace in the original value.
            name = matlab.net.internal.getString(name, mfilename, 'PARAM');
            obj.throwOnInvalidToken(name);
            value = matlab.net.internal.getString(value, mfilename, 'VALUE');
            data = matlab.net.http.internal.elementParser(obj.Value, true, true);
            matches = strcmpi(data(:,1),name);
            if any(matches)
                data(matches,2) = value;
                data(matches,1) = name;
            else
                % add a new parameter
                if name == ""
                    % if setting the Type, put it in front
                    data = ["" value; data];
                else
                    value = obj.quoteValue(value);
                    data(end+1,1) = name;
                    data(end,2) = obj.quoteValue(value);
                end
            end
            obj.Value = data;
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'setParameter');
        end
        
        function obj = removeParameter(obj, name)
        % removeParameter Remove a parameter from this field
        %   FIELD = removeParameter(FIELD, PARAM) remove all the parameters whose names
        %   match PARAM (case-insensitive) from from this field, along with their values.
        %   Does nothing if there is no matching parameter.
            data = matlab.net.http.internal.elementParser(obj.Value, true, true);
            name = matlab.net.internal.getString(name, mfilename, 'PARAM');
            matches = strcmpi(data(:,1),name);
            if any(matches)
                data(matches,:) = [];
            end
            obj.Value = data;
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'removeParameter');
        end
    end
    
    methods (Access=protected, Hidden)
        function exc = getStringException(~,~)
        % getStringException always returns [], since all strings are accepted
            exc = [];
        end
        
        function str = valueToString(obj, value, varargin)
        % This does the same as the superclass, except that, if useStringMatrix() is
        % true, allows a string matrix as input.
            if obj.useStringMatrix()
                % if string matrix allowed, and argument is a nonscalar string, need to do some
                % additional checking not done by superclass
                if isstring(value) && ~isscalar(value)
                    % string array should have 2 or 3 dimensions, depending on allowsArray(), and
                    % last dimension should be size 2 (for name,value)
                    if obj.allowsArray() 
                        reqsize = [NaN,NaN,2];
                        if ismatrix(value) && isstring(value)
                            % in the array case, string matrix of 2 dimensions should be have a singleton
                            % dimension added in front so it's 1xMxN
                            value = shiftdim(value, -1);
                        end
                    else
                        reqsize = [NaN,2];
                    end
                    validateattributes(value, {'string'}, {'size', reqsize}, mfilename, 'VALUE');
                end
            end
            str = obj.valueToString@matlab.net.http.HeaderField(value, varargin{:});
        end
    end
    
    methods (Static)
        function names = getSupportedNames()
        % getSupportedNames returns empty to indicate no specific names are supported
            names = [];
        end
    end
    
end

