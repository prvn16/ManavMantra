function s = replace(str, old, new) 
%REPLACE Replace segments from string elements
%   NEWSTR = REPLACE(STR,OLD,NEW) replaces all occurrences of OLD in STR
%   with NEW.
%
%   STR, OLD, and NEW can be string arrays, character vectors, or cell
%   arrays of character vectors. If OLD is a character vector, then NEW
%   must be a character vector, or a string array or cell array with one
%   element. If OLD is a string array or cell array, then NEW must be a
%   character vector, a string array or cell array that is the same size as
%   OLD, or a string array or cell array with one element. All
%   nonoverlapping occurrences of each element of OLD in STR are replaced
%   by the corresponding element of NEW.
%
%   If STR and OLD are string arrays or cell arrays, and both contain a
%   string with no characters (""), then REPLACE does not replace "" with
%   the contents of NEW.
%
%   Example:
%       claim = 'This is a good example';
%       new_claim = replace(claim,'good','great')
%
%       returns
%
%           'This is a great example.'
%
%   Example:
%       c_files = ["c:\cookies.m";
%                  "c:\candy.m";
%                  "c:\calories.m"];
%       d_files = replace(c_files,'c:','d:')
%
%       returns
%
%           "d:\cookies.m"
%           "d:\candy.m"
%           "d:\calories.m"
%
%   Example: 
%       STR = ["Submission Date: 11/29/15\r";
%              "Acceptance Date: 1/20/16\r";
%              "Contact: john.smith@example.com\r\n"];
%       OLD = {'\r\n','\r'};
%       NEW = '\n';
%       replace(STR,OLD,NEW)
%
%       returns
%
%           "Submission Date: 11/29/15\n"
%           "Acceptance Date: 1/20/16\n"
%           "Contact: john.smith@example.com\n"
%    
%   See also STRREP, REGEXP, REGEXPREP.

%   Copyright 2015-2017 The MathWorks, Inc. 

    narginchk(3, 3);
    
    if ~isTextStrict(str)
        error(fillMessageHoles('MATLAB:string:MustBeCharCellArrayOrString',...
                               'MATLAB:string:FirstInput'));
    end

    try
        s = string(str);
        s = s.replace(old, new);
        s = convertStringToOriginalTextType(s, str);
        
    catch ex
        if strcmp(ex.identifier, 'MATLAB:string:CannotConvertMissingElementToChar')
            error(fillMessageHoles('MATLAB:string:CannotInsertMissingIntoChar',...
                                   'MATLAB:string:MissingDisplayText'));
        end
        ex.throw;
    end

end 
