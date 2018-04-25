function hout = impixelregion(h)
%IMPIXELREGION Pixel Region tool.
%   IMPIXELREGION creates a Pixel Region tool associated with the
%   image displayed in the current figure, called the target image.
%
%   The Pixel Region tool opens a separate figure window containing
%   an extreme close-up view of a small region of pixels in the
%   target image. The tool superimposes the numeric value of the pixel
%   over each pixel. To define the region being examined, the tool overlays
%   a rectangle on the target image, called the pixel region rectangle.
%   To view pixels in a different region, click and drag the rectangle
%   over the target image.
%
%   IMPIXELREGION(H) creates a Pixel Region tool associated with the
%   image specified by the handle H. H may be an image, axes, uipanel,
%   or figure handle.  If H is an axes or figure handle, IMPIXELREGION
%   uses the first image found in the axes or figure.
%
%   HFIGURE = IMPIXELREGION(...) returns the handle of the figure
%   containing the Pixel Region tool.
%
%   Note
%   ----
%   To create a Pixel Region tool that can be embedded in an existing
%   figure window or uipanel, use IMPIXELREGIONPANEL.
%
%   Example
%   -------
%
%      imshow peppers.png
%      impixelregion
%
%   See also IMPIXELINFO, IMPIXELREGIONPANEL, IMTOOL.

%   Copyright 2004-2016 The MathWorks, Inc.

% validate input
if nargin < 1
    hFig = get(0,'CurrentFigure');
    hAx  = get(hFig,'CurrentAxes');
    hIm = findobj(hAx,'Type','image');
else
    iptcheckhandle(h,{'image','axes','figure','uipanel'},mfilename,'H',1);
    hIm = imhandles(h);
    if numel(hIm) > 1
        hIm = hIm(1);
    end
    hFig = ancestor(hIm,'figure');
    hAx  = ancestor(hIm,'axes');
end
if isempty(hIm)
    error(message('images:impixelregion:noImage'))
end

% create impixelregion figure
hPixelRegionFig = figure('Menubar','none',...
    'IntegerHandle','off',...
    'NumberTitle','off',...
    'Name',createFigureName(getString(message('images:commonUIString:pixelRegion')),hFig),...
    'Tag','impixelregion',...
    'Colormap',colormap(hAx),...
    'InvertHardCopy','off',...
    'HandleVisibility','callback',...
    'Visible','off',...
    'WindowStyle',get(0,'FactoryFigureWindowStyle'));

suppressPlotTools(hPixelRegionFig);

% keep the figure name up to date
linkToolName(hPixelRegionFig,hFig,getString(message('images:commonUIString:pixelRegion')));

% make the pixel region figure smaller than the default.
set(hPixelRegionFig,...
    'Position',get(hPixelRegionFig,'Position') .* [1 1 .6 .6]);

% create pixel region panel
sp_h = impixelregionpanel(hPixelRegionFig, hIm);
scrollpanelAPI = iptgetapi(sp_h);

% setup pan behavior on image
hPixelRegionIm = findobj(sp_h,'type','image');
set(hPixelRegionIm,'ButtonDownFcn',@impan);
iptPointerManager(hPixelRegionFig);
setPointerOverImageFcn = @(fig, cp) setptr(fig,'hand');
iptSetPointerBehavior(hPixelRegionIm, setPointerOverImageFcn);

% add impixelinfo to figure
hPixelRegionIm = findobj(sp_h,'type','image');
hPixelInfoPanel = impixelinfo(hPixelRegionFig, hPixelRegionIm);
hPixelInfoPanelOrigPos = get(hPixelInfoPanel,'Position');
iptui.internal.setChildColorToMatchParent(hPixelInfoPanel, hPixelRegionFig);

% customize pixel region figure toolbar and menubar
toolbarOld = findall(hPixelRegionFig,'type','uitoolbar');
delete(toolbarOld);
createToolbar(hPixelRegionFig,hIm,sp_h,scrollpanelAPI)
createMenubar(hPixelRegionFig,sp_h,scrollpanelAPI);

resizePixRegion(hPixelRegionFig);

% Position the pixel region figure to the upper right and make visible.
iptwindowalign(hFig,'right', hPixelRegionFig,'left');
iptwindowalign(hFig,'top', hPixelRegionFig,'top');
set(hPixelRegionFig, ...
    'Visible','on',...
    'ResizeFcn', @resizePixRegion);

% react to changes in target image
reactToImageChangesInFig(hIm,hPixelRegionFig,@reactDeleteFcn,...
    @reactRefreshFcn);
registerModularToolWithManager(hPixelRegionFig,hIm);

if nargout > 0
    hout = hPixelRegionFig;
end


    %-------------------------------
    function reactDeleteFcn(obj,evt) %#ok<INUSD>
        if ishghandle(hPixelRegionFig)
            delete(hPixelRegionFig);
        end
    end


    %-------------------------------
    function reactRefreshFcn(obj,evt) %#ok<INUSD>
        
        % close tool if the target image cdata is empty
        if isempty(get(hIm,'CData'))
            reactDeleteFcn();
        end
    end


    %--------------------------------------
    function resizePixRegion(src, varargin)
        figPos = get(src,'Position');

        set(hPixelInfoPanel,...
            'position',[0 0 figPos(3) hPixelInfoPanelOrigPos(4)]);
        panelPos = get(hPixelInfoPanel,'Position');

        % Only resize the scrollpanel if the figure height is greater than the panel
        % height because that is the only time the scrollpanel would be viewable.
        if figPos(4) > panelPos(4)

            % set scrollpanel position based on normalized units.
            newScrollpanelBottom = panelPos(4) / figPos(4);
            newScrollpanelHeight = 1 - newScrollpanelBottom;
                        
            % Workaround to g478875. There is an HG bug that is causing
            % pending resize events to be removed from the event queue if
            % the scrollpanel position is set to the same value as the
            % current value. This is breaking impixelregion when the
            % impixelregion figure is dragged horizontally.
            newScrollpanelPosition = [0 newScrollpanelBottom 1 newScrollpanelHeight];
            scrollPanelPositionChanged = ~isequal(newScrollpanelPosition,get(sp_h,'Position'));
            if scrollPanelPositionChanged
                set(sp_h,'Position', newScrollpanelPosition);
            end
        end

    end % resizePixRegion

end % impixelregion


%--------------------------------------
function createToolbar(hPixelRegionFig,hIm,sp_h,scrollpanelAPI) %#ok<INUSL>

toolbar = uitoolbar(hPixelRegionFig);
[iconRoot, iconRootMATLAB] = ipticondir;

zoomInIcon = makeToolbarIconFromPNG(fullfile(iconRoot,...
    'pixelreg_zoom_in.png'));
createToolbarPushItem(toolbar,zoomInIcon,...
    {@(obt,evt) zoomIn(scrollpanelAPI)},...
    getString(message('images:commonUIString:zoomInTooltip')),...
    'zoom in');

zoomOutIcon = makeToolbarIconFromPNG(fullfile(iconRoot,...
    'pixelreg_zoom_out.png'));
createToolbarPushItem(toolbar,zoomOutIcon,...
    {@(obj,evt) zoomOut(scrollpanelAPI)},...
    getString(message('images:commonUIString:zoomOutTooltip')),...
    'zoom out');

if ~isdeployed
    helpIcon = makeToolbarIconFromGIF(...
        fullfile(iconRootMATLAB,'helpicon.gif'));

    createToolbarPushItem(toolbar,...
        helpIcon,...
        @showPixelRegionHelp,...
        getString(message('images:commonUIString:help')),...
        'help');
end

% Store at function scope to be used during zoom out
im_xdata = getXData(hIm);
im_ydata = getYData(hIm);


    %------------------------
    function zoomIn(varargin)

        scrollpanelAPI.setMagnification(1.25 * scrollpanelAPI.getMagnification());

    end


    %-------------------------
    function zoomOut(varargin)

        min_zoom = getMinimumPixelRegionMag(scrollpanelAPI.getViewport(),hIm);

        candidate_zoom = scrollpanelAPI.getMagnification() / 1.25;
        if candidate_zoom >= min_zoom
            scrollpanelAPI.setMagnification(candidate_zoom);
        else

            rect_pos = scrollpanelAPI.getVisibleImageRect();
            image_rect = [im_xdata(1)-0.5, im_ydata(1)-0.5, im_xdata(2), im_ydata(2)];

            rect_aspect_ratio = rect_pos(3) / rect_pos(4);

            candidate_height = image_rect(3) / rect_aspect_ratio;
            constrained_in_height = candidate_height > image_rect(4);

            getCenterX = @(pos) mean([pos(1),pos(1)+pos(3)]);
            getCenterY = @(pos) mean([pos(2),pos(2)+pos(4)]);

            % If requested zoom is less than minimum zoom, rectangle is either
            % constrained in width or constrained in height
            if constrained_in_height
                cx = getCenterX(rect_pos);
                cy = getCenterY(image_rect);
            else
                cx = getCenterX(image_rect);
                cy = getCenterY(rect_pos);
            end
            scrollpanelAPI.setMagnificationAndCenter(min_zoom,cx,cy)
        end

    end % zoomOut

end % createToolbar


%-------------------------------------------------------------------
function item = createToolbarPushItem(toolbar,icon,callback,tooltip,tagString)

% The tagString parameter was added to ensure that clients can pass a
% string that won't be localized for purposes of testing.

item = uipushtool(toolbar,...
    'Cdata',icon,...
    'TooltipString',tooltip,...
    'Tag',[tagString ' toolbar button'],...
    'ClickedCallback',callback);

end % createToolbarPushItem


%----------------------------------------------------------
function createMenubar(hPixelRegionFig,sp_h,scrollpanelAPI)

filemenu = uimenu(hPixelRegionFig,...
    'Label',getString(message('images:commonUIString:fileMenubarLabel')),...
    'Tag','file menu');

uimenu(filemenu,...
    'Label',getString(message('images:commonUIString:printToFigureMenubarLabel')), ...
    'Tag','print to figure menu item', ...
    'Callback', @(obj,evt) printImageToFigure(sp_h));

uimenu(filemenu,...
    'Label',getString(message('images:commonUIString:closeMenubarLabel')), ...
    'Tag','close menu item', ...
    'Callback', @(varargin) close(hPixelRegionFig), ...
    'Accelerator','W');

editmenu = uimenu(hPixelRegionFig,...
    'Label',getString(message('images:commonUIString:editMenubarLabel')),...
    'Tag','edit menu', ...
    'Callback', @setupEditMenu);

uimenu(editmenu,...
    'Label',getString(message('images:commonUIString:copyPositionMenubarLabel')), ...
    'Callback', ...
    @(varargin) clipboard('copy', scrollpanelAPI.getVisibleImageRect()), ...
    'Tag','copy position menu item');

showPixValuesItem = uimenu(editmenu,...
    'Label',getString(message('images:impixelregionUIString:superimposeMenubarLabel')), ...
    'Callback', @showPixelValuesCallback, ...
    'Tag','superimpose pixel values menu item',...
    'Checked','on');

matlab.ui.internal.createWinMenu(hPixelRegionFig);

if ~isdeployed
    helpmenu = uimenu(hPixelRegionFig,...
        'Label',getString(message('images:commonUIString:helpMenubarLabel')),...
        'Tag','help menu');
    
    uimenu(helpmenu,...
        'Label',getString(message('images:impixelregionUIString:pixelRegionHelpMenubarLabel')), ...
        'Tag','help menu item',...
        'Callback', @showPixelRegionHelp);

    iptstandardhelp(helpmenu);
end


    %-------------------------------
    function setupEditMenu(varargin)

        api = getappdata(sp_h,'impixelregionpanelAPI');
        if api.isValueDisplayPossible()
            set(showPixValuesItem,'Enable','on');
        else
            set(showPixValuesItem,'Enable','off');
        end

    end % setupEditMenu


    %-----------------------------------------
    function showPixelValuesCallback(varargin)

        api = getappdata(sp_h,'impixelregionpanelAPI');
        if strcmp(get(gcbo,'Checked'),'on')
            api.setShowPixelValues(false);
            set(gcbo,'Checked','off');
        else
            api.setShowPixelValues(true);
            set(gcbo,'Checked','on');
        end

    end % showPixelValuesCallback

end % createMenubar


%-------------------------------------
function showPixelRegionHelp(varargin)

    topic = 'pix_region_tool_help';
    helpview([docroot '/toolbox/images/images.map'],topic);

end % showPixelRegionHelp

%--------------------------------
function xdata = getXData(handle)

xdata = get(handle,'XData');

if isscalar(xdata)
    xdata = [xdata xdata];
end

end

%--------------------------------
function ydata = getYData(handle)

ydata = get(handle,'YData');

if isscalar(ydata)
    ydata = [ydata ydata];
end

end
