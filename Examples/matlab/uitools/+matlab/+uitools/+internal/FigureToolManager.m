% Copyright 2014-2017 The MathWorks, Inc.

classdef FigureToolManager < matlab.mixin.SetGet
    properties
        CommandManager@matlab.uitools.internal.uiundo.CommandManager
        Figure@matlab.ui.Figure
        UndoUIMenu
        RedoUIMenu
    end

    properties(SetAccess = private, GetAccess = private)
        CommandManagerListeners
    end

    methods
        function hThis = FigureToolManager(hfig)
            hThis.Figure = hfig;
            
            % Create CommandManager  
            hCmdManager = matlab.uitools.internal.uiundo.CommandManager;
            hThis.CommandManager = hCmdManager;
            
            % Create Listeners
            l = event.listener(hCmdManager,'CommandStackChanged',@(o,~)locCommandStackChanged(o,hThis));
            
            % Add Listeners
            hThis.CommandManagerListeners = l;
        end
    end
end

%-----------------------------------------%
function locCommandStackChanged(obj,hThis)
    fig = hThis.Figure;
    cmd_manager = obj;

    locUpdateUndoUI(hThis,fig,cmd_manager);
    locUpdateRedoUI(hThis,fig,cmd_manager);
end

%-----------------------------------------%
function locUpdateUndoUI(hThis, fig,cmd_manager)
    undocmd = cmd_manager.peekundo;

    hMenu = hThis.UndoUIMenu;

    % If invalid handle, load by searching tag
    if isempty(hMenu) || ~ishghandle(hMenu)
      hMenu = findall(fig,'tag','figMenuEditUndo'); 
      hThis.UndoUIMenu = hMenu;
    end

    % If still no handle, bail out
    if isempty(hMenu) || ~ishghandle(hMenu)
      hThis.UndoUIMenu = [];
      return;
    end

    if isa(undocmd,'matlab.uitools.internal.uiundo.FunctionCommand') && isvalid(undocmd)
        label = getUndoRedoLabel(undocmd.Name, 'Undo');
        set(hMenu,'Label',label,'Enable','on');
        hfunc = @undo;
        set(hMenu,'Callback',@(~,~)locExecute(hfunc,cmd_manager));
    else
        % Show 'Undo' as a disabled menu item
        set(hMenu,'Label',getString(message('MATLAB:uistring:scribemenu:Undo')),...
            'Enable','off','Callback','');
    end
end

%-----------------------------------------%
function locUpdateRedoUI(hThis,fig,cmd_manager)
    redocmd = cmd_manager.peekredo;
    
    hMenu = hThis.RedoUIMenu;
    
    % If invalid handle, load by searching tag
    if isempty(hMenu) || ~ishghandle(hMenu)
      hMenu = findall(fig,'tag','figMenuEditRedo'); 
      hThis.RedoUIMenu = hMenu;
    end
    
    % If still no handle, bail out
    if isempty(hMenu) || ~ishghandle(hMenu)
      hThis.RedoUIMenu = [];
      return;
    end
    
    if isa(redocmd,'matlab.uitools.internal.uiundo.FunctionCommand') && isvalid(redocmd)
        label = getUndoRedoLabel(redocmd.Name, 'Redo');
        set(hMenu,'Label',label,'Enable','on');
        hfunc = @redo;
        set(hMenu,'Callback',@(~,~)locExecute(hfunc,cmd_manager));
    else
        set(hMenu,'Label',getString(message('MATLAB:uistring:scribemenu:Redo')),...
            'Enable','off','Callback','');
    end
end

%-----------------------------------------%
function locExecute(func,arg)
    feval(func,arg);
end

%-----------------------------------------%

% Returns the translated Undo or Redo string to display in the figure menu.
% cmdName is the command name, something like 'Pan', 'Zoom', 'Change Line
% Width', or 'Change Bold'.  undoRedoString is either 'Undo' or 'Redo', and
% is used to get entries from the message catalog.
function label = getUndoRedoLabel(cmdName, undoRedoString)
try
    changeIndex = strfind(cmdName, 'Change');
    if ~isempty(changeIndex) && changeIndex(1) == 1
        % Find the property name for the change from the cmdName. This will
        % be something like 'Change Line Width', so the property name is
        % 'Line Width'.  (Note that the property name came from a message
        % catalog, and is translated already, whereas 'Change' is always in
        % English).
        propName = strrep(cmdName, 'Change ', '');
        
        % Use this in a string from the message catalog, so the result
        % will look like: 'Undo Change: Line Width'.
        label = getString(message(['MATLAB:uistring:scribemenu:' ...
            undoRedoString 'PropertyChange'], propName));
    else
        % Try to find Undo<command> or Redo<command> in the message
        % catalog, where command has any spaces or dashes removed.  For
        % example, if command is '3-D Rotate', the entry in the message
        % catalog will be 'Undo3DRotate' or 'Redo3DRotate'.  The end result
        % will be something like: 'Undo: 3-D Rotate' or 'Redo: 3-D Rotate'.
        label = getString(message(['MATLAB:uistring:scribemenu:' ...
            undoRedoString strrep(strrep(cmdName, ' ', ''), '-', '')]));
    end
catch
    % Fallback to using 'Undo: {0}' or 'Redo: {0}' from the message catalog
    % if something above isn't found
    label = getString(message(['MATLAB:uistring:scribemenu:' ...
        undoRedoString 'Name'], cmdName));
end
end
