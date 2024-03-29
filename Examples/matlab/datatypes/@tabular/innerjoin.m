function [c,il,ir] = innerjoin(a,b,varargin)
%INNERJOIN Inner join between two tables or two timetables.
%   C = INNERJOIN(A, B) creates the table C as the inner join between the
%   tables A and B. If A is a timetable, then B can be either a table or a
%   timetable, and innerjoin returns C as a timetable for either
%   combination of inputs. An inner join retains only the rows that match
%   between A and B.
%
%   INNERJOIN first finds one or more key variables.  A key is a variable
%   that occurs in both A and B with the same name.  If both A and B are
%   timetables, the key variables are the time vectors of A and B.
%   INNERJOIN then uses those key variables to match up rows between A and
%   B.  C contains one row for each pair of rows in A and B that share the
%   same combination of key values.  In general, if there are M rows in A
%   and N rows in B that all contain the same combination of key values, C
%   contains M*N rows for that combination. INNERJOIN sorts the rows in the
%   result C by the key values.
%
%   C contains all variables from both A and B, but only one copy of the key
%   variables.  If A and B contain variables with identical names, INNERJOIN
%   adds a unique suffix to the corresponding variable names in C.
%
%   C = INNERJOIN(A, B, 'PARAM1',val1, 'PARAM2',val2, ...) allows you to specify
%   optional parameter name/value pairs to control how INNERJOIN uses the variables
%   in A and B.  Parameters are:
%
%           'Keys'      - specifies the variables to use as keys.
%           'LeftKeys'  - specifies the variables to use as keys in A.
%           'RightKeys' - specifies the variables to use as keys in B.
%
%   You may provide either the 'Keys' parameter, or both the 'LeftKeys' and
%   'RightKeys' parameters.  The value for these parameters is a positive
%   integer, a vector of positive integers, a variable name, a cell array of
%   variable names, or a logical vector.  'LeftKeys' or 'RightKeys' must both
%   specify the same number of key variables, and the left and right keys are
%   paired in the order specified.
%
%   When joining two timetables, 'Keys', or 'LeftKeys' and 'RightKeys',
%   must be the time vector names of the timetables.
%
%      'LeftVariables'  - specifies which variables from A to include in C.
%                         By default, INNERJOIN includes all variables from A.
%      'RightVariables' - specifies which variables from B to include in C.
%                         By default, INNERJOIN includes all variables from B
%                         except the key variables.
%
%   'LeftVariables' or 'RightVariables' can be used to include or exclude key
%   variables as well as data variables.  The value for these parameters is a
%   positive integer, a vector of positive integers, a variable name, a cell
%   array containing one or more variable names, or a logical vector.
%
%   [C,IA,IB] = INNERJOIN(A, B, ...) returns index vectors IA and IB indicating
%   the correspondence between rows in C and those in A and B.  INNERJOIN
%   constructs C by horizontally concatenating A(IA,LEFTVARS) and B(IB,RIGHTVARS).
%
%   Example:
%
%     % Create two tables that both contain the key variable 'Key1'.  The
%     % two arrays contain rows with common values of Key1, but each array
%     % also contains rows with values of Key1 not present in the other.
%     a = table({'a' 'b' 'c' 'e' 'h'}',[1 2 3 11 17]','VariableNames',{'Key1' 'Var1'})
%     b = table({'a' 'b' 'd' 'e'}',[4 5 6 7]','VariableNames',{'Key1' 'Var2'})
%
%     % Join a and b, retaining only rows whose key values match.
%     c = innerjoin(a,b,'key','Key1')
%
%
%     % Create two timetables a and b. The time vectors of each timetable
%     % partially overlap.
%     a = timetable(seconds([1;2;4;6]),[1 2 3 11]')
%     b = timetable(seconds([2;4;6;7]),[4 5 6 7]')
%
%     % Combine a and b with an inner join.  Only retains rows whose times have
%     % a match.
%     c = innerjoin(a,b)
%
%   See also OUTERJOIN, JOIN, HORZCAT, SORTROWS,
%            UNION, INTERSECT, ISMEMBER, UNIQUE, INNER2OUTER, ROWS2VARS.

%   Copyright 2012-2017 The MathWorks, Inc.

narginchk(2,inf);
if ~matlab.internal.datatypes.istabular(a) || ~matlab.internal.datatypes.istabular(b)
    error(message('MATLAB:table:join:InvalidInput'));
end

type = 'inner';
keepOneCopy = [];
pnames = {'Keys' 'LeftKeys' 'RightKeys' 'LeftVariables' 'RightVariables'};
dflts =  {   []         []          []              []               [] };
[keys,leftKeys,rightKeys,leftVars,rightVars,supplied] ...
         = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
supplied.KeepOneCopy = 0;

[leftVars,rightVars,leftVarDim,rightVarDim,leftKeyVals,rightKeyVals,leftKeys,rightKeys] ...
    = tabular.joinUtil(a,b,type,inputname(1),inputname(2), ...
                       keys,leftKeys,rightKeys,leftVars,rightVars,keepOneCopy,supplied);

leftOuter = false;
rightOuter = false;
[c,il,ir] = tabular.joinInnerOuter(a,b,leftOuter,rightOuter,leftKeyVals,rightKeyVals, ...
                                   leftVars,rightVars,leftKeys,rightKeys,leftVarDim,rightVarDim);
