%STRREP Find and replace substring.
%   MODIFIEDTEXT = STRREP(ORIGTEXT,OLDSUBTEXT,NEWSUBTEXT) replaces all 
%   occurrences of the text OLDSUBTEXT within text ORIGTEXT with the
%   text NEWSUBTEXT.
%
%   Notes:
%
%   * STRREP accepts input combinations of character vectors, scalar
%     character vector cells, same-sized cell arrays of character vectors,
%     scalar string arrays, and same-sized string arrays. If any input is a
%     string array, STRREP returns a string array. Otherwise, if any input
%     is a cell array, STRREP returns a cell array. Otherwise, STRREP
%     returns a character vector.
%
%   * STRREP does not find empty text for replacement. That is, when
%     ORIGTEXT and OLDSUBTEXT both contain no text (''), STRREP does not
%     replace '' with the contents of NEWSUBTEXT.
%
%   Examples:
%
%   % Example 1: Replace text in a character vector.
%
%       claim = 'This is a good example';
%       new_claim = strrep(claim, 'good', 'great')
%
%       new_claim = 
%       This is a great example.
%
%   % Example 2: Replace text in a cell array.
%
%       c_files = {'c:\cookies.m'; ...
%                  'c:\candy.m';   ...
%                  'c:\calories.m'};
%       d_files = strrep(c_files, 'c:', 'd:')
%
%       d_files = 
%           'd:\cookies.m'
%           'd:\candy.m'
%           'd:\calories.m'
%
%   % Example 3: Replace text in a cell array with values in a second cell
%   % array.
%
%       missing_info = {'Start: __'; ...
%                       'End: __'};
%       dates = {'01/01/2001'; ...
%               '12/12/2002'};
%       complete = strrep(missing_info, '__', dates)
%
%       complete = 
%           'Start: 01/01/2001'
%           'End: 12/12/2002'
%    
%   See also REPLACE, ERASE, REPLACEBETWEEN, CONTAINS, REGEXPREP, STRFIND

%   Copyright 1984-2017 The MathWorks, Inc. 
%   Built-in function.
