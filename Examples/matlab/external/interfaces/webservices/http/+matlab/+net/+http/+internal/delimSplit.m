function strings = delimSplit(str, delims) 
% delimSplit splits a string at delims and return vector of strings
%   This function is an assist for HTTP header field parsing to break up a string
%   into either array elements (typically separated by commas) and parameters
%   (typically separated by semicolons).  It allows for quoted strings and comments
%   in parens, and escaped characters in them.  It ignores characters in quoted
%   strings and comments and trims whitespace around strings and throws out ones with
%   all whitespace (thus ignoring consecutive delims).
%
%   str     the string or char vector to split 
%   delims  a cellstr or string vector of delimiters, as regular expressions
%
% Returns array of strings.  
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/http. Its behavior
%   may change, or the function itself may be removed in a future release.

% Copyright 2015-2017 The MathWorks, Inc.    

    persistent expr quotes parens
    if isempty(expr)
        quotes = '"(\\.|.)*?"';    % matches "quoted strings" with backslash escapes
        parens = '\((\\.|.)*?\)';  % matches (commented strings) with b.s. escapes
        other = '.';               % matches all other strings
        % expr matches 1 or more of any of above followed by delims, capturing only
        % the part that doesn't match delims
        expr = string(['((' quotes '|' parens '|' other ')*?']);
    end
    if isempty(delims) || (isstring(delims) && all(strlength(delims) == 0)) 
        delimExp = ')$'; 
    else
        if iscell(delims) || (isstring(delims) && ~isscalar(delims))
            % stringify and remove empty strings
            delims = string(delims);
            delims = strjoin(delims(strlength(delims) ~= 0), '|');
        else
            delims = string(delims);
        end
        % This looks ahead for delimiter or end of line and skips over it without
        % capture.  
        delimExp = '(?=(\s*' + delims + '\s*|$)))\s*(?:' + delims + ')?\s*'; 
    end
    % this gives cell array of strings, one string per cell, containing elements
    % between delimiters
    if ischar(str)
        str = string(str);
    end
    strings = regexp(str, expr + delimExp, 'tokens'); 
    if isempty(strings)
        strings = str;
    else
        % extract strings from the (1) element of each cell and save nonempty ones
        strings = [strings{~cellfun(@(x)eq(x(1),''), strings)}];
    end
end        
