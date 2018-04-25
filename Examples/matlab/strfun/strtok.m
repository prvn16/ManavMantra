function [token, remainder] = strtok(str, delimiters)
%STRTOK Split string into tokens.
%   [TOKEN,REMAIN] = STRTOK(STR) returns the first token in STR delimited
%   by whitespace characters and the rest of STR in REMAIN. STRTOK ignores
%   any leading whitespace. If STR is a cell array of character vectors,
%   TOKEN is a cell array of tokens. If STR is a string array, TOKEN is a
%   string array.
%
%   TOKEN = STRTOK(STR,DELIMITER) returns the first token delimited by one
%   of the characters in DELIMITER. STRTOK ignores any leading delimiters.
%   Do not use escape sequences as delimiters.  For example, use char(9)
%   rather than '\t' for tab.
%
%   If the input does not contain any delimiter characters, STRTOK returns
%   the entire input in TOKEN (excluding any leading delimiter characters),
%   and REMAIN contains text with no characters.
%
%   NOTE: Inputs STR and DELIMITER can be string arrays, character vectors
%   or cell arrays of character vectors. When STR is a string array outputs
%   TOKEN and REMAIN are string arrays. Otherwise TOKEN and REMAIN are cell
%   arrays of character vectors.
%
%   Example:
%
%       s = '  This is a simple example.';
%       [token, remain] = strtok(s)
%
%   returns
%
%       token = 
%       This
%       remain = 
%        is a simple example.
%
%   See also SPLIT, extractBefore, extractAfter, extractBetween, REGEXP,
%   ISSPACE, STRFIND, STRCMP, TEXTSCAN

%   Copyright 1984-2016 The MathWorks, Inc.

    if nargin < 1 || nargin > 2
        narginchk(1, 2);
    end
    
    if nargin < 2
        delimiters = char([9:13, 32]); % White space characters
    elseif iscell(delimiters)
        delimiters = char([delimiters{:}]);
    elseif isstring(delimiters)
        delimiters(ismissing(delimiters)) = [];
        delimiters = char([delimiters{:}]);
    end

    computeRemainder = (nargout > 1);
    
    if iscell(str)
        token = str;
        remainder = str;
        for idx = 1:numel(str)
            [token{idx}, remainder{idx}] = doStrtok(str{idx}, delimiters, computeRemainder);
        end
    elseif isstring(str)
        token = str;
        remainder = str;
        for idx = 1:numel(str)
            if ismissing(str(idx))
                remainder(idx) = '';
                continue;
            end
            [token{idx}, remainder{idx}] = doStrtok(str{idx}, delimiters, computeRemainder);
        end
    else
        [token, remainder] = doStrtok(str, delimiters, computeRemainder);
    end

end

function [token, remainder] = doStrtok(str, delimiters, computeRemainder)

    token = str([]);
    remainder = token;

    len = length(str);
    if len == 0
        return;
    end

    idx = 1;
    while (any(str(idx) == delimiters))
        idx = idx + 1;
        if (idx > len)
           return;
        end
    end

    start = idx;
    while (~any(str(idx) == delimiters))
        idx = idx + 1;
        if (idx > len)
           break;
        end
    end
    finish = idx - 1;

    token = str(start:finish);
    if computeRemainder && finish < len
        remainder = str(finish + 1:len);
    end

end
