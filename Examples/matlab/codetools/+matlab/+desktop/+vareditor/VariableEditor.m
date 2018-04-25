classdef VariableEditor < handle
    % VariableEditor - provide access to a VariableEditor.
    
    %   Copyright 2011-2015 The MathWorks, Inc.
    
    properties (Dependent, Hidden)
        WindowLocation
        WindowVisible
    end
    
    properties (SetAccess=private)
        VariableName
    end
    
    properties (SetAccess=private, Hidden)
        WorkspaceHandle = [];
        ValidWorkspaceHandle = false;
    end
    
    properties (Access=private)
        RequestedWindowLocation
        WorkspaceID
        WorkspaceVariable
        VariableEditorPeer
        WindowTitle
        DeletionListener = [];
    end
    
    methods (Static)
        function checkAvailable
            if ~usejava('swing')
                error(message('MATLAB:openvar:TheVariableEditorNotSupported'));
            end
        end
        
        function checkVariableName(expression)
            if isstring(expression) && isscalar(expression)
                expression=char(expression);
            end
            
            if ~ischar(expression)
                error(message('MATLAB:openvar:VariableNameAsString'));
            end
            
            first = min([strfind(expression, '.'), strfind(expression, '('), strfind(expression, '{')]);
            if isempty(first) || first == 1
                first = length(expression)+1;
            end
            
            if ~isvarname(expression(1:first-1))
                error(message('MATLAB:openvar:InvalidVariableName'));
            end
        end
        
    end
    
    methods
        function obj = VariableEditor(variableName, workspaceHandle, groupName)
            matlab.desktop.vareditor.VariableEditor.checkAvailable();
            
            matlab.desktop.vareditor.VariableEditor.checkVariableName(variableName);
            
            % workspaceHandle allows callers to open variables in a specific workspace.
            if nargin < 2
                workspaceHandle = '';
            end
            
            if nargin < 3
                groupName = '';
            end
            
            if ~isempty(workspaceHandle) && ~isequal(workspaceHandle,'default')
                try
                    % Throw error if an invalid reference variable is
                    % passed. evalin needs an assignment variable as it
                    % will create an 'ans' variable if the variableName is
                    % an expression(Ex:'var.a.b.c')
                    if ismethod(workspaceHandle, 'getVariable')
                        try
                            tmpVar = getVariable(workspaceHandle, variableName); %#ok<NASGU>
                        catch
                            % In case of failure, try using evalin
                            tmpVar = evalin(workspaceHandle,variableName); %#ok<NASGU>
                        end
                    else
                        tmpVar = evalin(workspaceHandle,variableName); %#ok<NASGU>
                    end
                    clear tmpVar;
                    
                    % Check to make sure this is a valid MCOS object before
                    % assigning a deletion listener
                    m = metaclass(workspaceHandle);
                    if ~isempty(m)
                        % Add listener for when the workspace is deleted
                        obj.DeletionListener = event.listener(workspaceHandle, ...
                            'ObjectBeingDestroyed', @obj.deletionCallback);
                    end
                catch e
                    error(message('MATLAB:openvar:NonExistentVariable',variableName));
                end
            end
            
            if nargout
                com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.reportWSChange();
            end
            
            obj.VariableName = variableName;
            obj.WorkspaceHandle = workspaceHandle;
            obj.ValidWorkspaceHandle = true;
            obj.WorkspaceID = workspacefunc('getworkspaceid',workspaceHandle);
            obj.RequestedWindowLocation = getDefaultScreenLocation(com.mathworks.mde.array.ArrayEditor.DEFAULT_SIZE.width);
            obj.WorkspaceVariable = com.mathworks.mlservices.WorkspaceVariable(obj.VariableName, obj.WorkspaceID);
            obj.VariableEditorPeer = com.mathworks.mde.array.ArrayEditor(obj.WorkspaceVariable, groupName);
            obj.WindowTitle = [];
        end
        
        function open(obj)
            if ~obj.ValidWorkspaceHandle
                error(message('MATLAB:openvar:NonExistentVariable', obj.VariableName));
            else
                location = obj.RequestedWindowLocation;
                point = java.awt.Point(location(1), location(2));
                obj.VariableEditorPeer.setWindowLocation(point)
                if ~isempty(obj.WindowTitle)
                    obj.VariableEditorPeer.setWindowTitle(obj.WindowTitle)
                end
            end
        end
        
        function setEditable(obj, editable)
            obj.VariableEditorPeer.setEditable(editable)
        end
        
        function setWindowTitle(obj, title)
            obj.WindowTitle = title;
            obj.VariableEditorPeer.setWindowTitle(title)
        end
        
        function close(obj)
            % Notify the VariableEditorPeer to stop editing (if editing is
            % in progress), and close
            if ~isempty(obj.VariableEditorPeer)
                if ~isempty(obj.WorkspaceHandle) &&...
                        ~isequal(obj.WorkspaceHandle, 'default')
                    % Also clear the stored workspace from workspacefunc
                    obj.VariableEditorPeer.stopEditingCloseAndClearWS(...
                        obj.WorkspaceID);
                else
                    obj.VariableEditorPeer.stopEditingAndClose();
                    
                end
            end
        end
        
        function refresh(obj)
            obj.VariableEditorPeer.refresh();
        end
        
        function set.WindowLocation(obj, xy)
            if ~isnumeric(xy) || ~isequal(size(xy),[1,2])
                error(message('MATLAB:openvar:LocationMustBeNumericVector'));
            end
            obj.RequestedWindowLocation = xy;
            if obj.WindowVisible
                obj.open();
            end
        end
        
        function xy = get.WindowLocation(obj)
            if obj.WindowVisible
                point = obj.VariableEditorPeer.getWindowLocation();
                xy = [point.x point.y];
            else
                xy = obj.RequestedWindowLocation;
            end
        end
        
        function visible = get.WindowVisible(obj)
            visible = ~isempty(obj.VariableEditorPeer) && obj.VariableEditorPeer.isWindowVisible();
        end
        
        function delete(obj)
            obj.close();
            obj.ValidWorkspaceHandle = false;
            if ~isempty(obj.DeletionListener)
                delete(obj.DeletionListener);
            end
        end
        
        function deletionCallback(obj, varargin)
            % The workspace handle was deleted, so close the Variable
            % Editor and set the WorkspaceHandle to empty.
            obj.close();
            obj.WorkspaceHandle = [];
            obj.ValidWorkspaceHandle = false;
        end
    end
end

function location = getDefaultScreenLocation(w)
    ssize = get(0,'ScreenSize');
    % center left to right, top edge 1/3 from top of screen
    screenWidth = ssize(3);
    screenHeight = ssize(4);
    targetPoint = [screenWidth / 2 screenHeight / 3];
    x = targetPoint(1) - w / 2;
    y = targetPoint(2);
    location = [x y];
end
