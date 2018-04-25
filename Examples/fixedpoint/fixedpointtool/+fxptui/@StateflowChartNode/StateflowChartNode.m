classdef StateflowChartNode < fxptui.SubsystemNode
% STATEFLOWCHARTNODE Class definition for the tree node representing a stateflow chart

% Copyright 2013-2017 The MathWorks, Inc.

    
    methods
        function this = StateflowChartNode(blkObj)
            if nargin  == 0
                argList = {};
            else
                argList = {blkObj};
            end
            this@fxptui.SubsystemNode(argList{:});
        end
        
        function icon = getDisplayIcon(this)
            if ~isa(this.DAObject,'DAStudio.Object')
                icon = '';
                return;
            end
            chartObj = fxptds.getSFChartObject(this.DAObject);
            if ~isempty(chartObj)
                icon = chartObj.getDisplayIcon;
            else
                icon = this.DAObject.getDisplayIcon;
            end
        end
    end
    
    methods(Hidden)
        setLogging(this, state, scope, depth);
        function b = hasLoggableSignals(this)
            b = numel(this.DAObject.AvailSigsInstanceProps.Signals) > 0;
        end
        
        function b = hasSubsystemInHierarchy(this)
            % Return true if the chart contains a subsystem in its
            % hierarchy
           b = numel(find(this.DAObject,'-isa','Simulink.SubSystem')) > 1;
        end
    end
    
    methods(Access=private)
        recreateHierarchy(this, event);
    end
    
    methods(Access=protected)
        function initialize(this, slObj)
            this.DAObject = slObj.up;
            this.Name = this.DAObject.Path;
            handler = fxptds.SimulinkDataArrayHandler;
            this.Identifier = handler.getUniqueIdentifier(struct('Object',slObj));
            this.CachedFullName = fxptui.getPath(this.DAObject.getFullName);
        end
        
        function addListeners(this)
            this.SLListeners = handle.listener(this.DAObject, 'NameChangeEvent', @(s,e)fireHierarchyChanged(this));
            this.SLListeners(2) = handle.listener(this.DAObject, findprop(this.DAObject, 'MinMaxOverflowLogging'),...
                'PropertyPostSet', @(s,e)firePropertyChanged(this));
            this.SLListeners(3) = handle.listener(this.DAObject, findprop(this.DAObject, 'DataTypeOverride'),...
                'PropertyPostSet', @(s,e)firePropertyChanged(this));
            ed = DAStudio.EventDispatcher;
            %listen to EventDispatcher HierarchyChangedEvent for Stateflow add/remove
            this.SLListeners(4) = handle.listener(ed, 'HierarchyChangedEvent', @(s,e)recreateHierarchy(this, e));
        end
        
        function key = getKeyAsDoubleType(this)
        % returns the handle to the Simulink object as a double to be used as a key on the maps.
            key = this.DAObject.Handle;
        end
        
        function children = getFilteredHierarchicalChildren(this)
            chart = fxptds.getSFChartObject(this.DAObject);
            children = chart.getHierarchicalChildren;
            children = fxptui.filter(children);
        end
        
        function createActionHandler(this)
            this.ActionHandler = fxptui.StateflowChartNodeActions(this);
        end
    end
end
