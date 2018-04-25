%IMLINE Create draggable, resizable line.
%   H = IMLINE begins interactive placement of a line on the current
%   axes. The function returns H, a handle to an imline object.
%
%   The line has a context menu associated with it that allows you to copy
%   the current endpoint positions to the clipboard in the form [X1 Y1; X2
%   Y2] and change the color used to display the line. Right-click on the
%   line to access this context menu.
%
%   H = IMLINE(HPARENT) begins interactive placement of a line on the
%   object specified by HPARENT. HPARENT specifies the HG parent of the
%   line graphics, which is typically an axes but can also be any other
%   object that can be the parent of an hggroup.
%
%   H = IMLINE(HPARENT,POSITION) creates a draggable, resizable line on the
%   object specified by HPARENT. POSITION is a 2-by-2 array that specifies
%   the initial position of the line. POSITION has the form [X1 Y1; X2 Y2].
%    
%   H = IMLINE(HPARENT,X,Y) creates a draggable, resizable line on the
%   object specified by HPARENT. X and Y specify the initial endpoint
%   positions of the line in the form X = [X1 X2], Y =[Y1 Y2].
%
%   H = IMLINE(...,PARAM1,VAL1,PARAM2,VAL2,...) creates a draggable,
%   resizable line, specifying parameters and corresponding values that
%   control the behavior of the line. Parameter names can be abbreviated,
%   and case does not matter.
%       
%   Parameters include:
%
%   'PositionConstraintFcn'        Function handle fcn that is called whenever
%                                  the line is dragged using the mouse. Type
%                                  "help imline/setPositionConstraintFcn"
%                                  for information on valid function
%                                  handles.
%
%   Methods
%   -------
%   Type "methods imline" to see a list of the methods.
%
%   For more information about a particular method, type 
%   "help imline/methodname" at the command line.
%
%   Remarks
%   -------    
%   If you use IMLINE with an axis that contains an image object, and do not
%   specify a position constraint function, users can drag the line outside the
%   extent of the image and lose the line.  When used with an axis created by
%   the PLOT function, the axis limits automatically expand to accommodate the
%   movement of the line.
%    
%   Example 1
%   ---------    
%   Use a custom color for displaying the line. Use addNewPositionCallback
%   method.  Move the line, note that the 2-by-2 position vector of the
%   line is displayed in the title above the image.  Explore the context
%   menu of the line by right clicking on the line.
%    
%   figure, imshow('pout.tif');
%   h = imline(gca,[10 100], [100 100]);
%   setColor(h,[0 1 0]);
%   id = addNewPositionCallback(h,@(pos) title(mat2str(pos,3)));
%
%   % After observing the callback behavior, remove the callback.
%   % using the removeNewPositionCallback API function.     
%   removeNewPositionCallback(h,id);
%    
%   Example 2
%   ---------
%   Interactively place a line by clicking and dragging. Use wait to block
%   the MATLAB command line. Double-click on the line to resume execution
%   of the MATLAB command line.
%   
%   figure, imshow('pout.tif');
%   h = imline;
%   position = wait(h);    
%     
%   See also IMROI, IMELLIPSE, IMFREEHAND, IMPOINT, IMPOLY, IMRECT, IPTGETAPI, makeConstrainToRectFcn.

%   Copyright 2005-2017 The MathWorks, Inc.

classdef imline < imroi
    
    methods

        function obj = imline(varargin)
            %imline  Constructor for imline.

            [h_group,draw_api] = imlineAPI(varargin{:});
            obj = obj@imroi(h_group,draw_api);

        end

        function setPosition(obj,varargin)
            %setPosition  Set line to new position.
            %
            %   setPosition(h,pos) sets the line h to a new position. The
            %   new position, pos, has the form [X1 Y1; X2 Y2].
            %
            %   setPosition(h,x,y) sets the line h to a new
            %   position. x and y specify the endpoint
            %   positions of the line in the form x = [x1 x2], y = [y1 y2].
            narginchk(2, 3);
            
            if length(varargin) == 1
                pos = varargin{1};
                invalidPosition = ~isequal(size(pos),[2 2]) || ~isnumeric(pos);
                if invalidPosition
                    error(message('images:imline:invalidPositionSizeOrClass'));
                end
            elseif length(varargin) == 2
                x = varargin{1};
                y = varargin{2};

                isInvalidXYVector = @(v) ~isvector(v) || length(v) ~=2 || ~isnumeric(v);
                if isInvalidXYVector(x) || isInvalidXYVector(y)
                    error(message('images:imline:invalidPositionNotVector'));
                end
                
                pos = [reshape(x,2,1),reshape(y,2,1)];
                
            end

            obj.api.setPosition(pos);

        end
        
        function setConstrainedPosition(obj,pos)
            %setConstrainedPosition  Set ROI object to new position.
            %
            %   setConstrainedPosition(h,candidate_position) sets the ROI
            %   object h to a new position.  The candidate position is
            %   subject to the position constraint function.
            %   candidate_position is of the form expected by the
            %   setPosition method.
            
            obj.api.setConstrainedPosition(pos);
            
        end

        function pos = getPosition(obj)
            %getPosition  Return current position of line.
            %
            %   pos = getPosition(h) returns the current position of the
            %   line h. The returned position, pos, is a 2-by-2 array 
            %   [x1 y1; x2 y2].

            pos = obj.api.getPosition();

        end
        
        function BW = createMask(varargin)
            %createMask  Create a mask within an image.
            %
            %   BW = createMask(h) returns a mask that is associated with
            %   the point object h over the target image. The target image
            %   must be contained within the same axes as the point. BW is a
            %   logical image the same size as the target image. BW is false
            %   outside the region of interest and true inside.
            %
            %   BW = createMask(h,h_im) returns a mask that is associated
            %   with the point object h over the image h_im. This syntax is
            %   required when the parent of the point contains more than
            %   one image.
            
            [obj,h_im] = parseInputsForCreateMask(varargin{:});
            [roix,roiy,m,n] = obj.getPixelPosition(h_im);
            
            [x,y] = iptui.intline(roix(1),roix(end), roiy(1), roiy(end));
            x = round(x);
            y = round(y);
            
            outOfBounds = (x < 1) | (x > n) | (y < 1) | (y > m);
            x(outOfBounds) = [];
            y(outOfBounds) = [];
            
            BW = false(m,n);
            ind = sub2ind([m n],y,x);
            BW(ind) = true;
            
        end

    end
    
    methods (Access = 'protected')
               
        function cmenu = getContextMenu(obj)
           
            cmenu = obj.api.getContextMenu();
            
        end
        
        function setContextMenu(obj,cmenu)
           
            obj.api.setContextMenu(cmenu);
            
        end
        
    end
       
end


function [h_group,draw_api] = imlineAPI(varargin)

commonArgs = roiParseInputs(0,3,varargin,mfilename,{});     

position              = commonArgs.Position;
interactive_placement = commonArgs.InteractivePlacement;
h_parent              = commonArgs.Parent;
h_axes                = commonArgs.Axes;
h_fig                 = commonArgs.Fig;

position_constraint_function = commonArgs.PositionConstraintFcn;
if isempty(position_constraint_function)
    % constraint_function is used by dragMotion() to give a client the
    % opportunity to constrain where the line can be dragged.
    position_constraint_function = identityFcn;
end

if ~isempty(position) && ~isequal(size(position),[2 2])
    error(message('images:imline:invalidPosition'));   
end

try
    h_group = hggroup('Parent', h_parent,...
                      'Tag','imline',...
                      'DeleteFcn',@deleteContextMenu);
catch ME
    error(message('images:imline:failureToParent'));
end

% Set up listener to store current mouse position on button down. Need to
% consistently use two argument form of hittest with same current position
% information to ensure that mouse affordances and button down gestures
% are in sync.

% button down listener on the figure to cache current point
setappdata(h_group,'ButtonDownListener',...
    iptui.iptaddlistener(h_fig,...
    'WindowMousePress',@buttonDownEventFcn));

setappdata(h_group,'ButtonUpListener',...
    iptui.iptaddlistener(h_fig,...
    'WindowMouseRelease',@buttonUpEventFcn));
buttonUp = false;

% Function scope variable used to generalize stopDrag.
dragFcn = [];

%Returns API used to draw line graphic.
draw_api = lineSymbol(h_group,@startTranslateLineDrag,@startResizeLineDrag);

% cmenu needs to be in an initialized state for setColor to be called within
% createROIContextMenu
cmenu = [];

cmenu = createROIContextMenu(h_fig,@getPosition,@setColor);
setContextMenu(cmenu);

% Pattern for set associated with callbacks that get called as a
% result of the set.
insideSetPosition = false;

% Create API used to dispatch callbacks
dispatchAPI = roiCallbackDispatcher(@getPosition);

% Used to stop interactive placement for any buttonDown or buttonUp event
% after user left clicks the first time.
placementStarted = false;

% Initialize drag variables at function scope.
[start_position,start_x,start_y,...
    drag_motion_callback_id,drag_up_callback_id] = deal([]);

if interactive_placement 
    placement_aborted = manageInteractivePlacement(h_axes,h_group,@placeLine);
    if placement_aborted
        h_group = [];
        return
    end
else
    
    % we are ready to draw hg objects created by draw_api
    draw_api.setVisible(true);
end

api.setPosition                 = @setPosition;
api.getPosition                 = @getPosition;
api.delete                      = @deleteLine;
api.setColor                    = @setColor;
api.addNewPositionCallback      = dispatchAPI.addNewPositionCallback;
api.removeNewPositionCallback   = dispatchAPI.removeNewPositionCallback;
api.getPositionConstraintFcn    = @getPositionConstraintFcn;
api.setPositionConstraintFcn    = @setPositionConstraintFcn;
api.setConstrainedPosition      = @setConstrainedPosition;

% Undocumented API methods
api.setContextMenu             = @setContextMenu;
api.getContextMenu             = @getContextMenu;

% Grandfathered API methods
api.setDragConstraintFcn      = @setPositionConstraintFcn;
api.getDragConstraintFcn      = @getPositionConstraintFcn;

iptsetapi(h_group,api)

updateView(position);

% Create update function that knows how to get the position it needs when it
% will be called from HG contexts where it may not have access to the position
% otherwise.
update_fcn = @(varargin) updateView(api.getPosition());

updateAncestorListeners(h_group,update_fcn);
      
    %--------------------------------- 
    function setContextMenu(cmenu_new)
       
       %In order for IMDISTLINE to be draggable in IMTOOL, the HitTest property
       %of the hg objects created by LineSymbol() must be set to 'on'.
       %this requires that the context menu be associated with the line objects
       %rather than the h_group.
       cmenu_obj = findobj(h_group,'Type','line'); 
       set(cmenu_obj,'uicontextmenu',cmenu_new);
       
       cmenu = cmenu_new;
        
    end
    
    %-------------------------------------
    function context_menu = getContextMenu
       
        context_menu = cmenu;
    
    end
    
    %--------------------------------------------
    function completed = placeLine(x_init,y_init)
        
        isLeftClick = strcmp(get(h_fig, 'SelectionType'), 'normal');
        if ~isLeftClick
            if ~placementStarted
                completed = false;
            else
                stopEndPointMotion();
                completed = true;
                placementStarted = false;
            end
            return
        end
        
        placementStarted = true;
        
        % make line visible, interactive placement has begun.
        draw_api.setVisible(true);
        
        pos = [x_init, y_init; x_init, y_init];
        setPosition(pos);
         
        % We want to short circuit the drag code as if there was already an
        % imline on screen at the user clicked on one of the end points.
        % Get a handle to one of the end points to short circuit a call to
        % startResizeLineDrag.
        h_end_point= findobj(h_group,'tag','end point 2');
        
        startResizeLineDrag(h_end_point);
        
        % endOnButtonUp specified as true to manageInteractivePlacement. placement
        % not complete until buttonUp event occurs.
		completed = false;
         
    end %placeLine
  
    %----------------------------
    function setPosition(pos)

        % Pattern to break recursion
        if insideSetPosition
            return
        else
            insideSetPosition = true;
        end
        
        position = pos;
        
        updateView(position);
        
        % User defined newPositionCallbacks may be invalid. Wrap
        % newPositionCallback dispatches inside try/catch to ensure that
        % insideSetPosition will be unset if newPositionCallback errors.
        try
            dispatchAPI.dispatchCallbacks('newPosition');
        catch ME
            insideSetPosition = false;
            rethrow(ME);
        end
        
        % Pattern to break recursion
        insideSetPosition = false;
    end

    %--------------------------------------------
    function setConstrainedPosition(cand_position)
      
        new_position = position_constraint_function(cand_position);
        setPosition(new_position);
        
    end
  
    %-------------------------
    function pos = getPosition
        pos = position;
    end

    %--------------------------------
    function setPositionConstraintFcn(fun)
        position_constraint_function = fun;
    end

    %---------------------------------
    function fh = getPositionConstraintFcn
        fh = position_constraint_function;
    end

    %-----------------------------------
    function deleteContextMenu(varargin)
        if ishghandle(cmenu)
            delete(cmenu)
        end
    end
    
    %--------------------------------
    function deleteLine(src, varargin) %#ok varargin needed by HG caller
        if ishghandle(h_group)
            delete(h_group);
        end
    end

    %---------------------------
    function updateView(position)
        draw_api.updateView(position);
    end
    
    %-----------------------
    function setColor(color)
        if ishghandle(getContextMenu())
            updateColorContextMenu(getContextMenu(),color);
        end
        
        draw_api.setColor(matlab.images.internal.stringToChar(color));
    end
    
    %----------------------------------
    function buttonDownEventFcn(hObj,ed) %#ok needed by HG caller
        
        % This flag is used to track whether buttonUp has occurred prior to
        % the buttonDown callbacks being dispatched in startDrag.
        buttonUp = false;
                
    end

    %----------------------------------
    function buttonUpEventFcn(varargin)
        
        % This listener is used to catch buttonUp events during the setup of drag
        % callbacks in startDrag. Set buttonUp flag to true to signal that
        % buttonUp has occurred during the setup of callbacks in startDrag.
        % buttonUp is set to false within stopDrag.
        buttonUp = true;
        
    end

    function startTranslateLineDrag(varargin)
        
        if ~strcmp(get(h_fig, 'SelectionType'), 'normal')
            return
        end
        
        % Disable figure's pointer manager.
        iptPointerManager(h_fig, 'disable');
        
        start_position = position;
        
        % Get the mouse location in data space.
        [start_x,start_y] = getCurrentPoint(h_axes);
        
        %translate entire line
        drag_motion_callback_id = iptaddcallback(h_fig, ...
            'WindowButtonMotionFcn', ...
            @dragMotion);
        
        drag_up_callback_id = iptaddcallback(h_fig, ...
            'WindowButtonUpFcn', ...
            @stopDrag);
        
        dragFcn = @dragMotion;
        
        % If buttonUp has already occurred during setup of drag, call stop drag.
        % Vigorous dragging of imrect with other callbacks competiting can
        % cause imrect to miss buttonUp and get into a bad state without this
        % check. This is a fix for g561297.
        if buttonUp
            stopDrag();
        end
        
    end % end startTranslateLineDrag

    function startResizeLineDrag(h_hit,~)
        
        if ~strcmp(get(h_fig, 'SelectionType'), 'normal')
            return
        end
                
        % Disable figure's pointer manager.
        iptPointerManager(h_fig, 'disable');
        
        start_position = position;
        
        % Get the mouse location in data space.
        [start_x,start_y] = getCurrentPoint(h_axes);
        
        % drag end point
        drag_motion_callback_id = iptaddcallback(h_fig, ...
            'WindowButtonMotionFcn', ...
            @(varargin) endPointMotion(h_hit) );
        
        drag_up_callback_id = iptaddcallback(h_fig, ...
            'WindowButtonUpFcn', ...
            @(varargin) stopDrag(h_hit));
        
        dragFcn = @endPointMotion;
        
        % If buttonUp has already occurred during setup of drag, call stop drag.
        % Vigorous dragging of imrect with other callbacks competiting can
        % cause imrect to miss buttonUp and get into a bad state without this
        % check. This is a fix for g561297.
        if buttonUp
            stopDrag();
        end
        
    end
                
    %---------------------------
    function dragMotion(varargin)
        
        if ~ishghandle(h_axes)
            return;
        end
        
        [new_x new_y] = getCurrentPoint(h_axes);
        delta_x = new_x - start_x;
        delta_y = new_y - start_y;
        
        candidate_position = start_position + ...
            [delta_x delta_y; delta_x delta_y];
        
        new_position = position_constraint_function(candidate_position);
        
        % Only fire setPosition/callback dispatch machinery if position has
        % actually changed
        if ~isequal(new_position,getPosition())
            setPosition(new_position)
        end
        
    end % end dragMotion

    %-------------------------------
    function endPointMotion(h_hit)
        ax = ancestor(h_group, 'axes');
        if ~ishghandle(ax)
            return;
        end
        
        [new_x new_y] = getCurrentPoint(h_axes);
        delta_x = new_x - start_x;
        delta_y = new_y - start_y;
        
        hit_point = draw_api.getHitPoint(h_hit);
        
        % Only one end point can be dragged at a time, hence the logical array indexing
        % with hit_point and its complement.
        stationary_point = start_position(~hit_point,:);
        moving_point     = start_position(hit_point,:);
        
        candidate_position(hit_point,:) =...
            moving_point + [delta_x delta_y];
        
        candidate_position(~hit_point,:) = stationary_point;
        
        new_position=position_constraint_function(candidate_position);
        
        % Only fire setPosition/callback dispatch machinery if position has
        % actually changed
        if ~isequal(new_position,getPosition())
            setPosition(new_position)
        end
        
        
    end % end endPointMotion

    %-----------------------------------
    function stopDrag(h_hit,~)
        dragFcn(h_hit);
        
        iptremovecallback(h_fig, 'WindowButtonMotionFcn', ...
            drag_motion_callback_id);
        iptremovecallback(h_fig, 'WindowButtonUpFcn', ...
            drag_up_callback_id);
        
        % Enable figure's pointer manager.
        iptPointerManager(h_fig, 'enable');
        
    end % end stopDrag

end %end imline

% This is a workaround to g411666. Need pragma to allow ROIs to compile
% properly.
%#function imroi

