classdef MLInspectorDataModel < ...
        internal.matlab.variableeditor.MLHandleObjectDataModel
    
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % DataModel for the Property Inspector.  Overrides the
    % MLObjectDataModel so the setData can be short-circuited for handle
    % objects (and objects which implement the InspectorProxyMixin
    % interface).
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties(Hidden = true)
        ChangedProperties;
    end
    
    methods
        % Constructor - creates a new MLInspectorDataModel for a variable
        % with the specified name and workspace
        function this = MLInspectorDataModel(name, workspace, useTimer)
            if nargin<3
                useTimer = true;
            end
            this@internal.matlab.variableeditor.MLHandleObjectDataModel(...
                name, workspace, useTimer);
        end
        
        % Called to set the data on the object.  varargin is the Property
        % Name and Value.
        function varargout = setData(this, varargin)
            index = find(strcmp(properties(this.Data), varargin{1}));
            if isa(this.Data, 'handle')
                setPropertyValue(this.Data, ...
                    varargin{1}, ...  % Property Name
                    varargin{2});     % New value
                varargout = {};
                
                % Trigger DataChange event
                eventdata = ...
                    internal.matlab.variableeditor.DataChangeEventData;
                eventdata.Range = [index, 1];
                eventdata.Values = varargin{2};
                this.notify('DataChange', eventdata);
            else
                % set name and call super method
                varargout{1} = ...
                    setData@internal.matlab.variableeditor.MLObjectDataModel(...
                    this, varargin{2}, index, [], []);
            end
        end
        
        function data = updateData(this, varargin)
            s = warning('off', 'all');
            data = varargin{1};
            
            if ~isa(data, 'handle')
                d = this.PreviousData;
                if ~isempty(d)
                    % Compare as a struct, just as a way to compare the
                    % the old and new data
                    dataStruct = ...
                        internal.matlab.inspector.Utils.createStructForObject(...
                        data);
                    
                    if ~isequaln(d, dataStruct)
                        this.DataChanged = true;
                        
                        props1 = fieldnames(d);
                        props2 = fieldnames(dataStruct);
                        if isequal(sort(props1), sort(props2))
                            changedIdx = cellfun(@(x) ~isequaln(...
                                d.(x), dataStruct.(x)), props1);
                            changedProps = props1(changedIdx);
                            this.ChangedProperties = changedProps;
                            this.DataChanged = true;
                            for i = 1:length(changedProps)
                                propName = changedProps{i};
                                dispValue = ...
                                    internal.matlab.variableeditor.peer.PeerStructureViewModel.getDisplayEditValue(...
                                    data.(propName));
                                
                                this.Data.setPropertyValue(propName, ...
                                    data.(propName), ...
                                    dispValue, this.Name);
                            end
                        else
                            this.ChangedProperties = setdiff(...
                                sort(props2), sort(props1));
                        end
                    end
                    this.PreviousData = dataStruct;
                else
                    this.PreviousData = ...
                        internal.matlab.inspector.Utils.createStructForObject(...
                        data);
                end
            end
            warning(s);
        end
        
        function checkForUnobservableUpdates(this)
            % Checks to see if any properties have changed between the
            % original object and the proxy object (this can happen with
            % non-observable properties).  If any changes are detected,
            % then the proxy object's properties are re-initialized with
            % the current values from the original object
            if isa(this.Data, 'internal.matlab.inspector.InspectorProxyMixin')
                
                % See if there were any changes, and what properties
                % changed
                [changed, changedProps, changedProxyProps] = ...
                    OrigObjectChange(this.Data);
                if changed
                    % Reinitialize the properties from the original object
                    reinitializeFromOrigObject(this.Data, changedProps, ...
                        changedProxyProps);
                    this.DataChanged = true;
                    if ~isempty(changedProxyProps)
                        this.ChangedProperties = unique({changedProps{:} changedProxyProps{:}});
                    else
                        this.ChangedProperties = changedProps;
                    end
                end
            end
        end
        
        function handleUpdateTimer(this)
            if ~isobject(this.Data) || ~isvalid(this.Data)
                % Stop the timer if the object has been deleted
                this.stopTimer;
            else
                % Check to see if any SetObservable=false properties have
                % changed
                this.checkForUnobservableUpdates;
                
                if this.DataChanged
                    % If the data has changed, fire an event
                    if ~isempty(this.ChangedProperties)
                        props = properties(this.getData);
                        for idx=1:length(this.ChangedProperties)
                            % Typically only one property changes at a time,
                            % but it can be multiple if there are dependent
                            % properties.  But this is rare, so firing an event
                            % for each property should be ok.
                            propName = this.ChangedProperties{idx};
                            if ismember(propName, props)
                                value = this.getData.(propName);
                            
                                % Fire property changed event
                                this.firePropertyChangedEvent(propName, value);
                            elseif ~isprop(this.getData, propName)
                                % Fire property removed event if it isn't a
                                % property of data (it may be a hidden
                                % property, which we shouldn't report as
                                % being removed)
                                this.firePropertyRemovedEvent(propName, '');
                            end
                        end
                    end
                    % Reset the DataChanged and Changed Properties flags
                    this.DataChanged = false;
                    this.ChangedProperties = {};
                end
            end
        end
    end
    
    methods(Access = protected)
        function updateChangeListeners(this, obj)
            % Override the super method, because we know the inspector is
            % always dealing with a proxy object
            this.removeChangeListeners();
            
            % Add listeners for dynamic properties being added or
            % removed
            this.PropAddedListener = event.listener(obj, ...
                'PropertyAdded', @this.propAddedCallback);
            this.PropRemovedListener = event.listener(obj, ...
                'PropertyRemoved', @this.propRemovedCallback);
            
            % Add listeners for all dynamically added properties of the
            % mixin
            p = properties(obj);
            for i=1:length(p)
                this.PropChangedListener{i} = event.proplistener(obj, ...
                    findprop(obj, p{i}), 'PostSet', ...
                    @this.propChangedCallback);
            end
        end
    end
end

