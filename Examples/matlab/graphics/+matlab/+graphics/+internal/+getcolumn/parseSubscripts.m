function [success, dim1, dim2, dim3] = parseSubscripts(subscriptstr)
% This function is undocumented and may change in a future release.

% This is a utility function for use by getcolumn.

%   Copyright 1984-2015 The MathWorks, Inc.

% Subscript string is a non-empty string enclosed by ()
% Remove parentheses to extract the subscript.
% Remove spaces from front and back
subscriptstr = strtrim(subscriptstr(2:end-1));

% Parse exprArgs into 3 subexpressions that represent
% subscripts for dimension 1, dimension 2, and subsequent
% dimensions. Dimensions 2 and subsequent dimensions, if
% non-empty, begin with a comma.

% The full regular expression breaks down like this:
%
% ^ - The full expression must start at start of the string
%
% subexp - First dimension. See subexpression breakdown below.
%
% (,subexp)? - Second dimension. Zero or one occurance of a
%              comma followed by the subexpression.
%
% (,subexp)*? - Subsequent dimensions. Zero or more occurances
%               of a comma followed by the subexpression.
%
% $ - The full expression must end at the end of the string.

% The sub-expression (individual subscript for a single
% dimension) must match of the following two options:
%
% (([0-9: ]|end)+?)
%     The characters 0-9, colon, space, or "end" occuring one
%     or more times (lazy).
%
% or
%
% (\[([0-9,;: ]|end)+?\])
%     The characters 0-9, comma, semicolon, colon, or "end"
%     occuring zero or more times enclosed in square brackets.
subexp = '( *((([0-9: ]|end)+?)|(\[([0-9,;: ]|end)*?\])) *)';
fullexp = ['^' subexp '(,' subexp ')?(,' subexp ')*?$'];

tokens = regexp(subscriptstr,fullexp,'once','tokens');
if ~isempty(tokens)
    dim1 = strtrim(tokens{1});
    dim2 = strtrim(tokens{2}(2:end));
    dim3 = strtrim(tokens{3}(2:end));
    success = true;
else
    dim1 = '';
    dim2 = '';
    dim3 = '';
    success = false;
end

end
