classdef MLHandleObjectDataModel < ...
        internal.matlab.variableeditor.MLObjectDataModel
    % MLHandleObjectDataModel - Data Model for handle objects for the
    % variable editor
    
    % Copyright 2014 The MathWorks, Inc.
    
    properties(Access = private)
        UpdateTimer = [];
        
        ListenersChecked = false;
    end
    
    properties(Access = protected)
        DataChanged = false;
        
        % Keep track of listeners added to check for properties being
        % added, removed or changed
        PropAddedListener = [];
        PropRemovedListener = [];
        PropChangedListener = [];
        
        PreviousData = [];
    end
    
    events
        PropertyChanged;
        PropertyAdded;
        PropertyRemoved;
    end
    
    methods(Access = public)
        function this = MLHandleObjectDataModel(name, workspace, useTimer)
            if nargin<3
                useTimer = true;
            end
            this@internal.matlab.variableeditor.MLObjectDataModel(...
                name, workspace);

            if useTimer
                this.startTimer;
            end
        end
        
        function startTimer(this)
            timername = ['veHandleObj_' this.Name];
                        
            % Startup a timer to check for changes to the variable
            this.UpdateTimer = timer(...
                'TimerFcn', @(~,~)handleUpdateTimer(this), ...
                'ErrorFcn', @(~,~)handleTimerError(this), ...
                'StartDelay', 2, ...
                'Period', 1, ...
                'Name', timername, ...
                'ObjectVisibility', 'off', ...
                'ExecutionMode', 'fixedRate');
            start(this.UpdateTimer)
        end
        
        function stopTimer(this)
            try
                % Try to stop the timer, but its possible its being deleted
                % at the time.  So if there's an exception, it can be
                % ignored.
                stop(this.UpdateTimer);
            catch
            end
        end
        
        function restartTimer(this)
            this.stopTimer;
            this.startTimer;
        end
        
        function pauseTimer(this)
            try
                if ~isempty(this.UpdateTimer)
                    stop(this.UpdateTimer);
                end
            catch
            end
        end
        
        function unpauseTimer(this)
            try
                if ~isempty(this.UpdateTimer)
                    start(this.UpdateTimer);
                end
            catch
            end
        end

        function handleUpdateTimer(this)
            try
                if ~this.ListenersChecked
                    this.updateChangeListeners(this.getData);
                end
                
                if ~isobject(this.Data) || ~isvalid(this.Data)
                    this.stopTimer;
                else
                    this.checkUnobservableUpdates(this.Data);
                end
                
                if this.DataChanged
                    
                    % If the data has changed, fire an event
                    eventdata = internal.matlab.variableeditor.DataChangeEventData;
                    eventdata.Range = [];
                    eventdata.Values = [];
                    this.notify('DataChange', eventdata);
                    this.DataChanged = false;
                end
            catch
                this.stopTimer;
            end
        end
        
        function handleTimerError(this)
            if ~isobject(this.Data) || ~isvalid(this.Data)
                this.stopTimer;
            end
        end

        % updateData
        function data = updateData(this, varargin)
            newData = varargin{1};
            this.updateChangeListeners(newData);
            this.checkUnobservableUpdates(newData);
            data = newData;
        end
        
        function checkUnobservableUpdates(this, newData)
            s = warning('off', 'all');
            if isa(newData,'handle') && isvalid(newData)
                d = this.PreviousData;
                if ~isempty(d)
                    % Compare as a struct, just as a way to compare the
                    % states of a handle between old data and new data
                    if ~isequal(d, struct(newData))
                        this.DataChanged = true;
                    end
                end
                this.PreviousData = struct(newData);
            end
            warning(s);
        end
        
        function delete(this)
            % Remove listeners if the object is destroyed
            this.removeChangeListeners();
            
            % Also stop the timer
            if ~isempty(this.UpdateTimer) && isvalid(this.UpdateTimer)
                % Also stop the timer
                this.stopTimer;
                delete(this.UpdateTimer);
            end
        end
        
        function evalStr = executeSetCommand(this, setCommand, errorMsg)
            % Call the super class to execute the command, and set the
            % DataChanged flag in the case of a private workspace
            evalStr = this.executeSetCommand@internal.matlab.variableeditor.MLObjectDataModel(...
                setCommand, errorMsg);
            if ~ischar(this.Workspace)
                this.DataChanged = true;
            end
        end
    end
    
    methods(Access = protected)
        function removeChangeListeners(this)
            % Remove any Property Added listeners which have been added
            if ~isempty(this.PropAddedListener)
                delete(this.PropAddedListener);
                this.PropAddedListener = [];
            end
            
            % Remove any Property Removed listeners which have been added
            if ~isempty(this.PropRemovedListener)
                delete(this.PropRemovedListener);
                this.PropRemovedListener = [];
            end
            
            % Remove any Property Changed listeners which have been added
            if ~isempty(this.PropChangedListener)
                if iscell(this.PropChangedListener)
                    cellfun(@(x) delete(x), this.PropChangedListener)
                else
                    delete(this.PropChangedListener);
                end
                this.PropChangedListener = [];
            end
            
            this.ListenersChecked = false;
        end
        
        function updateChangeListeners(this, obj)
            this.removeChangeListeners();
            
            if isa(obj, 'dynamicprops')
                % Add listeners for dynamic properties being added or
                % removed
                this.PropAddedListener = event.listener(obj, ...
                    'PropertyAdded', @this.propAddedCallback);
                this.PropRemovedListener = event.listener(obj, ...
                    'PropertyRemoved', @this.propRemovedCallback);
            end
            
            m = metaclass(obj);
            p = m.PropertyList;
            observables = findobj(p, 'SetObservable', true);
            if ~isempty(observables)
                % Add listeners for observable Property changes
                this.PropChangedListener = event.proplistener(obj, ...
                    observables, 'PostSet', @this.propChangedCallback);
            end
            this.ListenersChecked = true;
        end

        function propAddedCallback(this, es, ed)
            % Redisplay the object by setting DataChanged = true
            this.DataChanged = true;
            
            this.firePropertyAddedEvent('', '');
        end
        
        function propRemovedCallback(this, es, ed)
            % Redisplay the object by setting DataChanged = true
            this.DataChanged = true;
            
            this.firePropertyRemovedEvent('', '');
        end

        function propChangedCallback(this, es, ed)
            % Redisplay the object by setting DataChanged = true
            this.DataChanged = true;
            
            if isa(ed.AffectedObject, ...
                    'internal.matlab.inspector.InspectorProxyMixin')
                this.firePropertyChangedEvent(es.Name, ...
                    get(ed.AffectedObject, es.Name));
            end
        end
        
        function firePropertyChangedEvent(this, properties, values)
            this.firePropertyEvent('PropertyChanged', properties, values);
        end
        
        function firePropertyRemovedEvent(this, properties, values)
            this.firePropertyEvent('PropertyRemoved', properties, values);
        end
        
        function firePropertyAddedEvent(this, properties, values)
            this.firePropertyEvent('PropertyAdded', properties, values);
        end
        
        function firePropertyEvent(this, eventName, properties, values)
            % Fire a property changed event
            e = internal.matlab.variableeditor.PropertyChangeEventData;
            
            % Property name comes from the event source, which is the
            % metaclass data for the property. Property value can be
            % retrieved by getting the property from the affected source in
            % the event data
            e.Properties = properties;
            e.Values = values;
            this.notify(eventName, e);
        end
    end
end

