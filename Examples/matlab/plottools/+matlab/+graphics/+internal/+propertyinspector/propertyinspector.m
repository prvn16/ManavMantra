function propertyinspector(action,varargin)
% propertyinspector function can be called to show/hide/toggle property
% inspector

%    FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%    and is intended for use only with the scope of function in the MATLAB
%    Engine APIs.  Its behavior may change, or the function itself may be
%    removed in a future release.

% Copyright 2017 The MathWorks, Inc.

% For multiple objects, hObjs can be a cell array
switch lower(action)
    case 'show'
        hInspectorMgnr = matlab.graphics.internal.propertyinspector.PropertyInspectorManager.getInstance();
        
        % If no parameters are passed to the 'show'. Then, create/use the
        % current figure and enable plot-edit mode and select the default
        % object. If inspector already exists, then just bring it to the
        % front. If the inspect(obj) is called with a parameter, then use
        % the object and figure out the ancestor figure as before.
        if nargin < 2
            % Get/Create the current Figure
            hFig = gcf;
            % Use the figure as the default object
            hObjs = hFig;
            if isactiveuimode(hFig,'Standard.EditPlot')
                hMode = getuimode(hFig,'Standard.EditPlot');
                if ~isempty(hMode)
                    hObjs = hMode.ModeStateData.PlotSelectMode.ModeStateData.SelectedObjects;
                end
            end
        else
            hObjs = varargin{1};
            if iscell(hObjs)
                hFig = ancestor(hObjs{1},'figure');
                % Get the graphics array
                hObjs = [hObjs{:}];
            else
                hFig = ancestor(hObjs(1),'figure');
            end
        end
        
        % Enable plotedit mode if object is selectable and plotedit
        % mode is off
        if ~isempty(hFig) && isvalid(hFig) && ...
                ~isempty(matlab.graphics.internal.getFigureJavaFrame(hFig)) && ...
                all(isprop(hObjs,'Selected'))
            drawnow
            if ~isactiveuimode(hFig,'Standard.EditPlot')
                % when inspect(axes) is called, force drawnow so that
                % inspector positioning logic can work
                plotedit(hFig,'on');
            end
            selectobject(hObjs,'replace');
        end
        
        hInspectorMgnr.showInspector(hObjs);
    case 'hide'
        hInspectorMgnr = matlab.graphics.internal.propertyinspector.PropertyInspectorManager.getInstance();
        hInspectorMgnr.closePropertyInspector();
    case 'initinspector'
        if ~matlab.graphics.internal.propertyinspector.PropertyInspectorManager.showJavaInspector
            matlab.graphics.internal.propertyinspector.PropertyInspectorManager.getInstance();
        end
end