function b = inner2outer(a)
%INNER2OUTER Invert a nested table-in-table hierarchy.
%   T2 = INNER2OUTER(T1) acts on the a table or timetable T1 that contains
%   variables that are themselves tables or timetables. It returns T2, a
%   table that also contains nested tables as variables. The names of the
%   variables in T2 are taken from the names of the variables inside the
%   nested tables of T1. Then, INNER2OUTER regroups variables in the nested
%   tables of T2 appropriately. If T1 has variables that are not tables,
%   those variables are unaltered in T2.
%
%   Example:
%   
%     % Create table with variables that are tables
%     T1 = table(table([1;2;3],[4;5;6],[7;8;9]), ...
%                table(["a";"b";"c"],["d";"e";"f"],["h";"i";"j"]), ...
%                'VariableNames',{'A','B'});
%     T2 = inner2outer(T1)
%
%     T1 =                                            T2 = 
%              A                   B             ||       Var1        Var2        Var3  
%       Var1  Var2  Var3    Var1  Var2  Var3     ||     A     B     A     B     A     B 
%       ________________    ________________     ||     ________    ________    ________ 
%        1     4     7      "a"   "d"   "h"      ||     1    "a"    4    "d"    7    "h"
%        2     5     8      "b"   "e"   "i"      ||     2    "b"    5    "e"    8    "i"
%        3     6     9      "c"   "f"   "j"      ||     3    "c"    6    "f"    9    "j"
%
%   Consider using INNER2OUTER when the input T1 has hierarchical data
%   within nested tables, organized so that the inner tables all have
%   variables with the same names. Then INNER2OUTER creates T2 with
%   variables that are nested tables, but where each nested table gets a
%   name that is the name of a variable from one of the inner tables of T1.
%   In effect, INNER2OUTER swaps the hierarchy of inner and outer table
%   variables. INNER2OUTER also works in other cases where such a parallel
%   hierarchy is not present--for example, when some of the variables of T1
%   are tables, and the other variables are not.
%
%   See also ROWS2VARS, MERGEVARS, SPLITVARS

%   Copyright 2017 The MathWorks, Inc.

import matlab.internal.datatypes.istabular
import matlab.internal.datatypes.throwInstead

aData = a.data;
aWidth = a.varDim.length;
tableVars = false(1,aWidth);
for d = 1:aWidth
    tableVars(d) = istabular(aData{d});
end    

% If there are nested tables, do the inversion work.
if nnz(tableVars)>0
    % Set up table to track inner and outer vars.
    % tableNesting has the structure:
    % row: inner vars of a
    % col: outer vars of a
    w = warning('off', 'MATLAB:table:RowsAddedExistingVars');
    wobj = onCleanup(@() warning(w));
    tableNesting = array2table(false(0,aWidth),'VariableNames',a.varDim.labels);
    for ii = find(tableVars)
        tableNesting = tableNesting.subsasgnParens({a.subsrefDot({ii}).varDim.labels,ii},{true}); % tableNesting(a.(ii).Properties.VariableNames,ii)) = true
    end
    
    % find non-nested variables a(:,~tableVars)
    bNonNested = a.subsrefParens({':',~tableVars});
    % a(:,[]) to just get row labels and table metadata.
    bNested = a.subsrefParens({':',[]}); 
    
    % Build up the nested table.
    % Loop over the inner vars in a (outer vars in b). For each inner var
    % in a, loop over the outer vars in a that contain that inner var,
    % building up that table for b.
    for bOuter = tableNesting.rowDim.labels'
        % Get list of inner var names to go in b corresponding to the outer
        % var in b that we're working on (bOuter).
        bInnerVarNames = tableNesting.varDim.labels(tableNesting.subsrefBraces({bOuter,':'})); % tableNesting.varDim.labels(tableNesting{bOuter,:})
        % Set up an empty inner table from the outer variable in a
        % (bInnerVarNames(1) that is the first one that has the inner
        % variable that we're working on now (bOuter).
        tempInner = a.subsrefDot(bInnerVarNames(1)).subsrefParens({':',[]}); % tempInner = a.(bInnerVarNames(1))(:,[])
        for bInner = bInnerVarNames
            % tempInner(:,bInner) = a.bInner(:,bOuter)
            bInnerNoClash = matlab.lang.makeUniqueStrings(bInner,tempInner.metaDim.labels,namelengthmax);
            tempInner = tempInner.subsasgnParens({':',bInnerNoClash}, a.subsrefDot(bInner).subsrefParens({':',bOuter}));
        end
        % clean up per-table metadata
        tempInner = tempInner.setProperty('Description',tempInner.arrayPropsDflts.Description);
        tempInner = tempInner.setProperty('UserData',tempInner.arrayPropsDflts.UserData);
        
        % All inner timetables become tables and lose their row times.
        % Inner tables with row names lose their row names.
        if isa(tempInner,'timetable')
            tempInner = timetable2table(tempInner,'ConvertRowTimes',false);
        else
            tempInner.rowDim = tempInner.rowDim.removeLabels();
        end
        bOuterNoClash = matlab.lang.makeUniqueStrings(bOuter,bNested.metaDim.labels,namelengthmax);
        bNested = bNested.subsasgnDot(bOuterNoClash, tempInner); 
    end
    dupNames = intersect(bNonNested.varDim.labels,bNested.varDim.labels);
    if ~isempty(dupNames)
        bNested.varDim = bNested.varDim.setLabels(matlab.lang.makeUniqueStrings(bNested.varDim.labels,bNonNested.varDim.labels));
    end
    b = bNonNested.horzcat(bNested);
    
    % Loop over tableNesting rows to figure out where the bNested variables
    % should be located. Find the first true for each inner var (across a
    % row), add 1 for each time multiple new vars need to be moved to the
    % same place.
    prevFind = 0;
    dupShift = 0;
    for jj = 1:tableNesting.rowDim.length
        tableNestingData = [tableNesting.data{:}]; % get logical data
        % New nested table variables are always after the non-nested ones
        % and always get moved to the left, so no need to compensate for
        % the previous moves in the indexing.
        moveFromInd = bNonNested.varDim.length + jj; 
        % Find the first occurrence in the logical array of where the old
        % inner nested variable occurs. Add one each iteration to account
        % for the previous var that was moved (again, always moved left).
        newFind = find(tableNestingData(jj,:),1);
        if prevFind == newFind
            dupShift = dupShift + double(prevFind==newFind);
        end
        prevFind = newFind;
        moveToInd =  newFind + dupShift;
        b = b.movevars(moveFromInd,'Before',moveToInd);
    end
else
    b = a;
end
