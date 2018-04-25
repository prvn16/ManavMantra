classdef Inspector < internal.matlab.variableeditor.MLManager & ...
        internal.matlab.variableeditor.MLWorkspace & dynamicprops
    
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % The main property inspector class.  This class can be instantiated
    % and used to inspect an object.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties
        Application;
        InspectorID;
        CurrentObjects;
        Adapter;
        
        % Specifies how to handle properties when multiple objects are
        % selected
        MultiplePropertyCombinationMode@internal.matlab.inspector.MultiplePropertyCombinationMode;
        
        % Specifies how to handle values when multiple objects are selected
        MultipleValueCombinationMode@internal.matlab.inspector.MultipleValueCombinationMode;

        % Specifies if the a timer should be used to detect changes in handle objects
        UseTimerForHandleObjects = true;
    end
    
    properties(Hidden = true)
        DeletionListeners = {};
    end
    
    methods
        % Constructor - creates a new Inspector object.
        function this = Inspector(Application, InspectorID)
            this@internal.matlab.variableeditor.MLManager(false);
            if nargin == 0
                this.Application = 'PropertyInspector';
                this.InspectorID = '/PropertyInspector';
            elseif nargin == 1
                this.Application = Application;
                this.InspectorID = '/PropertyInspector';
            else
                this.Application = Application;
                this.InspectorID = InspectorID;
            end
            this.Adapter = [];
        end
        
        % Called to inspect an object or array of objects.  If the
        % workspace is not provided, it defaults to caller.  name is
        % optional, and is required only for non-handle (value) objets.
        % Returns the Document if an output argument is specified.
        function varargout = inspect(this, objects, ...
                multiplePropertyCombinationMode, ...
                multipleValueCombinationMode, ws, name)
            
            if nargin < 2 || isempty(objects)
                objects = internal.matlab.inspector.EmptyObject;
            end
            
            % Setup MultiplePropertyCombinationMode
            if nargin < 3 || isempty(multiplePropertyCombinationMode)
                this.MultiplePropertyCombinationMode = ...
                    internal.matlab.inspector.MultiplePropertyCombinationMode.getDefault;
            else
                this.MultiplePropertyCombinationMode = ...
                    internal.matlab.inspector.MultiplePropertyCombinationMode.getValidMultiPropComboMode(...
                    multiplePropertyCombinationMode);
            end
            
            % Setup MultipleValueCombinationMode
            if nargin < 4 || isempty(multipleValueCombinationMode)
                this.MultipleValueCombinationMode = ...
                    internal.matlab.inspector.MultipleValueCombinationMode.getDefault;
            else
                this.MultipleValueCombinationMode = ...
                    internal.matlab.inspector.MultipleValueCombinationMode.getValidMultiValueComboMode(...
                    multipleValueCombinationMode);
            end
            
            if nargin < 5 || isempty(ws)
                ws = 'caller';
            end
            
            % Get the mapped workspace
            workspace = this.getWorkspace(ws);
            
            % Create the DataModel
            if isa(objects, 'internal.matlab.inspector.EmptyObject')
                % Don't start the timer if we are inspecting the EmptyObject.
                % This is an internally created object that has no properties
                % that we need to monitor with the timer.
                useTimer = false;
            else
                useTimer = this.UseTimerForHandleObjects;
            end
                
            DataModel = internal.matlab.inspector.MLInspectorDataModel(...
                'inspector', workspace, useTimer);
            
            % If the object is not an InspectorProxyMixin, create one to
            % wrap it in
            if ~isa(objects, 'internal.matlab.inspector.InspectorProxyMixin')
                % Create a DefaultInspectorProxyMixin for the objects.  It
                % doesn't matter if there is a single object or multiple
                % objects
                defaultProxy = this.getProxyForObjects(objects);...
                if ~isa(objects, 'handle')
                    % Value objects need to provide a workspace and the
                    % name of the variable
                    defaultProxy.setWorkspace(workspace);
                    DataModel.Workspace = workspace;
                    DataModel.Name = name;
                end
                objectsToInspect = defaultProxy;
            elseif isscalar(objects)
                objectsToInspect = objects;
            else
                % For multiple objects which are already
                % InspectorProxyMixins, combine them into one
                objectsToInspect = ...
                    internal.matlab.inspector.InspectorProxyMixinArray(...
                    objects, this.MultiplePropertyCombinationMode, ...
                    this.MultipleValueCombinationMode);
            end
            
            if isa(objects, 'handle')
                if ~isprop(this, 'handleVariable')
                    addprop(this, 'handleVariable');
                end
                this.handleVariable = objectsToInspect;
                objectsToInspect.setWorkspace(this);
                DataModel.Workspace = this;
                DataModel.Name = 'handleVariable';
                
                this.DeletionListeners{end+1} = event.listener(...
                    objectsToInspect, 'ObjectBeingDestroyed', ...
                    @this.deletionCallback);
            end
            DataModel.Data = objectsToInspect;
            
            % Create the ViewModel and Adapter
            ViewModel = internal.matlab.inspector.InspectorViewModel(...
                DataModel);
            this.Adapter = internal.matlab.inspector.MLInspectorAdapter(...
                DataModel.Name, DataModel.Workspace, DataModel, ViewModel);
            
            % Remove any existing Inspectors.  By default, the inspector is
            % a singleton, although multiple instances can be created
            % through the factory, by using different application IDs.
            if ~isempty(this.Documents) && isvalid(this.Documents)
                try
                    delete(this.Documents(1));
                catch
                end
                this.Documents = [];
            end
            
            % Call the super openvar to open the inspector object
            varDocument = openvar(this, DataModel.Name, ...
                DataModel.Workspace, objectsToInspect);
            
            if nargout == 1
                varargout = {varDocument};
            end
        end
        
        function proxy = getProxyForObjects(this, objects)
%             if isa(objects, 'matlab.graphics.chart.primitive.Histogram')
%                 proxy = ...
%                     internal.matlab.inspector.views.HistogramGroupedView(...
%                     objects);
%             elseif ishghandle(objects, 'line')
%                 proxy = ...
%                     internal.matlab.inspector.views.LineGroupedView(...
%                     objects);
%             else
                proxy = ...
                    internal.matlab.inspector.DefaultInspectorProxyMixin(...
                    objects, this.MultiplePropertyCombinationMode, ...
                    this.MultipleValueCombinationMode);
%             end
        end
        
        % Override the getVariableAdapter method to always return the
        % Inspector Adapter (there's no choices, like in the super class)
        function veVar = getVariableAdapter(this, ~, ~, ~, ~, ~)
            veVar = this.Adapter;
        end
    end
        
    methods(Access = private)
        function removeDeletionListeners(this)
            if ~isempty(this.DeletionListeners)
                cellfun(@(x) delete(x), this.DeletionListeners);
            end
            this.DeletionListeners = {};
        end
        
        function deletionCallback(this, varargin)
            if ~isempty(this.Documents) && isvalid(this.Documents)
                % If the inspector is open, reopen it with an empty object
                try
                    delete(this.Documents(1));
                catch
                end
                this.Documents = [];

                o = internal.matlab.inspector.EmptyObject;
                this.inspect(o);
            end
        end
    end
end
