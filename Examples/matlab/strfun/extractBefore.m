function s = extractBefore(str, pos)
% EXTRACTBEFORE Extract substring before specified position
%    S = EXTRACTBEFORE(STR, END_STR) returns a substring of STR that starts
%    with the first character of STR and ends with the last character
%    before the first occurrence of END_STR.
%
%    S = EXTRACTBEFORE(STR, POS) returns a substring of STR that begins
%    with the first character of STR and ends with the last character
%    before the numeric position specified by POS. POS must be an integer
%    between 1 and the number of characters in STR.
%
%    NOTE: STR and END_STR can be string arrays, character vectors, or cell
%    arrays of character vectors. The output S has the same data type as
%    STR.
%
%    Examples:
%        STR = "The quick brown fox";
%        extractBefore(STR,' brown')
%
%        returns 
%
%            "The quick"
%
%        STR = 'peppers and onions';
%        extractBefore(STR,8)
%
%        returns
%
%            'peppers'
%
%    See also EXTRACTAFTER, EXTRACTBETWEEN

%   Copyright 2016-2017 The MathWorks, Inc.

    narginchk(2, 2);
    if ~isTextStrict(str)
        firstInput = getString(message('MATLAB:string:FirstInput'));
        error(message('MATLAB:string:MustBeCharCellArrayOrString', firstInput));
    end

    try
        s = string(str);
        s = s.extractBefore(pos);
        s = convertStringToOriginalTextType(s, str);
        
    catch E
        throw(E);
    end
end
