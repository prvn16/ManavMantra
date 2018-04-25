%STRING Convert to string array 
%   STR = STRING creates a string. STR is a 1-by-1 string that contains no
%   characters.
%
%   STR = STRING(CHR) converts character vector CHR to string array STR.
%   If CHR is a 1-by-N character vector then STRING returns STR as a 1-by-1
%   string that contains N characters.
% 
%   STR = STRING(C) converts cell array C to a string array. Each element
%   of C must contain a value that can be converted to a string scalar. STR
%   is the same size as C.
%
%   STR = STRING(X) converts the numeric matrix X into a string
%   representation STR. STR is the same size as X.
%
%   STR = STRING(TF) converts the logical matrix TF into a string
%   representation STR where each element of STR contains either "true" or
%   "false". STR is the same size as TF.
%
%   MATLAB displays string values with double quotes (for example, "ABC"),
%   and character arrays with single quotes (for example, 'ABC'), to
%   distinguish the two different data types.
%
%   STRING methods and functions:
%      STRING inspection:
%         contains           - True if pattern is found in string
%         count              - Number of occurrences of a pattern
%         endsWith           - True if string ends with pattern
%         ismissing          - True for <missing> string elements
%         isstring           - True for string array
%         startsWith         - True if string starts with pattern
%         strlength          - Lengths of string elements
%      STRING manipulation:
%         compose            - Converts data into formatted string arrays
%         erase              - Remove substring from string elements
%         eraseBetween       - Remove bounded substrings
%         extractAfter       - Extract substring after a specified position
%         extractBefore      - Extract substring before a specified position
%         extractBetween     - Extract bounded substrings
%         insertAfter        - Insert substring after a specified position
%         insertBefore       - Insert substring before a specified position
%         join               - Append elements of a string array together
%         lower              - Convert string to lowercase
%         pad                - Insert leading or trailing spaces
%         plus               - Append string arrays
%         replace            - Find and replace substring
%         replaceBetween     - Replace bounded substrings
%         reverse            - Reverse the order of characters
%         split              - Split string at delimiter
%         splitlines         - Split string at newlines
%         strings            - Create string array of empty string elements
%         strip              - Remove leading and trailing whitespaces
%         upper              - Convert string to uppercase
%      STRING conversion:
%         cellstr            - Convert to a cell array of character vectors
%         char               - Convert to a character array
%         double             - Convert to a double array
%      STRING operators:
%         +                  - Append string arrays
%         ==, ~=             - Equal and not equal for string arrays
%         <, <=, >, >=       - Comparison for string arrays
%         {}                 - Index character vector contents of string element
%
%   STRING compatible functions:
%      deblank            - Remove trailing whitespaces
%      regexp             - Match regular expression
%      regexprep          - Replace string using regular expression
%      regexptranslate    - Regular expression related string transformations
%      sprintf            - Write formatted data to string
%      strcat             - Concatenate text
%      strcmp             - Compare strings
%      strncmp            - Compare first N characters
%      strfind            - Find one string within another
%      strjoin            - Append elements of a string array together
%      strsplit           - Split string at delimiter
%      strtrim            - Remove whitespace
%
%   Example:
%       CHR = 'Four score and seven years ago';
%       string(CHR)        
%
%       returns
%
%           "Four score and seven years ago"
%
%   Example:
%       C = {'Four score and seven equals';87};
%       string(C)  
%
%       returns
%
%           "Four score and seven equals"
%           "87"
%
%   Example:
%       STR = ["Mercury","Gemini"];
%       STR(2,1) = 'Apollo'
%
%       returns
%
%           "Mercury"    "Gemini" 
%           "Apollo"     <missing>
%       
%   Example:
%       STR = ["Mercury","Gemini","Apollo"];
%       STR == 'Apollo'
%
%       returns
%
%          0   0   1
%
%   See also STRLENGTH, ISSTRING, CHAR, CELLSTR, STRINGS

%   Copyright 2014-2016 The MathWorks, Inc.
