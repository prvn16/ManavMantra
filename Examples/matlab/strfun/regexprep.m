%REGEXPREP Replace text using regular expression
%   S = REGEXPREP(STR,EXPRESSION,REPLACE) replaces all occurrences of the
%   regular expression, EXPRESSION, in the input argument, STR, with the text 
%   in REPLACE, and returns the resulting text as S. If no matches are found 
%   REGEXPREP returns STR unchanged. STR, EXPRESSION, and REPLACE can be
%   character vectors, strings arrays, or cell arrays of character vectors.
%
%   If STR is a string array or a cell array of character vectors, REGEXPREP 
%   returns an array of the same type, replacing each element of STR individually.
%
%   If EXPRESSION is a string array or a cell array of character vectors, REGEXPREP 
%   replaces each element of EXPRESSION sequentially.
%
%   If REPLACE is a string array or a cell array of character vectors, then EXPRESSION 
%   must be a string array or a cell array with the same number of elements.  REGEXPREP 
%   will replace each element of EXPRESSION sequentially with the corresponding element of 
%   REPLACE.
%
%   By default, REGEXPREP replaces all matches and is case sensitive.  Available
%   options are:
%
%           Option   Meaning
%   ---------------  --------------------------------
%     'ignorecase'   Ignore case of characters when matching EXPRESSION to STR.               
%   'preservecase'   Ignore case when matching (as with 'ignorecase'), but
%                       override the case of REPLACE characters with the case of
%                       corresponding characters in STR when replacing.
%           'once'   Replace only the first occurrence of EXPRESSION in STR.
%               N    Replace only the Nth occurrence of EXPRESSION in STR.
%
%   Example:
%      str = 'My flowers may bloom in May';
%      pat = 'm(\w*)y';
%      regexprep(str, pat, 'April')
%         returns 'My flowers April bloom in May'
%
%      str = 'My flowers may bloom in May';
%      pat = 'm(\w*)y';
%      regexprep(str, pat, 'April', 'ignorecase')
%         returns 'April flowers April bloom in April'
%
%      str = "My flowers may bloom in May";
%      pat = 'm(\w*)y';
%      regexprep(str, pat, 'April', 'preservecase')
%         returns "April flowers april bloom in April"
%
%   REGEXPREP can modify REPLACE using tokens from EXPRESSION.  The 
%   metacharacters for tokens are:
%
%    Metacharacter   Meaning
%   ---------------  --------------------------------
%              $N    Replace using the Nth token from EXPRESSION
%         $<name>    Replace using the named token 'name' from EXPRESSION
%              $0    Replace with the entire match
%
%   To escape a metacharacter in REGEXPREP, precede it with a '\'.
%
%   Example:
%      str = 'I walk up, they walked up, we are walking up, she walks.'
%      pat = 'walk(\w*) up'
%      regexprep(str, pat, 'ascend$1')
%         returns 'I ascend, they ascended, we are ascending, she walks.'
%
%   REGEXPREP supports international character sets.
%
%   See also REGEXP, REGEXPI, REGEXPTRANSLATE, STRREP.
%

%
%   E. Mehran Mestchian
%   J. Breslau
%   Copyright 1984-2016 The MathWorks, Inc.
%
