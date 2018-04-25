function [groupCode,msg] = variableEditorGroupCode(this,varName,startCol,endCol)
% This function is for internal use only and will change in a
% future release.  Do not use this function.

% Generate MATLAB command to group variables in column range startCol to
% endCol

%   Copyright 2013-2016 The MathWorks, Inc.

msg = '';
[varNames,varIndices] = variableEditorColumnNames(this);

if isdatetime(this.rowDim.labels) || isduration(this.rowDim.labels)
    % varNames and varIndices include the rownames, if they are datetimes
    % or duration.  These aren't needed for the group function.
    varNames(1) = [];
    varIndices(1) = [];
    varIndices = varIndices-1;
    % startCol and endCol also includes the time column, so decrement it
    startCol = startCol-1;
    endCol = endCol-1;
end

startIndex = find(varIndices(1:end-1)<=startCol,1,'last');
endIndex = find(varIndices(1:end-1)<=endCol,1,'last');

% Put together names of the table variables to merge and construct the new
% variable name.
namesVarsToGroup = '';
groupedVarName = '';
for k=startIndex:endIndex
    groupedVarName = sprintf('%s%s',groupedVarName,varNames{k});
    namesVarsToGroup = [namesVarsToGroup '''' varNames{k} '''']; %#ok<AGROW>
    if k<endIndex
        namesVarsToGroup = [namesVarsToGroup ',']; %#ok<AGROW>
       groupedVarName = sprintf('%s_',groupedVarName);
    end
end
namesVarsToGroup = ['{' namesVarsToGroup '}'];
% Make sure the new variable name is valid.
groupedVarName = matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(groupedVarName), {}, namelengthmax);

groupCode = [varName ' = mergevars(' varName ', ' namesVarsToGroup ', ''NewVariableName'', ''' groupedVarName ''', ''MergeAsTable'', false);'];
end
