function cb_opensystem
%CB_OPENSYSTEM opens selected model/system

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.

me =  fxptui.getexplorer;
if isempty(me); return; end
bd = me.getTopNode;
mdl = bd.getDAObject;
if(~isa(mdl, 'Simulink.BlockDiagram'))
	return;
end
mdl.hilite('off');
selection = me.getTreeSelection;
% Call the view method so that FPT's open action (from the context menu)
% has the same behavior as ME
if isa(selection, 'DAStudio.DAObjectProxy')
    selection = selection.getMCOSObjectReference;
end
selection.getUniqueIdentifier.openInEditor;

% [EOF]