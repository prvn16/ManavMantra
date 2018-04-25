function [success, head, field, tail] = parseExpression(expression)
% This function is undocumented and may change in a future release.

% This is a utility function for use by getcolumn.

%   Copyright 1984-2015 The MathWorks, Inc.

% Parse x in reverse for a word followed by optional fields followed by
% optional arguments enclosed by ().
% The regular expression breaks down like this:
%
% ^ - The expression must start at beginning of the string.
% 
% (\).*?\()? - Expression "tail": This is the subscripts at the end of the
%              expression, surrounded by parentheses. The "?" means zero or
%              one occurence of this pattern:
%
%     \).*?\( - Parentheses surrounding any number of any character (lazy)
%
% (.+[\.\(\{])? - Exression "field": This is the array, cell, or structure
%                 referencing to get to the target matrix from the variable
%                 name. For example: A.field.cellarray{1}.matrix
%
%     .+[\.\(\{] - At least one character ending with one of: .({
%
% (\w*[A-Za-z]) - Expression "head": This is the variable name. Any number
%                 of 'word' characters, but the last (first) character must
%                 be a letter.
%
% $ - The expression must end at the end of the string.

expression = fliplr(expression);
tokens = regexp(expression,'^(\).*?\()?(.+[\.\(\{])?(\w*[A-Za-z])$','once','tokens');

if ~isempty(tokens)
    % Record the subexpressions and trim any spaces from ends of string
    head = strtrim(fliplr(tokens{3})); % Variable name
    field = strtrim(fliplr(tokens{2})); % Array, cell, or structure referencing
    tail = strtrim(fliplr(tokens{1})); % Subscripts
    success = true;
else
    head = '';
    field = '';
    tail = '';
    success = false;
end

end
