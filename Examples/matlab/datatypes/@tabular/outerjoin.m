function [c,il,ir] = outerjoin(a,b,varargin)
%OUTERJOIN Outer join between two tables or two timetables.
%   C = OUTERJOIN(A, B) creates the table C as the outer join between the
%   tables A and B.  If A is a timetable, then B can be either a table or a
%   timetable, and outerjoin returns C as a timetable for either
%   combination of inputs. An outer join includes the rows that match
%   between A and B, and also unmatched rows from either A or B.
%
%   OUTERJOIN first finds one or more key variables.  A key is a variable
%   that occurs in both A and B with the same name.  If both A and B are
%   timetables, the key variables are the time vectors of A and B.
%   OUTERJOIN then uses those key variables to match up rows between A and
%   B.  C contains one row for each pair of rows in A and B that share the
%   same combination of key values.  In general, if there are M rows in A
%   and N rows in B that all contain the same combination of key values, C
%   contains M*N rows for that combination.  C also contains rows
%   corresponding to key combinations in A (or B) that did not match any
%   row in B (or A).  OUTERJOIN sorts the rows in the result C by the key
%   values.
%
%   C contains all variables from both A and B, including the keys.  If A and B
%   contain variables with identical names, OUTERJOIN adds a unique suffix
%   to the corresponding variable names in C.  Variables in C that came from A
%   (or B) contain null values in those rows that had no match from B (or A).
%
%   C = OUTERJOIN(A, B, 'PARAM1',val1, 'PARAM2',val2, ...) allows you to specify
%   optional parameter name/value pairs to control how OUTERJOIN uses the variables
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
%           'MergeKeys' - specifies if OUTERJOIN should include a single variable
%                         in C for each key variable pair from A and B,
%                         rather than including two separate variables.
%                         OUTERJOIN creates the single variable by merging
%                         the key values from A and B, taking values from A
%                         where a corresponding row exists in A, and from B
%                         otherwise.  Default is false. If both A and B are
%                         timetables, 'MergeKeys' must always be true.
%      'LeftVariables'  - specifies which variables from A to include in C.
%                         By default, OUTERJOIN includes all variables from A.
%      'RightVariables' - specifies which variables from B to include in C.
%                         By default, OUTERJOIN includes all variables from B.
%
%   'LeftVariables' or 'RightVariables' can be used to include or exclude key
%   variables as well as data variables.  The value for these parameters is a
%   positive integer, a vector of positive integers, a variable name, a cell
%   array containing one or more variable names, or a logical vector.
%
%                'Type' - specifies the type of outer join operation, either
%                         'full', 'left', or 'right'.  For a left (or right)
%                         outer join, C contains rows corresponding to keys in
%                         A (or B) that did not match any in B (or A), but not
%                         vice-versa.  By default, OUTERJOIN does a full outer
%                         join, and includes unmatched rows from both A and B.
%
%   [C,IA,IB] = OUTERJOIN(A, B, ...) returns index vectors IA and IB indicating
%   the correspondence between rows in C and those in A and B.  OUTERJOIN
%   constructs C by horizontally concatenating A(IA,LEFTVARS) and B(IB,RIGHTVARS).
%   IA or IB may also contain zeros, indicating the rows in C that do not
%   correspond to rows in A or B, respectively.
%
%   Examples:
%
%     % Create two tables that both contain the key variable 'Key1'.  The
%     % two arrays contain rows with common values of Key1, but each array
%     % also contains rows with values of Key1 not present in the other.
%     a = table({'a' 'b' 'c' 'e' 'h'}',[1 2 3 11 17]','VariableNames',{'Key1' 'Var1'})
%     b = table({'a' 'b' 'd' 'e'}',[4 5 6 7]','VariableNames',{'Key1' 'Var2'})
%
%     % Combine a and b with an outer join.  This matches up rows with
%     % common key values, but also retains rows whose key values don't have
%     % a match.  Keep the key values as separate variables in the result.
%     cfull = outerjoin(a,b,'key','Key1')
%
%     % Join a and b, merging the key values as a single variable in the result.
%     cfullmerge = outerjoin(a,b,'key','Key1','MergeKeys',true)
%
%     % Join a and b, ignoring rows in b whose key values do not match any
%     % rows in a.
%     cleft = outerjoin(a,b,'key','Key1','Type','left','MergeKeys',true)
%
%
%     % Create two timetables a and b. The time vector of each timetable
%     % contain some overlapping % times, but also include times that are not
%     % present in the other timetable. 
%     a = timetable(seconds([1;2;4;6]),[1 2 3 11]')
%     b = timetable(seconds([2;4;6;7]),[4 5 6 7]')
%
%     % Combine a and b with an outer join.  This matches up rows with
%     % common times, but also retains rows whose times don't have
%     % a match.
%     cfull = outerjoin(a,b)
%
%     % Join a and b, ignoring rows in b whose key values do not match any
%     % rows in a.
%     cleft = outerjoin(a,b,'Type','left')
%
%   See also INNERJOIN, JOIN, HORZCAT, SORTROWS,
%            UNION, INTERSECT, ISMEMBER, UNIQUE, INNER2OUTER, ROWS2VARS.

%   Copyright 2012-2017 The MathWorks, Inc.

import matlab.internal.datatypes.validateLogical

narginchk(2,inf);
if ~matlab.internal.datatypes.istabular(a) || ~matlab.internal.datatypes.istabular(b)
    error(message('MATLAB:table:join:InvalidInput'));
end

keepOneCopy = [];
pnames = {'Type' 'Keys' 'LeftKeys' 'RightKeys' 'MergeKeys' 'LeftVariables' 'RightVariables'};
dflts =  {'full'    []         []          []       false              []               [] };
[type,keys,leftKeys,rightKeys,mergeKeys,leftVars,rightVars,supplied] ...
         = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
supplied.KeepOneCopy = 0;

types = {'inner' 'left' 'right' 'full'};
i = find(strncmpi(type,types,length(type)));
if isempty(i) || isempty(type)
    error(message('MATLAB:table:join:InvalidType'));
end
leftOuter = (i == 2) || (i >= 4);
rightOuter = (i >= 3);

mergeKeys = validateLogical(mergeKeys,'MergeKeys');

[leftVars,rightVars,leftVarDim,rightVarDim,leftKeyVals,rightKeyVals,leftKeys,rightKeys] ...
     = tabular.joinUtil(a,b,type,inputname(1),inputname(2), ...
                        keys,leftKeys,rightKeys,leftVars,rightVars,keepOneCopy,supplied);

if mergeKeys
    % A key pair row labels from both is _always_ merged (in joinInnerOuter), but
    % row labels aren't among the data vars in the output, so no need to remove
    % them from the right's data vars or rename them in the left's.
    %
    % However, a row labels key may be paired with a key var in the other input.
    % Leave out any of B's key vars that correspond to a row labels key in A, the
    % key values from B will be merged into C's row labels (by joinInnerOuter).
    removeFromRight = ismember(rightVars,rightKeys(leftKeys==0));
    rightVars(removeFromRight) = [];
    rightVarDim = rightVarDim.deleteFrom(removeFromRight);
    % That still leavesa row labels key in B that corresponds to a key var in A,
    % those will be merged into C's key var below.
    
    % Find keys that appear in both leftVars and rightVars, and remove them from
    % rightVars. Remaining keys appear only once, either in leftVars or rightVars.
    inLeft = ismember(leftKeys,leftVars);
    [inRight,locr] = ismember(rightKeys,rightVars);
    removeFromRight = locr(inLeft(:) & inRight(:));
    rightVars(removeFromRight) = [];
    rightVarDim = rightVarDim.deleteFrom(removeFromRight);
    
    % Find the locations of keys in leftVars, keys from A will appear in the output
    % in those same locations. Find the (possibly thinned) locations of keys in
    % rightVars, keys from B will appear in the output in those same locations,
    % offset by length(leftVars).
    [~,keyVarLocsInLeftVars,locl] = intersect(leftVars,leftKeys,'stable');
    [~,keyVarLocsInRightVars,locr] = intersect(rightVars,rightKeys,'stable');
    keyVarLocsInOutput = [keyVarLocsInLeftVars; length(leftVars)+keyVarLocsInRightVars]; % where are the key vars in the output?
    numKeyVarsInOutputFromLeft = length(locl);
    numKeyVarsInOutputFromRight = length(locr);
    
    % Link the key vars in the output back to vars in A and B.
    keyVarLocsInLeftInput = leftKeys([locl; locr]); % where in A did the key vars come from?
    keyVarLocsInRightInput = rightKeys([locl; locr]); % where in B did the key vars come from?
    
    % Create a concatenated key var name wherever the names differ between the right
    % and left, use leave the existing name alone wherever they don't. This merges
    % the names even if one of the key pair was explicitly left out of the specified
    % output vars.
    %
    % Key names that were common between the two inputs had a suffix added in
    % leftVarDim and rightVarDim by joinUtil. That's not needed when merging keys,
    % so go back to the original names from the two inputs.
    keyNamesFromLeftInput = getVarOrRowLabelsNames(a,keyVarLocsInLeftInput);
    keyNamesFromRightInput = getVarOrRowLabelsNames(b,keyVarLocsInRightInput);
    keyNames = keyNamesFromLeftInput;
    diffNames = ~strcmp(keyNamesFromLeftInput,keyNamesFromRightInput);
    if any(diffNames)
        keyNames(diffNames) = strcat(keyNamesFromLeftInput(diffNames),'_',keyNamesFromRightInput(diffNames));
    end
    
    % Unique the key names against the already unique left and right data var names.
    varNames = [leftVarDim.labels rightVarDim.labels];
    varNames(keyVarLocsInOutput) = []; % remove names of keys
    otherNames = [varNames a.metaDim.labels];
    keyNames = matlab.lang.makeUniqueStrings(keyNames,otherNames,namelengthmax);
    
    leftVarDim = leftVarDim.setLabels(keyNames(1:numKeyVarsInOutputFromLeft),keyVarLocsInLeftVars);
    rightVarDim = rightVarDim.setLabels(keyNames(numKeyVarsInOutputFromLeft+(1:numKeyVarsInOutputFromRight)),keyVarLocsInRightVars);
end

[c,il,ir] = tabular.joinInnerOuter(a,b,leftOuter,rightOuter,leftKeyVals,rightKeyVals, ...
                                   leftVars,rightVars,leftKeys,rightKeys,leftVarDim,rightVarDim);

if mergeKeys
    % C's () non-row label) "left" and "right" key vars are (so far) a copy of
    % either A's or B's key vars, respectively, and unmatched rows have missing
    % values in the opposite's key var. Merging keys fills those in. Where there was
    % no source row in A, fill in C's "left" key vars from B's key vars, and "right"
    % from A's. There still may be missing values in C's key vars if there were
    % missing values in the original key vars, but those are not due to "no source
    % row".
    c_data = c.data;
    useRight = (il == 0);
    if any(useRight)
        b_data = b.data;
        for i = 1:numKeyVarsInOutputFromLeft
            isrc = keyVarLocsInRightInput(i);
            idest = keyVarLocsInOutput(i);
            if isrc > 0 % var/var key pair
                c_data{idest}(useRight,:) = b_data{isrc}(ir(useRight),:);
            else % var/rowLabels key pair
                c_data{idest}(useRight,:) = b.rowDim.labels(ir(useRight));
            end
        end
    end
    useLeft = (ir == 0);
    if any(useLeft)
        a_data = a.data;
        for i = numKeyVarsInOutputFromLeft + (1:numKeyVarsInOutputFromRight)
            isrc = keyVarLocsInLeftInput(i);
            idest = keyVarLocsInOutput(i);
            c_data{idest}(useLeft,:) = a_data{isrc}(il(useLeft),:);
        end
    end
    c.data = c_data;
end


%-----------------------------------------------------------------------
function names = getVarOrRowLabelsNames(t,indices)
isRowLabels = (indices == 0);
names(isRowLabels) = t.metaDim.labels(1);
names(~isRowLabels) = t.varDim.labels(indices(~isRowLabels));

