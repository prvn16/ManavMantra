function s = extractAfter(str, pos)
% EXTRACTAFTER Extract substring after specified position
%    S = EXTRACTAFTER(STR, START_STR) returns a substring of STR that
%    starts with the character after the first occurrence of START_STR and
%    ends with the last character of STR.
%
%    S = EXTRACTAFTER(STR, POS) returns a substring of STR that starts
%    with the character after numeric position POS and ends with the last
%    character of STR. POS must be an integer between 0 and the number of
%    characters in STR.
%
%    NOTE: STR and START_STR can be string arrays, character vectors, or cell
%    arrays of character vectors. The output S has the same data type as
%    STR.
%
%    Examples:
%        STR = "The quick brown fox";
%        extractAfter(STR,'quick ')
%
%        returns 
%
%            "brown fox"
%
%        STR = 'peppers and onions';
%        extractAfter(STR,12)
%
%        returns
%
%            'onions'
%
%    See also EXTRACTBEFORE, EXTRACTBETWEEN

%   Copyright 2016-2017 The MathWorks, Inc.

    narginchk(2, 2);
    if ~isTextStrict(str)
        firstInput = getString(message('MATLAB:string:FirstInput'));
        error(message('MATLAB:string:MustBeCharCellArrayOrString', firstInput));
    end

    try
        s = string(str);
        s = s.extractAfter(pos);
        s = convertStringToOriginalTextType(s, str);
        
    catch E
        throw(E);
    end
end
