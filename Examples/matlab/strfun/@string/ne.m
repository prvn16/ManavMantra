%NE Not equal for string arrays
%   STR1 ~= STR2 does element by element comparisons between STR1 and STR2
%   and returns an array with elements set to logical 1 (TRUE) where the
%   relation is true and elements set to logical 0 (FALSE) where it is not.
%
%   STR1 and STR2 must have compatible sizes. In the simplest cases, they
%   can be the same size or one can be a scalar. Two inputs have compatible
%   sizes if, for every dimension, the dimension sizes of the inputs are
%   either the same or one of them is 1.
%
%   Either STR1 or STR2 can be a character vector or a cell array of
%   character vectors.
%
%   Example:
%       STR1 = "Jones";
%       STR2 = "Peterson";
%       STR1 ~= STR2                        
%
%       returns  
%
%          1
%
%   Example:
%       STR1 = "Jones";
%       STR2 = ["Peterson","Jones"];
%       STR1 ~= STR2                        
%
%       returns  
%
%          1   0
%
%   Example:
%       STR1 = ["Jones","Smith"];
%       STR1 ~= 'Jones'                      
%
%       returns  
%
%          0   1
%
%   See also EQ, GT, GE, LT, LE, STRING, SORT, ISMEMBER, CONTAINS.

%   Copyright 2015-2016 The MathWorks, Inc.