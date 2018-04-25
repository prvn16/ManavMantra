function [className, variableName, foundVar] = getClassNameFromVariable(objectName, wsVariables, ignoreCase)    
    if ignoreCase
        matchedVar = strcmpi(objectName, {wsVariables.name});
    else
        matchedVar = strcmp(objectName, {wsVariables.name});
    end
    foundVar = any(matchedVar);
    if foundVar
        className = wsVariables(find(matchedVar, 1) ).class;
        variableName = wsVariables(find(matchedVar, 1) ).name;
    else
        className = '';
        variableName = '';
    end
end