classdef MediaType < matlab.mixin.CustomDisplay
    %MediaType an Internet media type used in HTTP headers
    %  An Internet media-type as defined in RFC 7231, <a href="http://tools.ietf.org/html/rfc7231#section-3.1.1">Section 3.1.1.1</a> is commonly
    %  portrayed as a string containing a type and subtype, followed by one or more
    %  optional parameters, each preceded by a semicolon:
    %
    %    type/subtype; param1=value1; param2=value2 ...
    %
    %  The type, subtype and param names are tokens containing characters from a
    %  restricted set, and the values are tokens or quoted strings.
    %
    %  This class models a media-type. The constructor parses a media-type string as
    %  it might appear in an HTTP ContentTypeField and the string method converts it
    %  back to a string. To obtain a MediaType from a ContentTypeField, use the
    %  convert method.
    %
    %  This class is also used to represent the media-range and accept-params in an
    %  AcceptField. The media-range has the same syntax as media-type and
    %  accept-params that may follow it are not part of the Internet media type (see
    %  RFC 7231, <a href="http://tools.ietf.org/html/rfc7231#section-5.3.2">Section 5.3.2</a>). These additional parameters always begin with a 
    %  weight parameter of the form, "q=qvalue" where qvalue is a number:
    %   
    %    type/subtype; param1=value1; param2=value2 ...; q=0.5; ap1=av1; ap2=av2
    %    \____________________media-type_______________/ \___ accept-params____/
    %
    %  The MediaInfo property returns just the media-type portion of a MediaType.
    %  Otherwise, this class treats all parameters similarly and does not distinguish
    %  between media-type parameters and accept-params. When constructing a
    %  MediaType to be used in an AcceptField, you are responsible for ordering
    %  parameters such that the accept-params always follow the "q" parameter.
    %
    %  MediaType properties:
    %
    %     Type         - (string) the primary type
    %     Subtype      - (string) the subtype
    %     Parameters   - (string matrix) the parameter names and values. The same
    %                    name may appear more than once, but most implementations
    %                    only use the last one.
    %     MediaInfo    - (MediaType, read-only) returns media-type portion 
    %     Weight       - (double) numeric value of q parameter
    %
    %  Except for special handling of the Weight property, this class does not
    %  enforce anything about or interpret values of the properties.
    %
    %  MediaType methods:
    %    
    %     MediaType       - constructor
    %     setParameter    - set parameter value
    %     getParameter    - get parameter value
    %     isequal, eq, == - compare two MediaType arrays
    %     string, char    - convert to string or character vector
    %
    % See also matlab.net.http.field.ContentTypeField, matlab.net.http.field.AcceptField
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties
        % Type - the primary type (string)
        %   This value is never empty.
        Type string
        % Subtype - the subtype (string)
        %   This value is never empty.
        Subtype string
    end
    
    properties (SetAccess=private)
        % Parameters - the parameters (n-by-2 string matrix)
        %   Parameters(i,1) is the name of the i'th parameter Parameters(i,2) is the
        %   value of the i'th parameter. You cannot set this array directly: use the
        %   setParameter method to remove, add or change parameter values. To reorder
        %   parameters, construct a new MediaType with the desired parameters from an
        %   an existing MediaType.
        %
        % See also setParameter
        Parameters = string.empty(0,2)
    end
    
    properties (Dependent, SetAccess=immutable)
        % MediaInfo - return the media-type portion of this object as a MediaType
        %   This returns this object minus all the parameters at or following the
        %   first 'q' parameter.
        %
        % See also Parameters
        MediaInfo
        
    end
    
    properties (Dependent)
        % Weight - the value of the weight (q) parameter as a double
        %   This is empty if there is no q parameter and NaN if the parameter
        %   cannot be converted to a double. If you set this property, it must
        %   have a value in the range 0-1, and will modify the final q parameter in
        %   this object (or add one to the end of the parameter list).
        %
        %   To obtain the exact string that is used to represent this Weight value,
        %   see Parameters or use getParameter('q').
        %
        % See also Parameters, getParameter
        Weight double
    end
    
    methods
        function obj = MediaType(type, varargin)
        % MediaType constructor
        %   MEDIATYPE = MediaType(TYPE, NAME1, VALUE1, ...) creates a MediaType
        %   given the TYPE with optional parameters. The TYPE must be a
        %   string with the syntax 'type/subtype' and the NAME arguments must be
        %   nonempty strings. The VALUE arguments must be nonempty strings or types
        %   acceptable to the string function. If a VALUE contains characters that
        %   need to be quoted or escaped, that will happen when you use the string
        %   method to convert this MediaType to a string. Do not include quotes or
        %   escape characers within a VALUE.
        %   
        %   MEDIATYPE = MediaType(STRING) parses the STRING to create a MEDIATYPE.
        %   Quotes and escape characters within the values of parameters will be
        %   processed out.
        %
        %   This constructor does not prevent creating a MediaType with duplicate
        %   parameter names.
         
        % The following behavior is for internal use only. It may change in a future
        % release.
        %   MEDIATYPE = MediaType(TYPE, PARAMS) constructs a MEDIATYPE from a TYPE
        %   and Nx2 string matrix of parameter names and values. PARAMS(i,1) is the
        %   name and PARAMS(i,2) is the value. This syntax does not throw an error
        %   if the TYPE is invalid. N may be 0.
        %   MEDIATYPE = MediaType(TYPE, string.empty) constructs a MEDIATYPE from a
        %   TYPE, with no parameters (i.e., TYPE is just type/subtype), and throws
        %   errors if invalid.

            import matlab.net.internal.getString
            if nargin == 0, return, end % allow empty array
            if nargin == 1 && isempty(type) && ~ischar(type)
                % counvert empty array other than char to an empty MediaType
                obj = matlab.net.http.MediaType.empty;
                return
            end
            % first arg is TYPE or STRING
            type = getString(type, mfilename, 'TYPE');
            if strlength(type) == 0
                error(message('MATLAB:http:BadMediaType', type));
            else
            end
            if nargin > 1 && (length(varargin) > 1 || ...
                 (length(varargin) == 1 && (ischar(varargin{1}) || isscalar(varargin{1}))))
                % first store/validate the type/subtype
                [obj.Type, obj.Subtype] = getTypeAndSubtype(type, false);
                % MediaType(TYPE, NAME, VALUE, ...)
                % go backwards through arg list to preallocate
                nargs = length(varargin);
                for i = nargs - 1 + mod(nargs,2): -2 : 1
                    name = getName(varargin{i});
                    if isempty(name)
                        error(message(...
                                  'MATLAB:http:ArgMustBeString', num2str(2*i)));
                    end
                    if i+1 > nargs
                        error(message(...
                             'MATLAB:webservices:MissingValue', name));
                    end
                    param = createParam(name, varargin{i+1}, false);
                    obj.Parameters((i+1)/2,:) = param;
                end
            else
                if nargin == 1
                    % MediaType(STRING) and MediaType(TYPE) with no optional args
                    % are functionally equivalent. If it's just TYPE, the following
                    % returns just one row, v(1,1) and v(1,2)
                    v = matlab.net.http.internal.elementParser(type, true, true); 
                    if ~isempty(v)
                        if strlength(v(1,1)) ~= 0
                            % This happens if the TYPE or first element in the
                            % string is of the NAME=VALUE form instead of
                            % type/subtype
                            error(message('MATLAB:http:BadMediaType', ...
                                          v(1,1) + '=' + v(1,2)));
                        end
                        type = v(1,2);
                        params = v(2:end,:);
                    end
                    silent = false;
                else
                    % nargin == 2, internal use only
                    % MediaType(TYPE, PARAMS) 
                    params = varargin{1};
                    if ~isstring(params) || ~ismatrix(params) || ...
                            (~isempty(params) && size(params,2) ~= 2)
                        % not Nx2 string or string.empty; generate same error as if user
                        % specified illegal value for fisrt param name
                        error(message('MATLAB:http:ArgMustBeString', 2));
                    end
                    if size(params,2) == 2
                        % Nx2 string: prevent syntax error message, even if N is 0
                        silent = true;
                    else
                        % string.empty
                        silent = false;
                    end
                end
                [obj.Type, obj.Subtype] = getTypeAndSubtype(type, silent);
                if ~isempty(params)
                    nparams = size(params,1);
                    obj.Parameters = strings(nparams,2);
                    for i = 1 : nparams
                        name = params(i,1);
                        value = params(i,2);
                        if strlength(name) == 0 || strlength(value) == 0
                            error(message('MATLAB:http:BadParameter', ...
                                          char(name+value)));
                        end
                        obj.Parameters(i,:) = createParam(name, value, silent);
                    end
                end
            end
        end
        
        function value = getParameter(obj, name)
        % getParameter Return the value of a parameter
        %   VALUE = getParameter(MEDIATYPE, NAME) returns the value of the named parameter.
        %   VALUE is an array of nonempty strings. It may contain multiple elements
        %   if the parameter appears more than once. Returns an empty array if the
        %   parameter does not exist. Parameter name matching is case-insensitive.
        %
        %   If MEDIATYPE is an array, VALUE is a cell array of values with the same size
        %   and shape
        %
        % See also setParameter
            if isempty(obj)
                value = [];
            else
                name = matlab.net.internal.getString(name, mfilename, 'NAME');
                if numel(obj) > 1
                    value = cell(size(obj));
                end
                for i = 1 : numel(obj)
                    match = lower(obj(i).Parameters(:,1)) == lower(string(name));
                    if any(match)
                        val = obj(i).Parameters(match, 2);
                    else
                        val = [];
                    end
                    if numel(obj) > 1
                        value{i} = val;
                    else
                        value = val;
                    end
                end
            end
        end
        
        function obj = setParameter(obj, name, value)
        % setParam Set a MediaType parameter
        %   NEWTYPE = setParameter(MEDIATYPE, NAME, VALUE) returns a copy of the
        %   MEDIATYPE with the parameter NAME set to VALUE, adding it if it doesn't
        %   exist. Parameter name matching is case-insensitive. If a parameter
        %   already exists with the same name but different case, the case will be
        %   changed to the specified name. If more than one match is found, only the
        %   last one is set. If the value is empty or an empty string, the parameter
        %   is removed. VALUE may be a scaler string, character vector, or any type
        %   supporting the string method. The resulting string must not be empty.
        %
        %   If you add a new parameter, it is added to the end of the list of
        %   parameters. This is important if there is already a "q" parameter in the
        %   list, as the new parameter will be treated as part of the accept-params
        %   rather than the media-type.
        %
        %   There is no validation of VALUE.
        %
        % See also getParameter
        
            % get indices of last matching name
            name = matlab.net.internal.getString(name, mfilename, 'NAME');
            if strlength(name) == 0
                error(message('MATLAB:http:ArgMustBeString', 'NAME'));
            end
            for i = 1 : numel(obj)
                index = find(lower(obj(i).Parameters(:,1)) == lower(string(name)), 1, 'last');
                if isempty(value) || (isstring(value) && isscalar(value) && strlength(value) == 0)
                    obj(i).Parameters(index, :) = [];
                else
                    % this might throw if name has bad syntax
                    param = createParam(name, value, false);
                    if isempty(index)
                        % add param to end
                        obj(i).Parameters(end+1, :) = param;
                    else
                        % set the last matching one to value
                        obj(i).Parameters(index, :) = param;
                    end
                end
            end
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'setParameter');
        end
        
        function str = string(obj)
        % string Return the value of a MediaType vector as a string
        %   STR = string(MEDIATYPE) returns the value of the MEDIATYPE as it would
        %   appear in an HTTP header. If input is a vector of MediaType, the strings
        %   are comma-separated as they would appear in a header.
            if isscalar(obj)
                if isempty(obj.Subtype) || strlength(obj.Subtype) == 0
                    str = obj.Type;
                else
                    if isempty(obj.Type)
                        str = '/' + obj.Subtype;
                    else
                        str = obj.Type + '/' + obj.Subtype;
                    end
                end
                params = getParamString(obj.Parameters);
                if ~isempty(params)
                    if isempty(str)
                        str = params;
                    else
                        str = str + '; ' + params;
                    end
                end
                if isempty(str)
                    str = "";
                end
            else
                members = arrayfun(@string, obj, 'UniformOutput', false);
                str = join([members{:}], ', ');
            end
        end
        
        function str = char(obj)
        % char Return the value of this MediaType vector as a character vector
        %   For details see string.
        %
        % See also string
            str = char(string(obj));
        end
        
        function mediaType = get.MediaInfo(obj)
            qIndex = find(lower(obj.Parameters(:,1)) == "q", 1);
            if ~isempty(qIndex)
                obj.Parameters(qIndex:end,:) = [];
            end
            mediaType = obj;
        end
        
        function weight = get.Weight(obj)
            weight = obj.getParameter('q');
            if ~isempty(weight)
                weight = str2double(weight);
            end
        end
        
        function obj = set.Weight(obj, weight)
            weight = matlab.net.http.HeaderField.qualityToString(weight);
            obj = obj.setParameter('q',weight);
        end
        
        function obj = set.Type(obj, value)
            obj.Type = matlab.net.internal.getString(value, mfilename, 'Type');
        end
            
        function obj = set.Subtype(obj, value)
            obj.Subtype = matlab.net.internal.getString(value, mfilename, 'Subtype');
        end
        
        function tf = eq(obj, other)
        % eq, == Compare two MediaTypes
        %   T1 == T2 does element by element comparisons between the MediaType arrays
        %   T1 and T2 and returns a logical array of the same dimensions. If they
        %   are not the same dimensions, one must be a scalar, and scalar-expansion
        %   is used.
        %
        %   Two MediaTypes are considered equal if they have the same type and
        %   subtype using a case-insensitive comparison, and they have the same
        %   parameters and values, where parameter names are case-insensitive and
        %   values are case-sensitive, except for 'charset' values (as per RFC 2046,
        %   <a href="http://tools.ietf.org/html/rfc2046#section-4.1.2">section 4.1.2</a>). Order of parameters is not significant.
            if size(obj) == size(other)
                if ~strcmp(class(obj),class(other))
                    error(message('MATLAB:http:MustBeSameClass'));
                end
                if isscalar(obj)
                    tf = (isempty(obj.Type) == isempty(other.Type)) && ...
                         (isempty(obj.Subtype) == isempty(other.Subtype));
                    if ~tf, return, end
                    tf1 = isempty(obj.Type) && isempty(other.Type);
                    tf2 = isempty(obj.Subtype) && isempty(other.Type);
                    tf = (tf1 || strcmpi(obj.Type,other.Type)) && ...
                         (tf2 || strcmpi(obj.Subtype,other.Subtype)) && ...
                         size(obj.Parameters,1) == size(other.Parameters,1);
                    if ~tf, return, end
                    % Type and Subtype match and they have the same number of
                    % parameters; sort them for comparison
                    p1 = sortParams(obj.Parameters);
                    p2 = sortParams(other.Parameters);
                    tf = false;
                    for i = 1 : size(p1,1)
                        if ~strcmp(p1(i,1),p2(i,1)), return, end  % names different
                        % names the same; do case-sensitive comparison of values
                        % except for charset
                        if strcmp(p1(i,1),'charset')
                            tf = strcmpi(p1(i,2), p2(i,2));
                        else
                            tf = strcmp(p1(i,2), p2(i,2));
                        end
                        if ~tf, return, end
                    end
                    tf = true;
                else
                    % Both args not scalars but sizes same, return array
                    tf = arrayfun(@(a,b) a == b, obj, other);
                end
            elseif isscalar(other)
                % obj is array or []; scalar expansion of other
                % returns [] if obj is []
                tf = arrayfun(@(a) a == other, obj);
            elseif isscalar(obj)
                % other is array or []; scalar expansion of obj
                % returns [] if other is []
                tf = arrayfun(@(b) obj == b, other);
            else
                % neither is scalar or [] and dimension sizes differ
                error(message('MATLAB:dimagree'));
            end
            
            function pout = sortParams(p)
            % lowercase parameter names and sort them
                p(:,1) = lower(p(:,1));
                pout = sortrows(p);
            end
        end
        
        function tf = isequal(obj, other)
        % isequal Compare two MediaType arrays
        %   TF = isequal(T1,T2) returns true if T1 and T2 are MediaType arrays with
        %   the same dimensions and corresponding elements compare equal according to
        %   eq.
        %
        % See also eq.
            tf = isequal(size(obj), size(other)) && all(eq(obj, other));
        end
        
    end
    
    methods (Access=protected)
        function group = getPropertyGroups(obj)
        % Provide a custom display that displays the Parameters array as an Mx2
        % matrix of strings on one line and stringifies the MediaInfo field.
            group = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            if isscalar(obj)
                formatPair = @(n,v) '"' + n + '" "' + v + '"';
                params = group.PropertyList.Parameters;
                pairs = arrayfun(formatPair, params(:,1), params(:,2), 'UniformOutput', false);
                if ~isempty(pairs)
                    group.PropertyList.Parameters = '[' + strjoin([pairs{:}], '; ') + ']';
                end
                if ~isempty(group.PropertyList.MediaInfo)
                    group.PropertyList.MediaInfo = string(group.PropertyList.MediaInfo);
                end
                names = fieldnames(group.PropertyList);
                for i = 1 : length(names)
                    name = names{i};
                    if isempty(group.PropertyList.(name))
                        group.PropertyList.(name) = [];
                    end
                end
            end
        end
    end

end

function value = getValue(name,value,silent)
% Return a string version of the value; throw mentioning name if not convertible
    try
        value = string(value);
        if ~isstring(value) || ~isscalar(value)
            if silent
                value = "";
            else
                throw(MException('MATLAB:http:CannotConvertValueToString', name));
            end
        end
    catch
        if silent
            if ~isstring(value)
                value = "";
            end
        else
            error(message(...
                'MATLAB:http:CannotConvertValueToString', name));
        end
    end
end

function name = getName(name)
% Return the name as a string; returns [] on error
    if (isstring(name) && isscalar(name) && strlength(name) ~= 0) || ...
       (ischar(name) && isvector(name))
        name = getToken(name);
    else
        name = [];
    end
end
        

function param = createParam(name, value, silent)
% Return a 2-element name,value vector. Return "" if name isn't a string.
% Throw mentioning name if value is invalid unless silent is set
    try
        name = getName(name);
    catch e
        if ~silent 
            rethrow(e)
        else
            if ~isstring(name)
                name = [];
            end
        end
    end
    if isempty(name)
        param(1) = "";
    else
        param(1) = name;
    end
    param(2) = getValue(name, value, silent);
end

function token = getToken(str)
% Verify syntax of token and return string. Throw on error.
    charName = char(str);
    % Look for any characters not allowed in a token as per RFC 7230, 3.2.6
    ic = regexp(charName, '[^' + matlab.net.http.HeaderField.TokenChars + ']', 'once');
    if isempty(ic)
        token = string(str);
    else
        error(message('MATLAB:http:IllegalCharInToken', ic, charName));
    end
end

function [type, subtype] = getTypeAndSubtype(str, silent)
    % Parse the type/subtype string for the MediaType
    % silent says don't throw error if syntax is invalid; instead include entire str
    % in type
    persistent token
    if isempty(token)
        % type and subtype are defined in RFC 7231, section 3.1.1.1 as tokens.
        token = '[' + matlab.net.http.HeaderField.TokenChars + ']+'; 
    end
    res = regexp(str, '^(?<type>(??@token))/(?<subtype>(??@token))$', 'names');
    if isempty(res)
        if silent
            res = struct('type',str,'subtype','');
        else
            % on error, re-parse allowing any characters in type and subtype except /
            res = regexp(str, '^(?<type>[^/]+)/(?<subtype>[^/]+)$', 'names');
            if ~isempty(res)
                % if it matches the type/subtype syntax, error must be due to illegal
                % character in token, so try both to issue bad char error
                getToken(res.type);
                getToken(res.subtype);
            else
                % not type/subtype syntax, so issue general error
                error(message('MATLAB:http:BadMediaType', str));
            end
        end
    end
    type = string(res.type);
    subtype = string(res.subtype);
end

function str = getParamString(params)
    if isempty(params)
        str = [];
    else
        values = arrayfun(@matlab.net.http.internal.quoteToken, ...
                                   params(:,2), 'UniformOutput',false);
        params(:,2) = [values{:}];
        str = join(join(params,'=',2),'; ');
    end
end
