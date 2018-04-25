function s = insertAfter(str, pos, text)
% INSERTAFTER Insert substring after specified position
%    S = INSERTAFTER(STR, START_STR, NEW_TEXT) inserts NEW_TEXT into STR
%    after the substring specified by START_STR and returns the result as
%    S. If START_STR occurs multiple times in STR, then INSERTAFTER inserts
%    NEW_TEXT after every nonoverlapping occurrence of START_STR.
%
%    S = INSERTAFTER(STR, POS, NEW_TEXT) inserts NEW_TEXT directly after
%    numeric position POS. POS must be an integer from 0 to the number of
%    characters in STR.
%
%    NOTE: STR, START_STR, and NEW_TEXT can be string arrays, character
%    vectors, or cell arrays of character vectors. The output S has the
%    same data type as STR.
%
%    Examples:
%        STR = "The quick fox";
%        insertAfter(STR,'quick',' brown')
%
%        returns 
%
%            "The quick brown fox"
%
%        STR = 'peppers and onions';
%        insertAfter(STR,'peppers ','mushrooms ')
%
%        returns
%
%            'peppers mushrooms and onions'
%
%    See also STRING/PLUS, INSERTBEFORE, REPLACE, REPLACEBETWEEN

%   Copyright 2016-2017 The MathWorks, Inc.

    narginchk(3, 3);

    if ~isTextStrict(str)
        error(fillMessageHoles('MATLAB:string:MustBeCharCellArrayOrString',...
                               'MATLAB:string:FirstInput'));
    end

    try
        s = string(str);
        s = s.insertAfter(pos, text);
        s = convertStringToOriginalTextType(s, str);
        
    catch ex
        if strcmp(ex.identifier, 'MATLAB:string:CannotConvertMissingElementToChar')
            error(fillMessageHoles('MATLAB:string:CannotInsertMissingIntoChar',...
                                   'MATLAB:string:MissingDisplayText'));
        end
        ex.throw;
    end
end
