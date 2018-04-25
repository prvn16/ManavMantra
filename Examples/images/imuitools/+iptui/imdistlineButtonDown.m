classdef imdistlineButtonDown < imdistline
    % This undocumented class may be removed in a future release.
    
    %   Copyright 2008-2010 The MathWorks, Inc.
   
    methods

        function obj = imdistlineButtonDown(h_img,evt) %#ok<INUSD>

            buttonState = iptui.buttonUpMonitor(ancestor(h_img,'figure'));
            h_ax = ancestor(h_img,'axes');
            h_fig = ancestor(h_img,'figure');

            currentPoint = get(h_ax,'CurrentPoint');
            initial_x = currentPoint(1,1);
            initial_y = currentPoint(1,2);

            % get image extent for boundary constraints
            [x_extent y_extent] = iptui.getImageExtent(h_img);
            constraint_fcn = makeConstrainToRectFcn('imline',...
                                                     x_extent,...
                                                     y_extent);
                                                     
            initial_position = drawDistlineAffordance(h_ax,...
                                                    initial_x,...
                                                    initial_y,...
                                                    constraint_fcn,...
                                                    buttonState);
                                                
            h_sp = findobj(h_fig,'tag','imscrollpanel');
            is_small_drag = tinyWidthOrHeight(h_sp,initial_position);

            obj = obj@imdistline(h_ax,...
                                initial_position(:,1),...
                                initial_position(:,2));
                            
            if is_small_drag
                obj.delete();
                return;
            end
                            
            obj.setPositionConstraintFcn(constraint_fcn);
            
        end
    end
end

function TF = tinyWidthOrHeight(h_sp,pos)

% This constant specifies the number of pixels the mouse
% must move in order to do a rbbox zoom.
% Note: same value as
% matlab/graphics/@graphics/@zoom/buttonupfcn2D.m
tiny_threshold = 5;

sp_api = iptgetapi(h_sp);
mag = sp_api.getMagnification();

length = hypot( diff(pos(:,1)), diff(pos(:,2)));  

length_screen_pixels = length * mag;

TF = length_screen_pixels < tiny_threshold;

end

function initial_position = drawDistlineAffordance(h_ax,init_x,init_y,...
                                                   constraint_fcn,...
                                                   buttonState)

% If buttonUp has already occurred, return ROI position, don't wire up
% callbacks.                                               
if buttonState.isButtonUp()
    initial_position = [init_x, init_y;...
                        init_x, init_y];
    return
end
    
                                               
h_fig = ancestor(h_ax,'figure');

% In the future, we should move lineSymbol into +iptui. For now, use
% imuitoolsgate because lineSymbol has a lot of dependencies on
% imuitools/private.
warnstate = warning('off','images:imuitoolsgate:undocumentedFunction');
lineSymbol = imuitoolsgate('FunctionHandle','lineSymbol');
warning(warnstate);

h_group_temp = hggroup('Parent',h_ax);

% The lineSymbol renderer wants to know about translateFcn and resizeFcn
% to wire ButtonDownFcn for each HG object managed by the renderer. The
% lifecycle of the imdistlineButtonDown object is only for one
% buttonDown/buttonUp sequence during interactive placement in imtool, so
% we just specify no-op function handles to lineSymbol. These function
% handles will never actually be called.
draw_line_api = lineSymbol(h_group_temp,'','');

color_choices = iptui.getColorChoices();
draw_line_api.setColor(color_choices(1).Color);

h_text = text(1,1,'',...
    'Parent',h_group_temp,...
    'BackgroundColor','w',...
    'Color','k',...
    'FontSize',9,...
    'FontName','FixedWidth',...
    'HitTest','off');

drag_id = iptaddcallback(h_fig,'WindowButtonMotionFcn',@drawLine);
stop_id = iptaddcallback(h_fig,'WindowButtonUpFcn',@stopDraw);

uiwait(h_fig);
delete(h_group_temp);

    function drawLine(varargin)

        % We only need to setVisible the first time through drawLine, but
        % this won't cause a noticeable performance difference. Calling
        % setVisible any earlier causes a flicker.
        draw_line_api.setVisible(true);
        
        pos = getCurrentPosition();
        pos = constraint_fcn(pos);
        
        draw_line_api.updateView(pos);
        
        distance = norm([diff(pos(:,1)), diff(pos(:,2))]);
        updateDistanceLabel(distance);
           
    end

    function stopDraw(varargin)

        pos = getCurrentPosition();
        pos = constraint_fcn(pos);
        
        draw_line_api.updateView(pos);

        initial_position = pos;

        iptremovecallback(h_fig,'WindowButtonMotionFcn',drag_id);
        iptremovecallback(h_fig,'WindowButtonUpFcn',stop_id);
        uiresume(h_fig);

    end

    function updateDistanceLabel(distance)
            position = constraint_fcn(getCurrentPosition());
            mid_point = [mean(position(:,1)) mean(position(:,2))];
            dist_str = sprintf('%1.2f',distance);
            set(h_text,'Position',mid_point);
            set(h_text,'String',dist_str);
    end

    function pos = getCurrentPosition

        currentPoint = get(h_ax,'CurrentPoint');
        current_x = currentPoint(1,1);
        current_y = currentPoint(1,2);

        pos = [init_x init_y; current_x current_y];
        
    end

end

