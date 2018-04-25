% Copyright 2016-2017 The MathWorks, Inc.

classdef GriddedAxes < handle
    
    properties
        % BlockSize - Axis is filled with discrete blocks of this size.
        %             Note order: [BlockSizeY, BlockSizeX]
        BlockSize = [100 100]; 
        
        % Layout - Layout of the grid, one of "Row", "Col", or "Auto"
        %
        Layout = "Auto";
        
        % NumBlocks - Total number of blocks needed
        NumBlocks = 0;
        
        hAxes;
        
        % CoalescePeriod - time (in seconds) to wait before after the view
        % port has settled before attempting to replace placeholder
        % thumbnails with real thumbnails.
        %
        CoalescePeriod = 1; % second
    end
          
    properties (SetAccess = private, GetAccess = protected)
        hParent;
        hParentSize;
        
        % GridSize  
        GridSize; 
        
        hHSlider;
        hHSliderScrollListener;
        
        hVSlider;
        hVSliderScrollListener;
        
        % ScrollBarWidth - width of the scroll bars (px)
        ScrollBarWidth = 15; 
        
        % LeftMargin - margin on the left side of the axis (px)
        LeftMargin = 0;
        
        CoalesceTimer = [];        
        
        % State - (of place holders being placed)
        PlacingHolders = false;
    end
    
    methods
        function gax = GriddedAxes(hParent)
            assert(isa(hParent,'matlab.ui.Figure') ...
                || isa(hParent,'matlab.ui.container.Panel'));                        
            gax.hParent = hParent;
            
            % Note SizeChangedFcn is clobbered
            % Client should call 'init' after setting required properties.
            
        end
        
        function delete(gax)
            try
                if ~isempty(gax.CoalesceTimer) && isvalid(gax.CoalesceTimer)
                    stop(gax.CoalesceTimer)
                    delete(gax.CoalesceTimer)
                end
            catch ALL %#ok<NASGU>
                % test timing causes stop to be called while timer is being
                % deleted.
            end
        end
        
        % Create UI elements, should only be called once
        function init(gax)
            gax.hAxes = axes(...
                'Units','pixels',...
                'Position', [ 0 0 1 1],...
                'Ydir', 'reverse',...        % Place origin on top left
                'XLimMode','manual',...
                'YLimMode','manual',...
                'Tag', 'griddedAxes',...
                'XTick', [],...
                'YTick', [],...
                'XColor', 'none',...
                'YColor', 'none',...
                'NextPlot','add',...
                'Parent',gax.hParent);
            
            % Ensure grayscale images show up as such
            colormap(gax.hAxes,gray);
            
            gax.hHSlider = uicontrol('Style','slider',...
                'Units','pixels',...
                'Parent',gax.hParent,...
                'Min', 0,...
                'Max', 1,...
                'Value', 1,...
                'Tag', 'griddedAxesHorizontalSlider',...
                'Visible','off');
            gax.hVSlider = uicontrol('Style','slider',...
                'Units','pixels',...
                'Parent',gax.hParent,...
                'Min', 0,...
                'Max', 1,...
                'Value', 1,...
                'Tag', 'griddedAxesVerticalSlider',...
                'Visible','off');
            
            
            gax.hParent.SizeChangedFcn = @gax.parentSizeChanged;
            
            gax.hHSliderScrollListener = ...
                addlistener(gax.hHSlider,...
                'Value','PostSet',@gax.hSliderScroll);
            gax.hVSliderScrollListener = ...
                addlistener(gax.hVSlider,...
                'Value','PostSet',@gax.vSliderScroll);
            
            % Fit to the initial size of parent
            gax.parentSizeChanged();
        end        
        
        % Recompute axis limits, in-view blocks, issue callbacks for view
        % change. Called on parent size change or block size change.
        function updateGridLayout(gax)
            % Reset Xlim and Ylim. When blocksize changes, ensure we start
            % with a clean limit
            gax.hAxes.XLim(1) = 0;
            gax.hAxes.YLim(1) = 0;
            
            % Find number of blocks that will fit in current view port
            oldUnits = gax.hParent.Units;
            gax.hParent.Units = 'pixels';
            gax.hParentSize = gax.hParent.InnerPosition;
            gax.hParent.Units = oldUnits;
                        
            viewPortLimits = gax.hParentSize(3:4);            
            % Move to Y - X order (height - width order)
            viewPortLimits = fliplr(viewPortLimits);
            
            numVisibleBlocksyx = viewPortLimits./gax.BlockSize;
            
            % GridSize            
            if strcmpi(gax.Layout, "Row")
                gax.GridSize(1) = 1;
                gax.GridSize(2) = gax.NumBlocks;
            elseif strcmpi(gax.Layout, "Col")
                gax.GridSize(1) = gax.NumBlocks;
                gax.GridSize(2) = 1;                
            elseif strcmpi(gax.Layout, "Auto")
                numFullVisibleBlocksyx = floor(numVisibleBlocksyx);
                % Show at least one.
                numFullVisibleBlocksyx = max(1, numFullVisibleBlocksyx);
                if numFullVisibleBlocksyx(1)==1
                    % Switch to 'Row'
                    gax.GridSize(1) = 1;
                    gax.GridSize(2) = gax.NumBlocks;                    
                else                    
                    % Vertical scroll, fill width
                    gax.GridSize(2) = numFullVisibleBlocksyx(2);
                    gax.GridSize(1) = ceil(gax.NumBlocks/numFullVisibleBlocksyx(2));
                    % Show at least one.
                    gax.GridSize = max(1, gax.GridSize);
                end
            else
                assert(false, 'Unsupported layout');
            end
            
            
            axesPosition = [0 0 fliplr(viewPortLimits)];
            
            % Block height is larger than parent
            forceVSliderOn = gax.BlockSize(1)>gax.hParentSize(4);
            
            if forceVSliderOn || (numVisibleBlocksyx(1) < gax.GridSize(1))
                gax.hVSlider.Position = ...
                    [gax.hParentSize(3)-gax.ScrollBarWidth 1 gax.ScrollBarWidth gax.hParentSize(4)];
                gax.hVSlider.Visible = 'on';
                % Shrink along x (width) to account for bar
                viewPortLimits(2) = viewPortLimits(2)-gax.ScrollBarWidth;
                axesPosition(3)   = axesPosition(3)-gax.ScrollBarWidth;
            else
                gax.hVSlider.Visible = 'off';
            end
            
            % Block width is larger than parent
            forceHSliderOn = gax.BlockSize(2)>gax.hParentSize(3);
            
            if forceHSliderOn || (numVisibleBlocksyx(2) < gax.GridSize(2))
                gax.hParentSize = getpixelposition(gax.hParent);
                gax.hHSlider.Position = ...
                    [1 1 gax.hParentSize(3) gax.ScrollBarWidth];
                if(strcmp(gax.hVSlider.Visible,'on'))
                    gax.hHSlider.Position(3) = max(1,gax.hHSlider.Position(3) - gax.ScrollBarWidth);
                end
                gax.hHSlider.Visible = 'on';
                % Shirink along y to account for bar
                viewPortLimits(1) = viewPortLimits(1)-gax.ScrollBarWidth;
                axesPosition(4)   = axesPosition(4)-gax.ScrollBarWidth;
                axesPosition(2)   = gax.ScrollBarWidth;
            else
                gax.hHSlider.Visible = 'off';
            end
                        
            gax.hAxes.Position = axesPosition;
            
            % Compute virtual canvas required to show all blocks
            totalXLim = [0 gax.GridSize(2)*gax.BlockSize(2)];
            totalYLim = [0 gax.GridSize(1)*gax.BlockSize(1)];
            
            % Update axes limits based on slider value. Try growing to
            % lower right
            xLim = gax.hAxes.XLim;
            yLim = gax.hAxes.YLim;
            if(strcmp(gax.hVSlider.Visible,'on'))
                xLim(2) = gax.hAxes.XLim(1)+gax.hParentSize(3)-gax.ScrollBarWidth;
            else
                xLim(2) = gax.hAxes.XLim(1)+gax.hParentSize(3);
            end
            if(strcmp(gax.hHSlider.Visible,'on'))
                yLim(2) = gax.hAxes.YLim(1)+gax.hParentSize(4)-gax.ScrollBarWidth;
            else
                yLim(2) = gax.hAxes.YLim(1)+gax.hParentSize(4);
            end
            
            % Account for edge cases with growing
            if(xLim(2)>totalXLim(2))
                % Right limit reached, grow left if possible
                xLimUnderFlow = xLim(1) + totalXLim(2)-xLim(2);
                if(xLimUnderFlow>0)
                    xLim(1) = xLimUnderFlow;
                    xLim(2) = totalXLim(2);
                end
                %Else - Limit reached on left too. Grow on right anyway.
            end
            if(yLim(2)>totalYLim(2))
                % Bottom limit reached, grow top if possible
                yLimUnderFlow = yLim(1) + totalYLim(2)-yLim(2);
                if(yLimUnderFlow>0)
                    yLim(1) = yLimUnderFlow;
                    yLim(2) = totalYLim(2);
                end
                %Else - Limit reached on top too
            end
            
            % Guard against hParentSize not settling when callbacks are
            % fired
            if diff(yLim)<=0
                yLim(2) = yLim(1)+eps;
            end
            if diff(xLim)<=0
                xLim(2) = xLim(1)+eps;
            end
            gax.hAxes.XLim = xLim;
            gax.hAxes.YLim = yLim;
            
            % Turn off callbacks while updating slider values
            gax.hHSliderScrollListener.Enabled  = false;
            gax.hVSliderScrollListener.Enabled  = false;            
            if strcmp(gax.hVSlider.Visible,'on')
                gax.hVSlider.Min = 0;
                gax.hVSlider.Value = 0;
                % Slider value corresponds to top edge postion. (For the
                % last 'page', top edge position is one 'viewport' height
                % full less than total extent required)
                gax.hVSlider.Max = max(totalYLim(2)-viewPortLimits(1), eps);
                % Vertical slider value is inverted. Limit to 0 incase
                % resize happens on bottom right (slider remains at 0)
                gax.hVSlider.Value = max(gax.hVSlider.Max - gax.hAxes.YLim(1),0);
                
                % One row
                oneRowPercent = gax.BlockSize(1)/gax.hVSlider.Max;
                % One 'page'
                onePagePercent = numVisibleBlocksyx(1)*gax.BlockSize(1)/gax.hVSlider.Max;
                sliderStep = [oneRowPercent, onePagePercent];
                sliderStep(sliderStep<=0) = eps;
                sliderStep(sliderStep>1)  = 1;
                if diff(sliderStep)<=0
                    sliderStep(1) = sliderStep(2)-eps;
                end
                gax.hVSlider.SliderStep = sliderStep;
                
            end
            if strcmp(gax.hHSlider.Visible,'on')
                gax.hHSlider.Min   = 0;
                gax.hHSlider.Value = 0;
                gax.hHSlider.Max   = max(eps,totalXLim(2)-viewPortLimits(2));
                % One col
                oneRowPercent = gax.BlockSize(2)/gax.hHSlider.Max;
                % One 'page'
                onePagePercent = numVisibleBlocksyx(2)*gax.BlockSize(2)/gax.hHSlider.Max;
                sliderStep = [oneRowPercent, onePagePercent];
                sliderStep(sliderStep<=0) = eps;
                sliderStep(sliderStep>1)  = 1;
                if diff(sliderStep)<=0
                    sliderStep(1) = sliderStep(2)-eps;
                end
                gax.hHSlider.SliderStep = sliderStep;                
            end
            % Restore callbacks
            gax.hHSliderScrollListener.Enabled  = true;
            gax.hVSliderScrollListener.Enabled  = true;
                        
            % Required left padding
            if numVisibleBlocksyx(2)>1 && gax.GridSize(1)~=1
                gax.LeftMargin = gax.hParentSize(3) - floor(numVisibleBlocksyx(2))*gax.BlockSize(2);
                % Distributed on left and right
                gax.LeftMargin = gax.LeftMargin/2;
            else
                gax.LeftMargin = 1;
            end
            
            % Position of all previously visible/created blocks will no
            % longer be valid
            gax.positionsInvalidated();
            
            gax.updateViewPortWithPlaceHolders();
        end
        
        % Mouse wheel scroll
        function mouseWheelFcn(gax, ~, hEvent)
            if strcmp(gax.hVSlider.Visible,'on')
                % Vertical scroll                
                oneBlockScrollAmount = gax.BlockSize(1);
                newValue = gax.hVSlider.Value...
                    - (hEvent.VerticalScrollCount * oneBlockScrollAmount);
                newValue = min(gax.hVSlider.Max, newValue);
                newValue = max(gax.hVSlider.Min, newValue);
                gax.hVSlider.Value = newValue;
                
            elseif strcmp(gax.hHSlider.Visible,'on')
                % Horizontal scroll
                oneBlockScrollAmount = gax.BlockSize(2);
                newValue = gax.hHSlider.Value ...
                    + (hEvent.VerticalScrollCount * oneBlockScrollAmount);
                newValue = min(gax.hHSlider.Max, newValue);
                newValue = max(gax.hHSlider.Min, newValue);
                gax.hHSlider.Value = newValue;
            end
        end
        
        % Scroll to ensure blockNum is in visible view port
        function scrollToBlockNum(gax, blockNum)
                        
            [rowInd, colInd] = gax.blockNum2yx(blockNum);
            
            % Number of (possibly partial) blocks that fit in viewport
            numBlocksY = diff(gax.hAxes.YLim)/gax.BlockSize(1);
            numBlocksX = diff(gax.hAxes.XLim)/gax.BlockSize(2);
            
            % Visible block bounds of current view port
            topVisibleRow    = ceil(gax.hAxes.YLim(1)/gax.BlockSize(1));
            leftVisibleCol   = ceil(gax.hAxes.XLim(1)/gax.BlockSize(2));
            bottomVisibleRow = floor(gax.hAxes.YLim(2)/gax.BlockSize(1));
            rightVisibleCol  = floor(gax.hAxes.XLim(2)/gax.BlockSize(2));
            
            if strcmp(gax.hVSlider.Visible,'on')
                if rowInd<=topVisibleRow
                    % Ensure rowInd is top row
                    requiredTopRow = rowInd-1;
                    requiredTopYLim = requiredTopRow*gax.BlockSize(1);
                    requiredTopYLim = max(requiredTopYLim, gax.hVSlider.Min);
                    requiredTopYLim = min(requiredTopYLim, gax.hVSlider.Max);
                    % V slider value is inverted
                    gax.hVSlider.Value = gax.hVSlider.Max-requiredTopYLim;
                elseif rowInd>=bottomVisibleRow
                    % Ensure rowInd is bottom row
                    requiredTopRow = rowInd-numBlocksY;
                    requiredTopYLim = requiredTopRow*gax.BlockSize(1);
                    requiredTopYLim = max(requiredTopYLim, gax.hVSlider.Min);
                    requiredTopYLim = min(requiredTopYLim, gax.hVSlider.Max);
                    % V slider value is inverted
                    gax.hVSlider.Value = gax.hVSlider.Max-requiredTopYLim;
                end
            end
            
            if strcmp(gax.hHSlider.Visible,'on')
                if colInd<=leftVisibleCol
                    % Ensure colInd is left col
                    requiredLeftCol = colInd-1;
                    requiredLeftXLim = requiredLeftCol*gax.BlockSize(2);
                    requiredLeftXLim = max(requiredLeftXLim, gax.hHSlider.Min);
                    requiredLeftXLim = min(requiredLeftXLim, gax.hHSlider.Max);
                    gax.hHSlider.Value = requiredLeftXLim;
                    
                elseif colInd>=rightVisibleCol
                    % Ensure colInd is right col
                    requiredLeftCol = colInd-numBlocksX;
                    requiredLeftXLim = requiredLeftCol*gax.BlockSize(2);
                    requiredLeftXLim = max(requiredLeftXLim, gax.hHSlider.Min);
                    requiredLeftXLim = min(requiredLeftXLim, gax.hHSlider.Max);
                    gax.hHSlider.Value = requiredLeftXLim;
                end
            end
        end
    end
    
    methods % helpers
        function [by, bx] = blockNum2yx(gax, blockNum)
            by = ceil(blockNum/gax.GridSize(2));
            bx = blockNum-(by-1)*gax.GridSize(2);
        end                
        
        function blockNum = getCurrentClickBlock(gax)
            axesPointYX    = gax.hAxes.CurrentPoint(1,2:-1:1);
            axesPointYX(2) = axesPointYX(2)-gax.LeftMargin;
            thumnailExtent = gax.GridSize.*gax.BlockSize;
            blockNum = Inf;
            if all(axesPointYX<thumnailExtent) && all(axesPointYX>0)
                blockYX = ceil(axesPointYX./gax.BlockSize);
                blockNum = (blockYX(1)-1)*gax.GridSize(2)+blockYX(2);
            end            
        end
        
        function topLeftYXs = getTopLeftYX(gax, blockNums)
            topLeftYXs = zeros(numel(blockNums),2);
            for ind = 1:numel(blockNums)
                blockNum = blockNums(ind);
                [by, bx] = gax.blockNum2yx(blockNum);
                px = (bx-1)*gax.BlockSize(2)+gax.LeftMargin;
                py = (by-1)*gax.BlockSize(1);
                topLeftYXs(ind,1) = py;
                topLeftYXs(ind,2) = px;
            end
        end
        
    end
    
    
    methods (Abstract)
        % Called on each block thats visible in a changed viewport
        putPlaceHolders(gax, topLeftYX, blockNum);
        putActual(gax, topLeftYX, blockNum);
        % Grid layout has changed, all positions of existing blocks are
        % invalid
        positionsInvalidated(gax);        
    end
    
    methods (Access = private)
        function parentSizeChanged(gax,~,~)
            oldUnits = gax.hParent.Units;
            gax.hParent.Units = 'pixels';
            newSize = gax.hParent.InnerPosition;
            gax.hParent.Units = oldUnits;
            if(isequal(gax.hParentSize, newSize))
                % Already handled
                return;
            end
            gax.hParentSize = newSize;            
            gax.updateGridLayout();
        end
        
        function hSliderScroll(gax, ~, ~)
            % Update axes limits
            % Assume slider Value controls left position
            curWidth = diff(gax.hAxes.XLim);
            gax.hAxes.XLim = [gax.hHSlider.Value,...
                gax.hHSlider.Value+max(curWidth, eps(gax.hHSlider.Value))];
            gax.updateViewPortWithPlaceHolders();
        end
        
        function vSliderScroll(gax, ~, ~)
            curHeight = max(diff(gax.hAxes.YLim),1);
            % Bottom is 0
            v = gax.hVSlider.Max - gax.hVSlider.Value;
            gax.hAxes.YLim = [v v+curHeight];
            gax.updateViewPortWithPlaceHolders();
        end
        
        function [topLeftYXs, oneBasedBlockNums] = inViewBlockDetails(gax)
            % Zero based subscripts
            xSubLims = [floor(gax.hAxes.XLim(1)/gax.BlockSize(2)), ...
                floor(gax.hAxes.XLim(2)/gax.BlockSize(2))];
            ySubLims = [floor(gax.hAxes.YLim(1)/gax.BlockSize(1)), ...
                floor(gax.hAxes.YLim(2)/gax.BlockSize(1))];
            
            % Limit subs to GridSize
            ySubLims(2) = min(gax.GridSize(1)-1, ySubLims(2));
            xSubLims(2) = min(gax.GridSize(2)-1, xSubLims(2));
            
            xSubs = xSubLims(1):xSubLims(2);
            ySubs = (ySubLims(1):ySubLims(2))';
            oneBasedBlockNums = xSubs + ySubs.*gax.GridSize(2)+ 1;
            % Trim
            oneBasedBlockNums = oneBasedBlockNums(oneBasedBlockNums>0 & oneBasedBlockNums<=gax.NumberOfThumbnails);
            topLeftYXs = getTopLeftYX(gax, oneBasedBlockNums);
        end
        
        function updateViewPortWithPlaceHolders(gax)
            gax.PlacingHolders = true;
            
            [topLeftYXs, oneBasedBlockNums] = gax.inViewBlockDetails();
            
            % Call update on each block to place the placeholder
            for ind =1:numel(oneBasedBlockNums)
                gax.putPlaceHolders(topLeftYXs(ind,:),...
                    oneBasedBlockNums(ind));
            end
            
            % Start/reset timer to put in actual block content after a delay
            if ~isempty(gax.CoalesceTimer) && isvalid(gax.CoalesceTimer)
                stop(gax.CoalesceTimer)
                delete(gax.CoalesceTimer)
            end
            
            gax.CoalesceTimer = timer(...
                'ExecutionMode','singleShot',...
                'StartDelay',gax.CoalescePeriod,...
                'TimerFcn',@(varargin)gax.updateViewPortWithActuals());
            start(gax.CoalesceTimer);
        end
        
        function updateViewPortWithActuals(gax)
            % Reset placing holder status
            gax.PlacingHolders = false;
            
            try
                [topLeftYXs, oneBasedBlockNums] = gax.inViewBlockDetails();
                % Call update on each block to place real content
                for ind =1:numel(oneBasedBlockNums)
                    % Allow other callbacks (scrolling etc), if view port
                    % changes, PlacingHolders will get set
                    iptui.internal.imageBrowser.drawnowWrapper();
                    
                    if gax.PlacingHolders
                        % More changes happening, place real content in
                        % blocks after they settle
                        break;
                    end
                    
                    gax.putActual(topLeftYXs(ind,:),...
                        oneBasedBlockNums(ind));
                end
            catch ALL %#ok<NASGU>
                %delete doesnt get called, hence timers are not
                %deleted and this method fails (when tool has already
                %closed)
            end
        end
        
    end
    
end