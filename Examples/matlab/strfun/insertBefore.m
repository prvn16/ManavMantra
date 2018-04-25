function s = insertBefore(str, pos, text)
% INSERTBEFORE Insert substring before specified position
%    S = INSERTBEFORE(STR, END_STR, NEW_TEXT) inserts NEW_TEXT into STR
%    before the substring specified by END_STR and returns the result as
%    S. If END_STR occurs multiple times in STR, then INSERTBEFORE inserts
%    NEW_TEXT before every nonoverlapping occurrence of END_STR.
%
%    S = INSERTBEFORE(STR, POS, NEW_TEXT) inserts NEW_TEXT directly before
%    numeric position POS. POS must be an integer between 1 and strlength(STR) + 1.
%
%    NOTE: STR, END_STR, and NEW_TEXT can be string arrays, character
%    vectors, or cell arrays of character vectors. The output S has the
%    same data type as STR.
%
%    Examples:
%        STR = "The quick fox jumps";
%        insertBefore(STR,' fox',' brown')
%
%        returns 
%
%            "The quick brown fox jumps"
%
%        STR = 'peppers and onions';
%        insertBefore(STR,'and','mushrooms ')
%
%        returns
%
%            'peppers mushrooms and onions'
%
%    See also INSERTAFTER, REPLACE, REPLACEBETWEEN, EXTRACTBEFORE,
%    EXTRACTAFTER, EXTRACTBETWEEN

%   Copyright 2016-2017 The MathWorks, Inc.

    narginchk(3, 3);
    
    if ~isTextStrict(str)
        error(fillMessageHoles('MATLAB:string:MustBeCharCellArrayOrString',...
                               'MATLAB:string:FirstInput'));
    end

    try
        s = string(str);
        s = s.insertBefore(pos, text);
        s = convertStringToOriginalTextType(s, str);
        
    catch ex
        if strcmp(ex.identifier, 'MATLAB:string:CannotConvertMissingElementToChar')
            error(fillMessageHoles('MATLAB:string:CannotInsertMissingIntoChar',...
                                   'MATLAB:string:MissingDisplayText'));
        end
        ex.throw;
    end

end
