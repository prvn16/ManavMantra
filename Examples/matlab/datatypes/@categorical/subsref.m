function b = subsref(a,s)
%SUBSREF Subscripted reference for a categorical array.
%     B = SUBSREF(A,S) is called for the syntax A(I).  S is a structure array
%     with the fields:
%         type -- Character vector containing '()' specifying the subscript type.
%                 Only parenthesis subscripting is allowed.
%         subs -- Cell array containing the actual subscripts.
%
%   See also CATEGORICAL/CATEGORICAL, SUBSASGN.

%   Copyright 2006-2016 The MathWorks, Inc.

% Make sure nothing follows the () subscript
if ~isscalar(s)
    error(message('MATLAB:categorical:InvalidSubscripting'));
end

switch s.type
case '()'
    b = a;
    b.codes = a.codes(s.subs{:});
case '{}'
    error(message('MATLAB:categorical:CellReferenceNotAllowed'))
case '.'
    error(message('MATLAB:categorical:FieldReferenceNotAllowed'))
end
