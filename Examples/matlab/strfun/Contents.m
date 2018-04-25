% Character arrays and strings.
%
% Conversion functions.
%   char           - Convert to a character array.
%   double         - Convert to a double array.
%   string         - Convert to a string array.
%   strings        - Create string array with no characters.
%   cellstr        - Convert to a cell array of character vectors.
%   blanks         - Character vector of spaces.
%
% Text determination functions.
%   iscellstr      - True for cell array of character vectors.
%   ischar         - True for character array.
%   isstring       - True for string array.
%   isstrprop      - Check whether elements are of a specified category.
%
% String operations.
%   compose        - Converts data into formatted string arrays.
%   contains       - True if pattern is found.
%   count          - Number of occurrences of a pattern.
%   deblank        - Remove trailing whitespaces.
%   endsWith       - True if string ends with pattern.
%   erase          - Remove substring from string elements.
%   eraseBetween   - Remove bounded substrings.
%   extractAfter   - Extract substring after a specified position.
%   extractBefore  - Extract substring before a specified position.
%   extractBetween - Extract bounded substrings.
%   insertAfter    - Insert substring after a specified position.
%   insertBefore   - Insert substring before a specified position.
%   join           - Append string elements.
%   lower          - Convert string to lowercase.
%   pad            - Insert leading and trailing spaces.
%   regexp         - Match regular expression.
%   regexpi        - Match regular expression, ignoring case.
%   regexprep      - Replace string using regular expression.
%   replace        - Find and replace substring.
%   replaceBetween - Replace bounded substrings.
%   reverse        - Reverse the order of characters.
%   split          - Split strings at delimiter.
%   splitlines     - Split strings at newlines.
%   startsWith     - True if string starts with pattern.
%   strsplit       - Split strings at delimiter.
%   strjoin        - Append string elements.
%   strcat         - Append strings together.
%   strcmp         - Compare strings.
%   strncmp        - Compare first N characters.
%   strcmpi        - Compare strings ignoring case.
%   strncmpi       - Compare first N characters ignoring case.
%   strfind        - Find one string within another.
%   strip          - Remove leading and trailing whitespaces.
%   strjust        - Justify character array.
%   strlength      - Lengths of string elements.
%   strrep         - Find and replace substring.
%   strtok         - Split string into tokens.
%   strtrim        - Remove leading and trailing whitespaces.
%   upper          - Convert string to uppercase.
%
% Character set conversion.
%   native2unicode - Convert bytes to Unicode characters.
%   unicode2native - Convert Unicode characters to bytes.
%
% Conversion between text and numbers.
%   double         - Convert to a double array.
%   int2str        - Convert integer to character vector.
%   mat2str        - Convert a 2-D matrix to a character vector in MATLAB syntax.
%   num2str        - Convert numbers to a character vector.
%   str2double     - Convert string to double precision value.
%   str2num        - Convert character vector to numeric array.
%   string         - Convert to string array.
%   sprintf        - Write formatted data to string.
%   sscanf         - Read string under format control.
%
% Base number conversion.
%   hex2num        - Convert hexadecimal string to double precision number.
%   hex2dec        - Convert hexadecimal string to decimal integer.
%   dec2hex        - Convert decimal integer to hexadecimal string.
%   bin2dec        - Convert binary string to decimal integer.
%   dec2bin        - Convert decimal integer to a binary string.
%   base2dec       - Convert base B string to decimal integer.
%   dec2base       - Convert decimal integer to base B string.
%   num2hex        - Convert singles and doubles to IEEE hexadecimal strings.
%
%   See also GENERAL, LANG, IOFUN, OPS, DATATYPES.

% Utility functions.
%   isletter    - True for letters of the alphabet.
%   isspace     - True for whitespace characters.
%
% Obsolete functions.
%   strread     - Read formatted data from character vector.
%   str2mat     - Form space padded character array.
%   isstr       - True for character array.
%   setstr      - Convert numeric values into character vectors.
%   strvcat     - Vertically concatenate character vectors.
%   findstr     - Find character vector within another.
%   strmatch    - Find possible matches for character vector.

%   Copyright 1984-2018 The MathWorks, Inc.
