function cb_highlightblock
%CB_HIGHLIGHTBLOCK highlights selected block in model

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

me =  fxptui.getexplorer;
if ~isempty(me)
    mdl = me.getTopNode.getDAObject;
    mdl.hilite('off');
end
fxptds.AbstractActions.selectAndInvoke('hiliteInEditor');

% selection = me.getlistselection;
% if(isa(selection, 'fxptui.abstractobject'))
%   selection.highlightblock;
% else
%     fxptui.showdialog('noselectionhighlight');
% end

% [EOF]