function updateFigUndoMenu(fig,newstring,redoOp,redoArgs,undoOp,undoArgs)

% Specify the undo/redo menu behavior on a single figure window.
% The varargin optionally indicates modification of
% to redo menu instead of the undo menu.

%  Copyright 2008-2014 The MathWorks, Inc.

% Create command structure
cmd.Function = redoOp;
cmd.Name = newstring;
cmd.InverseFunction = undoOp;
cmd.Varargin = redoArgs;
cmd.InverseVarargin = undoArgs;

% Empty existing data actions from the figure undo stack since the Data
% Manager Action Panel has a stack depth of 1
datamanager.clearUndoRedo('include',fig);
uiundo(handle(fig),'function',cmd);
if isprop(fig,'uitools_FigureToolManager')
    figtool_manager = fig.uitools_FigureToolManager;
else
    return
end
addprop(figtool_manager.CommandManager.UndoStack(end),'DataTransaction');