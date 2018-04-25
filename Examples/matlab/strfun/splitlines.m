function s = splitlines(str)
%SPLITLINES Split string at newline characters
%   NEWSTR = SPLITLINES(STR) splits the string STR at newline characters into 
%   a string array NEWSTR.
%
%   STR can be a string array, character vector, or a cell array of character
%   vectors. If STR is a string array then NEWSTR is a string array. Otherwise, 
%   NEWSTR is a cell array of character vectors.
%
%   NEWSTR = SPLITLINES(STR) is equivalent to calling SPLIT and specifying
%   newline characters as the delimiters to split upon, as in the code:
%       NEWSTR = split(STR,compose(string({'\r\n', '\n', '\r'})))
%
%   If STR contains literals such as '\n' to indicate newlines, then
%   convert the literals to actual newline characters with the COMPOSE
%   or SPRINTF functions. You also can add newline characters to strings with the
%   NEWLINE function.
%
%   Example:
%       STR = "Name:";
%       STR = STR + '\n' + 'Title:\n' + 'Company:';
%       STR = compose(STR);
%       splitlines(STR)
%
%       returns
%
%           "Name:"
%           "Title:"
%           "Company:"
%
%   Example:
%       STR = "In Xanadu did Kubla Khan";
%       STR = STR + newline + 'A stately pleasure-dome decree';
%       splitlines(STR)
%
%       returns
%
%           "In Xanadu did Kubla Khan"
%           "A stately pleasure-dome decree"
%
%   See also SPLIT, COMPOSE, NEWLINE, SPRINTF.

%  Copyright 2015-2016 The MathWorks, Inc.

    narginchk(1, 1);
    if ~isTextStrict(str)
        firstInput = getString(message('MATLAB:string:FirstInput'));
        error(message('MATLAB:string:MustBeCharCellArrayOrString', firstInput));
    end

    try
        s = string(str);
        s = s.splitlines;
        
        if ~isstring(str)
            s = cellstr(s);
        end
        
    catch E
       throw(E); 
    end
end
