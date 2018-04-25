function value = elementParser(str, allowsStruct, useStringMatrix, varargin)
% elementParser implements the behavior documented for
%   matlab.net.http.HeaderField.parseElement, to parse one "element" of a
%   comma-separated list of strings used in header field values.  Factored out here
%   because it is used in places other than HeaderField.  This throws exceptions if
%   the value could not be parsed.  Returns string.empty if str is empty.
%
%     elementParser(str, allowsStruct, useStringMatrix, structDelims, structFields)
%   
%   last two parameters are optional.  Default structDelims is ';' and whitespace. If
%   ~allowsStruct or structDelims is [], or strictDelims unspecified and str contains
%   no semicolons or = sign, don't process as struct.
%
%    useStringMatrix says how to process struct (elements containing name=value pairs)
%      true 
%        returns an n-by-2 matrix of strings containing names and values.  Unnamed
%        struct fields have empty names--structFields is ignored in this case.
%      false
%        returns a struct, with field names (using genvarname) and values.  Unnamed
%        struct fields have names taken from structFields or Arg_1 if missing.
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/http. Its behavior
%   may change, or the function itself may be removed in a future release.

% Copyright 2015-2017 The MathWorks, Inc.

    persistent whitespaceDelim
    if isempty(str)
        if useStringMatrix
            value = string.empty(0,2);
        else
            value = string.empty;
        end
        return
    end
    if ~isempty(varargin)
        structDelims = string(varargin{1});
        if length(varargin) > 1
            structFields = string(varargin{2});
        end
    end
    if ischar(str)
        str = string(str);
    end
    if ~useStringMatrix && (~allowsStruct ||  ...
       (isempty(varargin) && ~str.contains(';') && ~str.contains('=')) || ...
       (~isempty(varargin) && isempty(structDelims) && ~ischar(structDelims)))
        % structDelims is [] or unspecified, and string has no semicolons or =
        % This means string is plain value, not struct.
        value = matlab.net.http.internal.unquoteToken(str);
    else
        % structDelims specified, or unspecified and string has semicolons or =
        % always return struct (or string matrix).
        %
        % The default structDelims are ';' and whitespace.  The regexp for whitespace
        % considers whitespace a delimiter if it is not preceded by an = or followed by
        % an = (but not both).  It also does not treat a space as a delimiter if it
        % follows an = and the characters that follow the space appear to be the 
        % start of anohter name=value pair.  So in "a = b" or "a= b" or "a =b"
        % the spaces are not delimiters, but in "a b" or "a= =b" the space is a
        % delimiter.
        % 
        % For example in:  "a= b c = d e f=z= =g h= x=y"
        % all the spaces create new members except for the one after "a=" and those
        % in "c = d" because they have a single = either before or after, but not both:
        %     a: "b"
        %     c: "d"
        % Arg_3: "e"
        %     f: "z="
        % Arg_5: "=g"
        % Arg_6: "h="
        %     x: "y"
        % Note that the "h=" is considered to be the value of the unnamed parameter
        % Arg_6, not a parameter named "h" with no value.   It is necessary to interpret
        % this string as a value because trailing ='s are allowed in parameter values
        % that are base64-encoded (see basic-credentials in RFC 2617, section 2, for
        % example).
        if isempty(whitespaceDelim)
            whitespaceDelim = "(?<![=\s])\s+(?![=\s])|(?<==)\s+(?==)|(?<==)\s+(?=[" + ...
                              matlab.net.http.HeaderField.TokenChars + ...
                              "]+\s*=\s*[" + matlab.net.http.HeaderField.TokenChars + "])";
        end
        if isempty(varargin)
            structDelims = [";" whitespaceDelim];
        else
            % replace lone space or \s optionally by +, in structDelims with whitespaceDelim
            structDelims(structDelims == " " | structDelims == "\s" | ...
                         structDelims == " +" | structDelims == "\s+") = whitespaceDelim;
        end
        % Split string at the struct delim.  This gives us a fields array containing
        % each struct member. 
        fields = matlab.net.http.internal.delimSplit(str, structDelims); 
        names = strings(1,length(fields));
        if useStringMatrix
            value = strings(length(fields),2);
        else
            value = '';
        end
        if isscalar(fields) && ((isempty(structDelims) && ischar(structDelims)) || ...
                                (isstring(structDelims) && all(strlength(structDelims) == 0)))
            % if only one field and structDelims is '' or "", this means we don't
            % process the field for struct, so just return the value as a string
            value = matlab.net.http.internal.unquoteToken(fields);
            return;
        end
        % Now examine each member to see if it's of the form foo=bar
        for i = 1 : length(fields)
            % str is name and value of a field in the form foo=bar
            str = fields(i);
            % See if it's really a name-value pair. Most header field syntaxes only allow
            % BWS (bad whitespace) surrounding the = sign, which means we have to allow it,
            % but must not generated it.  In this parse, everything after the first = is the
            % value, but if all the ='s in the string are trailing, and the characters prior
            % to that belong to a certain subset, treat it as a single token.  This handles
            % a token68 string for base64 encoding (RFC 2045, section 6.8) which can have
            % trailing ='s for padding.  This regexp only extracts tokens for name=value and
            % rejects other matches.  We only recognize names containing token characters.
            nv = regexp(str, '^\s*[A-Za-z0-9+/]+=*$|^\s*([' + ...
                             matlab.net.http.HeaderField.TokenChars + ...
                             ']+?)\s*=\s*(.*)\s*$', 'tokens');
            % nv empty if there are no ='s
            % nv{1} empty if it's a base64 string with trailing ='s
            if isempty(nv) || isempty(nv{1}) 
                if ~useStringMatrix
                    % No = in field or just trailing =, its value is the whole field.  Give it
                    % the default name Arg_N or the name from structFields.
                    if length(varargin) < 2 || isempty(structFields) || ...
                        length(structFields) < i || isempty(structFields(i)) || strlength(structFields(i)) == 0
                        name = ['Arg_' num2str(i)];
                    else
                        name = structFields(i);
                    end
                else
                    % if useStringMatrix, name is empty
                    name = ''; 
                end
                val = matlab.net.http.internal.unquoteToken(str);
            else
                % if it had an =, have name and value in nv{1}
                name = nv{1}(1);
                val = matlab.net.http.internal.unquoteToken(nv{1}(2));
            end
            if useStringMatrix
                value(i,1) = name;
                value(i,2) = val; 
            else
                name = genvarname(name, names(1:i-1));
                % Create and set new struct field 
                value.(char(name)) = val;
                names(i) = name;
            end
        end
    end
end

