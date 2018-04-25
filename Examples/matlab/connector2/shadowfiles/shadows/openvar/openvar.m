function openvar(name, array)
%OPENVAR Open workspace variable in tool for graphical editing
%   OPENVAR(NAME) edits the array in the base workspace whose name is given
%   in NAME.  NAME must contain a string.

% Copyright 2013-2014 The MathWorks, Inc.

workspace = 'caller';

baseVariableName = arrayviewfunc('getBaseVariableName', name);

variableExists = evalin(workspace, ['builtin(''exist'',''' baseVariableName ''',''var'')']);
if ~variableExists
	% TODO: Replace with message catalog string
	error(['No such variable: ' name]);
end

if nargin > 1 && ~isempty(array)
    data = array;
else
    data = evalin(workspace, name);
end

% Create a Document for the new variable
if builtin('exist','internal.matlab.variableeditor.peer.PeerVariableEditor')
    veManager = internal.matlab.variableeditor.peer.PeerVariableEditor.getInstance.PeerManager;
else
    veManager = internal.matlab.variableeditor.peer.PeerManager.getInstance.createInstance('/VariableEditor',false);
end
veManager.openvar(name,workspace,data);
