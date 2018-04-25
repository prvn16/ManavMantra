function b = mergevars(a,varsToMerge,varargin)
%MERGEVARS Combine table or timetable variables into a multi-column variable.
%   T2 = MERGEVARS(T1, VARS) combines the table variables specified by VARS
%   to create one multi-column variable in T2. All other variables from T1
%   are copied to T2. VARS is a positive integer, a vector of positive
%   integers, a variable name, a cell array containing one or more variable
%   names, or a logical vector.
% 
%   T2 = MERGEVARS(T1, VARS, 'PARAM', 'VAL', ...) allows you to specify
%   optional parameter name/value pairs to control how MERGEVARS operates on
%   T1. Parameters are: 
%
%     'NewVariableName'    - Specifies the name of the multi-column variable
%                            as newName.
%     'MergeAsTable'       - When true, the variables are merged into a
%                            table, instead of an array. The new table is
%                            itself a variable of the output table T2. Use
%                            this syntax to combine variables that cannot
%                            be concatenated into one homogeneous array.
%                            You can use this syntax with any of the input
%                            arguments from the previous syntaxes.
%
%   See also REMOVEVARS, MOVEVARS, ADDVARS, SPLITVARS.

%   Copyright 2017 The MathWorks, Inc.

pnames = {'NewVariableName', 'MergeAsTable'};
dflts =  {                  []       false};
[mergedVarName,asTable,supplied] ...
    = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});

asTable = matlab.internal.datatypes.validateLogical(asTable,'MergeAsTable');

varsToMerge = a.varDim.subs2inds(varsToMerge);

% Special case an empty list of varsToMerge
if isempty(varsToMerge)
    b = a;
    return
end


if asTable
    newvar = a.subsrefParens({':',varsToMerge});
    if isa(newvar,'timetable') %avoid ending up with a timetable-in-a-timetable
        newvar = timetable2table(newvar,'ConvertRowTimes',false);
    end
    newvar = newvar.setProperty('Description',newvar.arrayPropsDflts.Description);
    newvar = newvar.setProperty('UserData',newvar.arrayPropsDflts.UserData);
else % ~asTable
    try
        newvar = a.extractData(varsToMerge);
    catch ME
        error(message('MATLAB:table:mergevars:ExtractDataIncompatibleTypeError'));
    end
end

if supplied.NewVariableName
    if ~matlab.internal.datatypes.isCharString(mergedVarName,false) % not char vector or is ''
        error(message('MATLAB:table:mergevars:InvalidNewVarName'));
    else % For consistency with default-created var name.
        mergedVarName = {mergedVarName};
    end
else
    % calculate position where merged vars will go
    pos = varsToMerge(1);
    % Uniquify varsToMerge to avoid double-counting duplicates listed in varsToMerge.
    % We've already gotten them multiple times for the merged data, just
    % need to avoid it in indexing.
    varsToMerge = unique(varsToMerge,'stable');
    pos = pos - nnz(varsToMerge < pos);
    mergedVarName = a.varDim.dfltLabels(pos);
    % Make sure default name does not conflict with remaining var names or dim names.
    remainingVarNames = a.varDim.labels;
    remainingVarNames(varsToMerge) = [];
    mergedVarName = matlab.lang.makeUniqueStrings(mergedVarName, [remainingVarNames,a.metaDim.labels], namelengthmax);
end

% Merged var is added in place of 1st of varsToMerge.
b = a.subsasgnDot(varsToMerge(1),newvar);
% Delete the other varsToMerge so they don't get involved in name disambiguation.
delVars = varsToMerge;
delVars(1) = [];
b = b.removevars(delVars);
% Figure out new index of the merged variable based on the number of
% deleted vars that were to the left of it.
newVarInd = varsToMerge(1) - nnz(delVars < varsToMerge(1));
if supplied.NewVariableName
    % Detect conflicts between the user-provided new var name and the original dim names.
    b.metaDim = b.metaDim.checkAgainstVarLabels(mergedVarName,'error');
end
b.varDim = b.varDim.setLabels(mergedVarName,newVarInd);
% Clear outdated outer per-variable metadata for newvar
b.varDim = b.varDim.assignInto(b.varDim.createLike(1,mergedVarName),newVarInd);
