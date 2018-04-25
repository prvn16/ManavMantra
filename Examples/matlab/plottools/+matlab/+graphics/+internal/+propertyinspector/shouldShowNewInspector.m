function doShowNewInspector = shouldShowNewInspector(varargin)

%    Returns true when new JS inspector needs to be shown, else false.

%    The requirement is any graphic object that can be parented to a
%    JAVA Figure should show the new JS inspector.
%    1. UIComponents like uibutton, uilabel which cannot be parented to a
%    JAVA figure should show old JAVA Inspector for 18a release.
%    2. uicontrol which can only be parented to a JAVA figure
%    should show new inspector.
%    3. All other objects that inherit from matlab.ui.control.internal.model.ComponentModel
%    exceptions being a UIFigure and UIAxes show old inspector.
%    Objects parented to a uifigure should show old inspector
%    4. When inspecting multiple heterogenous objects like uibutton and axes, show old
%    inspector
%    5. If the platform is unsupported by the JxBrowser Version

%    FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%    and is intended for use only with the scope of function in the MATLAB
%    Engine APIs.  Its behavior may change, or the function itself may be
%    removed in a future release.

% Copyright 2017 The MathWorks, Inc.

doShowNewInspector = false;

% Check if the platform is supported
hInspectorMgnr = matlab.graphics.internal.propertyinspector.PropertyInspectorManager.getInstance();
if hInspectorMgnr.IsUnSupportedPlatform
    return;
end

if nargin > 0
    hObjs = varargin{1};
    if ~isempty(hObjs)
        doShowNewInspector = true;
        
        for i = 1:numel(hObjs)
            hObj = hObjs(i);
            
            % Exclude UiFigure being inspected
            isUIFigure =  isa(hObj,'matlab.ui.Figure') && ...
                isempty(matlab.graphics.internal.getFigureJavaFrame(hObj));
            
            % exclude objects parented to a uifigure
            parentFigure = ancestor(hObj,'Figure');
            isParentUIFigure = ~isempty(parentFigure) && ...
                isempty(matlab.graphics.internal.getFigureJavaFrame(parentFigure));
            
            if isUIFigure || isParentUIFigure || ...
                    isa(hObj,'matlab.ui.control.UIAxes') || ...
                    isa(hObj,'matlab.ui.control.internal.model.ComponentModel')
                doShowNewInspector = false;
                break;
            end
        end
    end
else
   doShowNewInspector = true; 
end
end