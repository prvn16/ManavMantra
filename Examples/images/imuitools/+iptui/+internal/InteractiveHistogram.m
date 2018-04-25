%InteractiveHistogram  Histogram display with selection box.

%   Copyright 2013-2015 The MathWorks, Inc.

classdef InteractiveHistogram < handle
    
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
        
        function obj = InteractiveHistogram(hParent, data, varargin)
            % OBJ = InteractiveHistogram(PARENT, DATA) creates an
            % interactive histogram object for DATA, which should be a
            % single channel of an image. The histogram plot and selector
            % will be a child of PARENT, which must already exist.
            %
            % OBJ = InteractiveHistogram(PARENT, DATA, 'saturation') plots
            % the histogram with lines whose colors correspond to a typical
            % saturation for a color with the same saturation in the HSV
            % color model as DATA.
            %
            % OBJ = InteractiveHistogram(PARENT, DATA, 'LStar',label) plots
            % the histogram with lines whose colors correspond to the L*
            % values in the CIELAB color model.
            %
            % OBJ = InteractiveHistogram(PARENT, DATA, 'aStar') and
            % OBJ = InteractiveHistogram(PARENT, DATA, 'bStar') plot the
            % histogram with lines whose colors correspond to the a* or b*
            % values in the CIELAB color model.
            %
            % OBJ = InteractiveHistogram(PARENT, DATA, 'Cb') and
            % OBJ = InteractiveHistogram(PARENT, DATA, 'Cr') plot the
            % histogram with lines whose colors correspond to the Cb or Cr
            % values in the YCbCb color model.
            %
            % OBJ = InteractiveHistogram(PARENT, DATA, 'normal', LABEL)
            % plots the Histogram using one solid color for all lines in
            % the plot. This is the default. LABEL should be a short string
            % that will appear next to the histogram.
            %
            % OBJ = InteractiveHistogram(PARENT, DATA, 'BlackToWhite', LABEL)
            % plots the histogram using a dark-to-light, not-quite-gray
            % colormap for good visual separation from neutral backgrounds.
            % LABEL is a short string that will appear next to
            % the histogram.
            %
            % OBJ = InteractiveHistogram(PARENT, DATA, 'ramp', {MINRGB, MAXRGB}, LABEL)
            % plots the histogram using a linear spaced RGB color ramp
            % between MINRGB and MAXRGB. LABEL is a short string that will appear
            % next to the histogram.
            
            narginchk(2, 5);
            
            % Set the handles that point at existing UI objects.
            obj.parent = hParent;
            
            % Construct the histogram view.
            histStruct = iptui.internal.getHistogramDataRaw(data);
            
            % If image data is constant, manually set range for L*a*b* to
            % full range.
            if histStruct.xMin==histStruct.xMax && nargin>2
                switch varargin{1}
                    case 'LStar'
                        histStruct.histRange = [0 100];
                    case {'aStar','bStar'}
                        histStruct.histRange = [-100 100];
                end
            end
            obj.histRange  = histStruct.histRange;
            obj.histBins   = histStruct.finalBins;
            obj.histCounts = histStruct.counts;
            
            obj.hPanel = uipanel('Parent', obj.parent, ...
                'Units', 'normalized');
            
            iptui.internal.setChildColorToMatchParent(obj.hPanel, obj.parent);
            obj.hAx = createHistogram(obj.hPanel, histStruct, varargin{:});
            
            iptPointerManager(ancestor(obj.parent, 'figure'))
            
            % Create the selection patch.
            obj.currentSelection = obj.histRange;
            
            maxCounts = max(obj.histCounts);
            obj.selectorAPI = createSelector(obj.hAx, obj.currentSelection, obj.histRange, maxCounts);
            
            % Set up callbacks
            histEvent = iptui.internal.HistogramChanged();
            obj.selectorAPI = setUpCallbacksOnSelector(obj.selectorAPI, obj.hAx, obj.histRange, histEvent);
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
function hAx = createHistogram(parentForAxes, histStruct, varargin)

% Set the color modes for the histogram.
if (nargin == 2)
    colorDisplayMode = 'normal';
    rampRange = {};
    label = '';
elseif (nargin == 3)
    colorDisplayMode = varargin{1};
    rampRange = {};
    label = '';
elseif (nargin == 4)
    colorDisplayMode = varargin{1};
    rampRange = {};
    label = varargin{2};
elseif (nargin == 5)
    colorDisplayMode = varargin{1};
    rampRange = varargin{2};
    label = varargin{3};
else
    assert(false, 'Bad calling syntax to constructor')
end

% Create axes for histogram.
axColor = iptui.internal.histogramAxesColor();
hAx = axes('Parent', parentForAxes, ...
    'color', axColor, ...
    'ZTick', [], ...
    'ZColor', axColor);

% Create a colormap to use for the color coding of the histogram bars.
numBins = numel(histStruct.finalBins);

switch (colorDisplayMode)
    case 'normal'
        cmap = zeros([numBins, 3]);
        
    case 'ramp'
        rRamp = linspace(rampRange{1}(1), rampRange{2}(1), numBins);
        gRamp = linspace(rampRange{1}(2), rampRange{2}(2), numBins);
        bRamp = linspace(rampRange{1}(3), rampRange{2}(3), numBins);
        cmap = [rRamp(:) gRamp(:) bRamp(:)];
        
    case 'saturation'
        sRamp = reshape(linspace(0, 1, numBins), [], 1);
        cmap = hsv2rgb([ones(size(sRamp)) sRamp ones(size(sRamp))]);  % HSV = [1 s 1];
        
        label = 'S';
        
    case 'aStar'
        aStarRamp = linspace(histStruct.finalBins(1), histStruct.finalBins(end), numBins);
        aStarRamp = aStarRamp(:);
        cmapLab = [90*ones(size(aStarRamp)), aStarRamp, zeros(size(aStarRamp))];
        cmap = double(images.internal.Lab2sRGB(cmapLab));
        cmap(cmap>1) = 1;
        cmap(cmap<0) = 0;
        
        label = 'a*';
        
    case 'bStar'
        bStarRamp = linspace(histStruct.finalBins(1), histStruct.finalBins(end), numBins);
        bStarRamp = bStarRamp(:);
        cmapLab = [90*ones(size(bStarRamp)), zeros(size(bStarRamp)), bStarRamp];
        cmap = double(images.internal.Lab2sRGB(cmapLab));
        cmap(cmap>1) = 1;
        cmap(cmap<0) = 0;
        
        label = 'b*';
        
        set(hAx, 'Tag', 'bStar'); % Required for testing.
        
    case 'Cb'
        cbRamp = linspace(histStruct.finalBins(1), histStruct.finalBins(end), numBins);
        cbRamp = cbRamp(:);
        if (max(cbRamp) <= 1)
            % Double in range [0,1]
            cmapYCbCr = [225/255 * ones(size(cbRamp)), cbRamp, max((175/255 - (175/225)*cbRamp), 0)];
            cmap = ycbcr2rgb(cmapYCbCr);
        elseif (max(cbRamp) > 255)
            % uint16 range
            cmapYCbCr = uint16([225*255*ones(size(cbRamp)), cbRamp, 175*255-(175/225)*cbRamp]);
            cmap = double(ycbcr2rgb(cmapYCbCr)) ./ 65535;
        else
            % uint8 range
            cmapYCbCr = uint8([225*ones(size(cbRamp)), cbRamp, 175-(175/225)*cbRamp]);
            cmap = double(ycbcr2rgb(cmapYCbCr)) ./ 255;
        end
        
        label = 'Cb';
        
    case 'Cr'
        crRamp = linspace(histStruct.finalBins(1), histStruct.finalBins(end), numBins);
        crRamp = crRamp(:);
        if (max(crRamp) <= 1)
            % Double in range [0,1]
            cmapYCbCr = [175/255 * ones(size(crRamp)), crRamp, crRamp];
            cmap = ycbcr2rgb(cmapYCbCr);
        elseif (max(crRamp) > 255)
            % uint16 range
            cmapYCbCr = uint16([175*255*ones(size(crRamp)), crRamp, crRamp]);
            cmap = double(ycbcr2rgb(cmapYCbCr)) ./ 65535;
        else
            % uint8 range
            cmapYCbCr = uint8([175*ones(size(crRamp)), crRamp, crRamp]);
            cmap = double(ycbcr2rgb(cmapYCbCr)) ./ 255;
        end
        
        label = 'Cr';
        
    case {'LStar','BlackToWhite'}
        % Use a slightly off-neutral colormap for better visual separation
        % from gray.
        cmap = bone(numBins);
        
    otherwise
        assert(false, 'Unrecognized colorDisplayMode ''%s''', colorDisplayMode)
end

% Plot the histogram as multiple lines with their own color.
lineWidth = 2;
for p = 1:numBins
    location = histStruct.finalBins(p);
    height = histStruct.counts(p);
    rgb = cmap(p,:);
    line([location location], [0 height], 'Color', rgb, 'LineWidth', lineWidth, 'Parent', hAx);
end

maxCount = max(histStruct.counts);

set(hAx, 'YTick', []);
set(hAx, 'YLim', [0 maxCount]);

switch (colorDisplayMode)
    case {'aStar', 'bStar'}
        minValue = min(floor(histStruct.xMin), -100);
        maxValue = max(ceil(histStruct.xMax), 100);
        set(hAx, 'XLim', double([minValue maxValue]));
    otherwise
        set(hAx, 'XLim', double(histStruct.histRange));
end


% Turn off HitTest of the histogram so it doesn't intercept button
% down events - g330176,g412094
hHistogram = findobj(parentForAxes, 'type', 'hggroup','-or',...
    'type','line');
set(hHistogram, 'HitTest', 'off');

if (~isempty(label))
    iptui.internal.addLabelToHistogram(hAx, label)
end

end

%==========================================================================
function selectorAPI = createSelector(hAx, selection, histRange, maxCounts)
%createSelector  Create draggable selection window over the histogram
%   selectorAPI = createSelector(hAx, selection, maxCounts) creates a
%   draggable window on the axes specified by the handle HAX.

% Divide the selector's parts into upper and lower parts to make sure that
% the right things are pickable.
bottom = 1;
top = 2;

faceAlpha = 0;
edgeAlpha = 0.4;
selectorBorderThickness = 1.5;
edgeColor = [1 0 0]; % Red

% The main selection patch.
hPatch = patch([selection(1) selection(1) selection(2) selection(2)], ...
    [0 maxCounts maxCounts 0], [1 1 1], ...
    'parent', hAx, ...
    'zData', ones(1,4) * bottom, ...
    'LineWidth', selectorBorderThickness, ...
    'tag', 'window patch', ...
    'EdgeColor', edgeColor, ...
    'EdgeAlpha', edgeAlpha, ...
    'FaceAlpha', faceAlpha);

% The left- and right-hand deselected regions.
deselectedFaceColor = get(hAx, 'Color');
deselectedFaceAlpha = 0.5;

% Make sure that patch is draggable
hPatch.PickableParts = 'all';

x1 = histRange(1);
x2 = selection(1);
hDeselectedPatchL = patch([x1 x1 x2 x2], [0 maxCounts maxCounts 0], deselectedFaceColor, ...
    'parent', hAx, ...
    'edgeColor', deselectedFaceColor, ...
    'edgeAlpha', deselectedFaceAlpha, ...
    'FaceAlpha', deselectedFaceAlpha, ...
    'zData', ones([1 4]) * bottom, ...
    'tag', 'left deselected patch');

x1 = selection(2);
x2 = histRange(2);
hDeselectedPatchR = patch([x1 x1 x2 x2], [0 maxCounts maxCounts 0], deselectedFaceColor, ...
    'parent', hAx, ...
    'edgeColor', deselectedFaceColor, ...
    'edgeAlpha', deselectedFaceAlpha, ...
    'FaceAlpha', deselectedFaceAlpha, ...
    'zData', ones([1 4]) * bottom, ...
    'tag', 'right deselected patch');


% Minimum and maximum selection handles. (Useful when min is near max.)
selectorColor = iptui.internal.selectorColor;

[xMinShape, yMinShape] = getSidePatchShape(maxCounts, histRange, true);
hMinPatch = patch(double(histRange(1)) + xMinShape, yMinShape, selectorColor, ...
    'parent', hAx, ...
    'zData', ones(size(xMinShape)) * top, ...
    'tag', 'min patch');

[xMaxShape, yMaxShape] = getSidePatchShape(maxCounts, histRange, false);
hMaxPatch = patch(double(histRange(2)) - xMaxShape, yMaxShape, selectorColor, ...
    'parent', hAx, ...
    'zData', ones(size(xMaxShape)) * top, ...
    'tag', 'max patch');

% Min and max lines.
hMinLine = line('parent', hAx, ...
    'LineWidth', selectorBorderThickness, ...
    'tag', 'min line', ...
    'xdata', [selection(1) selection(1)], ...
    'ydata', [0 maxCounts], ...
    'ZData', ones(1,2) * bottom, ...
    'color', selectorColor);

hMaxLine = line('parent', hAx, ...
    'LineWidth', selectorBorderThickness, ...
    'tag', 'max line', ...
    'xdata', [selection(2) selection(2)], ...
    'ydata', [0 maxCounts], ...
    'ZData', ones(1,2) * bottom, ...
    'color', selectorColor);

createselectorAPI();

%=======================
    function createselectorAPI
        
        selectorAPI.maxLine.handle = hMaxLine;
        selectorAPI.maxLine.get    = @() getXLocation(hMaxLine);
        selectorAPI.maxLine.set    = @(selection) setXLocation(hMaxLine,selection(2));
        
        selectorAPI.minLine.handle = hMinLine;
        selectorAPI.minLine.get    = @() getXLocation(hMinLine);
        selectorAPI.minLine.set    = @(selection) setXLocation(hMinLine,selection(1));
        
        selectorAPI.maxPatch.handle = hMaxPatch;
        selectorAPI.maxPatch.get    = @() getXLocation(hMaxPatch);
        selectorAPI.maxPatch.set    = @setmaxPatch;
        
        selectorAPI.minPatch.handle = hMinPatch;
        selectorAPI.minPatch.get    = @() getXLocation(hMinPatch);
        selectorAPI.minPatch.set    = @setminPatch;
        
        selectorAPI.bigPatch.handle = hPatch;
        selectorAPI.bigPatch.get    = @() getXLocation(hPatch);
        selectorAPI.bigPatch.set    = @setPatch;
        
        selectorAPI.deselectedPatchL.handle = hDeselectedPatchL;
        selectorAPI.deselectedPatchL.get    = @() getXLocation(hDeselectedPatchL);
        selectorAPI.deselectedPatchL.set    = @setDeselectedPatchL;
        
        selectorAPI.deselectedPatchR.handle = hDeselectedPatchR;
        selectorAPI.deselectedPatchR.get    = @() getXLocation(hDeselectedPatchR);
        selectorAPI.deselectedPatchR.set    = @setDeselectedPatchR;
        
        %==========================
        function setmaxPatch(selection)
            xData = getSidePatchShape(maxCounts, histRange, true);
            set(hMaxPatch, 'XData', double(selection(2)) - xData);
        end
        
        %==========================
        function setminPatch(selection)
            xData = getSidePatchShape(maxCounts, histRange, false);
            set(hMinPatch, 'XData', double(selection(1)) +  xData);
        end
        
        %==========================
        function setPatch(selection)
            set(hPatch, 'XData', [selection(1) selection(1) selection(2) selection(2)]);
        end
        
        %==========================
        function setDeselectedPatchL(selection)
            xData = get(hDeselectedPatchL, 'XData');
            xData(3:4) = selection(1);
            set(hDeselectedPatchL, 'XData', xData);
        end
        
        %==========================
        function setDeselectedPatchR(selection)
            xData = get(hDeselectedPatchR, 'XData');
            xData(1:2) = selection(2);
            set(hDeselectedPatchR, 'XData', xData);
        end
        
        %===========================
        function value = getXLocation(h)
            value = get(h,'xdata');
            value = value(1);
        end
        
        %========================
        function setXLocation(h,value)
            % these are the same because we are setting the location of a
            % vertical line
            set(h,'XData',[value value]);
        end
        
    end %createselectorAPI
end %createClimWindowOnAxes

%==========================================================================
function selectorAPI = setUpCallbacksOnSelector(selectorAPI, hAx, histRange, histEvent)

isFloatingPointData = isa(histRange, 'double') || isa(histRange, 'single');
hFig = ancestor(hAx, 'figure');

set(selectorAPI.maxLine.handle,  'ButtonDownFcn', @minMaxLineDown)
set(selectorAPI.minLine.handle,  'ButtonDownFcn', @minMaxLineDown)
set(selectorAPI.maxPatch.handle, 'ButtonDownFcn', @minMaxPatchDown)
set(selectorAPI.minPatch.handle, 'ButtonDownFcn', @minMaxPatchDown)
set(selectorAPI.bigPatch.handle, 'ButtonDownFcn', @bigPatchDown)

% Set the mouse-over pointer behaviors.
draggableObjList = [selectorAPI.maxLine.handle
    selectorAPI.minLine.handle
    selectorAPI.minPatch.handle
    selectorAPI.maxPatch.handle];
initCursorChangeOverDraggableObjs(hFig, draggableObjList, 'lrdrag');

draggableObjList = selectorAPI.bigPatch.handle;
initCursorChangeOverDraggableObjs(hFig, draggableObjList, 'fleur');

%====================================
    function minMaxLineDown(src,varargin)
        
        if src == selectorAPI.maxLine.handle
            isMaxLine = true;
        else
            isMaxLine = false;
        end
        
        idButtonMotion = iptaddcallback(hFig, 'WindowButtonMotionFcn', ...
            @minMaxLineMove);
        idButtonUp = iptaddcallback(hFig, 'WindowButtonUpFcn', ...
            @minMaxLineUp);
        
        % Disable pointer manager.
        iptPointerManager(hFig, 'disable');
        
        %==============================
        function minMaxLineUp(varargin)
            
            acceptChanges(idButtonMotion, idButtonUp);
        end
        
        %====================================
        function minMaxLineMove(~,varargin)
            
            xpos = double(iptui.internal.getCurrentPoint(hAx));
            if isMaxLine
                newMax = xpos;
                newMin = selectorAPI.minLine.get();
            else
                newMin = xpos;
                newMax = selectorAPI.maxLine.get();
            end
            
            newSelection = validateSelection([newMin newMax], ~isMaxLine, histRange, isFloatingPointData);
            updateAll(selectorAPI, newSelection, histEvent);
            if isequal(newSelection(1), xpos) || isequal(newSelection(2), xpos)
                updateAll(selectorAPI, newSelection, histEvent);
            end
        end
    end %lineButtonDown

%======================================
    function minMaxPatchDown(src, varargin)
        
        if isequal(src, selectorAPI.minPatch.handle)
            srcLine = selectorAPI.minLine;
            minPatchMoved = true;
        else
            srcLine = selectorAPI.maxLine;
            minPatchMoved = false;
        end
        
        startX = iptui.internal.getCurrentPoint(hAx);
        oldX = srcLine.get();
        
        idButtonMotion = iptaddcallback(hFig, 'WindowButtonMotionFcn', ...
            @minMaxPatchMove);
        idButtonUp = iptaddcallback(hFig, 'WindowButtonUpFcn', ...
            @minMaxPatchUp);
        
        % Disable pointer manager.
        iptPointerManager(hFig, 'disable');
        
        %===============================
        function minMaxPatchUp(varargin)
            
            acceptChanges(idButtonMotion, idButtonUp);
        end
        
        %======================================
        function minMaxPatchMove(~, varargin)
            
            newX = double(iptui.internal.getCurrentPoint(hAx));
            delta = newX - startX;
            
            % Set the window endpoints.
            if minPatchMoved
                minX = oldX + delta;
                maxX = selectorAPI.maxLine.get();
            else
                maxX = oldX + delta;
                minX = selectorAPI.minLine.get();
            end
            newSelection = validateSelection([minX maxX], minPatchMoved, histRange, isFloatingPointData);
            updateAll(selectorAPI, newSelection, histEvent);
        end
    end %minMaxPatchDown

%==============================
    function bigPatchDown(varargin)
        
        idButtonMotion = iptaddcallback(hFig, 'windowButtonMotionFcn', ...
            @bigPatchMove);
        idButtonUp = iptaddcallback(hFig, 'WindowButtonUpFcn', @bigPatchUp);
        
        % Disable pointer manager.
        iptPointerManager(hFig, 'disable');
        
        startX = get(hAx, 'CurrentPoint');
        oldMinX = selectorAPI.minLine.get();
        oldMaxX = selectorAPI.maxLine.get();
        
        %============================
        function bigPatchUp(varargin)
            
            acceptChanges(idButtonMotion, idButtonUp);
        end
        
        %===========================
        function bigPatchMove(varargin)
            
            newX = iptui.internal.getCurrentPoint(hAx);
            delta = newX(1) - startX(1);
            
            % Set the window endpoints.
            newMin = double(oldMinX) + delta;
            newMax = double(oldMaxX) + delta;
            
            % Don't let window shrink when dragging the window patch.
            %origWidth = getWidthOfWindow;
            origWidth = oldMaxX - oldMinX;
            
            if newMin < histRange(1)
                newMin = histRange(1);
                newMax = newMin + origWidth;
            end
            
            if newMax > histRange(2)
                newMax = histRange(2);
                newMin = newMax - origWidth;
            end
            newSelection = validateSelectionPatch([newMin newMax], [oldMinX oldMaxX], histRange, isFloatingPointData);
            updateAll(selectorAPI, newSelection, histEvent);
        end
    end %bigPatchDown

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

enterFcn = @(f,cp) setptr(f, ptrType);
iptSetPointerBehavior(drag_objs, enterFcn);

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
function newSelection = validateSelection(selection, minMovedTF, histRange, isFloatingPointData)

% Prevent new endpoints from exceeding the min and max of the histogram
% range. Don't want to get to the actual endpoints because there is a
% problem with the painters renderer and patchs at the edge (g298973).
newMin = max(selection(1), histRange(1));
newMax = min(selection(2), histRange(2));

% Keep min < max
if ( ((newMax - 1) < newMin) && ~isFloatingPointData )
    
    % Stop at limiting value.
    if (minMovedTF)
        newMin = newMax;
    else
        newMax = newMin;
    end
    
    %Made this less than or equal to as a possible workaround to g226780
elseif ( (newMax <= newMin) && isFloatingPointData )
    
    % Stop at limiting value.
    if (minMovedTF)
        newMin = newMax;
    else
        newMax = newMin;
    end
end

newSelection = [newMin newMax];

end

%==========================================================================
function newSelection = validateSelectionPatch(newSelection, oldSelection, histRange, isFloatingPointData)

% Prevent new endpoints from exceeding the min and max of the histogram
% range. Don't want to get to the actual endpoints because there is a
% problem with the painters renderer and patchs at the edge (g298973).
newMin = max(newSelection(1), histRange(1));
newMax = min(newSelection(2), histRange(2));

% Keep min < max
if ( ((newMax - 1) < newMin) && ~isFloatingPointData )
    % Stop at limiting value.
    newMin = min(newMin, oldSelection(2));
    newMax = max(newMax, oldSelection(1));
    
    %Made this less than or equal to as a possible workaround to g226780
elseif ( (newMax <= newMin) && isFloatingPointData )
    % Stop at limiting value.
    newMin = min(newMin, newMax);
    newMax = min(newMin, newMax);
end


newSelection = [newMin newMax];
end

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
function [xShape, yShape] = getSidePatchShape(maxCounts, histRange, isMin)

% Determine height and width based on the histogram X and Y data extents.

% Use 20% of Y height and 4% of the total width for each handle (2% on each
% side of the min/max line).
height = 0.2 * maxCounts;
width = diff(double(histRange)) * 0.02;

% Put the patches at different heights so that they don't collide.
if (isMin)
    yLoc = 0.4*maxCounts - height/2;
else
    yLoc = 0.6*maxCounts - height/2;
end

% Ensure that the first point in the patch is directly over the min/max
% line, even though it isn't a necessary vertex of the patch. This makes it
% possible to query the patch's position and get the X location (min/max).
xShape = [0 -width -width width width];
yShape = yLoc + [0 0 height height 0];

end
