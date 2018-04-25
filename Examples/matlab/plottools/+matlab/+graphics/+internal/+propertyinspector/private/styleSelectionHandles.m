% Called by property inspector to show/hide the selection handles
% When called without passing any arguments, this function will restore the
% selection handles in all the figures in plot-edit mode

% Copyright 2017 The MathWorks, Inc.

function styleSelectionHandles(varargin)
% Find all the selected objects in the figure
allFigures = findobj(0,'-depth',1,'type','figure',...
    '-function',@(x) isactiveuimode(x,'Standard.EditPlot'),...
    '-and','BeingDeleted','off');
for i = 1:numel(allFigures)    
    selectedObjects = findobj(allFigures(i),'Selected','on','-and','SelectionHighlight','on');
    % Hide the selection handles in the figure that is not currently being
    % inspected
    if ~isempty(selectedObjects)
        set(selectedObjects,'SelectionHighlight','off');
    end
end

if nargin < 1
    % Restore the selection handles in all the figures in plot-edit mode
    % when inspector window is hidden
    restoreAllSelectionHandles();
else
    % Restore the selection handles in the figure that is currently being
    % inspected
    hFig = varargin{:};
    showSelectionHandles(hFig);
end
end

function showSelectionHandles(hFig)
selectedObjects = findobj(hFig,'-and','Selected','on','-and','SelectionHighlight','off');
if ~isempty(selectedObjects)
    set(selectedObjects,'SelectionHighlight','on');
end
end

function restoreAllSelectionHandles()
allFigures = findobj(0,'-depth',1,'type','figure',...
    '-function',@(x) isactiveuimode(x,'Standard.EditPlot'),...
    '-and','BeingDeleted','off');

for i = 1:numel(allFigures)
    showSelectionHandles(allFigures(i));
end
end