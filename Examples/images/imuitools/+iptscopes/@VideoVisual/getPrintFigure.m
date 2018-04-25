function printFig = getPrintFigure(this)
%GETPRINTFIGURE Creates and returns the Print Figure
%   An utility method for print and printToFigure methods to create the
%   print figure. Creates a generic figure by copying the scope axes.  
%   Passes the generic figure to the updatePrintAxes method to make any 
%   other visual specific updates

%   Copyright 2010-2015 The MathWorks, Inc.

% Get the scope figure and the color map
hScope = this.Application;
scopeFig = hScope.Parent;

scopeCmap = get(scopeFig,'Colormap');
guiExt = getExtInst(this.Application,'Core','General UI');
bgndColor = getPropertyValue(guiExt,'FigureColor');

% Create a figure to print the scope data
printFig = figure ('Visible', 'off', ...
    'Units', 'pixels', ...
    'Colormap', scopeCmap, ...
    'Color',bgndColor, ...    
    'PaperPositionMode', 'auto', ...
    'Tag', 'ScopePrintToFigure');

% Set the position for the print to figure
scopePos = get(scopeFig,'Position');
printPos = get(printFig, 'Position');

% Reset the figure position to accommodate for any changes in resizing 
% scope window.
printPos(2) = printPos(2) - (scopePos(4) - printPos(4))/2;
figCentre = [printPos(1) + printPos(3)/2 printPos(2) + printPos(4)/2];
       
printPos(1)   = figCentre(1) - scopePos(3)/2;
printPos(2) = figCentre(2) - scopePos(3)/2;

set(printFig, 'Position', [printPos(1) printPos(2) scopePos(3) scopePos(4)]);

% Copy the visible editor axes
% Get the visual
scopeAxes = this.Axes;

if ~isempty(scopeAxes)
    % Copy the visible scope axes to the new print axes parented under the 
    % print to figure object.
    printAxes =  copyobj(scopeAxes,printFig);
    
    % Lock in axis limits and ticks to ensure snapshot of plot 
    set(printAxes, ...
        'XLimMode', 'manual', 'XTickMode', 'manual', 'XTickLabelMode', 'manual', ...
        'YLimMode', 'manual', 'YTickMode', 'manual', 'YTickLabelMode', 'manual', ...
        'ZLimMode', 'manual', 'ZTickMode', 'manual', 'ZTickLabelMode', 'manual');                      
        
    % Make visual specific interactive behaviors on the new plot
    this.updatePrintAxesInteractivity(printAxes);
    
    % Remove appdata
    removeAppData(printAxes);
    
    % Make visual Specific Updates
    this.updatePrintAxes(printFig);
end

%--------------------------------
function removeAppData(printAxes)
% Clear appdata
if isappdata(printAxes,'MWBYPASS_axis')
    rmappdata(printAxes,'MWBYPASS_grid');
    rmappdata(printAxes,'MWBYPASS_title');
    rmappdata(printAxes,'MWBYPASS_xlabel');
    rmappdata(printAxes,'MWBYPASS_ylabel');
    rmappdata(printAxes,'MWBYPASS_axis');
end
