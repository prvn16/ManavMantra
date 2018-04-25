%InteractiveHistogramHue  Circular histogram display with selection.

%   Copyright 2013-2014 The MathWorks, Inc.

classdef InteractiveHistogramHue < handle
    
    properties (Access=public, SetObservable=true)
        currentSelection  % Limits of current selection, where (min > max) is possible
    end
    
    
    properties (Access=public)
        histBins    % The histogram bin centers
        histCounts  % The histogram counts
        histRange   % The histogram data range
    end

    
    properties (Access=private, Hidden=true)
        parent  % Figure or panel associated with this histogram viewer
        hPanel  % Panel containing the axes with stem plot and selector
        hAx     % Axes containing the histogram and selector
        
        selectionListener  % Handle to the listener used for triggering callbacks
        selectorAPI        % Handles and callbacks for the selector
    end
    
    
    methods
        
        function obj = InteractiveHistogramHue(hParent, data)
            % OBJ = InteractiveHistogram(PARENT, DATA) creates an
            % interactive histogram object for DATA, which should be the
            % hue channel of an image. The histogram plot and selector
            % will be a child of PARENT, which must already exist.
            
            % Set the handles that point at existing UI objects.
            obj.parent = hParent;
            
            % Construct the histogram view.
            histStruct = iptui.internal.getHistogramDataRaw(data);
            
            obj.histRange  = histStruct.histRange;
            obj.histBins   = histStruct.finalBins;
            obj.histCounts = histStruct.counts;

            obj.hPanel = uipanel('Parent', obj.parent, ...
                           'Units', 'normalized');
            
            iptui.internal.setChildColorToMatchParent(obj.hPanel, obj.parent);
            obj.hAx = createHistogram(obj.hPanel, histStruct);
            
            iptPointerManager(ancestor(obj.parent, 'figure'))
            
            % Create the selection patch.
            obj.currentSelection = obj.histRange;

            obj.selectorAPI = createSelector(obj.hAx, obj.currentSelection);

            % Add label.
            iptui.internal.addLabelToHistogram(obj.hAx, 'H')
            
            % Set up callbacks
            histEvent = iptui.internal.HistogramChanged();
            obj.selectorAPI = setUpCallbacksOnSelector(obj.selectorAPI, obj.hAx, histEvent);
            obj.selectionListener = addlistener(histEvent, 'changed', @obj.updateSelection);
        end
        
        %-----
        function updateSelection(obj, evt, ~)
            obj.currentSelection = evt.newSelection;
        end
        
        %-----
        function updateHistogram(obj)
            names = fieldnames(obj.selectorAPI);
            for k = 1 : length(names)
                obj.selectorAPI.(names{k}).set(obj.currentSelection);
            end
        end
        
        %-----
        function setTag(obj, newTag)
            set(obj.hPanel, 'Tag', newTag)
        end
    end
end

%==========================================================================
function hAx = createHistogram(parentForAxes, histStruct)

    innerCircleDiameter = 0.3;
    outerCircleDiameter = outerRainbowDiameter();
    maxBarLength = maxHistLineLength();

    axesColor = iptui.internal.histogramAxesColor();
   
    % Create an axes to hold the circular histogram. Remove labels/lines.
    hAx = axes('XLim', [-3.5 3.5], ...
        'YLim', [-3.5 3.5], ...
        'Color', axesColor, ...
        'DataAspectRatio', [1 1 1], ...
        'Parent', parentForAxes);
    set(hAx, 'XColor', axesColor, ...
        'YColor', axesColor, ...
        'ZColor', axesColor, ...
        'XTick', [], ...
        'YTick', [], ...
        'ZTick', []);

    % Plot color ring.
    numColors = 256;
    for hue = 0:1/numColors:1
        [xIn1, yIn1] = pol2cart(hue * 2 * pi, innerCircleDiameter);
        [xIn2, yIn2] = pol2cart((hue + 1/numColors) * 2 * pi, innerCircleDiameter);
        [xOut1,yOut1] = pol2cart(hue * 2 * pi, outerCircleDiameter);
        [xOut2,yOut2] = pol2cart((hue + 1/numColors) * 2 * pi, outerCircleDiameter);
        patch([xIn1 xIn2 xOut2 xOut1], ...
            [yIn1 yIn2 yOut2 yOut1], ...
            [5 5 5 5], ... % Use "large" Z value so it's on top.
            hsv2rgb([hue, 1, 1]), ...
            'Parent', hAx, ...
            'EdgeColor', 'none')
    end

    maxCount = max(histStruct.counts);

    % Plot the histogram for the data.
    for hue = 1:histStruct.nbins
        count = histStruct.counts(hue);

        if (count == 0)
            continue
        end

        [barStartX, barStartY] = pol2cart(histStruct.finalBins(hue) * 2 * pi, ...
            outerCircleDiameter + 0.1);
        [barStopX, barStopY] = pol2cart(histStruct.finalBins(hue) * 2 * pi, ...
            outerCircleDiameter + 0.1 + (count/maxCount) * maxBarLength);
        line([barStartX, barStopX], [barStartY, barStopY], 'LineWidth', 1, 'Parent', hAx)
    end
    
end

%==========================================================================
function selectorAPI = createSelector(hAx, currentSelection)
%createSelector  Create draggable selection window over the histogram
%   selectorAPI = createSelector(hAx, selection, maxCounts) creates a
%   draggable window on the axes specified by the handle HAX.

% The selector comprises one main patch showing what is currently selected.
% Dragging the main patch does not change the size of the color selection,
% but it does rotate the selection around the color wheel. At each end of
% the selector (which can span the 0/360 degree boundary) is a minimum or
% maximum line that changes the amount of color values in the selection.
% These can be hard to grab when they are close to each other, so the
% selector also has minimum and maximum arrow-shaped patchs that correspond
% to the location of the minimum and maximum end points of the selection.
% There is also one patch corresponding to the "deselected" region, which
% is always the inverse of the currently selected values. This patch has a
% different visual appearance than the selected region.

bottom = 1;
top = 2;

faceAlpha = 0;
edgeAlpha = 0.4;
selectorBorderThickness = 1.5;
edgeColor = [1 0 0];

% Main selection patch.
[patchShapeX, patchShapeY] = getMainPatchShape(currentSelection);
hPatch = patch(patchShapeX, patchShapeY, [1 1 1], ...
    'parent', hAx, ...
    'edgeColor', edgeColor, ...
    'FaceAlpha', faceAlpha, ...
    'LineWidth', selectorBorderThickness, ...
    'zData', ones(size(patchShapeX)) * bottom, ...
    'tag', 'window patch', ...
    'EdgeAlpha', edgeAlpha);

hPatch.PickableParts = 'all';

selectorAPI.bigPatch.handle = hPatch;
selectorAPI.bigPatch.get    = @() getXLocation(hPatch);
selectorAPI.bigPatch.set    = @(selection) setPatch(hPatch, selection);

% Deselected patch.
deselectedFaceColor = get(hAx, 'Color');
deselectedFaceAlpha = 0.7;
[patchShapeX, patchShapeY] = getMainPatchShape(fliplr(currentSelection));
hDeselectedPatch = patch(patchShapeX, patchShapeY, deselectedFaceColor, ...
    'parent', hAx, ...
    'edgeColor', 'none', ...
    'FaceAlpha', deselectedFaceAlpha, ...
    'zData', ones(size(patchShapeX)) * top, ...
    'tag', 'deselected patch');

outerEdgeOfRainbow = outerRainbowDiameter();
length = maxHistLineLength();

selectorAPI.deselectedPatch.handle = hDeselectedPatch;
selectorAPI.deselectedPatch.get    = @() getXLocation(hDeselectedPatch);
selectorAPI.deselectedPatch.set    = @(selection) setDeselectedPatch(hDeselectedPatch, selection);

% Min and max lines.
[x,y] = getMinLine(currentSelection, outerEdgeOfRainbow, length);
hMinLine = line(x, y, ...
    'LineWidth', selectorBorderThickness, ...
    'Color', edgeColor, ...
    'tag', 'min line', ...
    'ZData', ones(1,2) * top);

selectorAPI.minLine.handle = hMinLine;
selectorAPI.minLine.get    = @() getXLocation(hMinLine);
selectorAPI.minLine.set    = @(selection) setLineLocation(hMinLine,selection(1));

[x,y] = getMaxLine(currentSelection, outerEdgeOfRainbow, length);
hMaxLine = line(x, y, ...
    'LineWidth', selectorBorderThickness, ...
    'Color', edgeColor, ...
    'tag', 'max line', ...
    'ZData', ones(1,2) * top);

selectorAPI.maxLine.handle = hMaxLine;
selectorAPI.maxLine.get    = @() getXLocation(hMaxLine);
selectorAPI.maxLine.set    = @(selection) setLineLocation(hMaxLine,selection(2));

% Min and max arrow patches.
selectorColor = iptui.internal.selectorColor;

bottomOfArrow = outerEdgeOfRainbow + length + arrowOffset();
[XShape, YShape] = getArrowPatchShape(currentSelection(1), bottomOfArrow, true);
hMinPatch = patch('parent', hAx, ...
    'XData', XShape, ...
    'YData', YShape, ...
    'ZData', ones(size(XShape)) * top, ...
    'FaceColor', selectorColor, ...
    'EdgeColor', selectorColor, ...
    'tag', 'min patch');

selectorAPI.minPatch.handle = hMinPatch;
selectorAPI.minPatch.get    = @() getXLocation(hMinPatch);
selectorAPI.minPatch.set    = @(selection) setMinPatch(hMinPatch, selection);

bottomOfArrow = outerEdgeOfRainbow + length + arrowOffset() + arrowHeight();
[XShape, YShape] = getArrowPatchShape(currentSelection(2), bottomOfArrow, false);
hMaxPatch = patch('parent', hAx, ...
    'XData', XShape, ...
    'YData', YShape, ...
    'ZData', ones(size(XShape)) * top, ...
    'FaceColor', selectorColor, ...
    'EdgeColor', selectorColor, ...
    'tag', 'max patch');

selectorAPI.maxPatch.handle = hMaxPatch;
selectorAPI.maxPatch.get    = @() getXLocation(hMaxPatch);
selectorAPI.maxPatch.set    = @(selection) setMaxPatch(hMaxPatch, selection);

end

%==========================================================================
function setPatch(hPatch, selection)
%setPatch   Set the location of the main selection patch.

[newPatchShapeX, newPatchShapeY] = getMainPatchShape(selection);
set(hPatch, 'XData', newPatchShapeX, 'YData', newPatchShapeY);
end

%==========================================================================
function setMaxPatch(hPatch, selection)
%setMaxPatch   Set the location of the maximum selection arrow.

localBottomOfArrow = outerRainbowDiameter() + maxHistLineLength() + arrowOffset() + arrowHeight();
[maxPatchXData, maxPatchYData] = getArrowPatchShape(selection(2), localBottomOfArrow, false);
set(hPatch, 'XData', maxPatchXData, 'YData', maxPatchYData, 'ZData', ones(size(maxPatchXData)));
end

%==========================================================================
function setMinPatch(hPatch, selection)
%setMinPatch  Set the location of the minimum selection arrow.

localBottomOfArrow = outerRainbowDiameter() + maxHistLineLength() + arrowOffset();
[minPatchXData, minPatchYData] = getArrowPatchShape(selection(1), localBottomOfArrow, true);
set(hPatch, 'XData', minPatchXData, 'YData', minPatchYData, 'ZData', ones(size(minPatchXData)));
end

%==========================================================================
function setDeselectedPatch(hPatch, selection)
%setDeselectedPatch   Set the location of the main selection patch.

[newPatchShapeX, newPatchShapeY] = getMainPatchShape(fliplr(selection));
set(hPatch, 'XData', newPatchShapeX, 'YData', newPatchShapeY, 'ZData', ones(size(newPatchShapeX)));
end

%==========================================================================
function setLineLocation(hLine, value)
%setLineLocation   Set the location of an individual line.

startRadius = outerRainbowDiameter();
[newX, newY] = getMinLine(value, startRadius, maxHistLineLength());
set(hLine, 'XData', newX, 'YData', newY);
end

%==========================================================================
function value = getXLocation(h)
%getXLocation   Find the minimum theta value of the patch/line object.

XData = get(h, 'XData');
YData = get(h, 'YData');
value = rem(cart2pol(XData(1), YData(1)) / (2*pi) + 1, 1);
end

%==========================================================================
function selectorAPI = setUpCallbacksOnSelector(selectorAPI, hAx, histEvent)

set(selectorAPI.maxLine.handle,  'ButtonDownFcn', @maxLineButtonDown)
set(selectorAPI.minLine.handle,  'ButtonDownFcn', @minLineButtonDown)
set(selectorAPI.maxPatch.handle, 'ButtonDownFcn', @maxPatchButtonDown)
set(selectorAPI.minPatch.handle, 'ButtonDownFcn', @minPatchButtonDown)
set(selectorAPI.bigPatch.handle, 'ButtonDownFcn', @patchButtonDown)

hFig = ancestor(hAx, 'figure');

% Set the mouse-over pointer behaviors.
draggableObjList = [selectorAPI.maxLine.handle
    selectorAPI.minLine.handle
    selectorAPI.maxPatch.handle
    selectorAPI.minPatch.handle
    selectorAPI.bigPatch.handle];
initCursorChangeOverDraggableObjs(hFig, draggableObjList, 'hand');

    %==============================
    function patchButtonDown(varargin)
        
        prevPtr = 'arrow';
        setptr(hFig, 'closedhand')
        
        idButtonMotion = iptaddcallback(hFig, 'windowButtonMotionFcn', ...
            @patchMove);
        idButtonUp = iptaddcallback(hFig, 'WindowButtonUpFcn', @patchUp);
        
        % Disable pointer manager.
        iptPointerManager(hFig, 'disable');
        
        [startX, startY] = iptui.internal.getCurrentPoint(hAx);
        [startTheta, ~] = cart2pol(startX, startY);
        
        origSelection(1) = selectorAPI.minLine.get();
        origSelection(2) = selectorAPI.maxLine.get();
        
        %============================
        function patchUp(varargin)
            setptr(hFig, prevPtr);
            acceptChanges(idButtonMotion, idButtonUp);
        end
        
        %===========================
        function patchMove(varargin)
            
            [newX, newY] = iptui.internal.getCurrentPoint(hAx);
            [newTheta, ~] = cart2pol(newX, newY);
            
            deltaTheta = newTheta - startTheta;
            newSelection = wrapSelectionToRange(origSelection + deltaTheta/(2*pi));
            updateAll(selectorAPI, newSelection, histEvent);
        end
    end

    %==============================
    function minLineButtonDown(varargin)
        
        prevPtr = 'arrow';
        setptr(hFig, 'closedhand')
        
        idButtonMotion = iptaddcallback(hFig, 'windowButtonMotionFcn', ...
            @minLineMove);
        idButtonUp = iptaddcallback(hFig, 'WindowButtonUpFcn', @minLineUp);
        
        % Disable pointer manager.
        iptPointerManager(hFig, 'disable');
                
        %============================
        function minLineUp(varargin)
            setptr(hFig, prevPtr);
            acceptChanges(idButtonMotion, idButtonUp);
        end
        
        %===========================
        function minLineMove(varargin)
            
            [newX, newY] = iptui.internal.getCurrentPoint(hAx);
            [newTheta, ~] = cart2pol(newX, newY);
            
            newSelection(1) = wrapSelectionToRange(newTheta/(2*pi));
            newSelection(2) = selectorAPI.maxLine.get();
            updateAll(selectorAPI, newSelection, histEvent);
        end
    end

    %==============================
    function minPatchButtonDown(varargin)
        
        prevPtr = 'arrow';
        setptr(hFig, 'closedhand')
        
        idButtonMotion = iptaddcallback(hFig, 'windowButtonMotionFcn', ...
            @minPatchMove);
        idButtonUp = iptaddcallback(hFig, 'WindowButtonUpFcn', @minPatchUp);
        
        % Disable pointer manager.
        iptPointerManager(hFig, 'disable');
                
        [startX, startY] = iptui.internal.getCurrentPoint(hAx);
        [startTheta, ~] = cart2pol(startX, startY);
        
        origSelection(1) = selectorAPI.minLine.get();
        origSelection(2) = selectorAPI.maxLine.get();
        
        %============================
        function minPatchUp(varargin)
            setptr(hFig, prevPtr);
            acceptChanges(idButtonMotion, idButtonUp);
        end
        
        %===========================
        function minPatchMove(varargin)
            
            [newX, newY] = iptui.internal.getCurrentPoint(hAx);
            [newTheta, ~] = cart2pol(newX, newY);
            
            deltaTheta = newTheta - startTheta;
            newSelection(1) = wrapSelectionToRange(origSelection(1) + deltaTheta/(2*pi));
            newSelection(2) = selectorAPI.maxLine.get();
            updateAll(selectorAPI, newSelection, histEvent);
        end
    end

    %==============================
    function maxLineButtonDown(varargin)
        
        prevPtr = 'arrow';
        setptr(hFig, 'closedhand')
        
        idButtonMotion = iptaddcallback(hFig, 'windowButtonMotionFcn', ...
            @maxLineMove);
        idButtonUp = iptaddcallback(hFig, 'WindowButtonUpFcn', @maxLineUp);
        
        % Disable pointer manager.
        iptPointerManager(hFig, 'disable');
        
        %============================
        function maxLineUp(varargin)
            setptr(hFig, prevPtr);
            acceptChanges(idButtonMotion, idButtonUp);
        end
        
        %===========================
        function maxLineMove(varargin)
            
            [newX, newY] = iptui.internal.getCurrentPoint(hAx);
            [newTheta, ~] = cart2pol(newX, newY);
            
            newSelection(1) = selectorAPI.minLine.get();
            newSelection(2) = wrapSelectionToRange(newTheta/(2*pi));
            updateAll(selectorAPI, newSelection, histEvent);
        end
    end

    %==============================
    function maxPatchButtonDown(varargin)
        
        prevPtr = 'arrow';
        setptr(hFig, 'closedhand')
        
        idButtonMotion = iptaddcallback(hFig, 'windowButtonMotionFcn', ...
            @maxPatchMove);
        idButtonUp = iptaddcallback(hFig, 'WindowButtonUpFcn', @maxPatchUp);
        
        % Disable pointer manager.
        iptPointerManager(hFig, 'disable');
                
        [startX, startY] = iptui.internal.getCurrentPoint(hAx);
        [startTheta, ~] = cart2pol(startX, startY);
        
        origSelection(1) = selectorAPI.minLine.get();
        origSelection(2) = selectorAPI.maxLine.get();
        
        %============================
        function maxPatchUp(varargin)
            setptr(hFig, prevPtr);
            acceptChanges(idButtonMotion, idButtonUp);
        end
        
        %===========================
        function maxPatchMove(varargin)
            
            [newX, newY] = iptui.internal.getCurrentPoint(hAx);
            [newTheta, ~] = cart2pol(newX, newY);
            
            deltaTheta = newTheta - startTheta;
            newSelection(1) = selectorAPI.minLine.get();
            newSelection(2) = wrapSelectionToRange(origSelection(2) + deltaTheta/(2*pi));
            updateAll(selectorAPI, newSelection, histEvent);
        end
    end

    %=================================================
    function acceptChanges(idButtonMotion, idButtonUp)
        
        iptremovecallback(hFig, 'WindowButtonMotionFcn', idButtonMotion);
        iptremovecallback(hFig, 'WindowButtonUpFcn', idButtonUp);
        
        % Enable the figure's pointer manager.
        iptPointerManager(hFig, 'enable');
    end

end % setUpCallbacksOnSelector

%==========================================================================
function cbk_id_cell = initCursorChangeOverDraggableObjs(client_fig, drag_objs, ptrType)
% initCursorChangeOverDraggableObjs

% initialize variables for function scope
num_of_drag_objs    = numel(drag_objs);

s.enterFcn = @(f,cp) setptr(f, ptrType);
s.traverseFcn = [];
s.exitFcn = @(f,cp) setptr(f, 'arrow');
iptSetPointerBehavior(drag_objs, s);

% Add callback to turn on flag indicating that dragging has stopped.
stop_drag_cbk_id = iptaddcallback(client_fig, ...
    'WindowButtonUpFcn', @stopDrag);

obj_btndwn_fcn_ids = zeros(1, num_of_drag_objs);

% Add callback to turn on flag indicating that dragging has started
for n = 1 : num_of_drag_objs
    obj_btndwn_fcn_ids(n) = iptaddcallback(drag_objs(n), ...
        'ButtonDownFcn', @startDrag);
end

cbk_id_cell = {client_fig, 'WindowButtonUpFcn', stop_drag_cbk_id;...
    drag_objs,  'ButtonDownFcn', obj_btndwn_fcn_ids};


    %==========================
    function startDrag(~,~)
        % Disable the pointer manager while dragging.
        iptPointerManager(client_fig, 'disable');
    end

    %========================
    function stopDrag(~,~)
        % Enable the pointer manager.
        iptPointerManager(client_fig, 'enable');
    end

end % initCursorChangeOverDraggableObjs

%==========================================================================
function updateAll(selectorAPI, newSelection, histEvent)

    % Update the selector components.
    names = fieldnames(selectorAPI);
    for k = 1 : length(names)
        selectorAPI.(names{k}).set(newSelection);
    end

    % Trigger the user-specified callback.
    histEvent.newSelection = newSelection;
    notify(histEvent, 'changed')

end

%==========================================================================
function [patchShapeX, patchShapeY] = getMainPatchShape(currentSelection)

outerCircleDiameter = 1.4;
maxHistLineLength = 1;

resolution = 1/20;  % Minimum that doesn't introduce a wobble.

minTheta = currentSelection(1) * 2 * pi;
maxTheta = currentSelection(2) * 2 * pi;
if (maxTheta <= minTheta)
    maxTheta = maxTheta + 2 * pi;
end

% In order to prevent sampling artifacts, compute the whole range and then
% also at the maximum and minimum theta values explicitly.
[insideCircleX, insideCircleY] = pol2cart(minTheta:resolution:maxTheta, ...
    outerCircleDiameter + 0.05);
[insideCircleMaxX, insideCircleMaxY] = pol2cart(maxTheta, ...
    outerCircleDiameter + 0.05);
[outsideCircleX, outsideCircleY] = pol2cart(maxTheta:-resolution:minTheta, ...
    outerCircleDiameter + maxHistLineLength + 0.15);
[outsideCircleMinX, outsideCircleMinY] = pol2cart(minTheta, ...
    outerCircleDiameter + maxHistLineLength + 0.15);


patchShapeX = [insideCircleX insideCircleMaxX outsideCircleX outsideCircleMinX];
patchShapeY = [insideCircleY insideCircleMaxY outsideCircleY outsideCircleMinY];


end

%==========================================================================
function [x,y] = getMinLine(currentSelection, outerDiameter, maxHistLineLength)
[x(1), y(1)] = pol2cart(currentSelection(1)*2*pi, outerDiameter + 0.05);
[x(2), y(2)] = pol2cart(currentSelection(1)*2*pi, outerDiameter + maxHistLineLength + 0.15);
end

%==========================================================================
function [x,y] = getMaxLine(currentSelection, outerDiameter, maxHistLineLength)
[x(1), y(1)] = pol2cart(currentSelection(2)*2*pi, outerDiameter + 0.05);
[x(2), y(2)] = pol2cart(currentSelection(2)*2*pi, outerDiameter + maxHistLineLength + 0.15);
end

%==========================================================================
function correctedSelection = wrapSelectionToRange(selection)
%wrapSelectionToRange   Ensure selection values are in [0,1].

correctedSelection = rem(selection + 1, 1);

% Make sure values of 1 aren't changed.
mask = (selection == 1);
correctedSelection(mask) = 1;

end

%==========================================================================
function [shapeX, shapeY] = getArrowPatchShape(minSelection, radius, isMin)

% Minimum handles point counterclockwise, while max points clockwise.
if (isMin)
    multiplier = 1;
else
    multiplier = -1;
end

h = arrowHeight();
sweep = 15/360 * (2*pi);
sweepStem = sweep/3;
theta = minSelection * (2*pi);
res = 1/360 * (2*pi);

[xBottomCornerOverLine, yBottomCornerOverLine] = pol2cart(theta, radius + h/4);
[xStemBottom, yStemBottom] = pol2cart(theta + multiplier*(0:res:sweepStem), radius + h/4);
[xArrowheadBottom, yArrowheadBottom] = pol2cart(theta + multiplier*sweepStem, radius);
[xArrowheadPoint, yArrowheadPoint] = pol2cart(theta + multiplier*sweep, radius + 5*h/8); % 5/8 looks better than 1/2
[xArrowheadTop, yArrowheadTop] = pol2cart(theta + multiplier*sweepStem, radius + h);
[xStemTop, yStemTop] = pol2cart(theta + multiplier*(sweepStem:-res:0), radius + 3*h/4);
[xTopCornerOverLine, yTopCornerOverLine] = pol2cart(theta, radius + 3*h/4);

% Require that the vertex pointing toward the circle center is first.
shapeX = [xBottomCornerOverLine, xStemBottom, xArrowheadBottom, xArrowheadPoint, xArrowheadTop, xStemTop, xTopCornerOverLine];
shapeY = [yBottomCornerOverLine, yStemBottom, yArrowheadBottom, yArrowheadPoint, yArrowheadTop, yStemTop, yTopCornerOverLine];

end

%==========================================================================
function diameter = outerRainbowDiameter
%getOuterCircleDiameter   Distance to outside of rainbow.

diameter = 1.4;
end

%==========================================================================
function length = maxHistLineLength
%getMaxHistLineLength   Length of longest line in the histogram.

length = 1;
end

%==========================================================================
function offset = arrowOffset
%arrowOffset   Distance between top of selector and lowest arrow.

offset = 0.2;
end

%==========================================================================
function height = arrowHeight
%arrowHeight   Height of arrow patch.

height = 0.4;
end
