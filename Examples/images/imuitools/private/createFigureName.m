function figName = createFigureName(toolName,targetHandle)
% CREATEFIGURENAME(TOOLNAME, TARGETHANDLE) creates a name for the figure
% created by the tool, TOOLNAME.  The figure name, FIGNAME, will include
% TOOLNAME and the name of the figure on which the tool depends. TOOLNAME must
% be a string, and TARGETHANDLE must be a valid handle to the figure or the
% axes on which TOOLNAME depends.
%
%   Example
%   -------
%       h = imshow('bag.png');
%       hFig = figure;
%       imhist(imread('bag.png'));
%       toolName = 'Histogram';
%       targetFigureHandle = ancestor(h,'Figure');
%       name = createFigureName(toolName,targetFigureHandle);
%       set(hFig,'Name',name);
%
%   See also IMAGEINFO, BASICIMAGEINFO, IMPIXELREGION.

%   Copyright 1993-2016 The MathWorks, Inc.

if ~ischar(toolName)
    error(message('images:createFigureName:invalidInput'))
end

if ishghandle(targetHandle,'figure')
    
    figureName = getFigureName(targetHandle);
    
    if ~isempty(figureName)
        figName = sprintf('%s (%s)', toolName, figureName);
    else
        figName = toolName;
    end
    
elseif ishghandle(targetHandle,'axes')
    
    parentFig = targetHandle.Parent;
    figureName = getFigureName(parentFig);
    
    if ~isempty(figureName)
        figName = sprintf('%s (Child Axes of %s)', toolName, figureName);
    else
        figName = toolName;
    end
    
else
    error(message('images:createFigureName:invalidFigureHandle'))
end

%--------------------------------------------------------------------------
function figureName = getFigureName(figureHandle)

figureName = figureHandle.Name;

if isempty(figureName) && isequal(figureHandle.IntegerHandle,'on')
    
    figureName = getString(message( ...
        'images:commonUIString:createFigureNameEmptyName', ...
        double(figureHandle)));
end
