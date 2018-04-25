function reconcile(h)

% Removes any orphaned brushing entries from the brushmanager, i.e.,
% variables which do not appear in any linked plot or Variable Editor
% regardless of the workspace.

%   Copyright 2008 The MathWorks, Inc.

linkManager = datamanager.LinkplotManager.getInstance();

% Get all the variable names used in linked plots.
varNames = {};
for k=1:length(linkManager.Figures)
    locVarNames = linkManager.Figures(k).('VarNames');
    locVarNames = locVarNames(~cellfun('isempty',locVarNames));
    varNames = [varNames; locVarNames(:)]; %#ok<AGROW>
end
varNames = unique(varNames(~cellfun('isempty',varNames)));

% Find the row position of variables used in a linked plot or a Variable
% Editor, regardless of the workspace.
I = false(size(h.VariableNames));
arrayEditorVariables = h.ArrayEditorVariables;
if ~isempty(arrayEditorVariables) && ~isempty(varNames)
    for k=1:length(I)
        I(k) = ismember(h.VariableNames{k},varNames) || ismember(h.VariableNames{k},arrayEditorVariables);
    end
elseif ~isempty(varNames)
    for k=1:length(I)
        I(k) = ismember(h.VariableNames{k},varNames);
    end
elseif ~isempty(arrayEditorVariables)
    for k=1:length(I)
        I(k) = ismember(h.VariableNames{k},arrayEditorVariables);
    end
end

% Remove orphaned brushing entries from the brushmanager.
if any(~I)
    h.SelectionTable(~I) = [];
    h.VariableNames(~I) = [];
    h.DebugMFiles(~I) = [];
    h.DebugFunctionNames(~I) = [];
end