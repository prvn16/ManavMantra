%STRTRIM Remove leading and trailing whitespaces
%   S = STRTRIM(M) removes leading and trailing whitespace characters from
%   M and returns the result as S. The input argument M can be a string array,
%   character array, or a cell array of character vectors. When M is a
%   string or cell array of character vectors, STRTRIM removes leading and
%   trailing whitespace from each element of M. S is the same type as M.
%
%   STRTRIM treats all Unicode space characters as whitespace. These
%   characters include space, tab, new line, vertical tab, form feed,
%   carriage return, and any other character for which ISSPACE returns
%   true.
%
%   Examples:
%
%       % Remove the leading spaces and tab from a list of file names.
%       M = sprintf(' \t data.csv   data.txt    image.jpg   results.xls');
%       S = strtrim(M)
%
%       % Remove spaces from a cell array of character vectors.
%       % The output argument S is a cell array that is the same size as M.
%       M = {'     Adams, John'; ...
%            'Smith, Mary     '};
%       S = strtrim(M)
%       
%   See also STRIP, PAD, ISSPACE, DEBLANK.

%   Copyright 1984-2017 The MathWorks, Inc.
%==============================================================================
