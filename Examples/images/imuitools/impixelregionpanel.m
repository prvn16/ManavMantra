function sp_h = impixelregionpanel(parent, hImage)
%IMPIXELREGIONPANEL Pixel Region tool panel.
%   HPANEL = IMPIXELREGIONPANEL(HPARENT, HIMAGE) creates a Pixel Region tool
%   panel associated with the image specified by the handle HIMAGE, called the
%   target image. This is the image whose pixels are to be displayed. HPARENT
%   is the handle to the figure or uipanel object that will contain the Pixel
%   Region tool panel.
%
%   The Pixel Region tool is a uipanel object that contains an extreme close-up
%   view of a small region of pixels in the target image. The tool superimposes
%   the numeric value of the pixel over each pixel. To define the region being
%   examined, the tool overlays a rectangle on the target image, called the
%   pixel region rectangle. To view pixels in a different region, click and
%   drag the rectangle over the target image.
%
%   HPANEL is the handle to the Pixel Region tool scroll panel.
%
%   Note
%   ----
%   To open the Pixel Region Tool in a separate figure window, use
%   IMPIXELREGION.
%
%   Example
%   -------
%
%      himage = imshow('peppers.png');
%      hfigure = figure('Toolbar','none','MenuBar','none');
%      hpanel = impixelregionpanel(hfigure, himage);
%
%      % Set the panel's position to the lower-left quadrant of the
%      % figure.
%      set(hpanel, 'Position', [0 0 .5 .5])
%
%   See also IMPIXELREGION, IMRECT, IMSCROLLPANEL.

%   Copyright 2004-2016 The MathWorks, Inc.

iptcheckhandle(parent,{'figure','uipanel','uicontainer'},mfilename,'HPARENT',1)
iptcheckhandle(hImage,{'image'},mfilename,'HIMAGE',2)

% initialize function scope variables
[is_rect_moving, h_rect, h_line_group, text_handles, getPixelRegionString, ...
    old_axes_dims, old_im_dim, min_spip] = deal([]);

% get HG handles
hAxes   = ancestor(hImage, 'axes');
hPixelRegionFig = ancestor(parent, 'figure');

% set figure colormap
if ismatrix(get(hImage, 'CData'))
    hPixelRegionFig.Colormap = colormap(hAxes);
end

% create and initialize axes
hPixelRegionAx = createPixelRegionAxes(parent);
clim = get(hAxes, 'CLim');
if ~isempty(clim) && (clim(1) < clim(2))
    set(hPixelRegionAx, 'CLim', clim);
end

% create and initialize image
hPixelRegionIm = createImageFromTargetImage(hImage, hPixelRegionAx);
set(hPixelRegionIm, ...
    'BusyAction', 'cancel', ...
    'Interruptible', 'off');

% get image model
pixRegionImModel = getimagemodel(hPixelRegionIm);

% create scrollpanel
warnstate = warning('off','images:imscrollpanel:nonDefaultXDataOrYData');
sp_h = imscrollpanel(parent,hPixelRegionIm);
warning(warnstate);

% setup text objects and turn off hittest on text objects by default
set(hPixelRegionFig, ...
    'DefaultTextFontSize', 9,...
    'DefaultTextFontName', 'FixedWidth', ...
    'DefaultTextInterpreter', 'none', ...
    'DefaultTextHorizontalAlignment', 'center', ...
    'DefaultTextHitTest', 'off');

% Use a small tolerance to keep actual magnification of scrollpanel slightly
% larger than minimum magnification required to view text. There may be
% numerical errors introduced in dragging the pixelregion rect. Keeping the
% magnification slightly larger than min_spip prevents numerical error from
% making pixel region text invisible.
mag_tol = 1000 * eps;

% Visually obtained threshold at which gridlines begin to obscure
% underlying image. Gridlines are not shown below this magnification.
min_mag_gridlines = 5;

% get scrollpanel API
sp_api = iptgetapi(sp_h);

% initialize the impixelregionpanel scrollpanel
initializePanel();

% we show pixel values by default
show_pixel_values = true;

% create custom API
api.setShowPixelValues       = @setShowPixelValues;
api.isValueDisplayPossible   = @isValueDisplayPossible;
api.centerRectInViewport     = @centerRectInViewport;
setappdata(sp_h,'impixelregionpanelAPI',api);

% initialize text and rect position
updatePosition();

% create listeners for objects property changes
axes_listener = iptui.iptaddlistener(hPixelRegionAx,'Position',...
    'PostSet', @updatePosition);

cdatamapping_listener = iptui.iptaddlistener(hImage, ...
    'CDataMapping', 'PostSet', @updateCDataMapping);

clim_listener = iptui.iptaddlistener(hAxes, ...
    'CLim', 'PostSet', @updateCLim);

% Listen to the MarkedDirty event of the hAxes object for colormap changes.
colormap_listener = iptui.iptaddlistener(hAxes, ...
    'MarkedDirty', @updateColormap);

setappdata(hPixelRegionIm, 'Listeners', {axes_listener, ...
    cdatamapping_listener, colormap_listener, clim_listener});

% clear unused references to listeners
clear axes_listener cdatamapping_listener clim_listener;
clear colormap_listener;

% react to changes in target image
reactToImageChangesInFig(hImage,sp_h,@reactDeleteFcn,@reactRefreshFcn);
registerModularToolWithManager(sp_h,hImage);


    %-----------------------
    function initializePanel

        % compute minimum zoom level to display text
        h = text(1,1,getDefaultPixelRegionString(pixRegionImModel), ...
            'Parent', hPixelRegionAx,...
            'Units', 'Pixels',...
            'Visible','Off');
        te = get(h,'Extent');
        delete(h);
        text_gutter_space = 8;
        
        % minimum screen pixels per image pixel required to display text
        min_spip = ceil(max(te(3:4))) + 2 * text_gutter_space;
        dprect = matlab.ui.internal.PositionUtils.getPixelRectangleInDevicePixels(...
            [0 0 min_spip min_spip], ancestor(hAxes,'figure'));
        min_spip = dprect(3);
        
        % if the view has changed (cdata size, or axes limits) then we need
        % to recreate some components.
        new_axes_dims = [get(hAxes,'XLim') get(hAxes,'YLim')];
        new_im_dim = size(get(hImage,'CData'));
        view_changed = ~isequal(new_axes_dims,old_axes_dims) || ...
            ~isequal(new_im_dim(1:2),old_im_dim(1:2));
        if view_changed
            
            min_mag = getMinimumPixelRegionMag(sp_api.getViewport(),hImage);

            % reset magnification/viewport to default
            if min_spip >= min_mag
                sp_api.setMagnification(min_spip+mag_tol);
            else
                sp_api.setMagnification(min_mag);
            end
            centerRectInViewport();

            % if this is our first trip through the init function, we need 
            % to create our rectangle and wire the scrollpanel to clean it
            % up when we delete sp_h
            if isempty(h_rect)
                h_rect = makePixelRegionRect();
                set(sp_h,'DeleteFcn',@(obj,evt) deleteTool(h_rect));
                
                % add rect API too tool appdata
                setappdata(sp_h,'imrectAPI',h_rect);
            end
            is_rect_moving = false;

            % if our viewport changed, we may be in violation of our
            % previous position constraint function, so we re-position
            % the rectangle and reset the position constraint function
            h_rect.setPosition(sp_api.getVisibleImageRect());
            % get image extent for boundary constraint
            [x_extent, y_extent] = iptui.getImageExtent(hImage);
            % create boundary constraint function
            boundary_constraint_fcn = makeConstrainToRectFcn('imrect',...
                x_extent,y_extent);
            h_rect.setPositionConstraintFcn(boundary_constraint_fcn);
            
            % create grid lines on pixelregion panel image
            delete(h_line_group);
            h_line_group = imgridlines(hPixelRegionIm);
            
            % reset flags
            old_axes_dims = new_axes_dims;
            old_im_dim = new_im_dim;
        end

        % get text format function
        getPixelRegionString = getPixelRegionFormatFcn(pixRegionImModel);
    end


    %--------------------------------
    function reactDeleteFcn(obj,evt) %#ok<INUSD>

        % delete pixel region panel
        if ishghandle(sp_h)
            delete(sp_h);
        end

    end


    %--------------------------------
    function reactRefreshFcn(obj,evt) %#ok<INUSD>
        
        % close tool if the target image cdata is empty
        if isempty(get(hImage,'CData'))
            reactDeleteFcn();
            return;
        end
        
        % disable stored listeners
        tool_listeners = getappdata(hPixelRegionIm,'Listeners');
        cellfun(@(c) iptui.internal.setListenerEnabled(c, false), tool_listeners);
        
        % replace image with new image
        new_cdata = get(hImage,'CData');
        new_map   = colormap(hAxes);
        new_clim  = get(hAxes,'CLim');
        if ismatrix(new_cdata)
            sp_api.replaceImage(new_cdata,...
                'DisplayRange',new_clim,...
                'Colormap',new_map,...
                'PreserveView',true);
        else
            sp_api.replaceImage(new_cdata,...
                'DisplayRange',new_clim,...
                'PreserveView',true);
        end
        
        % udpate cdatamapping
        new_cdatamapping = get(hImage,'CDataMapping');
        set(hPixelRegionIm,'CDataMapping',new_cdatamapping);

        % update image model
        pixRegionImModel = getimagemodel(hPixelRegionIm);

        % re-initialize the impixelregionpanel scrollpanel
        initializePanel()

        % initialize text and rect position
        updatePosition();

        % re-enable tool listeners and clear extra reference
        cellfun(@(c) iptui.internal.setListenerEnabled(c, true), tool_listeners);

        clear tool_listeners

    end


    %------------------------------------
    function h_rect = makePixelRegionRect

        h_rect = iptui.pixelRegionRect(hAxes,...
            sp_api.getVisibleImageRect(),hImage);
        h_rect.addCallback(@rectTranslated,'translateDrag');
        h_rect.addCallback(@rectResized,'resizeDrag');

        % Remove fix aspect ratio context menu option in the context of
        % impixelregionpanel, always want aspect ratio to be fixed.
        h_fig = iptancestor(hAxes,'figure');
        fixed_aspect_context_menu = findobj(h_fig,'tag','fix aspect ratio cmenu item');
        delete(fixed_aspect_context_menu);

    end % makePixelRegionRect


    %--------------------------------
    function rectTranslated(rect_pos)

        is_rect_moving = true;

        sp_api.setVisibleLocation(rect_pos(1), rect_pos(2));

        % force update, see: g309823 and g295731, g301382, g303455
        % keeps pixelregionpanel in sync with navigational tool
        drawnow expose;

        is_rect_moving = false;

    end % rectTranslated


    %-----------------------------
    function rectResized(rect_pos)

        is_rect_moving = true;

        getCenter = @(start,length) mean([start,start+length]);

        cx = getCenter(rect_pos(1),rect_pos(3));
        cy = getCenter(rect_pos(2),rect_pos(4));

        viewport = sp_api.getViewport();

        % viewport is [w h] of scrollpanel viewport in screen pixels.  rect_pos is
        % position of rectangle in image pixels. viewport and rect_pos aspect
        % ratios are equal. ratio of widths or heights of viewport/rect_pos
        % describes magnification in screen pixels per image pixel.
        new_mag = viewport(1)/rect_pos(3);

        sp_api.setMagnificationAndCenter(new_mag,cx,cy);

        is_rect_moving = false;

    end % rectResized


    %--------------------------------
    function updateColormap(varargin)
        
        if ishghandle(hPixelRegionFig)
            hPixelRegionFig.Colormap = colormap(hAxes);
            updateText();
        end
        
    end % updateColormap


    %------------------------------------
    function updateCDataMapping(varargin)
        
        if ishghandle(hPixelRegionIm)
            set(hPixelRegionIm,'CDataMapping',get(hImage,'CDataMapping'));
            initializePanel();
        end
        updateText();
        
    end % updateCDataMapping


    %----------------------------
    function updateCLim(varargin)
        
        if ishghandle(hPixelRegionAx)
            set(hPixelRegionAx, 'CLim', get(hAxes, 'CLim'));
            updateText();
        end
        
    end % updateCLim


    %-------------------------------------------------
    function setShowPixelValues(new_show_pixel_values)
        
        show_pixel_values = new_show_pixel_values;
        if show_pixel_values && (sp_api.getMagnification() < min_spip)
            sp_api.setMagnification(min_spip+mag_tol);
        end

        updateText();

    end % setShowPixelValues


    %-------------------------------------
    function tf = isValueDisplayPossible()

        tf = (sp_api.getMagnification() >= min_spip);

    end % isValueDisplayPossible


    %--------------------------------
    function updatePosition(varargin)

        if ~is_rect_moving
            updateRect();
        end
        updateText();

    end % updatePosition


    %----------------------------
    function updateRect(varargin)
        if ~isvalid(h_rect)
            return;
        end
        h_rect.setConstrainedPosition(sp_api.getVisibleImageRect())

    end % updateRect


    %---------------------
    function TF = showText

        TF = sp_api.getMagnification() >= min_spip;

    end % showText


    %--------------------------
    function TF = showGridLines

        TF = sp_api.getMagnification() >= min_mag_gridlines;

    end % showGridLines


    %----------------------------
    function updateText(varargin)

        if ~show_pixel_values && ~isempty(text_handles)
            set(text_handles, 'Visible', 'off');
            return
        end

        if showText()
            [xx,yy] = visiblePixelCenters(sp_api.getVisibleImageRect());
            num_new_text_objects_needed = numel(xx) - numel(text_handles);
            if num_new_text_objects_needed > 0
                text_handles = [text_handles; zeros(num_new_text_objects_needed, 1)];
                for k = 1:num_new_text_objects_needed
                    text_handles(end - k + 1) = text('Parent', hPixelRegionAx);
                end
            end

            screen_pixel_colors = getScreenPixelRGBValue(pixRegionImModel, yy(:), xx(:));
            gray_screen_pixel_colors = screen_pixel_colors * [0.2989; 0.5870; 0.1140];
            pixel_value_strings = getPixelRegionString(yy(:), xx(:));

            for k = 1:numel(xx)
                if (gray_screen_pixel_colors(k) > 0.5)
                    text_color = 'k';
                else
                    text_color = 'w';
                end
                 
                set(text_handles(k), 'Position', [xx(k) yy(k)], ...
                    'String', pixel_value_strings{k}, ...
                    'Color', text_color,...
                    'PickableParts', 'none');
            end

            set(text_handles(1:numel(xx)), 'Visible', 'on');
            set(text_handles(numel(xx)+1:end), 'Visible', 'off');

        else
            set(text_handles, 'Visible', 'off');
        end

        if showGridLines()
            set(get(h_line_group,'Children'),'Visible','on');
            set(get(h_line_group,'Children'),'PickableParts','none');
        else
            set(get(h_line_group,'Children'),'Visible','off');
            set(get(h_line_group,'Children'),'PickableParts','none');
        end

    end % updateText


    %-----------------------------------------------
    function [xx, yy] = visiblePixelCenters(im_rect)

        xmin = im_rect(1);
        xmax = xmin + im_rect(3);

        ymin = im_rect(2);
        ymax = ymin + im_rect(4);

        x1 = max(1, floor(xmin));
        x2 = min(getImageWidth(pixRegionImModel), ceil(xmax));

        y1 = max(1, floor(ymin));
        y2 = min(getImageHeight(pixRegionImModel), ceil(ymax));

        [xx,yy] = meshgrid(x1:x2,y1:y2);

    end % visiblePixelCenters


    %------------------------------
    function centerRectInViewport()
        % aligns the pixelregionpanel's scrollpanel's viewport center with a
        % target image's imscrollpanel's viewport center, thus bringing the
        % impixelregionpanel's draggable rectangle into view

        % only affects images contained in an imscrollpanel
        target_sp = imshared.getimscrollpanel(hImage);
        if ~isempty(target_sp)
            % find center of target image scrollpanel view
            target_sp_api = iptgetapi(target_sp);
            target_viewport = target_sp_api.getVisibleImageRect();
            new_center_x = target_viewport(1) + target_viewport(3)/2;
            new_center_y = target_viewport(2) + target_viewport(4)/2;

            % find impixelregionpanel center
            pixregion_pos = sp_api.getVisibleImageRect();
            old_center_x = pixregion_pos(1) + pixregion_pos(3)/2;
            old_center_y = pixregion_pos(2) + pixregion_pos(4)/2;

            % computer delta
            delta_x = new_center_x - old_center_x;
            delta_y = new_center_y - old_center_y;

            % apply delta to center impixelregionpanel
            new_pos = pixregion_pos + [delta_x delta_y 0 0];
            sp_api.setVisibleLocation( new_pos(1),new_pos(2) );
        end

    end % centerRectInViewport

end % impixelregionpanel


%---------------------------------------------
function haxes = createPixelRegionAxes(parent)

struct         = getCommonAxesProperties;
struct.Visible = 'on';
struct.Parent  = parent;

haxes = axes(struct);

end % createPixelRegionAxes


%--------------------------
function deleteTool(h_rect)

if isvalid(h_rect)
    h_rect.delete();
end

end % deleteTool
