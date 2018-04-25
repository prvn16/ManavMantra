%ISSPACE True for whitespace characters
%   For a character vector or string scalar CHR, ISSPACE(CHR) is 1 for 
%   Unicode-represented whitespace characters and 0 otherwise.
%   Whitespace characters for which ISSPACE returns TRUE include tab, line
%   feed, vertical tab, form feed, carriage return, and space, in addition
%   to a number of other Unicode characters. 
%
%   Example
%      isspace('  Find spa ces ')
%      Columns 1 through 13 
%         1   1   0   0   0   0   1   0   0   0   1   0   0
%      Columns 14 through 15 
%         0   1
%     
%   See also ISLETTER, ISSTRPROP.
 
%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.

