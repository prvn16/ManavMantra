function retval = datacursormode(varargin)
%DATACURSORMODE Interactively create data cursors on plot
%   DATACURSORMODE ON turns on cursor mode.
%   DATACURSORMODE OFF turns off cursor mode
%   DATACURSORMODE by itself toggles the state.
%   DATACURSORMODE(FIG,...) works on specified figure handle.
%
%   H = DATACURSORMODE(FIG)
%        Returns the figure's data cursor mode object for
%        customization. The following properties can be
%        modified using set/get:
%
%        Figure <handle>
%        Specifies associated figure handle. This property
%        supports GET only.
%
%        Enable  'on'|'off'
%        Specifies whether this figure mode is currently
%        enabled on the figure.
%
%        SnapToDataVertex 'on'|'off'
%        Specified whether data cursors snap to nearest data
%        value or appear at mouse position.
%
%        DisplayStyle 'datatip' | 'window'
%        'datatip' displays cursor information as a text box
%        and marker and 'window' displays cursor information
%        in a floating window within the figure.
%
%        UpdateFcn <function_handle>
%        Set this callback to customize the text that appears
%        in the data cursor. The input function handle should
%        reference a function with two implicit arguments (similar
%        to handle callbacks):
%
%             function [output_txt] = myfunction(obj,event_obj)
%             % OBJ        handle to object generating the
%             %            callback (empty in this release).
%             % EVENT_OBJ  handle to event object
%             % OUTPUT_TXT data cursor text string (string or
%             %            cell array of strings).
%
%             The event object has the following read only
%             properties:
%             Target    The handle of the object the data cursor
%                       is referencing.
%             Position  An array specifying x,y,(z) location of
%                       cursor.
%
%   INFO = getCursorInfo(H)
%       Calling the function GETCURSORINFO on the data cursor
%       mode object, H, will return a vector structures (one for
%       each data cursor). Each structure contains the fields:
%             Target    The handle of the object the data cursor
%                       is referencing (i.e. the object that was
%                       clicked on).
%             Position  An array specifying x,y,(z) location of
%                       cursor.
%
%   EXAMPLE 1:
%
%   surf(peaks);
%   datacursormode on
%   % mouse click on plot
%
%
%   EXAMPLE 2:
%
%   surf(peaks);
%   h = datacursormode;
%   h.DisplayStyle = 'datatip';
%   h.SnapToData = 'off';
%   % mouse click on plot
%   s = getCursorInfo(h);
%
%   EXAMPLE 3: (copy into a file)
%
%   function demo
%   % Customize datatip string to display 'Amplitude' and
%   % 'Time'.
%   fig = figure;
%   plot(rand(1,10));
%   h = datacursormode(fig);
%   h.UpdateFcn = @myupdatefcn;
%   h.SnapToDataVertex = 'on';
%   datacursormode on
%   % mouse click on plot
%
%   function [txt] = myupdatefcn(obj,event_obj)
%   % Display 'Time' and 'Amplitude'
%   pos = event_obj.Position;
%   txt = {['Time: ',num2str(pos(1))],['Amplitude: ',num2str(pos(2))]};
%
%   See also GINPUT.

%   Copyright 2003-2015 The MathWorks, Inc.

% UNDOCUMENTED FUNCTIONALITY
% The following features may change in a future release.
%
% DATACURSORMODE(fig,'enableandcreate')
%    Turns on mode and fires button down function as if user clicked
%    at current mouse location.
%
%
% The following object events are thrown by the data cursor
% mode object:
%   'MouseMotion' Fires when mode is enabled and mouse is moving.
%   'ButtonDown'  Fires when mode is enabled and mouse is pressed.

action = []; % 'toggle' | 'on' | 'off'

fig = [];
if nargin==0
    fig = gcf;
    action = 'toggle';
    
elseif nargin==1
    arg1 = varargin{1};
    if ischar(arg1) || isstring(arg1)
        if nargout > 0
            error(message('MATLAB:datacursormode:NoOutputOnEnableDisable')); 
        end
        % Check for valid action types else throw an error
        actionTypes = {'on','off','toggle','ison','retval','none'};
        if isempty(find(strcmpi(arg1,actionTypes), 1))
            error(message('MATLAB:datacursormode:UnrecognizedInput'));
        else
            action = arg1;
            fig = gcf;
        end        
    elseif ishghandle(arg1,'figure')
        fig = arg1;
        if nargout==1
            action = 'retval';
        else
            action = 'toggle';
        end
    end
    
elseif nargin==2
    if nargout > 0
        error(message('MATLAB:datacursormode:InvalidInputForOutArg'));        
    end
    fig = varargin{1};
    action = varargin{2};    
else
    error(message('MATLAB:datacursormode:maxrhs'));
end

fig = handle(fig);

if isempty(fig) || ~ishghandle(fig,'figure')
    error(message('MATLAB:datacursormode:InvalidFigureHandle'))
end

% Get the data cursor tool object
hMode = localGetMode(fig);
hTool = localGetObj(hMode);

% Take appropriate action
switch(action)
    case 'on'
        activateuimode(fig,'Exploration.Datacursor');
    case 'off'
        if isactiveuimode(fig,'Exploration.Datacursor')
            activateuimode(fig,'');
        end
    case 'toggle'
        curr = get(hMode,'Enable');
        if strcmp(curr,'on') && isactiveuimode(fig,'Exploration.Datacursor')
            activateuimode(fig,'');
        else
            activateuimode(fig,'Exploration.Datacursor');
        end
        if nargout==1
            retval = hTool;
        end
        
        % Undocumented syntax
    case 'ison'
        retval = get(hMode,'Enable');
        
    case 'retval'
        retval = hTool;
        
    case 'none'
        % do nothing        
end

%-----------------------------------------------%
function localUpdateUIContextMenu(varargin) %#ok
% Stub method for reverse compatibility purposes.

%-----------------------------------------------%
function hTool = localGetObj(hMode)

hTool = hMode.ModeStateData.DataCursorTool;

% Create tool object
if isempty(hTool) || ~isvalid(hTool)
    hTool = matlab.graphics.shape.internal.DataCursorManager(hMode);
    hMode.UIContextmenu = hTool.UIContextMenu;
end

%-----------------------------------------------%
function hMode = localGetMode(hFig)

hMode = getuimode(hFig,'Exploration.Datacursor');
if isempty(hMode)
    hMode = uimode(hFig,'Exploration.Datacursor');
    
    % Create the datacursormanager object
    hTool = matlab.graphics.shape.internal.DataCursorManager(hMode);
    hMode.UIContextMenu = hTool.UIContextMenu;
    hMode.ModeStateData.DataCursorTool = hTool;
    
    %Set mode properties
    set(hMode,'WindowButtonMotionFcn',@localWindowMotionFcn);
    set(hMode,'WindowButtonDownFcn',@localWindowButtonDownFcn);
    set(hMode,'KeyPressFcn',@localKeyPressFcn);
    set(hMode,'ModeStartFcn',{@localSetUIOn,hMode});
    set(hMode,'ModeStopFcn',{@localSetUIOff,hMode});
    hMode.ModeStateData.newCursor = false;
end

%-----------------------------------------------%
function localSetEnable(obj,evd,hTool,hMode) %#ok
% Turn on/off UI to maintain consistency between the object and mode.

if get(hTool,'Debug')
    disp('localSetEnable')
end
fig = get(hTool,'Figure');
onoff = get(hTool,'Enable');
if strcmpi(onoff,'on')
    activateuimode(fig,'Exploration.Datacursor');
else
    activateuimode(fig,'');
end

%-----------------------------------------------%
function localSetUIOn(hMode)

fig = get(hMode,'FigureHandle');
hTool = hMode.ModeStateData.DataCursorTool;
hTool.startMode();

setptr(fig,'datacursor');

% Turn on UI state
set(uigettool(fig,'Exploration.DataCursor'),'State','on');
set(findall(fig,'Tag','figMenuDatatip'),'Checked','on');

%-----------------------------------------------%
function localSetUIOff(hMode)
% Turn off UI state

fig = get(hMode,'FigureHandle');
hTool = hMode.ModeStateData.DataCursorTool;
hTool.endMode();
set(uigettool(fig,'Exploration.DataCursor'),'State','off');
set(findall(fig,'Tag','figMenuDatatip'),'Checked','off');

%-----------------------------------------------%
function localKeyPressFcn(fig,evd)

hMode = localGetMode(fig);
hTool = localGetObj(hMode);

% Exit early if invalid event data
if ~isobject(evd) || ~isvalid(evd)
    return;
end

keypressed = evd.Key;

consumekey = false;

% Parse key press
movedir = [];
switch keypressed
    case 'leftarrow'
        movedir = 'left';
    case 'rightarrow'
        movedir = 'right';
    case 'uparrow'
        movedir = 'up';
    case 'downarrow'
        movedir = 'down';
    case {'alt', 'shift'}
        consumekey = true;
end

% Move/delete datacursor
hCursor = get(hTool,'CurrentCursor');
if ~isempty(hCursor) && isvalid(hCursor)
    if ~isempty(movedir)
        hCursor.increment(movedir);
        consumekey = true;
    elseif strcmp(keypressed,'delete')
        hTool.removeDataCursor(hCursor);
        consumekey = true;
    end
end

% Pass key to command window if ignored here. This maintains
% old style figure behavior
if ~consumekey
    graph2dhelper('forwardToCommandWindow',fig,evd);
end

%-----------------------------------------------%
function localWindowButtonDownFcn(fig,evd)

hMode = localGetMode(fig);
hTool = localGetObj(hMode);

% Right click is for reserved context menu and we don't have an open
% action.  We need to continue with "extend" because this includes
% shift-clicking
sel_type = get(fig,'SelectionType');
mod = get(fig,'CurrentModifier');
isAddRequest = numel(mod)==1  && (strcmp(mod{1},'shift') || strcmp(mod{1},'alt'));
if ~(strcmp(sel_type,'normal') ...
        || (isAddRequest && strcmp(sel_type,'extend')))
    return;
end

% Determine the object that we clicked on.
[hTarget, doignore] = localGetTarget(fig, evd);

if ~doignore
    set(fig,'CurrentObject',hTarget);
    disp_style = get(hTool,'DisplayStyle');
    if strcmp(disp_style,'datatip')
        
        % Create new datatip if user clicks on 'shift' key (documented behaviour)
        % or 'alt' key (old behaviour still supported)
        doNewDatatip = hMode.ModeStateData.newCursor || isAddRequest;
        % Reset the new cursor state.
        hMode.ModeStateData.newCursor = false;
        
        localCreateTip(fig, hTool, hTarget, doNewDatatip);
    else
        localCreateTip(fig, hTool, hTarget, false);
    end
end

%-----------------------------------------------%
function [TargetDA, doignore] = localGetTarget(~, evd)
% Call a function that contains heuristics to cope with other objects such
% as brushing and selection handles.
hTarget = evd.HitObject;

% Check whether this target has been intentionally disabled via the
% behavior object.
hBehavior = hggetbehavior(hTarget, 'DataCursor', '-peek');
if ~isempty(hBehavior) && isvalid(hBehavior) && ~get(hBehavior,'Enable')
    TargetDA = [];
    doignore = true;
else
    % Get a data annotatable handle for hTarget if possible
    TargetDA = matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(hTarget);
    
    if isempty(TargetDA)
        % Try to search for a hTarget ancestor that is DataAnnotatable
        TargetDA = ancestor(hTarget,'matlab.graphics.chart.interaction.DataAnnotatable');
    end
    
    doignore = isempty(TargetDA);
end

%-----------------------------------------------%
function localCreateTip(fig, hTool, hTarget, docreate)
% Create datatip UI

hTip = hTool.getCurrentDataTip();

% Check whether to override due to Draggable property
if ~docreate && strcmp(hTool.DisplayStyle,'datatip') ...
        && ~isempty(hTip) && strcmpi(hTip.Draggable,'off')
    
    docreate = true;
end

if ~docreate
    % Query target's behavior object to see if we should always create a
    % new datatip
    hTargetBehavior = hggetbehavior(hTarget,'DataCursor','-peek');
    if ~isempty(hTargetBehavior) && isvalid(hTargetBehavior)
        docreate = get(hTargetBehavior,'CreateNewDatatip');
    end
end

% Get position to place the tip at
figPoint = get(fig,'CurrentPoint');
figPoint = hgconvertunits(fig,[figPoint 0 0],get(fig,'Units'),'pixels',fig);
figPoint = figPoint(1:2);

% Create a new datatip when appropriate
if isempty(hTip) || docreate
    hTip = hTool.createDatatip(hTarget, figPoint);
else
    % Update the target
    hTip.DataSource = hTarget;
    
    % Update position
    hTip.Cursor.moveTo(figPoint);
end

% Begin interaction with the tip
hTip.beginInteraction;

%-----------------------------------------------%
function localWindowMotionFcn(obj,evd)

fig = obj;

hHit = evd.HitObject;
if isa(hHit,'matlab.graphics.shape.internal.TipLocator') ...
        ||  isa(hHit,'matlab.graphics.shape.internal.TipInfo')
    % If over a tip component, set the pointer to a fleur.
    set(fig,'Pointer','fleur');
elseif isa(hHit, 'matlab.graphics.shape.internal.ScribePeer') && any(strcmp(hHit.Tag,{'PointTipLocator', 'GraphicsTip'}))
    % If over a tip component, set the pointer to a fleur.
    set(fig,'Pointer','fleur');
elseif isa(hHit, 'matlab.ui.control.StyleControl')  && strcmpi(hHit.Tag,'figpanel: title bar')
    % If in window mode and over the window title bar, set the pointer to a
    % fleur.
    set(fig,'Pointer','fleur');
elseif isa(hHit, 'matlab.ui.control.StyleControl')  && strcmpi(hHit.Tag,'figpanel:text field')
    % If over the text field, set the pointer to an arrow.
    setptr(fig,'arrow');
else
    % Test whether we will be able to get a DataAnnotatable target if the
    % user were to click here.
    [~, doignore] = localGetTarget(fig, evd);
    
    if ~doignore
        % Set the pointer to a datacursor creation one
        setptr(fig,'datacursor');
    else
        % Over nothing of interest, i.e., the space outside all axes.  Set the
        % pointer back to the default arrow.
        setptr(fig,'arrow');
    end
end

% LocalWords:  myfunction GETCURSORINFO myupdatefcn enableandcreate ison
% LocalWords:  retval Datatips noselect mlwidgets interactivecallbacks Ljava
% LocalWords:  awt lang leftarrow rightarrow uparrow downarrow hittest
% LocalWords:  Annotatable draggable docreate

