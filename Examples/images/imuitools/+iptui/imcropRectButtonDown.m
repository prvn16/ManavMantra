classdef imcropRectButtonDown < iptui.imcropRect
    % This undocumented class may be removed in a future release.
    
    %   Copyright 2008-2016 The MathWorks, Inc.
    
    properties
        
        draw_rect_api
        
        h_fig
        h_ax
        h_im
        
        key_id
        
    end
    
    methods
        
        function obj = imcropRectButtonDown(h_img,evt) %#ok<INUSD>
            
            buttonState = iptui.buttonUpMonitor(ancestor(h_img,'figure'));
            
            h_ax = ancestor(h_img,'axes');
            h_fig = ancestor(h_ax,'figure');
            
            % Any previously created cropping rectangles are cached in the
            % figure appdata.
            old_rect = getappdata(h_fig,'imcropRectButtonDownOld');
            
            old_color = [];
            if ~isempty(old_rect) && isvalid(old_rect)
                % If there is currently a cropping rectangle over the
                % image, determine its color so that color is persistent
                % when the rectangle is redrawn. Destroy old cropping rect.
                old_color = get(findobj(old_rect,'tag','wing line'),'Color');
                delete(old_rect);
            end
            
            currentPoint = get(h_ax,'CurrentPoint');
            initial_x = currentPoint(1,1);
            initial_y = currentPoint(1,2);
            
            % Begin drawing rectangle over image. drawRectAffordance
            % draws a rectangle over the image that looks like imrect.
            initial_position = drawRectAffordance(h_img,initial_x,initial_y,old_color,buttonState);
            
            h_sp = findobj(h_fig,'tag','imscrollpanel');
            is_small_drag = tinyWidthOrHeight(h_sp,initial_position);
            
            % Now that we know where user wants cropping rectangle, create
            % cropping rectangle in specified position.
            obj = obj@iptui.imcropRect(h_ax,initial_position,h_img);
            
            obj.h_ax  = h_ax;
            obj.h_fig = h_fig;
            obj.h_im  = h_img;
            
            if is_small_drag
                obj.delete();
                return
            end
            
            % Use color of previous cropping rectangle if rectangle is
            % being re-drawn.
            if ~isempty(old_color)
                obj.setColor(old_color);
            end
            
            % Store handle to cropping rect in figure appdata so that we
            % can detect presence of cropping rectangle during redraw.
            setappdata(h_fig,'imcropRectButtonDownOld',obj);
            
            % Wire double click action for cropping rectangle.
            h_double_click = findobj(obj,'hittest','on');
            for i = 1:length(h_double_click)
                iptaddcallback(h_double_click(i),'ButtonDownFcn',@(h_obj,evt) obj.cropOnDoubleClick());
            end
            
            obj.wireKeyPress();
            
        end
        
        function delete(obj)
            % Clean up WindowKeyPress callbacks that are maintained at
            % figure level once associated cropping rectangle is destroyed.
            iptremovecallback(obj.h_fig,'WindowKeyPress',obj.key_id);
        end
        
        function wireKeyPress(obj)
            
            obj.key_id = iptaddcallback(obj.h_fig,'WindowKeyPressFcn',@reactToKeyPress);
            
            function reactToKeyPress(src,evt) %#ok<INUSL>
                
                switch (evt.Key)
                    case {'delete','escape','backspace'}
                        obj.delete();
                    case {'return'}
                        obj.completeCrop();
                end
                
            end
            
        end
        
        function completeCrop(obj)
            
            cropPos = obj.getPosition();
            new_cdata = imcrop(get(obj.h_im,'CData'),cropPos);
            
            % Make local copies of HG handles before destroying cropping
            % rectangle.
            h_fig = obj.h_fig; %#ok<PROP>
            h_ax = obj.h_ax; %#ok<PROP>
            h_im = obj.h_im; %#ok<PROP>
       
            % Delete cropping rectangle before we begin replacing image in
            % scrollpanel.
            obj.delete();
            
            % Delete any distance tools that are within HG hierarchy of
            % parent figure.
            dist_lines = findobj(h_fig,'tag','distance label'); %#ok<PROP>
            for i = 1:numel(dist_lines)
                delete(ancestor(dist_lines(i),'hggroup'));
            end
            
            if ~isempty(new_cdata)
                % cache old clim
                oldCLim = get(h_ax,'CLim'); %#ok<PROP>
                
                hsp = findall(h_fig,'tag','imscrollpanel'); %#ok<PROP>
                hsp_api = iptgetapi(hsp);
                
                % account for indexed images
                is_indexed_image = strcmpi(get(h_im,'CDataMapping'),'direct'); %#ok<PROP>
                cmap = colormap(h_ax); %#ok<PROP>
                if is_indexed_image
                    hsp_api.replaceImage(new_cdata,cmap,...
                                        'DisplayRange',oldCLim,...
                                        'PreserveView',true);
                else
                    hsp_api.replaceImage(new_cdata,...
                                        'DisplayRange',oldCLim,...
                                        'PreserveView',true,...
                                        'Colormap',cmap);
                end
                
            end

        end
        
        function cropOnDoubleClick(obj)
            
            if strcmp(get(obj.h_fig,'SelectionType'),'open')
                obj.completeCrop();
            end
               
        end
    end
end

function TF = tinyWidthOrHeight(h_sp,position)

TF = false;

% Same metric as used in imzoomin
tiny_threshold = 5;

sp_api = iptgetapi(h_sp);
mag = sp_api.getMagnification();

pos = position(3:4) .* mag;

if any(pos < tiny_threshold)
    TF = true;
end

end

function initial_position = drawRectAffordance(h_img,init_x,init_y,old_color,buttonState)

h_fig = ancestor(h_img,'figure');
h_ax = ancestor(h_img,'axes');

if buttonState.isButtonUp();
    % Because we have to call the imcropRect constructor, choose an
    % offscreen initial position. The rectangle will be deleted shortly
    % after creation, so it doesn't really matter.
    off_screen_position = [-20 -20 0 0];
    initial_position = off_screen_position;
    return;
end

% In the future, we should move wingedRect into +iptui.
warnstate = warning('off','images:imuitoolsgate:undocumentedFunction');
wingedRect = imuitoolsgate('FunctionHandle','wingedRect');

draw_rect_api = wingedRect();
warning(warnstate);

% get image extent for boundary constraints
[x_extent,y_extent] = iptui.getImageExtent(h_img);
constraint_fcn = makeConstrainToRectFcn('imrect',...
    x_extent,...
    y_extent);

h_group_temp = hggroup('Parent',h_ax);

% Provide no-op functions to meet initialize method API need for dragFcn
% handles. These functions will never be called.
draw_rect_api.initialize(h_group_temp,'','','');

if ~isempty(old_color)
    draw_rect_api.setColor(old_color)
else
    color_choices = iptui.getColorChoices();
    draw_rect_api.setColor(color_choices(1).Color);
end

draw_rect_api.setVisible(true);

drag_id = iptaddcallback(h_fig,'WindowButtonMotionFcn',@drawRect);
stop_id = iptaddcallback(h_fig,'WindowButtonUpFcn',@stopDraw);

uiwait(h_fig);
delete(h_group_temp);


    function drawRect(varargin)
        
        initial_position = getCurrentPositionRect();
        draw_rect_api.updateView(initial_position);
        
    end

    function stopDraw(varargin)
        
        drawRect();
        
        iptremovecallback(h_fig,'WindowButtonMotionFcn',drag_id);
        iptremovecallback(h_fig,'WindowButtonUpFcn',stop_id);
        uiresume(h_fig);
        
    end

    function pos = getCurrentPositionRect(obj) %#ok<INUSD>
        
        currentPoint = get(h_ax,'CurrentPoint');
        current_x = currentPoint(1,1);
        current_y = currentPoint(1,2);
        
        w = abs(current_x - init_x);
        h = abs(current_y - init_y);
        
        x = min(current_x,init_x);
        y = min(current_y,init_y);
        
        pos = constraint_fcn([x y w h]);
        
    end

end

