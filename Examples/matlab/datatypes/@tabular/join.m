function [c,ir] = join(a,b,varargin)
%JOIN Merge tables or timetables by matching up rows using key variables.
%   C = JOIN(A, B) creates a table C by merging rows from the two tables A
%   and B.  If both A and B are timetables, C is also a timetable. You can
%   also merge A and B if A is a timetable and B is a table, but not if A
%   is a table and B is a timetable. JOIN performs a simple form of join
%   operation where each row of A must match exactly one row in B.  If
%   necessary, JOIN replicates rows of B and "broadcasts" them out to A.
%   For more complicated forms of inner and outer joins, see INNERJOIN and
%   OUTERJOIN.
%
%   JOIN first finds one or more key variables.  A key is a variable that
%   occurs in both A and B with the same name. If both A and B are
%   timetables, the key variables are the time vectors of A and B. If A is
%   a timetable and B is a table, the keys are variables that occur in both
%   A and B with the same name. Each row in B must contain a unique
%   combination of values in the key variables, and B must contain all
%   combinations of key values that are present in A's keys.  JOIN uses the
%   key variables to find the row in B that matches each row in A, and
%   combines those rows to create a row in C.  C contains one row for each
%   row in A, appearing in the same order as rows in A.
%
%   C contains all variables from A, as well as all of the non-key variables
%   from B.  If A and B contain variables with identical names, JOIN adds
%   a unique suffix to the corresponding variable names in C.  Use the
%   'KeepOneCopy' input parameter to retain only one copy of variables with
%   identical names.
%
%   C = JOIN(A, B, 'PARAM1',val1, 'PARAM2',val2, ...) allows you to specify
%   optional parameter name/value pairs to control how JOIN uses the variables
%   in A and B.  Parameters are:
%
%          'Keys'       - specifies the variables to use as keys.   Specify
%                         the character vector 'RowNames' to use A's and
%                         B's rownames as keys.  In this case, there must
%                         be a one-to-one correspondence between rows of A
%                         and rows of B. 
%          'LeftKeys'   - specifies the variables to use as keys in A.
%          'RightKeys'  - specifies the variables to use as keys in B.
%
%   You may provide either the 'Keys' parameter, or both the 'LeftKeys' and
%   'RightKeys' parameters.  The value for these parameters is a positive
%   integer, a vector of positive integers, a variable name, a cell array of
%   variable names, or a logical vector.  'LeftKeys' or 'RightKeys' must both
%   specify the same number of key variables, and the left and right keys are
%   paired in the order specified.
%
%   When joining two timetables, 'Keys', or 'LeftKeys' and 'RightKeys',
%   must be the names of the time vector of the timetables.
%
%      'LeftVariables'  - specifies which variables from A to include in C.
%                         By default, JOIN includes all variables from A.
%      'RightVariables' - specifies which variables from B to include in C.
%                         By default, JOIN includes all variables from B except
%                         the key variables.
%
%   'LeftVariables' or 'RightVariables' can be used to include or exclude key
%   variables as well as data variables.  The value for these parameters is a
%   positive integer, a vector of positive integers, a variable name, a cell
%   array containing one or more variable names, or a logical vector.
%
%      'KeepOneCopy'    - When A and B may contain non-key variables with identical
%                         names, JOIN ordinarily retains both copies in C.  This
%                         parameter specifies variables for which JOIN retains
%                         only A's copy.  'KeepOneCopy' is a variable name or a
%                         cell array containing one or more variable names.
%                         Default is none.
%
%   [C,IB] = JOIN(...) returns an index vector IB, where JOIN constructs C by
%   horizontally concatenating A(:,LEFTVARS) and B(IB,RIGHTVARS).
%
%   Example:
%
%     % Append values from one table to another using a simple join.
%     a = table({'John' 'Jane' 'Jim' 'Jerry' 'Jill'}',[1 2 1 2 1]', ...
%                 'VariableNames',{'Employee' 'Department'})
%     b = table([1 2]',{'Mary' 'Mike'}','VariableNames',{'Department' 'Manager'})
%     c = join(a,b)
%
%     % Append values from one timetable to another timetable using a simple join.
%     Traffic = [0.8, 0.9, 0.1, 0.7, 0.9];
%     Noise = [0, 1, 1.5, 2, 2.3];
%     a = timetable(hours(1:5)',Traffic',Noise');
%     
%     Distance = [0.88, 0.86, 0.91, 0.9, 0.86];
%     b = timetable(hours(1:5)',Distance');
%     c = join(a,b)
%   
%     % Append values from a table to a timetable.
%     Measurements = [0.13 0.22 0.31 0.42 0.53 0.57 0.67 0.81 0.90 1.00];
%     Device = ['A';'B';'A';'B';'A';'B';'A';'B';'A';'B'];
%     a = timetable(seconds(1:10)', Measurements', Device);
%
%     Device = ['A';'B'];
%     Accuracy = [0.023;0.037];
%     b = table(Device, Accuracy);
%     c = join(a,b)
%
%   See also INNERJOIN, OUTERJOIN, HORZCAT, SORTROWS,
%            UNION, INTERSECT, ISMEMBER, UNIQUE, INNER2OUTER, ROWS2VARS.

%   Copyright 2012-2017 The MathWorks, Inc.

narginchk(2,inf);
if ~matlab.internal.datatypes.istabular(a) || ~matlab.internal.datatypes.istabular(b)
    error(message('MATLAB:table:join:InvalidInput'));
end

type = 'simple';
pnames = {'Keys' 'LeftKeys' 'RightKeys' 'LeftVariables' 'RightVariables' 'KeepOneCopy'};
dflts =  {   []         []          []              []               []            {} };
[keys,leftKeys,rightKeys,leftVars,rightVars,keepOneCopy,supplied] ...
         = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
     
if supplied.KeepOneCopy
    % The names in keepOneCopy must be valid var names, but need not actually match a
    % duplicated variable, or even any variable.
    if ~matlab.internal.datatypes.isCharStrings(keepOneCopy,false,false) % do not allow empty strings
        error(message('MATLAB:table:join:InvalidKeepOneCopy'));
    end
    try
        a.varDim.makeValidName(keepOneCopy,'error'); % error if invalid
    catch
        error(message('MATLAB:table:join:InvalidKeepOneCopy'));
    end
end

[leftVars,rightVars,leftVarDim,rightVarDim,leftKeyVals,rightKeyVals,leftKeys,rightKeys] ...
     = tabular.joinUtil(a,b,type,inputname(1),inputname(2), ...
                      keys,leftKeys,rightKeys,leftVars,rightVars,keepOneCopy,supplied);

if isSimpleJoinOnUniqueRowLabels(leftKeys,rightKeys,type,a,b)
    % Fast special case: row labels are unique, so joinUtil uses the right's row
    % indices as the key values, and leftKeyVals contains indices of the right's
    % rows that match the left's rows.
    ir = leftKeyVals;
else
    % Do the simple join C = [A(:,LEFTVARS) B(IB,RIGHTVARS)] by computing the row
    % indices into B for each row of C.  The row indices into A are just 1:n.

    % Check that B's key contains no duplicates.
    if length(unique(rightKeyVals)) < size(rightKeyVals,1)
        error(message('MATLAB:table:join:DuplicateRightKeyVarValues'));
    end
    
    % Use the key vars to find indices from A into B, and make sure every
    % row in A has a corresponding one in B.
    try
        [tf,ir] = ismember(leftKeyVals,rightKeyVals);
    catch me
        error(message('MATLAB:table:join:KeyIsmemberMethodFailed', me.message));
    end
    if ~isequal(size(tf),[length(leftKeyVals),1])
        error(message('MATLAB:table:join:KeyIsmemberMethodReturnedWrongSize'));
    elseif any(~tf)
        nkeys = length(leftKeys);

        % First check if any keys, either vars or row labels, contain missing values.
        % Otherwise throw an error about unmatched key values.
        aKeys = a.subsrefParens({':',leftKeys(leftKeys>0)});
        missingInLeft = any(ismissing(aKeys),2);
        if any(leftKeys == 0) && a.rowDim.hasLabels
            missingInLeft = missingInLeft | ismissing(a.rowDim.labels);
        end
        bKeys = b.subsrefParens({':',rightKeys(rightKeys>0)});
        missingInRight = any(ismissing(bKeys),2);
        if any(rightKeys == 0) && b.rowDim.hasLabels
            missingInRight = missingInRight | ismissing(b.rowDim.labels);
        end
        if any(missingInLeft) || any(missingInRight)
            error(message('MATLAB:table:join:MissingKeyValues'));
        elseif nkeys == 1
            error(message('MATLAB:table:join:LeftKeyValueNotFound'));
        else
            error(message('MATLAB:table:join:LeftKeyValuesNotFound'));
        end
    end
end

% Create a new table by combining the specified variables from A with those
% from B, the latter broadcasted out to A's length using the key variable
% indices.
c = a; % preserve all of a's per-array and per-row properties
numLeftVars = length(leftVars);
numRightVars = length(rightVars);
c.data = [a.data(leftVars) cell(1,numRightVars)];
for j = 1:numRightVars
    var_j = b.data{rightVars(j)};
    szOut = size(var_j); szOut(1) = a.rowDim.length;
    c.data{numLeftVars+j} = reshape(var_j(ir,:),szOut);
end

% Assign names and merge a's and b's per-var properties.
c_varDim = leftVarDim.lengthenTo(numLeftVars+numRightVars,rightVarDim.labels);
c.varDim = c_varDim.moveProps(rightVarDim,1:numRightVars,numLeftVars+(1:numRightVars));

%-----------------------------------------------------------------------
function tf = isSimpleJoinOnUniqueRowLabels(leftKeys,rightKeys,type,a,b)
tf = isequal(leftKeys,rightKeys,0) && strcmpi(type,'simple') ...
    && a.rowDim.requireUniqueLabels && b.rowDim.requireUniqueLabels;
