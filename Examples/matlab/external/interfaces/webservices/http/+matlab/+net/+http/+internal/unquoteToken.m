function value = unquoteToken(value)
% Remove quotes and escapes within quotes or parens from a string and returns it.
%   Accepts only string, not char.  This is typically used to convert a quoted string
%   or comment in an HTTP header field to unquoted form for internal processing.  It
%   basically undoes what quoteToken does, but also removes escapes from comments
%   while leaving the () surrounding comments.

% Copyright 2015 The MathWorks, Inc.

    %   If value contains any double-quoted strings, remove the quotes and,
    %   within the quotes, remove backslashes from backslash-escaped characters.
    %   Process comments (surrounded by open-closed parentheses) the same way,
    %   except preserve the parentheses.  If the quotes and parens can be trusted
    %   to completely surround the value, checking the first character of the
    %   result can tell you whether the string is a comment or not.
    %
    %   We don't expect to see a quoted or commented substring inside a value, rather
    %   than completely enclosing it.  If we did get one of those, removal of the
    %   quotes and escapes could yield ambiguous results; for example:
    %               a=foo", b=bar"
    %   would return:
    %               a=foo, b=bar  
    %   which can make the string say something completely different from what
    %   was intended if comma processing was subsequently applied. This
    %   particular problem doesn't occur in the normal case because we only apply
    %   this function to individual values within strings _after_ having parsed
    %   them for array and struct delims, so the ambiguity only affects parsing
    %   that would happen after that (something only subclasses might do).
    qchar = '';
    i = 1;
    while i <= strlength(value)
        ch = extractBetween(value,i,i);
        if ch == qchar
            % end of quotes or comment
            qchar = '';
            if ch == '"'
                value = eraseBetween(value,i,i); % remove close quote
            else
                i = i + 1;
            end
        elseif ch == '"'
            % start of quotes
            value = eraseBetween(value,i,i);     % remove open quote
            qchar = ch;
        elseif ch == '('
            % start of comment
            qchar = ')';
            i = i + 1;
        elseif ~isempty(qchar)
            % inside quotes, remove backslash and skip next char
            if ch == '\';
                value = eraseBetween(value,i,i);
            end
            i = i + 1;
        else
            i = i + 1;
        end
    end
end

