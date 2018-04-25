function clearUndoRedo(actionStr,figArray)

%  Copyright 2008-2014 The MathWorks, Inc.

% Clears the figure undo/redo stacks excluding or including the specified
% figures. Clear operations are only performed for actions which occurred
% after the most recent data action so as not to flush more recent graphic
% actions.
if nargin==0 || strcmp(actionStr,'exclude')
    h = datamanager.LinkplotManager.getInstance();
    for k=1:length(h.Figures)
        if nargin<=1 || isempty(figArray) || ...
                ~any(double(h.Figures(k).Figure)==double(figArray))
            if isprop(h.Figures(k).Figure,'uitools_FigureToolManager')
                figtool_manager = h.Figures(k).Figure.uitools_FigureToolManager;
            else
                figtool_manager = [];
            end
            localEmptyUndoStack(figtool_manager);
        end
    end
elseif strcmp(actionStr,'include')
    for k=1:length(figArray)
        figtool_manager = getappdata(double(figArray(k)),...
                'uitools_FigureToolManager');
        localEmptyUndoStack(figtool_manager);
    end
end

function localEmptyUndoStack(figtool_manager)

if ~isempty(figtool_manager) && ishandle(figtool_manager) && ...
        ~isempty(figtool_manager.CommandManager)
    undoStack = figtool_manager.CommandManager.UndoStack;
    redoStack = figtool_manager.CommandManager.RedoStack;
    
    dataUndoPos = -1;
    if ~isempty(undoStack) && all(ishandle(undoStack))
        dataUndos = find(undoStack,'-property','DataTransaction'); 
        if ~isempty(dataUndos)
            [~,I] = ismember(dataUndos,undoStack);
            dataUndoPos = max(I);
        end
    end
    dataRedoPos = -1;
    if ~isempty(redoStack) && all(ishandle(redoStack))
        dataRedos = find(redoStack,'-property','DataTransaction'); 
        if ~isempty(dataRedos)
            [~,I] = ismember(dataRedos,redoStack);
            dataRedoPos = max(I);
        end
    end
    figtool_manager.CommandManager.empty(dataUndoPos,dataRedoPos);
end