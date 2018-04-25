function this = BAExplorer(TreeObject, varargin)
%BAEXPLORER Construct a BAEXPLORER object
%   OUT = BAEXPLORER(ARGS) <long description>

%   Copyright 2010-2012 MathWorks, Inc.

this = fxptui.BAExplorer.getBAExplorer;
showUI = true;
if nargin > 1
    showUI = varargin{1};
end

if isempty(this)
    treeRoot = fxptui.BAERoot(TreeObject);

    if ~isempty(treeRoot)
        % Do not translate the title of the explorer
        this =  fxptui.BAExplorer(treeRoot, fxptui.message('titleFPToolShortcutEditor'),...
                                  false);
        this.imme = DAStudio.imExplorer(this);
        customize(this);
        this.MEListeners = handle.listener(this, 'ObjectBeingDestroyed', @(s,e)cleanup(this));
        this.MEListeners(end+1) = handle.listener(this,'METreeSelectionChanged',@(s,e) refreshTreeView(this, e));
        this.MEListeners(end+1) = handle.listener(TreeObject, 'CloseEvent', @(s,e)cleanup(this));
        this.MEListeners(end+1) = handle.listener(this, 'MEPostShow', @(s,e)selectNode(this));
    end
elseif ~strcmpi(this.getTopNode.daobject.getFullName,TreeObject.getFullName)
    changeRoot(this, TreeObject.getFullName);
end

if showUI
    if this.isVisible
        this.hide;
        this.show;
    else
        this.show;
    end
else
    this.hide;
end

selectNode(this);

this.getRoot.firehierarchychanged;
this.getRoot.firepropertychange;

%----------------------------------------------------------------------------------------
function refreshTreeView(this, ev)
% refresh the tree view if the selected node is a Model Block node.

if isa(ev.EventData, 'fxptui.BAEMdlBlkNode')
    wasRefreshed = refreshModelTree(this);
    if wasRefreshed
        % refresh the loaded shortcut
        hDlg = this.getDialog;
        this.loadShortcut(hDlg);
    end
end

%----------------------------------------------------------------------------------------
function customize(this)

this.Title = fxptui.message('titleFPToolShortcutEditor');
this.setTreeTitle(fxptui.message('labelModelHierarchy'));
this.showListView(false);
this.actions = java.util.HashMap;
createActions(this);
createMenus(this);
this.setStatusMessage(fxptui.message('labelBAEInitialized'));

%-----------------------------------------------------
function createActions(this)
% Creates the default actions for the Shortcut Editor.

am = DAStudio.ActionManager;
am.initializeClient(this);

% Create a default action for File->Close
action = am.createDefaultAction(this, 'FILE_CLOSE');
action.statusTip = fxptui.message('tooltipCloseFPTSE');
action.Tag = 'FPT_SE_file_close';
this.actions.put('SE_FILE_CLOSE', action);

% Install the action to ignore/apply dialog changes. The user's choice gets
% saved in the preference file.
action = am.createDefaultAction(this, 'TOOLS_PROMPT_DLG_REPLACE');
action.on = 'on';
action.Tag = 'ShortcutEditor_dlgreplace';
this.actions.put('SE_TOOLS_PROMPT_DLG_REPLACE', action);

action = am.createDefaultAction(this, 'VIEW_INCREASEFONT');
action.statusTip = fxptui.message('tooltipIncreaseFont');
action.Tag = 'FPT_SE_view_increasefont';
this.actions.put('SE_VIEW_INCREASEFONT', action);

action = am.createDefaultAction(this, 'VIEW_DECREASEFONT');
action.statusTip = fxptui.message('tooltipDecreaseFont');
action.Tag = 'FPT_SE_view_decreasefont';
this.actions.put('SE_VIEW_DECREASEFONT', action);


%--------------------------------------------------------------------
function createMenus(this)
am = DAStudio.ActionManager;

m = am.createPopupMenu(this);
action = this.getaction('SE_FILE_CLOSE');
m.addMenuItem(action);
am.addSubMenu(this, m, fxptui.message('menuFile'));

m = am.createPopupMenu(this);
action = this.getaction('SE_VIEW_INCREASEFONT');
m.addMenuItem(action);
action = this.getaction('SE_VIEW_DECREASEFONT');
m.addMenuItem(action);
am.addSubMenu(this, m, fxptui.message('menuView'));

m = am.createPopupMenu(this);
action = this.getaction('SE_TOOLS_PROMPT_DLG_REPLACE');
m.addMenuItem(action);
am.addSubMenu(this, m, fxptui.message('menuTools'));

%--------------------------------------------------------------------

% [EOF]

% LocalWords:  FPT BAE dlgreplace INCREASEFONT increasefont DECREASEFONT
% LocalWords:  decreasefont
