classdef (Sealed) QueryParameter
% QueryParameter A parameter in the query portion of a URI
%   This class assists in the creation of a URI query string of the form:
%     name1=value1&name2=value2&name3=value3 
%   where each "name=value" segment is a QueryParameter, converted to a string
%   using the string method.  If you call the string method on a vector of
%   QueryParameter, the results are joined by the '&' character.  The string
%   method converts any values to strings and performs all necessary encoding
%   of special characters in the result.
%
%   The constructor lets you create a vector of QueryParameters given an
%   entire string as above, a list of names and values, or a structure.
%
%  QueryParameter properties:
%     Name     - name of the parameter
%     Value    - value of the parameter
%     Format   - format for encoding value if non-scalar or cell
%
%  QueryParameter methods:
%     QueryParameter - constructor
%     string, char   - convert to encoded string
%
%  See also char, string, URI, ArrayFormat

% Copyright 2015-2017 The Mathworks, Inc.
    
    properties
        % Name - the name of the parameter (string).
        Name string
        % Value - value of the parameter  
        %   This property may be a real number, logical, datetime (with value other
        %   than NaT), string, character array, or vector or cell vector of these.  If
        %   it is any other type, it is acceptable if it supports a string or char
        %   method that converts the value to a string, character vector, or cell
        %   array of character vectors.
        %
        %   When a URI containing a Query is converted to a string, or when you call
        %   the string method on this QueryParameter, a scalar Value will create a result
        %   such as "Name=Value".  If Value is "" or '' (an empty string), it will
        %   appear as "Name=".  If Value is an empty array (other than char or cell)
        %   it will appear as "Name".
        %
        %   If value is a cell array or non-scalar, it will be converted based on
        %   Format.
        % 
        %   You should not percent-encode strings you store here, because percent
        %   signs will be treated as literal symbols and will get improperly encoded
        %   when this QueryParameter is converted to a string.
        %
        % See also string, char, Format, matlab.net.URI.Query
        Value
        % Format - the format to use for encoding if Value is not a scalar or cell
        %   The value is an ArrayFormat enumeration.  Default is ArrayFormat.csv.
        %
        %   When converting a QueryParameter with a Value of {} to a string, the
        %   result will be:
        %     "Name=[]" or "Name=" for ArrayFormat.json or ArrayFormat.csv
        %     ""                   for ArrayFormat.php or ArrayFormat.repeating
        %
        %   If an individual value in a cell array is empty, is value will appear
        %   empty.  For example:
        %        >> string(QueryParameter('name',{1 [] 2},ArrayFormat.csv))
        %        ans =
        %        name=1,,2
        %        >> string(QueryParameter('name',{1 [] 2},ArrayFormat.repeating))
        %        ans = 
        %        name=1&name=&name=2
        %
        % See also Name, Value, ArrayFormat
        Format matlab.net.ArrayFormat = matlab.net.ArrayFormat.csv
    end
    
    properties (Access=private)
        Literal logical = false
    end
    
    methods
        function obj = set.Name(obj, name)
            obj.Name = matlab.net.internal.getString(name,mfilename,'Name');
        end
        
        function obj = set.Value(obj, value)
            % Allow anything: we'll error out when attempt is made to convert this to
            % a string.
            obj.Value = value;
         end
        
        function obj = QueryParameter(varargin)
        % QueryParameter Creates query parameters for use in a URI  
        %   QP = QueryParameter returns QP, an empty QueryParameter
        %
        %   QPs = QueryParameter(NAME1, VALUE1, ..., NAMEn, VALUEn) returns QPs, a
        %      vector of QueryParameters, one for each NAME,VALUE pair
        %           NAME    The name of the parameter (string)
        %           VALUE   The value of the parameter.  See description of the
        %                   Value property to determine data types permitted.
        %
        %   QPs = QueryParameter(STRUCT) returns QPs, a vector of QueryParameters,
        %      with NAME and VALUE equal to the fields of the structure STRUCT.
        %
        %   QPs = QueryParameter(___, FORMAT) specifies the FORMAT to be used for
        %      non-scalar VALUEs.  FORMAT is an ArrayFormat enumeration value.
        %      Default is matlab.net.ArrayFormat.csv.
        % 
        %   QPs = QueryParameter(QUERYSTR) parses the string QUERYSTR and returns a
        %      vector of QueryParameters representing the query.  The QUERYSTR is a
        %      completed, encoded query as it would appear in a URI, with leading '?'
        %      optional.  For example:
        %           '?foo=bar&one=2'
        %      The string will be split at '&' characters into individual
        %      QueryParameters, with the NAME and VALUE of each taken from the
        %      name=value pairs in the string.  
        %
        %      In QUERYSTR, it is assumed that triplets of characters consisting of a
        %      percent sign and two hex digits represent a percent-encoded byte, so
        %      sequences of these will be treated as UTF-8 encoded characters, which
        %      will be decoded to form the Name and Value properties of the
        %      QueryParameters.  Also, any '+' sign in QUERYSTR will be treated as if it
        %      was a space (as is '%20').  When the QueryParameter is converted back to
        %      a string (and 'literal' is not specified as described below), any
        %      required percent-encoding will be performed only on characters that
        %      should be encoded, and this will be done whether or not those characters
        %      were originally encoded in QUERYSTR, so the result from the string method
        %      may not exactly match QUERYSTR (although the meaning will be the same
        %      when used in a URI).
        %
        %      For example, the UTF-8 encoding for the euro sign (€) is the three hex
        %      bytes E2 82 AC, and the encoding for 'a' is 61.  
        %
        %         >> QueryParameter('foo=b %61%20r+%e2%82%ac')
        %         ans = 
        %            QueryParameter with properties:
        % 
        %                Name: "foo"
        %               Value: "b a r €"
        %              Format: csv     
        %         >> string(ans)
        %         ans = 
        %         foo=b+a+r+%E2%82%AC
        %
        %     The above produces the same result as using these NAME,VALUE arguments:
        % 
        %        >> QueryParameter('foo','b a r €')
        %
        % See also Name, Value, Format, string, char, ArrayFormat, URI
        
        % Undocumented behavior for internal use only:
        %
        %   QPs = QueryParameter(___, 'literal') treats the inputs as literal
        %     (pre-encoded) strings, and prevents the string method from encoding them
        %     again.  If present, the 'literal' argument must be last.
        %
        
        % Undocumented behavior for internal use only:
        %   QueryParameter(CELLARRAY) is the same as QueryParameter(CELLARRAY{:})
            import matlab.net.*
            if nargin > 0
                if nargin == 1 && (isempty(varargin{1}) || iscell(varargin{1}))
                    if isempty(varargin{1})
                        % Accept [] as only argument
                        obj = QueryParameter.empty;
                    else
                        obj = QueryParameter(varargin{1}{:});
                    end
                else
                    % if we see 'literal' as the last arg, remember that
                    lastArg = varargin{end};
                    if ((ischar(lastArg) && isvector(lastArg)) || ...
                            (isstring(lastArg) && isscalar(lastArg))) && strcmpi(lastArg,'literal')
                        literalArg = lastArg;
                        varargin(end) = [];         % erase the 'literal' arg
                    else
                        literalArg = [];
                    end
                    arrayFormat = varargin{end};
                    if isa(arrayFormat, 'matlab.net.ArrayFormat')
                        % it's really literal if 'literal' follows ArrayFormat
                        literal = ~isempty(literalArg);
                        varargin(end) = []; % erase ArrayFormat and 'literal' args
                    else
                        % no ArrayFormat, so use default
                        arrayFormat = ArrayFormat.csv;
                        literal = false; % don't know yet if literalArg is really 'literal' or value of the last parameter
                    end
                    if isempty(varargin) 
                        obj = QueryParameter.empty;
                        return;
                    end
                    % now varargin contains all the arguments minus ArrayFormat and, if the last arg
                    % was 'literal', literalArg is its value
                    firstArg = varargin{1};
                    if (isstring(firstArg) || ischar(firstArg)) && ...
                       (length(varargin) == 1 && (isempty(literalArg) || ...
                                                  (startsWith(firstArg,'?') || any(contains(firstArg,["&" "="])))))
                        % One nonempty argument, or two args where the second is 'literal' and the first
                        % begins with '?' or contains & or =.  Treat the first arg as a QUERYSTR.  While
                        % 'literal' with QUERYSTR is redundant, we don't want to disallow it.  This
                        % handles ("foo=bar","literal") as expected, but will interpret
                        % ("foo","literal") as name,value pair "foo=literal" instead of "foo", which may
                        % not be what the user expected, but a lone "foo" doth not a valid query make
                        % anyway.
                        value = matlab.net.internal.getString(firstArg, mfilename, 'query string');
                        if strlength(value) == 0
                            obj = QueryParameter.empty;
                        else
                            % Parse the string
                            % skip leading '?', if any
                            if value.startsWith('?')
                                value = value.extractAfter(1);
                            end
                            % split value into name/value pairs of params, at = and &
                            % and get QueryParameter array
                            parsed = regexp(value, ...
                                            '([^=&]*)(=?)([^&]*)?(?:&|$)+', 'tokens');
                            % params is cell array of 3-element string vectors, containing
                            % [name, equals, value] where equals is "=" or "" depending on
                            % presence of an "=" sign.  Create cell array of name,value
                            % pairs, setting value to [] if there was no "=".
                            params{length(parsed)*2} = [];
                            for i = 1 : length(parsed)
                                paramx = 2*i;
                                if ~isempty(literalArg)
                                    params{paramx-1} = parsed{i}(1);
                                else
                                    params{paramx-1} = matlab.net.internal.urldecode(parsed{i}(1),true);
                                end
                                if strlength(parsed{i}(2)) == 0
                                    params{paramx} = [];
                                elseif ~isempty(literalArg)
                                    params{paramx} = parsed{i}(3);
                                else
                                    params{paramx} = matlab.net.internal.urldecode(parsed{i}(3),true);
                                end
                            end
                            if ~isempty(literalArg) || literal
                                obj = QueryParameter(params{:},'literal');
                            else
                                obj = QueryParameter(params{:});
                            end
                        end
                    else
                        % More than one argument or arg isn't a string, expect a struct or NAME,VALUE
                        if length(varargin) == 1 && isstruct(firstArg)
                            % if first and only arg is a struct, convert to NAME,VALUE arglist
                            validateattributes(firstArg, {'struct'}, {'scalar'}, mfilename);
                            fn = fieldnames(firstArg);
                            len = 2*length(fn);
                            if ~isempty(literalArg)
                                literal = true;
                            end
                            args(2:2:len) = struct2cell(firstArg);
                            args(1:2:len) = fn;
                        else
                            args = varargin;
                        end
                        if ~literal && ~isempty(literalArg)
                            % If we haven't set literal yet and the last arg was 'literal',
                            % see if it means literal mode or should be the value of the last name,value
                            % pair
                            if mod(length(args),2) == 0 
                                % if even number of args left and we saw 'literal' at end, 
                                % set Literal mode for sure
                                literal = true;
                            else
                                % if odd number of args, 'literal' is the value of the last pair
                                % so put it back on the arg list
                                args{end+1} = literalArg;
                            end
                        end
                        % Assign back to front
                        if isscalar(args) && strcmp(args{1},'')
                            % this case can arise from a statement like:
                            %  QueryParameter("", ArrayFormat.csv, 'literal')
                            obj = QueryParameter.empty;
                        else
                            for i = length(args) + mod(length(args),2) : -2 : 2
                                i2 = i/2;
                                % Assign Name first, as this will error out if name isn't stringifiable
                                obj(i2).Name = args{i-1};
                                if i > length(args)
                                    % No value for last Name (odd number of arguments)
                                    if literal
                                        % OK, put name in value and leave name empty
                                        % This will cause it to encode as just a value 
                                        % instead of "name=" or "=value"
                                        obj(i2).Value = obj(i2).Name;
                                        obj(i2).Name = "";
                                    else
                                        error(message('MATLAB:http:MissingValueForParam', char(obj(i2).Name)));
                                    end
                                else
                                    obj(i2).Value = args{i};
                                end
                                obj(i2).Format = arrayFormat;
                                obj(i2).Literal = literal;
                            end
                        end
                    end
                end
            end
        end
        
        function res = string(obj)
        % string Return the QueryParameter as an encoded string
        %   STR = string(OBJ) converts the QueryParameter to a string of the form
        %   "name=value" where the name is the Name property and the value is the
        %   stringified Value property.  If the Value is a cell array or non-scalar
        %   other than a character vector, it will be converted based on the Format
        %   property, which may result in multiple name=value pairs separated by the "&"
        %   character and including other punctuation.  In addition, if 'literal' was
        %   not specified in the constructor, any special characters in Name or Value
        %   not permitted in a query are percent-encoded, except that a space is encoded
        %   as '+' (see the QUERYSTR argument to the QueryParameter constructor for more
        %   information on encoding).
        %
        %   If OBJ is a vector of QueryParameter, returns a single string joining the
        %   encoded members with '&'.
        %
        %   If OBJ is empty, returns "".
        %
        % See also Name, Value, Format, ArrayFormat, matlab.net.QueryParameter.QueryParameter
        
        % Undocumented behavior: In addition, if 'literal' was
        %   not specified in the constructor, any special characters in Name or Value
        %   not permitted in a query are percent-encoded, except that a space is encoded
        %   as '+' (see the QUERYSTR argument to the QueryParameter constructor for more
        %   information on encoding).
            if isempty(obj)
                res = "";
                return;
            end
                
            validateattributes(obj,{'matlab.net.QueryParameter'},{'vector'},mfilename);
            
            if isscalar(obj)
                % handle the scalar obj case.
                if obj.Literal
                    name = obj.Name;
                else
                    name = queryEncode(obj.Name);
                end
                % value may be any type; need to convert it to string before encoding
                value = obj.Value;
                if isempty(value) && ~ischar(value) && ~iscell(value)
                    % This is the case where Value is any empty array other than ''
                    % or {}.  It gets just the Name with no '=' sign.  This will
                    % not error out even if value is not a type we support (e.g., an
                    % empty struct array or table with no values).
                    res = name;
                else
                    % Get vector of strings by converting value array to strings.
                    % This may return a string scalar or string vector, URL-encoded.
                    values = convert(obj.Name, value, obj.Literal);
                    if isscalar(values) && ~iscell(value)
                        % if we have a scalar not in a cell, we're done. If Literal specified and there
                        % is no name, just use value without the "=".
                        if obj.Literal && name == ""
                            res = values;
                        else
                            res = name + '=' + values;
                        end
                    else
                        % Non-scalar values or any value in cell require use of
                        % ArrayFormat.  If value was {}, we'll get here with values =
                        % string.empty.
                        import matlab.net.ArrayFormat
                        % Add appropriate punctuation for arrays.  The characters =&, are in
                        % sub-delims which are allowed in pchar, but [] are not, so they need to be
                        % encoded.
                        switch obj.Format
                            case ArrayFormat.repeating
                                % name=v1&name=v2&name=v3...  or "" if string.empty
                                res = strjoin(name + '=' + values, '&');
                            case ArrayFormat.csv
                                % name=v1,v2,v3... or "name=" if string.empty
                                res = name + '=' + strjoin(values, ',');
                            case ArrayFormat.json
                                % name=[v1,v2,v3...] or "name=[]" if string.empty
                                res = name + '=%5B' + strjoin(values, ',') +'%5D';
                            case ArrayFormat.php
                                % name[]=v1&name[]=v2&name[]=v3... or "" if string.empty
                                res = strjoin(name + '%5B%5D=' + values, '&');
                        end
                    end
                end
            else
                res = arrayfun(@string, obj, 'UniformOutput', false);
                res = strjoin([res{:}], '&');
            end
        end
        
        function str = char(obj)
        % char Return the encoded QueryParameter as a character vector
        %   For more information, see the string method.
        %
        % See also string
            str = char(string(obj));
        end
        
        function tf = isequal(obj,other)
        % isequal Compare QueryParameter arrays
        %   TF = isequal(QP1,AP2) returns true if the stringified QueryParameter arrays
        %   QP1 and QP2 return the same strings.
            tf = isa(other,'matlab.net.QueryParameter');
            if tf 
                tf = isempty(obj) && isempty(other);
                if ~tf
                    % not both empty
                    tf = string(obj) == string(other);
                    if isempty(tf)
                        % tf is [] if either was empty
                        tf = false;
                    end
                end
            end
        end
    end
end

function strings = convert(name, values, literal)
% Convert the array of values to a vector of URL-encoded strings.  Values can be
% numerous types, including cell arrays.  Any empty members of values (e.g., if it's
% a cell array with empty elements) become "".  However, if values is a char array,
% each row is treated as one element.
%
% If values is [], returns "".  If values is {}, returns string.empty.  The input
% value of [] would not occur on the call from QueryParameter, but could on the
% recursive call below when a member of a cell array is [].
%
% We try to be liberal about what we accept as values, attempting to convert numbers
% to strings and even invoking the string or char function in case those are
% implemented for the type of values.  The length of strings is not necessarily equal
% to the length of values if calling string or char on the entire values array
% returns more or fewer strings than the length of values.  

    if isempty(values) 
        if isnumeric(values)
            strings = "";
            return
        elseif iscell(values)
            strings = string.empty;
            return
        end
    end
    if isa(values, 'datetime') 
        % datetime gets special processing
        if any(isnat(values))
            error(message('MATLAB:http:NaTNotAllowed',char(name)));
        end
        if isnan(tzoffset(values))
            % Make sure datetimes have time zones, just in case they have a
            % Format that requires it.  Otherwise we'd get *** in the output
            % which would surely cause problems with servers.  Note the TimeZone
            % property applies to the whole array, not just to individual
            % members.
            values.TimeZone = 'local';
        end
        strings = string(char(values)); % TBD remove char when datetime supports string
    else
        try
            % First, just try to convert the whole ball of wax using the string function.
            % This will do the right thing for string, real numeric, logical and char
            % arrays, cellstrs and numeric arrays. 

            % TBD For numbers or logicals, it's not compatible with webread/webwrite, the
            % old urlencode behavior. To get existing tests to pass, we need to use
            % num2str instead.  Not clear whether to preserve this legacy behavior or
            % not.
            if isnumeric(values) || islogical(values)
                values = arrayfun(@num2str, values, 'UniformOutput', false);
            end
            if iscell(values) && any(cellfun(@isempty, values))
                throw(MException('a:b','c')); % go to catch block if any empty cells
            end
            strings = string(values);
        catch 
            % Conversion failed; see if char works.  
            try
                strings = string(char(values));
            catch e
                if startsWith(e.identifier, "MATLAB:http")
                    % let HTTP errors (those created by classes in the http packages)
                    % get thrown normally, as this is the error the user would
                    % expect.
                    throw(e);
                end

                % Neither string nor char works.  It must be a cell array other than
                % cellstr; or a non-scalar for a type on which string/char only works
                % for scalars, or a type for which nothing works.
                if iscell(values) || ~isscalar(values)
                    % convert cell members or non-scalar members individually
                    if iscell(values)
                        fun = @cellfun;
                    else
                        fun = @arrayfun;
                    end
                    % Convert each member to string vector.  Note members could
                    % themselves be arrays, cell arrays, or empty.
                    res = fun(@(v)convert(name,v,literal), values, 'UniformOutput', false);
                    % If we get [], it means the value couldn't be converted to a
                    % string array or values was actually empty in the first place.
                    if isempty(res)
                        error(message('MATLAB:http:CannotConvertQueryToString', ...
                                  char(name), class(values)));
                    end
                    % concatenate results into one vector; allows cells to contain
                    % different length string vectors
                    strings = [res{:}];
                    % above convert call has already encoded each value, so done
                    return;
                elseif isnumeric(values) && ~isreal(values)
                    % complex scalar needs special conversion
                    strings = string(num2str(values));
                else
                    % if a scalar and we couldn't convert it using string or char, 
                    % unconvertible
                    error(message('MATLAB:http:CannotConvertQueryToString', ...
                                  char(name), class(values)));
                end
            end
        end
    end
    if ~isstring(strings) 
        % this case means that the call to string above returned something other than
        % string array -- unlikely but possible
        error(message('MATLAB:http:stringNotReturnString', char(name), ...
                      class(values), class(strings)));
    end
    % whatever we end up with, flatten to row vector and encode
    if literal
        strings = strings(:)';
    else
        strings = string(queryEncode(strings(:)'));
    end
end
    
function res = queryEncode(str)
% Encode a name or value in the query.  This is intended to encode the name or
% value so that it is preserved as the user entered it.  Encodes anything not
% a pchar or /?, as per RFC 3986.
%    query  = *( pchar / "/" / "?" )
% but also characters that mean something special in the query: & = +
% (It's not clear if servers treat an encoded &, = or + different from an
% unencoded one, but encoding them can't hurt.)
%
% This is a minimalist encoding: we don't encode some characters that other
% encoders like java.net.URLEncoder and Javascript's encodeURIComponent do,
% because those encoders are designed to encode any component of a URI, not just
% query names and values.  Here we try to encode only what's really necessary
% according to the RFC.
    persistent noEncodeChars
    if isempty(noEncodeChars)
        % characters not to encode start out with pchar
        % remove &=+ from pchar and add /? that query allows
        noEncodeChars = [regexprep(matlab.net.URI.Pchar, '[&=+]', '') '/?'];
    end
    res = matlab.net.internal.urlencode(str, noEncodeChars, true);
end




          
