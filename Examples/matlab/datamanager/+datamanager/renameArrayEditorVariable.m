function renameArrayEditorVariable(oldVarName, newVarName)
    
    % Called from ArrayEditorManager.java when a variable that is open in
    % the Variable Editor is renamed.
    
    % Copyright 2014 The MathWorks, Inc.
    
    h = datamanager.BrushManager.getInstance();
    
    % Do the rename for the ArrayEditorVariables list
    oldIndex = find(strcmp(h.ArrayEditorVariables, oldVarName));
    newIndex = find(strcmp(h.ArrayEditorVariables, newVarName));
    if isempty(newIndex) || any(oldIndex ~= newIndex)
        if ~isempty(newIndex)
            % renaming to an existing variable, just delete the old variable
            % name's information
            h.ArrayEditorVariables(oldIndex) = [];
            h.ArrayEditorSubStrings(oldIndex) = [];
        elseif any(oldIndex)
            % renaming to a new variable name, reassign the old name to the new
            % name.
            [h.ArrayEditorVariables{oldIndex}] = deal(newVarName);
        end
    end
    
    % Do the rename with the other data
    [mfilename, fcnname] = datamanager.getWorkspace(1);
    oldVarNameIndex = find(strcmp(oldVarName, h.VariableNames) & ...
        strcmp(mfilename, h.DebugMFiles) & ...
        strcmp(fcnname, h.DebugFunctionNames));
    newVarNameIndex = find(strcmp(newVarName, h.VariableNames) & ...
        strcmp(mfilename, h.DebugMFiles) & ...
        strcmp(fcnname, h.DebugFunctionNames));
    
    if ~isequal(newVarNameIndex, oldVarNameIndex)
        if ~isempty(newVarNameIndex)
            % renaming to an existing brushed variable
            h.VariableNames{newVarNameIndex} = newVarName;
            h.SelectionTable(newVarNameIndex) = h.SelectionTable(oldVarNameIndex);
            h.DebugMFiles(newVarNameIndex) = h.DebugMFiles(oldVarNameIndex);
            h.DebugFunctionNames(newVarNameIndex) = h.DebugFunctionNames(oldVarNameIndex);
            
            h.VariableNames(oldVarNameIndex) = [];
            h.SelectionTable(oldVarNameIndex) = [];
            h.DebugMFiles(oldVarNameIndex) = [];
            h.DebugFunctionNames(oldVarNameIndex) = [];
        elseif ~isempty(oldVarNameIndex)
            % renaming to a non-existing brushed variable
            h.VariableNames{oldVarNameIndex} = newVarName;
        end
    end
    
    h.draw(newVarName, '', '');
    