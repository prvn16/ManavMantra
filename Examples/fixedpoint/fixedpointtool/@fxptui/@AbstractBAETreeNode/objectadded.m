function objectadded(this, ~, event)
%OBJECTADDED <short description>
%   OUT = OBJECTADDED(ARGS) <long description>

%   Copyright 2010-2015 MathWorks, Inc.


bae = fxptui.BAExplorer.getBAExplorer;
if isprop(event,'Child')
   blk = event.Child;
else
   % find the child Chart object that is wrapped in the subsystem whos name just changed. 
   % the event.Source is the newly named Simulink.SubSystem object that wraps the Stateflow.Chart object. We need to find the Stateflow.Chart object
   % to re-populate the Tree view. Perform a find only with depth=1 since we don't want to grab other Stateflow.Chart objects that are deep within other 
   % contained Simulink.Subsystem objects.
   blk =  find(event.Source.getHierarchicalChildren,'-isa','Stateflow.Chart','-or','-isa','Stateflow.TruthTableChart','-or','-isa','Stateflow.LinkChart','-depth',1); %#ok
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
        l = handle.listener(blk, 'ObjectChildAdded', @(s,e)locsfobjectadded(s,e,this));
        if(isempty(this.sfobjectbeingaddedlisteners))
            this.sfobjectbeingaddedlisteners = l;
        else
            this.sfobjectbeingaddedlisteners(end+1) = l;
        end
        l = handle.listener(blk,'NameChangeEvent',@(s,e)locsfobjectadded(s,e,this));
        this.sfobjectbeingaddedlisteners(end+1) = l;
        return;
    end
end
for i = 1:length(children)
    child = fxptui.filter(children(i));
    if isempty(child) || this.TreeNode.isUnderMaskedSubsystem; continue; end
    if isa(child, 'Simulink.ModelReference')
        newnode = fxptui.BAEMdlBlkNode(child);
        if ~isempty(bae)
            if bae.getRoot.SubMdlToBlkMap.isKey(child.ModelName)
                newval = find(bae.getRoot, '-isa', 'fxptui.BAEMdlBlkNode', 'modelName', child.ModelName);  %#ok<GTARG>
                % Add the new node to the list.
                newval(end+1) = newnode;
            else
                newval = newnode;
            end
            bae.getRoot.SubMdlToBlkMap.insert(child.ModelName, newval);
        end
    else
        newnode = fxptui.BAETreeNode(child);
    end
    if ~isempty(this.Children)
        this.Children{end+1} = newnode;
    else
        this.Children = {newnode};
    end
    newnode.parent = this;
    connect(this,newnode,'down');
    
    %updatre tree
    ed = DAStudio.EventDispatcher;
    ed.broadcastEvent('ChildAddedEvent', this, newnode);
    
    if ~isempty(bae)
        dlg = bae.getDialog;
        if ~isempty(dlg)
            activeTab = dlg.getActiveTab('shortcut_editor_tabs');
            if activeTab == 1
                bae.loadShortcut(dlg);
            end
        end
    end
end
%--------------------------------------------------------------------------
function locsfobjectadded(s,e,this)
%remove the listeners in FIFO order and add the chart to the parent
delete(this.sfobjectbeingaddedlisteners(1:length(this.sfobjectbeingaddedlisteners)));
this.sfobjectbeingaddedlisteners = [];
this.objectadded(s,e);

%-------------------------------------------------------------------------

% [EOF]
