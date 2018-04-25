function objectAdded(this,event)
% OBJECTADDED adds the child information to the node

% Copyright 2013 MathWorks, Inc.

    me = fxptui.getexplorer;
    if isempty(me); return; end;
    if(~strcmp('done', me.status)); return; end
    
    if ~strcmpi(get_param(me.getTopNode.getDAObject.getFullName,'SimulationStatus'),'stopped')
        return;
    end
    
    if isprop(event,'Child')
        blk = event.Child;
    else
        % find the child Chart object that is wrapped in the subsystem whos
        % name just changed.  the event.Source is the newly named
        % Simulink.SubSystem object that wraps the Stateflow.Chart
        % object. We need to find the Stateflow.Chart object to re-populate
        % the Tree view. Perform a find only with depth=1 since we don't
        % want to grab other Stateflow.Chart objects that are deep within
        % other contained Simulink.Subsystem objects.
        blk =  find(event.Source.getHierarchicalChildren,'-isa','Stateflow.Chart',...  
                    '-or','-isa','Stateflow.TruthTableChart',...
                    '-or','-isa','Stateflow.StateTransitionTableChart',...
                    '-or','-isa','Stateflow.ReactiveTestingTableChart',...
                    '-or','-isa','Stateflow.LinkChart',...      
                    '-or','-isa','Stateflow.EMChart',...
                    '-depth',1);%#ok
    end
    blk = fxptui.filter(blk);
    if(isempty(blk)); return; end
    children = blk;
    
    %Stateflow charts are wrapped by masked subsystems. We want to wrap the
    %chart, not the subsystem, so listen temporarily for the chart being
    %added to the subsystem. If several charts are being added (paste
    %operation) we need to listen to all of them (listener vector) Simulink
    %adds all the subsystems and then adds all the charts to the subsystems
    %in the same order. In the case of making the chart a subsystem, we need to listen to namechange events to
    % add the chart correctly in the tree hierarchy.
    if blk.isa('Simulink.Block') && slprivate('is_stateflow_based_block', blk.Handle)
        children = find(blk.getHierarchicalChildren,'-isa','Stateflow.Chart',...
                        '-or','-isa','Stateflow.TruthTableChart',...
                        '-or','-isa','Stateflow.StateTransitionTableChart',...
                        '-or','-isa','Stateflow.ReactiveTestingTableChart',...
                        '-or','-isa','Stateflow.LinkChart',...
                        '-or','-isa','Stateflow.EMChart',...
                        '-depth',1);%#ok
        if isempty(children)
            l = handle.listener(blk, 'ObjectChildAdded', @(s,e)locSFObjectAdded(this,s,e));
            if(isempty(this.SFObjectBeingAddedListeners))
                this.SFObjectBeingAddedListeners = l;
            else
                this.SFObjectBeingAddedListeners(end+1) = l;
            end
            l = handle.listener(blk,'NameChangeEvent',@(s,e)locSFObjectAdded(this,s,e));
            this.SFObjectBeingAddedListeners(end+1) = l;
            return;
        end
    end
    for i = 1:length(children)
        child = fxptui.filter(children(i));
        if isempty(child) || this.isUnderMaskedSubsystem; continue; end
        newnode = this.addChild(child);
        newnode.populate;
        %update tree
        this.fireHierarchyChanged;
    end
end

%--------------------------------------------------------------------------
function locSFObjectAdded(this,~,e)
%remove the listeners in FIFO order and add the chart to the parent
    delete(this.SFObjectBeingAddedListeners(1:length(this.SFObjectBeingAddedListeners)));
    this.SFObjectBeingAddedListeners = [];
    this.objectAdded(e);
end

%-------------------------------------------------------------------------
