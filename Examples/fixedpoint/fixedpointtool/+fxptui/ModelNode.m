classdef ModelNode < fxptui.SubsystemNode
    % MODELNODE Class definition for the block diagram node in FPT
    
    %   Copyright 2007-2015 The MathWorks, Inc.
    properties(SetAccess=private, GetAccess=private)
        IsClosing;
        WasSignalLoggingEnabled = false
        DeleteListener
    end
    
    methods
        function this = ModelNode(blkObj)
            if nargin  == 0
                argList = {};
            else
                blkObj.getChildren; % force creation of UDD children
                argList = {blkObj};
            end
            this@fxptui.SubsystemNode(argList{:});
            this.IsClosing = false;
            if nargin > 0
                this.populate;
            end
        end
        
        function b = isClosing(this)
            b = this.IsClosing;
        end
        
        
        
        function enableSignalLog(this)
            %ENABLESIGLLOG attempts to turn on signal logging for the models returns
            %true if logging was set false otherwise
            
            if(~isequal(this.DAObject.SimulationStatus, 'stopped')); return; end
            sys = fxptui.getPath(this.DAObject.getFullName);
            try
                config = getActiveConfigSet(bdroot(sys));
                if isa(config,'Simulink.ConfigSetRef') && strcmp(config.SourceResolved, 'on') ...
                        && strcmp(get_param(bdroot(sys), 'SignalLogging'), 'on')
                    return;
                else
                    set_param(sys, 'SignalLogging', 'On');
                    this.WasSignalLoggingEnabled = true;
                    % Turn off diagnostic that will error out if outports cannot be logged. For
                    % example, outports of virtual blocks. Since the tool does not compile the
                    % model before turning on signal logging, there is no easy way of knowing
                    % the outports that cannot be logged.
                    set_param(sys, 'LoggingUnavailableSignals', 'none');
                end
            catch fpt_exception
                fxptui.showdialog('genericerror',fpt_exception);
            end
        end
    end
    
    methods(Hidden)
        
    end
    
    methods(Access=protected)
        function createActionHandler(this)
            this.ActionHandler = fxptui.ModelNodeActions(this);
        end
        
        function addListeners(this)
            % Force a search that loads all libraries that the model has references to
            % before attaching listeners. This prevents firing of PropertyChangedEvent
            % listeners when libraries are loaded into memory. Turn off warnings before
            % calling find_system. This will prevent warnings pertaining to libraries
            % not being able to load - G518520. The tree hierarchy displayes children
            % under library linked blocks that are not masked, so follow library links
            % in find_system to load all libraries that are referenced under library
            % linked blocks.
            warn_state = warning('off','all');
            find_system(this.DAObject.getFullName,'FollowLinks','On','LookUnderMasks','all','BlockType','dummy');
            warning(warn_state);
            this.SLListeners = handle.listener(this.DAObject, findprop(this.DAObject, 'MinMaxOverflowLogging'),...
                'PropertyPostSet', @(s,e)firePropertyChanged(this));
            this.SLListeners(2) = handle.listener(this.DAObject, findprop(this.DAObject, 'DataTypeOverride'),...
                'PropertyPostSet', @(s,e)firePropertyChanged(this));
            this.SLListeners(3) = handle.listener(this.DAObject, 'ObjectChildAdded', @(s,e)objectAdded(this,e));
            this.SLListeners(4) = handle.listener(this.DAObject, 'ObjectChildRemoved', @(s,e)objectRemoved(this,e));
            this.SLListeners(5) = handle.listener(this.DAObject, 'CloseEvent', @(s,e)locShutdown(this));
            this.SLListeners(6) = handle.listener(this.DAObject, 'PostSaveEvent', @(s,e)locRefresh(this));
            this.DeleteListener = event.listener(this, 'ObjectBeingDestroyed', @(s,e)destroy(this));
        end
    end
    
    methods(Access=private)
        function locRefresh(this)
            % refresh the properties on save
            this.fireHierarchyChanged;
            this.firePropertyChanged;
        end
        
        function destroy(this)
            %Cleanup the object on deletion.
            
            % Flag to indicate that the model is closing.
            delete(this.SLListeners);
            this.SLListeners = [];
        end
        
        function locShutdown(this)
        % Deleting FPT if it exists will delete the "this" object when
        % the root is unpopulated. Get the application data before
        % deleting FPT.
            modelName = this.DAObject.getFullName;
            me = fxptui.getexplorer;
            if ~isempty(me) 
                if isequal(me.getTopNode, this)
                    delete(me);
                else
                    % Identify if the current node is the top model in the
                    % hierarchy 
                    if ~isequal(this, me.getTopNode)
                        % If the deleted system was set as a SUD, then disable workflow
                        % actions
                        if isequal(this, me.ConversionNode)
                            me.invalidateSUDSelection;
                        end

                        allChildren = me.getFPTRoot.getModelNodes;
                        for idx = 1:length(allChildren)
                            if isequal(allChildren(idx), this)
                                me.getFPTRoot.removeChild(allChildren(idx));
                                break;
                            end
                        end
                        return;
                    end
                end
            end
            % Clear the collected data for the model            
            appData = SimulinkFixedPoint.getApplicationData(modelName);
            ds = appData.dataset;
            ds.clearResultsInRuns;
            if appData.subDatasetMap.Count > 0
                subDatasets = appData.subDatasetMap.values;
                for in_idx = 1:length(subDatasets)
                    subDs =  subDatasets{in_idx};
                    subDs.clearResultsInRuns;
                end
            end
        end
    end
end
