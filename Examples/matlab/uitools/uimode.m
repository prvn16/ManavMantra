function hMode = uimode(hObj,name)
% This function is undocumented and will change in a future release

%UIMODE
%   MODE = UIMODE(FIG,NAME) returns a new mode for the figure
%   specified by FIG with the unique name specified by NAME.
%   The uimode object returned by the functions UIMODE and GETUIMODE
%   has the following properties which can be modified using set/get.
%
%        Name <char array>
%        The name of the mode. This property supports GET only.
%
%        FigureHandle <handle>
%        The handle of the figure on which the mode operates. This property
%        supports GET only.
%
%        WindowButtonDownFcn <function_handle>
%        Set this callback to define a callback routine that MATLAB
%        executes whenever you press a mouse button while the pointer is 
%        in the figure window.
%
%        WindowButtonUpFcn <function_handle>
%        Set this callback to define a callback routine that MATLAB
%        executes whenever you release a mouse button while the pointer is
%        in the figure window.
%
%        WindowButtonMotionFcn <function_handle>
%        Set this callback to define a callback routine that MATLAB
%        executes whenever you move the pointer within the figure window.
%
%        WindowScrollWheelFcn <function_handle>
%        Set this callback to define a callback routine that MATLAB
%        executes when the mouse scroll wheel is used in the figure window.
%
%        WindowKeyPressFcn <function_handle>
%        Set this callback to define a callback routine that MATLAB
%        executes when a key is pressed in the figure window or one of its 
%        children.
% 
%        WindowKeyReleaseFcn <function_handle>
%        Set this callback to define a callback routine that MATLAB
%        executes when a key is pressed an then released in the figure window
%        or one of its children.
%
%        KeyPressFcn <function_handle>
%        Set this callback to define a callback routine that MATLAB
%        executes when a key is pressed in the figure window.
%
%        ModeStartFcn <function_handle>
%        Set this function to define a function to be executed when the
%        mode is started.
%
%        ModeStopFcn <function_handle>
%        Set this function to define a function to be executed when the
%        mode is stopped.
%
%        UIContextMenu <function_handle>
%        Specifies a custom context menu to be displayed during a
%        right-click action.
%
%        ModeStateData <structure>
%        Use this structure to maintain state information which relates to
%        the operation of the mode.
%
%        ShowContextMenu <on/off>
%        Set this flag in the "WindowButtonDownFcn" callback to determine
%        whether a context menu should appear during the current
%        right-click operation. This property is set to "on" after the
%        completion of the operation.
%
%        ButtonDownFilter <function_handle>
%        The mode may allow an object to execute the function specified by
%        its "ButtonDownFcn" under circumstances the programmer defines,
%        depending on what the callback returns. The input function handle
%        should reference a function with two implicit arguments (similar
%        to handle callbacks):
%        
%             function [res] = myfunction(obj,event_obj)
%             % OBJ        handle to the object that has been clicked on.
%             % EVENT_OBJ  handle to event object (empty in this release).
%             % RES        a logical flag to determine whether the mode
%                          operation should take place or the 
%                          'ButtonDownFcn' property of the object should 
%                          take precedence.
%
%        UseModeContextMenu <on/off>
%        Set this property to determine whether the mode specifies its own
%        context menu or the objects in the figure should continue to post
%        their own registered context menus.
%
%   See also GETUIMODE, HASUIMODE, ACTIVATEUIMODE, ISACTIVEUIMODE

%   Copyright 2006-2014 The MathWorks, Inc.

% First check if a mode by this name is registered. If it is, error out.
if hasuimode(hObj,name)
    error(message('MATLAB:uimode:ExistingMode'));
end

if ~(ishghandle(hObj,'figure') ...
        || (isobject(hObj) && isa(hObj,'matlab.uitools.internal.uimode')))
    error(message('MATLAB:uimode:InvalidFirstInput'));
end
if ~ischar(name)
    error(message('MATLAB:uimode:InvalidSecondInput'));
end

% Call the appropriate uimode constructor
if ishghandle(hObj,'figure')
    hMode = matlab.uitools.internal.uimode;
    hMode.createuimode(handle(hObj),name);
    hManager = uigetmodemanager(hObj);
    hManager.registerMode(hMode);
elseif isa(hObj,'matlab.uitools.internal.uimode')
    hMode = matlab.uitools.internal.uimode;
    hMode.createuimode(handle(hObj.FigureHandle),name);
    hObj.registerMode(hMode);
end
