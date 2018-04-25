%IMPOINT Create draggable point.
%   H = IMPOINT begins interactive placement of a point on the current
%   axes. The function returns H, a handle to an impoint object.
%
%   The point has a context menu associated with it that allows you to copy
%   the current position to the clipboard and change the color used to
%   display the point. Right-click on the point to access this context
%   menu.
%
%   H = IMPOINT(HPARENT) begins interactive placement of a point on the
%   object specified by HPARENT. HPARENT specifies the HG parent of the
%   point graphics, which is typically an axes but can also be any other
%   object that can be the parent of an hggroup.
%
%   H = IMPOINT(HPARENT,POSITION) creates a draggable point on the object
%   specified by HPARENT. POSITION is a two-element vector that specifies
%   the initial position of the point. POSITION has the form [X Y].
%
%   H = IMPOINT(HPARENT,X,Y) creates a draggable point on the object
%   specified by HPARENT. X and Y are both scalars that together specify the
%   initial position of the point.
%
%   H = IMPOINT(...,PARAM1,VAL1,PARAM2,VAL2,...) creates a draggable point,
%   specifying parameters and corresponding values that control the behavior
%   of the point. Parameter names can be abbreviated, and case does not
%   matter.
%
%   Parameters include:
%
%   'PositionConstraintFcn'        Function handle fcn that is called whenever the
%                                  point is dragged using the mouse. Type
%                                  "help impoint/setPositionConstraintFcn"
%                                  for information on valid function
%                                  handles.
%
%   Methods
%   -------
%   Type "methods impoint" to see a list of the methods.
%
%   For more information about a particular method, type
%   "help impoint/methodname" at the command line.
%
%   Remarks
%   -------
%   If you use IMPOINT with an axis that contains an image object, and do not
%   specify a position constraint function, users can drag the point outside the
%   extent of the image and lose the point.  When used with an axis created by
%   the PLOT function, the axis limits automatically expand to accommodate the
%   movement of the point.
%
%   Example 1
%   ---------
%   Use impoint methods to set custom color, set a label, enforce a
%   boundary constraint, and update position in title as point moves.
%
%   figure, imshow('rice.png')
%   h = impoint(gca,100,200);
%   % Update position in title using newPositionCallback
%   addNewPositionCallback(h,@(h) title(sprintf('(%1.0f,%1.0f)',h(1),h(2))));
%   % Construct boundary constraint function
%   fcn = makeConstrainToRectFcn('impoint',get(gca,'XLim'),get(gca,'YLim'));
%   % Enforce boundary constraint function using setPositionConstraintFcn
%   setPositionConstraintFcn(h,fcn);
%   setColor(h,'r');
%   setString(h,'Point label');
%
%   Example 2
%   ---------
%   Interactively place a point. Use wait to block the MATLAB command line.
%   Double-click on the point to resume execution of the MATLAB command
%   line.
%
%   figure, imshow('pout.tif');
%   h = impoint;
%   position = wait(h);
%
%   See also IMROI, IMELLIPSE, IMFREEHAND, IMLINE, IMPOLY, IMRECT,
%   makeConstrainToRectFcn.

%   Copyright 2005-2017 The MathWorks, Inc.

classdef impoint < imroi
  
    methods

        function obj = impoint(varargin)
            %impoint  Constructor for impoint.

            [h_group,draw_api] = impointAPI(varargin{:});
            obj = obj@imroi(h_group,draw_api);

        end

        function setPosition(obj,varargin)
            %setPosition  Set point to new position.
            %
            %   setPosition(h,pos) sets the point h to a new
            %   position pos. The new position, pos, has the form [x y].
            %
            %   setPosition(h,new_x,new_y) sets the point h to a new
            %   position. new_x and new_y are both scalars that together
            %   specify the position of the point.

            narginchk(2, 3);

            if length(varargin) == 1
                pos = varargin{1};
                invalidPosition = ndims(pos) ~=2 || length(pos) ~=2 || ~isnumeric(pos);
                if invalidPosition
                    error(message('images:impoint:invalidPositionSizeOrClass'))
                end
            elseif length(varargin) == 2
                x = varargin{1};
                y = varargin{2};

                isInvalidCoord = @(coord) ~isscalar(coord) || ~isnumeric(coord);
                if isInvalidCoord(x) || isInvalidCoord(y)
                    error(message('images:impoint:invalidPositionNotScalar'))
                end
                pos = [x,y];
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
            %getPosition  Return current position of point.
            %
            %   pos = getPosition(h) returns the current position of the
            %   point h. The returned position, pos, is a two-element
            %   vector [x y].

            pos = obj.api.getPosition();

        end

        function setString(obj,str)
            %setString  Set text label for point.
            %
            %   setString(h,s) sets a text label for the point h. The
            %   string, s, is placed to the lower right of the point.

            obj.api.setString(str)

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
            
            BW = false(m,n);
            BW(round(roiy),round(roix)) = true;
            
        end

    end
        
    events (Hidden = true)
       
        ImpointDragged
        ImpointButtonDown
        
    end
    
end

function [h_group,draw_api] = impointAPI(varargin)

[commonArgs,specificArgs] = roiParseInputs(0,3,varargin,mfilename,{'DrawAPI'});

position              = commonArgs.Position;
interactive_placement = commonArgs.InteractivePlacement;
h_parent              = commonArgs.Parent;
h_axes                = commonArgs.Axes;
h_fig                 = commonArgs.Fig;

invalid_position =  ~isempty(position) && ~isequal(size(position), [1 2]);
if invalid_position
    error(message('images:impoint:invalidPosition'))
end

draw_api = specificArgs.DrawAPI;
if isempty(draw_api);
    draw_api = defaultPointSymbol();
end

position_constraint_function = commonArgs.PositionConstraintFcn;
if isempty(position_constraint_function)
    % constraint_function is used by dragMotion() to give a client the
    % opportunity to constrain where the point can be dragged.
    position_constraint_function = identityFcn;
end

try
    h_group = hggroup('ButtonDownFcn', @startDrag,...
        'Parent', h_parent, ...
        'HitTest', 'on',...
        'Tag','impoint',...
        'DeleteFcn',@deleteContextMenu);
catch ME
    error(message('images:impoint:failureToParent'))
end

% Initialize the draw_api now that h_group has been created.
draw_api.initialize(h_group)

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

% Initialize variables used during drag
[start_x,start_y,start_position,...
 drag_motion_callback_id,drag_up_callback_id] = deal([]);

if interactive_placement
    placement_aborted = manageInteractivePlacement(h_axes,h_group,@placePoint);
    if placement_aborted
        h_group = [];
        return
    end
else

    % If initial position specified, make graphics objects created by draw_api
    % visible
    draw_api.setVisible(true);
end

api.setPosition                = @setPosition;
api.getPosition                = @getPosition;
api.delete                     = @deletePoint;
api.setColor                   = @setColor;
api.addNewPositionCallback     = dispatchAPI.addNewPositionCallback;
api.removeNewPositionCallback  = dispatchAPI.removeNewPositionCallback;
api.getPositionConstraintFcn   = @getPositionConstraintFcn;
api.setPositionConstraintFcn   = @setPositionConstraintFcn;
api.setConstrainedPosition     = @setConstrainedPosition;
api.setString                  = @setString;

% Undocumented API methods
api.getDrawAPI                 = @getDrawAPI;
api.addCallback                = dispatchAPI.addCallback;
api.removeCallback             = dispatchAPI.removeCallback;
api.setContextMenu             = @setContextMenu;
api.getContextMenu             = @getContextMenu;

% Grandfathered API methods
api.setDragConstraintFcn      = @setPositionConstraintFcn;
api.getDragConstraintFcn      = @getPositionConstraintFcn;

iptsetapi(h_group,api)

updateView(position);

% If there is no pointer manager installed in h_fig, install and enable a
% pointer manager in the current figure.
if isempty(getappdata(h_fig,'iptPointerManager'))
    iptPointerManager(h_fig);
end

% Store pointer behavior in the hggroup object and all its children.
enterFcn = @(f,cp) set(f, 'Pointer', 'fleur');
iptSetPointerBehavior(findobj(h_group), enterFcn);

%---------------------------------
    function setContextMenu(cmenu_new)

        cmenu_obj = h_group;
        set(cmenu_obj,'uicontextmenu',cmenu_new);

        cmenu = cmenu_new;

    end

%-------------------------------------
    function context_menu = getContextMenu

        context_menu = cmenu;

    end

%---------------------------------------------
    function completed = placePoint(x_init,y_init)

        isLeftClick = strcmp(get(h_fig, 'SelectionType'), 'normal');
        if ~isLeftClick
            if ~placementStarted
                completed = false;
            else
                stopDrag();
                completed = true;
                placementStarted = false;
            end
            return
        end
        
        placementStarted = true;

        % make point visible, interactive placement has begun.
        draw_api.setVisible(true);

        position = [x_init,y_init];

        % Do not use setPosition, translateView method of draw_api depends on
        % variables which are not yet initialized during interactive
        % placement.
        updateView(position);
        drawnow('expose');

        startDrag();

        % endOnButtonUp specified as true to manageInteractivePlacement. placement
        % not complete until buttonUp event occurs.
        completed = false;
        
    end

%-----------------------------
    function setPosition(pos)

        % Pattern to break recursion
        if insideSetPosition
            return
        else
            insideSetPosition = true;
        end

        position = pos;

        if isfield(draw_api,'translateView')
            % Call translateView here if we can instead of updateView because
            % we know that we are just translating the point symbol and
            % translateView is faster than updateView which also handles
            % other changes to the ancestor properties.
            draw_api.translateView(position);
        else
            updateView(position)
        end

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

%---------------------------------
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
            delete(cmenu);
        end
    end

%-----------------------------
    function deletePoint(varargin)
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

%--------------------
    function setString(s)
        s = matlab.images.internal.stringToChar(s);
        draw_api.setString(s);
    end

%------------------------
    function api = getDrawAPI
        api = draw_api;
    end

%--------------------------------
    function startDrag(varargin)

        % If the impoint object already exists, notify all listeners that a
        % buttonDownEvent has happened. This use of getappdata won't be
        % necessary once the impointAPI is converted into an object.
        if ~isempty(getappdata(h_group,'roiObjectReference'))
            notify(getappdata(h_group,'roiObjectReference'),'ImpointButtonDown');
        end
        
        if strcmp(get(h_fig, 'SelectionType'), 'normal')

            % Disable the figure's pointer manager during the drag.
            iptPointerManager(h_fig, 'disable');

            % Get the mouse location in data space.
            [start_x,start_y] = getCurrentPoint(h_axes);

            start_position = [start_x,start_y];

            drag_motion_callback_id = iptaddcallback(h_fig, ...
                'WindowButtonMotionFcn', ...
                @dragMotion);

            drag_up_callback_id = iptaddcallback(h_fig, ...
                'WindowButtonUpFcn', ...
                @stopDrag);
        end

    end % startDrag

%----------------------------
    function dragMotion(varargin)
        
        if ~ishghandle(h_axes)
            return;
        end
        
        [new_x,new_y] = getCurrentPoint(h_axes);
        delta_x = new_x - start_x;
        delta_y = new_y - start_y;
        
        candidate_position = start_position + [delta_x delta_y];
        new_position = position_constraint_function(candidate_position);
        
        % Don't allow setPosition or callback machinery to fire unless
        % position has actually changed
        if ~isequal(new_position,getPosition())
            setPosition(new_position)
            dispatchAPI.dispatchCallbacks('translateDrag');
            
            % If the impoint object already exists, notify all listeners that a
            % ImpointDragged event has happened. This use of getappdata won't be
            % necessary once the impointAPI is converted into an object.
            if ~isempty(getappdata(h_group,'roiObjectReference'))
                notify(getappdata(h_group,'roiObjectReference'),'ImpointDragged');
            end
        end
        
    end


%--------------------------
    function stopDrag(varargin)
        dragMotion();
        
        iptremovecallback(h_fig, 'WindowButtonMotionFcn', ...
            drag_motion_callback_id);
        iptremovecallback(h_fig, 'WindowButtonUpFcn', ...
            drag_up_callback_id);
        
        % Enable the figure's pointer manager.
        iptPointerManager(h_fig, 'enable');
    end % stopDrag


end % impoint

% This is a workaround to g411666. Need pragma to allow ROIs to compile
% properly.
%#function imroi

