%IMRECT Create draggable rectangle.
%   H = IMRECT begins interactive placement of a rectangle on the current
%   axes. The function returns H, a handle to an imrect object.
%
%   The rectangle has a context menu associated with it that allows you to
%   copy the current position to the clipboard and change the color used to
%   display the rectangle. Right-click on the rectangle to access this
%   context menu.
%
%   H = IMRECT(HPARENT) begins interactive placement of a rectangle on the
%   object specified by HPARENT. HPARENT specifies the HG parent of the
%   rectangle graphics, which is typically an axes but can also be any
%   other object that can be the parent of an hggroup.
%
%   H = IMRECT(HPARENT,POSITION) creates a draggable rectangle on the
%   object specified by HPARENT. POSITION is a four-element vector that
%   specifies the initial position of the rectangle. POSITION has the form
%   [XMIN YMIN WIDTH HEIGHT].
%
%   H = IMRECT(...,PARAM1,VAL1,PARAM2,VAL2,...) creates a draggable
%   rectangle, specifying parameters and corresponding values that control
%   the behavior of the rectangle. Parameter names can be abbreviated, and
%   case does not matter.
%
%   Parameters include:
%
%   'PositionConstraintFcn'        Function handle fcn that is called whenever the
%                                  rectangle is dragged using the mouse. Type
%                                  "help imrect/setPositionConstraintFcn"
%                                  for information on valid function
%                                  handles.
%
%   Methods
%   -------
%   Type "methods imrect" to see a list of the methods.
%
%   For more information about a particular method, type
%   "help imrect/methodname" at the command line.
%
%   Remarks
%   -------
%   If you use IMRECT with an axis that contains an image object, and do
%   not specify a position constraint function, users can drag the
%   rectangle outside the extent of the image and lose the rectangle.  When
%   used with an axis created by the PLOT function, the axis limits
%   automatically expand to accommodate the movement of the rectangle.
%
%   Example 1
%   ---------
%   Display updated position in the title. Specify a position constraint
%   function using makeConstrainToRectFcn to keep the rectangle inside the
%   original xlim and ylim ranges.
%
%   figure, imshow('cameraman.tif');
%   h = imrect(gca, [10 10 100 100]);
%   addNewPositionCallback(h,@(p) title(mat2str(p,3)));
%   fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
%   setPositionConstraintFcn(h,fcn);
%
%   Example 2
%   ---------
%   Interactively place a rectangle by clicking and dragging. Use wait to block
%   the MATLAB command line. Double-click on the rectangle to resume execution
%   of the MATLAB command line.
%
%   figure, imshow('pout.tif');
%   h = imrect;
%   position = wait(h);
%
%   See also IMROI, IMELLIPSE, IMFREEHAND, IMLINE, IMPOINT, IMPOLY,
%   makeConstrainToRectFcn.

%   Copyright 2005-2017 The MathWorks, Inc.

classdef imrect < imroi
    
    methods
        
        function obj = imrect(varargin)
            %imrect  Constructor for imrect.
            
            [h_group,draw_api] = imrectAPI(varargin{:});
            obj = obj@imroi(h_group,draw_api);
            
        end
        
        function setPosition(obj,pos)
            %setPosition  Set rectangle to new position.
            %
            %   setPosition(h,pos) sets the rectangle h to a new position.
            %   The new position, pos, has the form
            %   [xmin ymin width height].
            
            invalidPosition = ~isequal(size(pos),[1 4]) || ~isnumeric(pos);
            if invalidPosition
                error(message('images:imrect:invalidPosition'))
            end
            
            obj.api.setPosition(pos);
            
        end
        
        function pos = getPosition(obj)
            %getPosition  Return current position of rectangle.
            %
            %   pos = getPosition(h) returns the current position of the
            %   rectangle h. The returned position, pos, is a 1-by-4 array
            %   [xmin ymin width height].
            
            pos = obj.api.getPosition();
            
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
        
        function setResizable(obj,TF)
            %setResizable  Set resize behavior of rectangle.
            %
            %   setResizable(h,TF) sets whether the rectangle h may be
            %   resized interactively. TF is a logical scalar.
            
            obj.api.setResizable(TF);
            
        end
        
        function setFixedAspectRatioMode(obj,TF)
            %setFixedAspectRatioMode  Control whether aspect ratio
            %preserved during resize.
            %
            %   setFixedAspectRatioMode(h,TF) sets the interactive resize
            %   behavior of the rectangle h. TF is a logical scalar. True
            %   means that the current aspect ratio is preserved during
            %   interactive resizing. False means that interactive resizing
            %   is not constrained.
            
            obj.api.setFixedAspectRatioMode(TF);
            
        end
        
    end
    
    methods (Access = 'protected')
        
        function [roix,roiy,m,n] = getPixelPosition(obj,h_im)
            
            % Overriding base class. getPixelPosition wouldn't need to be
            % overridden if getVertices becomes a public method of all ROI
            % objects.
            [xdata,ydata,a] = getimage(h_im);
            m = size(a,1);
            n = size(a,2);
            
            vert = posRect2Vertices(obj.getPosition());
            xi = vert(:,1);
            yi = vert(:,2);
            
            % Transform xi,yi into pixel coordinates.
            roix = axes2pix(n, xdata, xi);
            roiy = axes2pix(m, ydata, yi);
            
        end
        
    end
    
end


function [h_group,draw_api] = imrectAPI(varargin)


[commonArgs,specificArgs] = roiParseInputs(0,2,varargin,mfilename,{'DrawAPI'});

position              = commonArgs.Position;
interactive_placement = commonArgs.InteractivePlacement;
h_parent              = commonArgs.Parent;
h_axes                = commonArgs.Axes;
h_fig                 = commonArgs.Fig;

xy_position_vectors_specified = (nargin > 2) && ...
    isnumeric(varargin{2}) && ...
    isnumeric(varargin{3});

invalid_position_matrix = ~isempty(position) && ~isequal(size(position),[1 4]);

if xy_position_vectors_specified || invalid_position_matrix
    error(message('images:imrect:invalidPosition'))
end

draw_api = specificArgs.DrawAPI;
if isempty(draw_api);
    draw_api = wingedRect();
end

position_constraint_function = commonArgs.PositionConstraintFcn;
if isempty(position_constraint_function)
    % constraint_function is used by dragMotion() to give a client the
    % opportunity to constrain where the point can be dragged.
    position_constraint_function = identityFcn;
end

try
    h_group = hggroup('Parent', h_parent,...
        'Tag','imrect',...
        'DeleteFcn',@deleteContextMenu);
catch ME
    error(message('images:imrect:failureToParent'))
end

% This is a workaround to HG bug g349263. There are problems with the figure
% selection mode when both the hggroup and its children have a
% buttonDownFcn. Need the hittest property of the hgobjects defined in
% wingedRect to be on to determine what type of drag action to take.  When
% the hittest of hggroup children is on, the buttonDownFcn of the hggroup
% doesn't fire. Instead, pass buttonDownFcn to children inside the appdata of
% the hggroup.
draw_api.initialize(h_group,@startTranslateDrag,@startSideResizeDrag,@startCornerResizeDrag)

% cmenu needs to be in an initialized state for setColor to be called within
% createROIContextMenu
cmenu = [];

cmenu = createROIContextMenu(h_fig,@getPosition,@setColor);
setContextMenu(cmenu);

% Cache a handle to fix aspect context menu at function scope
fix_aspect_context_menu = uimenu(cmenu,...
    'Label', getString(message('images:roiContextMenuUIString:fixAspectRatioContextMenuLabel')), ...
    'Tag','fix aspect ratio cmenu item',...
    'Callback',@manageFixedAspectContextMenu);

% Set up listener to store current mouse position on button down. Need to
% consistently use two argument form of hittest with same current position
% information to ensure that mouse affordances and button down gestures
% are in sync.
setappdata(h_group,'ButtonDownListener',...
    iptui.iptaddlistener(h_fig,...
    'WindowMousePress',@buttonDownEventFcn));

setappdata(h_group,'ButtonUpListener',...
    iptui.iptaddlistener(h_fig,...
    'WindowMouseRelease',@buttonUpEventFcn));
buttonUp = false;

% Pattern for set associated with callbacks that get called as a
% result of the set.
insideSetPosition = false;

% aspect_ratio_fixed is logical scalar that controls whether the aspect
% ratio of the rectangle is preserved during corner drag gestures.
aspect_ratio_fixed = false;

% Create callback dispatcher API.
dispatchAPI = roiCallbackDispatcher(@getPosition);

% Used to stop interactive placement for any buttonDown or buttonUp event
% after user left clicks the first time.
placementStarted = false;

[start_vert,start_x,start_y,dragFcn,drag_motion_callback_id,...
 connected_vertices_x,connected_vertices_y,selected_vertex,drag_up_callback_id,...
 connected_vertices,is_vertical_side,is_shift_click,start_position] = deal([]);

if interactive_placement
    placement_aborted = manageInteractivePlacement(h_axes,h_group,@placeRect);
    if placement_aborted
        h_group = [];
        return;
    end
else
    % If user specified position, turn on visibility of hg objects.
    draw_api.setVisible(true);
end

api.setPosition                   = @setPosition;
api.getPosition                   = @getPosition;
api.delete                        = @deleteRect;
api.setColor                      = @setColor;
api.addNewPositionCallback        = dispatchAPI.addNewPositionCallback;
api.removeNewPositionCallback     = dispatchAPI.removeNewPositionCallback;
api.getPositionConstraintFcn      = @getPositionConstraintFcn;
api.setPositionConstraintFcn      = @setPositionConstraintFcn;
api.setConstrainedPosition        = @setConstrainedPosition;
api.setResizable                  = @setResizable;
api.setFixedAspectRatioMode       = @setFixedAspectRatioMode;

% Undocumented API methods.
api.addCallback    = dispatchAPI.addCallback;
api.removeCallback = dispatchAPI.removeCallback;
api.setContextMenu = @setContextMenu;
api.getContextMenu = @getContextMenu;

% Note: The Following API syntaxes are discouraged.  Each
% discouraged syntax is aliased to a current syntax to support clients
% calling the old discouraged syntaxes.
api.setDragConstraintCallback = @setPositionConstraintFcn;
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
        
        %In order for IMRECT to have different drag behaviors based on the object
        %returned by hittest, the hittest property of the hg objects created by
        %wingedRect must be set to 'on'.  This requires that the context menu be
        %associated with the hg objects created by wingedRect rather than the h_group.
        cmenu_obj = findobj(h_group,'Type','line','-or','Type','patch');
        set(cmenu_obj,'uicontextmenu',cmenu_new);
        
        cmenu = cmenu_new;
        
    end

%-------------------------------------
    function context_menu = getContextMenu
        
        context_menu = cmenu;
        
    end

%-----------------------------------------------------
    function completed = placeRect(x_init,y_init)
        
        isLeftClick = strcmp(get(h_fig, 'SelectionType'), 'normal');
        if ~isLeftClick
            if ~placementStarted
                completed = false;
            else
                stopCornerResize();
                completed = true;
                placementStarted = false;
            end
            return
        end
        
        placementStarted = true;
        
        % User has clicked within axes, make hg objects created by draw_api visible.
        draw_api.setVisible(true);
        
        setPosition([x_init y_init 0 0]);
                
        % We want to short circuit the drag code as if there was already an
        % imrect on screen at the user clicked on one of the corners.
        % Get a handle to one of the corners to short circuit a call to
        % startCornerResizeDrag.
        h_corner = findobj(h_group,'tag','minx miny corner marker');
        startCornerResizeDrag(h_corner);
        
        % endOnButtonUp specified as true to manageInteractivePlacement. placement
        % not complete until buttonUp event occurs.
        completed = false;
        
    end %placeRect

%---------------------------------
    function setPosition(new_position)
        
        % Pattern to break recursion
        if insideSetPosition
            return
        else
            insideSetPosition = true;
        end
        
        position = new_position;
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

%-------------------------------------
    function setPositionConstraintFcn(fun)
        position_constraint_function = fun;
    end

%-------------------------------------
    function fh = getPositionConstraintFcn
        fh = position_constraint_function;
    end

%-----------------------------------
    function deleteContextMenu(varargin)
        if ishghandle(cmenu)
            delete(cmenu);
        end
    end

%----------------------------
    function deleteRect(varargin)
        if ishghandle(h_group)
            delete(h_group);
        end
    end

%-----------------------
    function updateView(pos)
        draw_api.updateView(pos);
    end

%-----------------------
    function setColor(color)
        if ishghandle(getContextMenu())
            updateColorContextMenu(getContextMenu(),color);
        end
        color = matlab.images.internal.stringToChar(color);
        draw_api.setColor(color);
    end

%-----------------------------------
    function buttonDownEventFcn(hObj,ed) %#ok later argument ed is needed
        
        % This function also sets the buttonUp flag to false. This flag is used
        % to track whether buttonUp has occurred prior to the buttonDown
        % callbacks being dispatched in startDrag.
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

%------------------------
    function setResizable(TF)
        
        if TF
            draw_api.setResizable(true);
            set(fix_aspect_context_menu,'Visible','on')
        else
            draw_api.setResizable(false);
            set(fix_aspect_context_menu,'Visible','off')
        end
        
    end

%----------------------------------------------
    function manageFixedAspectContextMenu(varargin)
        
        if ~aspect_ratio_fixed
            setFixedAspectRatioMode(true);
        else
            setFixedAspectRatioMode(false);
        end
        
    end

%-------------------------------
    function fixAspectRatio(TF)
        
        if TF
            aspect_ratio_fixed = true;
        else
            aspect_ratio_fixed = false;
        end
        
    end

%-----------------------------------
    function setFixedAspectRatioMode(TF)
        
        if TF
            fixAspectRatio(true);
            draw_api.setFixedAspectRatio(true);
            set(fix_aspect_context_menu,'Checked','on');
        else
            fixAspectRatio(false);
            draw_api.setFixedAspectRatio(false);
            set(fix_aspect_context_menu,'Checked','off');
        end
        
    end

  function [abortDrag,start_position,start_vert,start_x,start_y] = basicDragSetup
        
        mouse_selection = get(h_fig,'SelectionType');
        is_normal_click = strcmp(mouse_selection,'normal');
        
        is_modifier_key_pressed = ~isempty(get(h_fig,'CurrentModifier'));
        is_shift_click = strcmp(mouse_selection,'extend') &&...
            is_modifier_key_pressed;
        
        abortDrag = ~(is_normal_click || is_shift_click);
        
        start_position = position;
        
        start_vert = posRect2Vertices(start_position);
        
        [start_x,start_y] = getCurrentPoint(h_axes);
        
        if ~abortDrag
            iptPointerManager(h_fig,'disable');
        end
        
    end


    function startTranslateDrag(~,~)
        
        [abortDrag,start_position,start_vert,start_x,start_y] = basicDragSetup();
        
        if abortDrag
            return
        end
                
        dragFcn = @translateRect;
        
        drag_motion_callback_id = iptaddcallback(h_fig, ...
            'WindowButtonMotionFcn', ...
            dragFcn);
        
        drag_up_callback_id = iptaddcallback(h_fig, ...
            'WindowButtonUpFcn', ...
            @stopDrag);
        
        if buttonUp
            stopDrag();
        end
        
    end

    function startCornerResizeDrag(h_hit,~)
                
        [abortDrag,start_position,start_vert,start_x,start_y] = basicDragSetup();
        
        if abortDrag
            return
        end
                
        selected_vertex = draw_api.findSelectedVertex(h_hit);
        
        [connected_vertices_x,connected_vertices_y] = findXYConnection(selected_vertex);
        
        if is_shift_click
            fixAspectRatio(true);
        end
        
        dragFcn = @cornerResize;
        
        drag_motion_callback_id = iptaddcallback(h_fig, ...
            'WindowButtonMotionFcn', ...
            dragFcn);
        
        drag_up_callback_id = iptaddcallback(h_fig, ...
            'WindowButtonUpFcn', ...
            @stopCornerResize);
        
        if buttonUp
            stopDrag();
        end
        
    end

    function startSideResizeDrag(h_hit,~)
       % Vertex      Index
        %-----------------
        % xmin,ymin   1
        % xmin,ymax   2
        % xmax,ymax   3
        % xmax,ymin   4
        %
        %        2
        %  2------------3
        %  |            |
        % 1|            |3
        %  |            |
        %  1------------4
        %        4
        
        [abortDrag,start_position,start_vert,start_x,start_y] = basicDragSetup();
        
        if abortDrag
            return
        end
                
        findConnectedVertices = @(side_index) [side_index,1+mod(side_index,4)];
        isVerticalSide = @(side_index) (side_index == 1) || (side_index ==3);
        
        side_index = draw_api.findSelectedSide(h_hit);
        connected_vertices = findConnectedVertices(side_index);
        is_vertical_side = isVerticalSide(side_index);
        
        dragFcn = @sideResize;
        
        drag_motion_callback_id = iptaddcallback(h_fig, ...
            'WindowButtonMotionFcn', ...
            dragFcn);
        
        drag_up_callback_id = iptaddcallback(h_fig, ...
            'WindowButtonUpFcn', ...
            @stopDrag);
        
        if buttonUp
            stopDrag();
        end
        
    end
           
%--------------------------------------------------------
    function [conn_x,conn_y] = findXYConnection(corner_index)
        % conn_x are indices are vertices that are connected by a vertical line and
        % will move in the same delta_x. conn_y are indices that are connected
        % by a horizontal line and will move in the same delta_y. conn_x and
        % conn_y are used in moveConnectedVertices.
        
        % Vertex      Index
        %-----------------
        % xmin,ymin   1
        % xmin,ymax   2
        % xmax,ymax   3
        % xmax,ymin   4
        %
        %        2
        %  2------------3
        %  |            |
        % 1|            |3
        %  |            |
        %  1------------4
        %        4
        
        conn_x = [1 2];
        if ~any(corner_index == [1 2])
            conn_x = [3 4];
        end
        
        conn_y = [1 4];
        if ~any(corner_index == [1 4])
            conn_y = [2 3];
        end
        
    end


    %-------------------------------
    function translateRect(varargin)
        
        if ~ishghandle(h_axes)
            return;
        end
        
        [new_x,new_y] = getCurrentPoint(h_axes);
        delta_x = new_x - start_x;
        delta_y = new_y - start_y;
        
        current_pos = getPosition();
        start_loc = start_position(1:2);
        
        % Use start_loc + [delta_x delta_y] to determine translation. Use
        % current width and height, not starting width/height. Width/Height
        % can actually change during translation in the context of imtool
        % due to snap to pixels behavior.
        candidate_position = [start_loc current_pos(3:4)] + [delta_x delta_y 0 0];

        new_position = position_constraint_function(candidate_position);
        
        % Only fire setPosition/callback dispatch machinery if position has
        % actually changed
        if ~isequal(new_position,getPosition())
            setPosition(new_position)
            dispatchAPI.dispatchCallbacks('translateDrag');
        end
        
    end

    %----------------------------
    function sideResize(varargin)
        
        [new_x,new_y] = getCurrentPoint(h_axes);
        delta_x = new_x - start_x;
        delta_y = new_y - start_y;
        
        if is_vertical_side
            candidate_vertices = moveConnectedVertices(start_vert,connected_vertices,[],delta_x,delta_y);
        else %is_horizontal_side
            candidate_vertices = moveConnectedVertices(start_vert,[],connected_vertices,delta_x,delta_y);
        end
        
        candidate_position = vertices2PosRect(candidate_vertices);
        new_position = position_constraint_function(candidate_position);
        
        % Only fire setPosition/callback dispatch machinery if position has
        % actually changed
        if ~isequal(new_position,getPosition())
            setPosition(new_position);
            dispatchAPI.dispatchCallbacks('resizeDrag');
        end
        
    end

    %------------------------------
    function cornerResize(varargin)
        
        current_vert = posRect2Vertices(position);
        
        [new_x,new_y] = getCurrentPoint(h_axes);
        
        delta_x = new_x - start_x;
        delta_y = new_y - start_y;
        
        if ~aspect_ratio_fixed
            candidate_vertices = moveConnectedVertices(start_vert,connected_vertices_x,connected_vertices_y,delta_x,delta_y);
        else
            start_x = new_x;
            start_y = new_y;
            
            [delta_x_fixed,delta_y_fixed] = calculateFixedAspectMovement(delta_x,delta_y);
            candidate_vertices = moveConnectedVertices(current_vert,connected_vertices_x,connected_vertices_y,delta_x_fixed,delta_y_fixed);
            
            % If connectivity of vertices in sorted order has changed,
            % redetermine connectivity. It is necessary to preserve
            % connectivity in a given sorting order because position constraint
            % function requires a position rectangle.  When constrained
            % position rectangle is moved back to vertices, a sorting order
            % must be chosen.
            candidate_vertices_sorted = sortVertices(candidate_vertices);
            if (~isequal(candidate_vertices_sorted,candidate_vertices))
                
                connected_vertices_x = ...
                    recalculateConnectedVertices(connected_vertices_x,...
                    candidate_vertices,...
                    candidate_vertices_sorted);
                
                connected_vertices_y = ...
                    recalculateConnectedVertices(connected_vertices_y,...
                    candidate_vertices,...
                    candidate_vertices_sorted);
                
                selected_vertex = intersect(connected_vertices_x,connected_vertices_y);
                
            end
        end
        
        candidate_position = vertices2PosRect(candidate_vertices);
        constrained_position = position_constraint_function(candidate_position);
        
        aspect_ratio_violated_by_position_constraint = aspect_ratio_fixed && ~isequal(candidate_position,constrained_position);
        if aspect_ratio_violated_by_position_constraint
            %  If aspect_ratio has been violated by position constraint function, vert back
            %  to last known position if the last known position is at the
            %  boundary of the position constraint function. Otherwise, it is
            %  necessary to adjust the last known position such that the
            %  position constraint function is satisfied and the rectangle is
            %  positioned at the boundary of the position constraint function.
            constrained_vertices = posRect2Vertices(constrained_position);
            needToReconstrain = ~isequal(current_vert(selected_vertex,:),constrained_vertices(selected_vertex,:));
            if needToReconstrain
                constrained_position = reconstrainRectToFixedAspectRatio(candidate_position,constrained_position);
                % we have to call the position constraint function to keep
                % the cached position up to date.  We can remove this
                % additional call once we can specify the type of
                % interactive behavior to the boundary constraint functions
                % generated by makeConstrainToRectFcn (g413389).
                constrained_position = position_constraint_function(constrained_position);
            else
                constrained_position = position;
            end
        end
        
        new_position = constrained_position;
        
        % Only fire setPosition/callback dispatch machinery if position has
        % actually changed
        if ~isequal(new_position,getPosition())
            setPosition(new_position);
            dispatchAPI.dispatchCallbacks('resizeDrag');
        end
        
        %---------------------------------------------------------------------------------------------------------
        function constrained_position = reconstrainRectToFixedAspectRatio(candidate_position,constrained_position)
            
            position_constraint_correction = abs(candidate_position(3:4) - constrained_position(3:4));
            constrained_vertices = posRect2Vertices(constrained_position);
            
            if position_constraint_correction(1) > position_constraint_correction(2)
                delta_x = constrained_vertices(selected_vertex,1) -  current_vert(selected_vertex,1);
                [delta_x_fixed,delta_y_fixed] = calculateFixedAspectMovement(delta_x,0);
            else
                delta_y = constrained_vertices(selected_vertex,2) -  current_vert(selected_vertex,2);
                [delta_x_fixed,delta_y_fixed] = calculateFixedAspectMovement(0,delta_y);
            end
            
            constrained_vertices = moveConnectedVertices(current_vert,connected_vertices_x,connected_vertices_y,delta_x_fixed,delta_y_fixed);
            
            constrained_position = vertices2PosRect(constrained_vertices);
        end
        
        %-------------------------------------------------------------------------------------
        function [delta_x_fixed,delta_y_fixed] = calculateFixedAspectMovement(delta_x,delta_y)
            % Maintain aspect ratio by only allowing fixed aspect ratio changes to
            % current vertex positions.
            
            % At [xmin ymax] and [xmax ymin] vertices delta_x and delta_y need to have
            % opposite signs.
            %
            % Vertex      Index
            %-----------------
            % xmin,ymin   1
            % xmin,ymax   2
            % xmax,ymax   3
            % xmax,ymin   4
            %
            %  2------------3
            %  |            |
            %  |            |
            %  1------------4
            
            sgn = 1;
            if (selected_vertex == 2 || selected_vertex == 4)
                sgn = -sgn;
            end
            
            pos = getPosition();
            
            degenerate_point      = pos(3) == 0 && pos(4) == 0;
            degenerate_vert_line  = pos(3) == 0 && pos(4) ~= 0;
            degenerate_horiz_line = pos(4) == 0 && pos(3) ~= 0;
            
            if ~degenerate_point
                aspect_ratio = pos(3)/pos(4);
            else
                aspect_ratio = 1;
            end
                        
            if degenerate_vert_line
                delta_y_fixed = delta_y;
                delta_x_fixed = 0;
            elseif degenerate_horiz_line
                delta_x_fixed = delta_x;
                delta_y_fixed = 0;
            else
                if abs(delta_y) > abs(delta_x)
                    delta_y_fixed = delta_y;
                    delta_x_fixed = sgn * delta_y * aspect_ratio;
                else
                    delta_x_fixed = delta_x;
                    delta_y_fixed = sgn * delta_x / aspect_ratio;
                end
            end
            
        end %calculateFixedAspectMovement
        
    end %cornerResize

    %--------------------------
    function stopDrag(varargin)
        
        dragFcn();
        iptremovecallback(h_fig, 'WindowButtonMotionFcn', ...
            drag_motion_callback_id);
        iptremovecallback(h_fig, 'WindowButtonUpFcn', ...
            drag_up_callback_id);
        
        % Enable the figure's pointer manager.
        iptPointerManager(h_fig, 'enable');
        
    end

    %----------------------------------
    function stopCornerResize(varargin)
        
        stopDrag();
        if is_shift_click
            fixAspectRatio(false)
        end
        
    end

    %--------------------------------------------------------------------------------------------------------------
    function vert_out = moveConnectedVertices(start_vert,connected_vertices_x,connected_vertices_y,delta_x,delta_y)
        
        % When connected_vertices_x or connected_vertices_y is empty, the assignment
        % operations for delta_vert are no-ops. Empty for either delta_x or
        % delta_y means do not apply a delta_x or delta_y to the matrix of
        % vertices.
        
        delta_vert = zeros(size(start_vert));
        delta_vert(connected_vertices_x,1) = delta_x;
        delta_vert(connected_vertices_y,2) = delta_y;
        vert_out = start_vert + delta_vert;
        
    end

    %-------------------------------------
    function vert_out = sortVertices(vert)
        
        vert_out = zeros(4,2);
        xmin = min(vert(:,1));
        ymin = min(vert(:,2));
        xmax = max(vert(:,1));
        ymax = max(vert(:,2));
        
        vert_out(1,:) = [xmin ymin];
        vert_out(2,:) = [xmin ymax];
        vert_out(3,:) = [xmax ymax];
        vert_out(4,:) = [xmax ymin];
        
    end

    %-------------------------------------------------------------------------------
    function connected_vertices = recalculateConnectedVertices(connected_vertices,...
            candidate_vertices,...
            candidate_vertices_sorted)
        
        % Purpose: when moving from a position rectangle to a list of vertices,
        % there must be a consistent sorting order. If the rectangle folds
        % over itself during a drag, the indices of the vertices being
        % moved by the drag need to be updated to be consistent with the
        % vertices in sorted order.
        %
        % Inputs: connected_vertices is a set of indices into the rows of candidate_vertices
        %         candidate_vertices is a matrix of vertices, one row at a time which are not in sorted order
        %         candidate_vertices_sorted is a sorted version of candidate_vertices in some sorting order.
        %
        % Output: connected_vertices is a recalculated set of indices
        %         corresponding to the rows of candidate_vertices_sorted.
        
        perms = 1:4;
        numRows = size(candidate_vertices,1);
        
        for i = 1:numRows
            if ~isequal(candidate_vertices(i,:),candidate_vertices_sorted(i,:))
                
                vertex_to_find = repmat(candidate_vertices_sorted(i,:),numRows-(i-1),1);
                matching_vertices = all(candidate_vertices(i:end,:) == vertex_to_find,2);
                
                sorted_loc = find(matching_vertices,1)+(i-1);
                
                temp = candidate_vertices(i,:);
                candidate_vertices(i,:) = candidate_vertices(sorted_loc,:);
                candidate_vertices(sorted_loc,:) = temp;
                
                temp = perms(i);
                perms(i) = perms(sorted_loc);
                perms(sorted_loc) = temp;
                
            end
        end
        
        connected_vertices = perms(connected_vertices);
        
        
    end % recalculateConnectedVertices

end % imrect

% This is a workaround to g411666. Need pragma to allow ROIs to compile
% properly.
%#function imroi

