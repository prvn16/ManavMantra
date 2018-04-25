%REGEXP Match regular expression
%   S = REGEXP(STR,EXPRESSION) matches the regular expression, EXPRESSION, in
%   the input argument, STR.  The indices of the beginning of the matches are 
%   returned. STR and EXPRESSION can be character vectors, string arrays,
%   or cell arrays of character vectors.
%
%   S = REGEXP(STR,EXPRESSION,'forceCellOutput') returns S as a cell array
%   in all cases, even when the output would otherwise be returned as a numeric 
%   array, character vector, or a string array. In those cases, the
%   numeric array, character vector, or string array is contained within a scalar cell.
%   
%   In EXPRESSION, patterns are specified using combinations of metacharacters 
%   and literal characters.  There are a few classes of metacharacters, 
%   partially listed below.  More extensive explanation can be found in the 
%   Regular Expressions section of the MATLAB documentation.
%
%   The following metacharacters match exactly one character from its respective 
%   set of characters:  
%
%    Metacharacter   Meaning
%   ---------------  --------------------------------
%               .    Any character
%              []    Any character contained within the brackets
%             [^]    Any character not contained within the brackets
%              \w    A word character [a-z_A-Z0-9]
%              \W    Not a word character [^a-z_A-Z0-9]
%              \d    A digit [0-9]
%              \D    Not a digit [^0-9]
%              \s    Whitespace [ \t\r\n\f\v]
%              \S    Not whitespace [^ \t\r\n\f\v]
%
%   The following metacharacters are used to logically group subexpressions or
%   to specify context for a position in the match.  These metacharacters do not
%   match any characters in STR:
%  
%    Metacharacter   Meaning
%   ---------------  --------------------------------
%             ()     Group subexpression
%              |     Match subexpression before or after the |
%              ^     Match expression at the start of STR
%              $     Match expression at the end of STR
%             \<     Match expression at the start of a word
%             \>     Match expression at the end of a word
%
%   The following metacharacters specify the number of times the previous
%   metacharacter or grouped subexpression may be matched:
%   
%    Metacharacter   Meaning
%   ---------------  --------------------------------
%              *     Match zero or more occurrences
%              +     Match one or more occurrences
%              ?     Match zero or one occurrence
%           {n,m}    Match between n and m occurrences
%
%   Characters that are not special metacharacters are all treated literally in
%   a match.  To match a character that is a special metacharacter, escape that
%   character with a '\'.  For example '.' matches any character, so to match
%   a '.' specifically, use '\.' in your pattern.
%
%   Example:
%      str = 'bat cat can car coat court cut ct caoueouat';
%      pat = 'c[aeiou]+t';
%      regexp(str, pat)
%         returns [5 17 28 35]
%
%      regexp(str, pat, 'forceCellOutput')
%         returns {[5 17 28 35]}
%
%   When one of STR or EXPRESSION is a string array or a cell array of character 
%   vectors, REGEXP matches the scalar input with each element of the array input.
%
%   Example:
%      str = ["Madrid, Spain","Romeo and Juliet","MATLAB is great"];
%      pat = '\s';
%      regexp(str, pat)
%         returns {[8]; [6 10]; [7 10]}
%
%   When both STR and EXPRESSION are string arrays or cell arrays of character 
%   vectors, REGEXP matches the elements of STR and EXPRESSION sequentially.  
%   The number of elements in STR and EXPRESSION must be identical.
%
%   Example:
%      str = {'Madrid, Spain' 'Romeo and Juliet' 'MATLAB is great'};
%      pat = {'\s', '\w+', '[A-Z]'};
%      regexp(str, pat)
%         returns {[8]; [1 7 11]; [1 2 3 4 5 6]}
%
%   REGEXP supports up to seven outputs.  These outputs may be requested 
%   individually or in combinations by using additional input keywords.  The 
%   order of the input keywords corresponds to the order of the results.  The 
%   input keywords and their corresponding results in the default order are:
%
%          Keyword   Result
%   ---------------  --------------------------------
%          'start'   Row vector of starting indices of each match
%            'end'   Row vector of ending indices of each match
%   'tokenExtents'   Cell array of extents of tokens in each match
%          'match'   Cell array or string array of the text of each match
%         'tokens'   Cell array or string array of the text of each token in each match
%          'names'   Structure array of each named token in each match
%          'split'   Cell array or string array of the text delimited by each match
%
%   If you specify 'match', 'tokens', or 'split', then REGEXP returns a
%   string array if STR is a string array, or a cell array if STR is a cell
%   array of character vectors.
%
%   Example:
%      str = 'regexp helps you relax';
%      pat = '\w*x\w*';
%      m = regexp(str, pat, 'match')
%         returns
%            m = {'regexp', 'relax'}
%
%   Example:
%      str = "regexp helps you relax";
%      pat = '\s+';
%      s = regexp(str, pat, 'split')
%         returns
%            s = ["regexp"    "helps"    "you"    "relax"]
%
%   Tokens are created by parenthesized subexpressions within EXPRESSION.
%
%   Example:
%      str = 'six sides of a hexagon';
%      pat = 's(\w*)s';
%      t = regexp(str, pat, 'tokens')
%         returns
%            t = {{'ide'}}
%
%   Named tokens are denoted by the pattern (?<name>...).  The 'names' result 
%   structure will have fields corresponding to the named tokens in EXPRESSION.
%
%   Example:
%      str = 'John Davis; Rogers, James';
%      pat = '(?<first>\w+)\s+(?<last>\w+)|(?<last>\w+),\s+(?<first>\w+)';
%      n = regexp(str, pat, 'names')
%         returns
%             n(1).first = 'John'
%             n(1).last  = 'Davis'
%             n(2).first = 'James'
%             n(2).last  = 'Rogers'
%
%   By default, REGEXP returns all matches.  To find just the first match, use
%   REGEXP(STR,EXPRESSION,'once').
%
%   REGEXP supports international character sets.
%
%   See also REGEXPI, REGEXPREP, REGEXPTRANSLATE, STRCMP, STRFIND.
%

%
%   E. Mehran Mestchian
%   J. Breslau
%   Copyright 1984-2016 The MathWorks, Inc.
%

