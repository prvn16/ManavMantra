function scribeccp(varargin)
%SCRIBECCP  Tools for copying/cutting & pasting plot objects
%
%   SCRIBECCP(FIG, ACTION) performs the specified ACTION on the selected objects of figure FIG.
%   SCRIBECCP(ACTION) performs the specified ACTION on the selected objects of gcf.
%      ACTION can be one of the strings:
%          CUT - Cuts the selected objects into the clipboard
%          COPY - Copies the selected objects into the clipboard
%          PASTE - Pastes from the clipboard
%          CLEAR - Clears the clipboard
%          DELETE - Removes the object and does not copy to the clipboard.
%          CREATE - Pretends to paste, but just adds the serialized data to
%                   the undo stack.
%   
%   PLOTEDIT must be ON, for this functionality to be available
%   See also PLOTEDIT.

%   Copyright 1984-2015 The MathWorks, Inc.

narginchk(1,2);

% Get the figure and the action from the args
if (nargin == 1)
  fig = get(groot,'CurrentFigure');
  if isempty(fig)
       error(message('MATLAB:scribeccp:CurrentFigureEmpty'));
  end
  action = lower(varargin{1});
else
  fig = varargin{1};
  action = lower(varargin{2});
end

hPlotEdit = plotedit(fig,'getmode');


if strcmpi(hPlotEdit.Enable,'off')
    error(message('MATLAB:scribeccp:PLOTEDITisOff'));
end


if ~isactiveuimode(hPlotEdit,'Standard.PlotSelect') && ~strcmpi(action,'create')   
    activateuimode(hPlotEdit,'Standard.PlotSelect');   
end
hMode = hPlotEdit.ModeStateData.PlotSelectMode;

% Change the cursor to an hourglass
ptr = get(fig, 'pointer');
set(fig, 'pointer', 'watch');

% Perform the actual requested action
switch action
    case 'copy'
        selobjs = localGetCopyData(hMode);        
        ccpCopy(hMode, selobjs, 0, true);
        ccpCopyPostProcess(hMode,selobjs);
        hMode.ModeStateData.OperationData = [];
    case 'cut'
        selobjs = localGetcopyDataForCut(localGetCopyData(hMode));
        ccpCopy(hMode, selobjs, 0, true);
        selContainer = ancestor(selobjs(1),{'uipanel','uicontainer'});
        % To ensure that everything gets serialized, deselect everything
        % and then copy again:
        deselectall(fig);
        selobjs = ccpCopyPostProcess(hMode,selobjs);
        res = ccpCopy(hMode, selobjs, 1, false);
        localCreateCutUndo(hMode,'Cut',selobjs,res);
        % Set the selection back to the container, if the contaier does not
        % exist anymore the figure will be selected
        selectobject(selContainer,'replace');
    case 'delete'
        selobjs = localGetcopyDataForCut(localGetCopyData(hMode));
        selContainer = ancestor(selobjs(1),{'uipanel','uicontainer'});        
        % To ensure that everything gets serialized, deselect everything
        % and then copy again:
        deselectall(fig);
        selobjs = ccpCopyPostProcess(hMode,selobjs);
        res = ccpCopy(hMode, selobjs, 1, false);
        localCreateCutUndo(hMode,'Delete',selobjs,res);        
        % Set the selection back to the container, if the contaier does not
        % exist anymore the figure will be selected
        selectobject(selContainer,'replace');
    case 'paste'
        serialized = getappdata(0, 'ScribeCopyBuffer');
        res = ccpPaste(hMode,serialized,true);
        if ~isempty(res)
            res = localGetCopyData(hMode,res);
            serialized = ccpCopy(hMode,res, 0, false);
            res = ccpCopyPostProcess(hMode,res);
            localCreatePasteUndo(hMode,'Paste',res,serialized);
        end
    case 'create'
        selobjs = localGetCopyData(hMode);
        handles = handle(unique(findall(selobjs),'legacy'));
        serialized = ccpCopy(hMode, handles, 0, false);
        localCreatePasteUndo(hMode,'New Object',handles,serialized);
    case 'clear'
        ccpClearBuffer(fig);
end
% If nothing is selected, default to selecting the figure:
if isempty(hMode.ModeStateData.SelectedObjects)
    hMode.ModeStateData.SelectedObjects = matlab.graphics.primitive.world.SceneNode.empty;
    selectobject(fig);
end

% Reset the cursor back to its original state
set(fig, 'pointer', ptr);

%-------------------------------------------------------------------------%
function selobjs = localGetCopyData(hMode,selobjs)
% Preprocess the selected objects to play nice with undo/redo.

if nargin == 1
    selobjs = hMode.ModeStateData.SelectedObjects;
end
selobjs = ccpCopyPreProcess(hMode,selobjs);
% Remove stale handles
selobjs(~ishghandle(selobjs)) = [];

% Store the parents of the selected objects in the OperationData.  If the
% selected object contains an Axes property (like ColorBar and Legend),
% save this as its parent instead, since this will be used to properly
% place it when it is pasted back into the figure  Otherwise, save its true
% parent property value.
hParents = cell(length(selobjs), 1);
for i=1:length(selobjs)
    if isprop(selobjs(i), 'Axes') && ~isa(selobjs(i),'matlab.graphics.chart.Chart')
        hParents{i} = get(selobjs(i), 'Axes');
    else
        hParents{i} = get(selobjs(i), 'Parent');
    end
    
    % Tag the Legend's PlotChildren with proxy values so they can be found
    % if you try to undo the deletion of a Legend. g1299604
    if isa(selobjs(i), 'matlab.graphics.illustration.Legend')
        pc = selobjs(i).PlotChildren;
        if ~isempty(pc)
            plotedit({'getProxyValueFromHandle',pc});
        end
        
        pcs = selobjs(i).PlotChildrenSpecified; 
        if ~isempty(pcs)
            plotedit({'getProxyValueFromHandle',pcs});
        end
        
        pce = selobjs(i).PlotChildrenExcluded;
        if ~isempty(pce)
            plotedit({'getProxyValueFromHandle',pce});
        end
    end
    
    if isa(selobjs(i),'matlab.graphics.mixin.Legendable')
        ax = ancestor(selobjs(i),'matlab.graphics.axis.AbstractAxes','node');
        if ~isempty(ax) && isvalid(ax)
            axesHasLegend = ~isempty(ax.Legend) && isvalid(ax.Legend);
            if axesHasLegend
                leg = ax.Legend;
                pcs = leg.PlotChildrenSpecified; 
                if ~isempty(pcs)
                    val = plotedit({'getProxyValueFromHandle',pcs});
                    % Append proxy values to existing appdata so
                    % information is not lost on successive interactive
                    % deletes.  Use 'stable' unique to ensure specified
                    % order is not altered.
                    curPCSproxyvalues = getappdata(leg,'PlotChildrenSpecifiedProxyValues');
                    val = unique([curPCSproxyvalues; val],'stable');
                    setappdata(leg,'PlotChildrenSpecifiedProxyValues',val);
                end

                pce = leg.PlotChildrenExcluded;
                if ~isempty(pce)
                    val = plotedit({'getProxyValueFromHandle',pce});
                    % Append proxy values to existing appdata so
                    % information is not lost on successive interactive
                    % deletes.
                    curPCEproxyvalues = getappdata(leg,'PlotChildrenExcludedProxyValues');
                    val = unique([curPCEproxyvalues; val]);
                    setappdata(leg,'PlotChildrenExcludedProxyValues',val);
                end
            end
        end
    end
end

parentProxy = zeros(size(hParents));
for i = 1:length(hParents)
    parentP = hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles == hParents{i});
    if ~isempty(parentP)
        parentProxy(i) = parentP;
    else
        % If the parent is not registered, register it:
        hMode.ModeStateData.ChangedObjectHandles(end+1) = handle(hParents{i});
        hMode.ModeStateData.ChangedObjectProxy(end+1) = now + rand;
        setappdata(hParents{i},'ScribeProxyValue',hMode.ModeStateData.ChangedObjectProxy(end));
        parentProxy(i) = hMode.ModeStateData.ChangedObjectProxy(end);
    end
end
hMode.ModeStateData.OperationData.Parents = parentProxy;



%-------------------------------------------------------------------------%

function selobjs = localGetcopyDataForCut(selobjs)
% We dont cut/delete figures/root , if selobjs contains any - remove them

ind2empty = arrayfun(@(obj) ishghandle(obj,'figure') | ishghandle(obj,'root'),selobjs);

if any(ind2empty)
    selobjs(ind2empty > 0) = [];
    warning(message('MATLAB:scribeccp:CannotCutDelete'));
end


%-------------------------------------------------------------------------%
function localCreatePasteUndo(hMode,commandName,handles,serialized)
% Register the undo with the figure and the mode

handles = findall(handle(handles));
proxyList = zeros(size(handles));
% Store the handle proxies rather than the handles
for i = 1:length(handles)
    proxyVal = hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles == handle(handles(i)));
    if ~isempty(proxyVal)
        proxyList(i) = proxyVal;
    end
end
proxyList(proxyList == 0) = [];

% Create command structure
cmd.Name = commandName;
cmd.Function = @localUndoCut;
cmd.Varargin = {hMode,serialized,hMode.ModeStateData.OperationData.Parents};
cmd.InverseFunction = @localDoCut;
cmd.InverseVarargin = {hMode,proxyList};

% Register with undo/redo
uiundo(hMode.FigureHandle,'function',cmd);
% Clear the operation data:
hMode.ModeStateData.OperationData = [];

%-------------------------------------------------------------------------%
function localCreateCutUndo(hMode,action,handles,serialized)
% Register the undo with the figure and the mode. 

proxyList = zeros(size(handles));
% Store the handle proxies rather than the handles
for i = 1:length(handles)
    proxyVal = hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles == handle(handles(i)));
    if ~isempty(proxyVal)
        proxyList(i) = proxyVal;
    end
end
proxyList(proxyList == 0) = [];

% Create command structure
cmd.Name = action;
cmd.Function = @localDoCut;
cmd.Varargin = {hMode,proxyList};
cmd.InverseFunction = @localUndoCut;
% Parent information is in the Operation Data
cmd.InverseVarargin = {hMode,serialized,hMode.ModeStateData.OperationData.Parents};
    
% Register with undo/redo
uiundo(hMode.FigureHandle,'function',cmd);
% Clear the operation data:
hMode.ModeStateData.OperationData = [];

%-------------------------------------------------------------------------%
function localDoCut(hMode,proxyList)
% Given a list of proxies, delete the associated objects

handles = matlab.graphics.GraphicsPlaceholder;

for i = length(proxyList):-1:1
    handles(i) = hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == proxyList(i));
end

% Remove invalid handles
handles(~ishghandle(handles)) = [];

ccpCopy(hMode,handles,true,false);

%-------------------------------------------------------------------------%
function localUndoCut(hMode,serialized,parentProxy)
% Given a list of proxies and serialized data, restore the original
% objects.

% First, extract the parents:
hParents = matlab.graphics.GraphicsPlaceholder;
for i = length(parentProxy):-1:1
    hParents(i) = hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == parentProxy(i));
end

ccpPaste(hMode,serialized,false,hParents,false);

%-------------------------------------------------------------------------%
function serialized = ccpCopy(hMode, selobjs, bDelete, copyToClipBoard)
% Do the copy operation.

serialized = {};

for i=1:length(selobjs)
    obj = selobjs(i);
    if ~isvalid(obj)
        continue;
    end
    
    % Turn off editing before we serialize the object
    % This code can be removed once g871613 has been resolved
    isEditing = false;
    if isprop(obj, 'Editing') && strcmpi(obj.Editing,'on')
        isEditing = true;
        set(obj,'Editing','off');
    end
    
    serialized{end+1} = getCopyStructureFromObject(obj); %#ok<AGROW>

    % Capture axes relationships
    serialized{end} = copyAxesRelationships(serialized{end}, obj);
    
    % For Bar objects where there are multiple bar peers, serialize their 
    % relative position among their peers because this information is not
    % serialized with the Bar object. Note this code should be 
    % moved out of scribeccp into the Bar class
    % in a future release.
    if ishghandle(obj,'bar')
        barPeers = findall(obj.Parent,'-function',...
            @(x) ishghandle(x,'bar') &&  get(x,'BarPeerId')==obj.BarPeerID);
        if length(barPeers)>=2
            serialized{end}.BarChildPos = find(barPeers==obj);
        end
    elseif localIsAxesChild(obj)
        % serialize the child position so that the object will be
        % placed in its original position upon deserialization (undo)
        pos = find(obj.Parent.Children == obj);
        if ~isempty(pos)
            serialized{end}.ChildPos = pos;
            serialized{end}.ParentScribeProxyValue = getappdata(obj.Parent,'ScribeProxyValue');
        end
    end
    
    % Turn editing back on after serialization
    % This code can be removed once g871613 has been resolved
    if isEditing
        set(obj,'Editing','on');
    end
end

if bDelete
    % If all selected objects share the same parent, the parent will be
    % selected after the "cut" operation.
    hPar = get(selobjs,'Parent');
    toSelect = [];
    if ~iscell(hPar)
        hPar = {hPar;hPar};
    end
    if isequal(hPar{:})
        toSelect = hPar{1};
    end

    if ~isempty(toSelect) && isprop(toSelect,'Visible') && strcmpi(get(toSelect,'Visible'),'on')
        selectobject(toSelect,'replace');
    else
        deselectall(hMode.FigureHandle);
    end
    delete(selobjs);
    
end

if copyToClipBoard
    setappdata(0,'ScribeCopyBuffer', serialized);
    % Update the edit menus because the ScribeCopyBuffer has been updated g1155209
    plotedit({'update_edit_menu',hMode.FigureHandle,false});
end

%-------------------------------------------------------------------------%
function selobjs = ccpCopyPreProcess(hMode,selobjs)
% Before we do the copy, we want to make sure that we don't duplicate
% effort (i.e. creating extra axes children).

len = length(selobjs);
i = 1;
currIndex = 1;
parentedChildrenIndices = false(len,1);
while i<=len
    obj = selobjs(i);
    if isa(obj,'matlab.graphics.internal.Legacy')
        parent = get(obj, 'Parent');
        % The parent is also selected so there is no need to serialize this 
        % object. Mark it for exclusion
        if any(selobjs == parent)
            parentedChildrenIndices(i) = true;
        end

        if isprop(obj, 'Axes') && (ishghandle(obj, 'colorbar') || ...
                ishghandle(obj, 'legend')) && any(selobjs == obj.Axes)
            % If we have selected an object which has an Axes as a property
            % (like ColorBar or Legend), and the Axes is also selected,
            % then there's no need to include it, because it will be
            % included with the axes.  Mark it for exclusion.
            parentedChildrenIndices(i) = true;
        end
        
        % If we have selected an object and some of its children, remove
        % the unselected children for the purposes of the copy.
        if isprop(obj,'Children')
            chil = obj.Children;
            selChil = intersect(chil,selobjs,'legacy');
            if ~isempty(selChil)
                nonChil = setdiff(chil,selChil,'legacy');
                chilStruct.ParentProxy = plotedit({'getProxyValueFromHandle',obj});
                % We want to cache the child order
                chilStruct.Children = chil; 
                chilStruct.Unselected = nonChil;
                % Disconnect the children from the parent
                set(nonChil,'Parent',matlab.graphics.primitive.world.Group.empty);
                hMode.ModeStateData.OperationData.CachedChildren(currIndex) = chilStruct;
                currIndex = currIndex+1;
            end
        end
    end
    i=i+1;
end

% Exclude child objects which were excluded because they were serialized
% with their parents
selobjs(parentedChildrenIndices) = [];

%-------------------------------------------------------------------------%
function selobjs = ccpCopyPostProcess(hMode,selobjs)
% Restore any disconnected children, if we have any
if isfield(hMode.ModeStateData.OperationData,'CachedChildren')
    cachedChildren = hMode.ModeStateData.OperationData.CachedChildren;
    for i=1:numel(cachedChildren)
        chilStruct = cachedChildren(i);
        par = plotedit({'getHandleFromProxyValue',hMode.FigureHandle,chilStruct.ParentProxy});
        set(chilStruct.Unselected,'Parent',par);
        % Restore the child order.
        set(par,'Children',chilStruct.Children);
    end
end

%-------------------------------------------------------------------------%
function newObjs = ccpPaste(hMode,serialized,updateProxyList,hParents,doOffset)
fig = hMode.FigureHandle;
pm = graph2dhelper('getplotmanager','-peek');

if nargin < 4
    hParents = [];
end
if nargin < 5
    doOffset = true;
end

selAxes = matlab.graphics.primitive.world.Group.empty;
selParent = matlab.graphics.primitive.world.Group.empty;

if ~isempty(hMode.ModeStateData.SelectedObjects)
    selAxes = findobj(hMode.ModeStateData.SelectedObjects,'-function',@(obj)(isa(obj,'matlab.graphics.axis.AbstractAxes')),'-depth',0);
    selParent = findobj(hMode.ModeStateData.SelectedObjects,'-function',@(obj)(isa(obj,'matlab.ui.container.Panel')),'-depth',0);
end

if isempty(selAxes)
    selAxes = matlab.graphics.primitive.world.Group.empty;
end
if isempty(selParent)
    selParent = matlab.graphics.primitive.world.Group.empty;
end

% deselect all selected objects in the destination figure
deselectall(hMode.FigureHandle);

% Fire an event that a paste is about to happen for tools to prepare (e.g.
% Basic Fitting).
if isa(pm, 'matlab.graphics.internal.PlotManager') && isvalid(pm)
    evdata = matlab.scribe.internal.ScribeEvent;
    evdata.Figure = fig;
    notify(pm,'PlotEditBeforePaste',evdata);
end
newObjs = matlab.graphics.primitive.world.SceneNode.empty;
toSelect = [];
childOrderForParent = containers.Map('KeyType', 'double', 'ValueType', 'any');

for i=1:length(serialized)
    if isempty(serialized{i})
        return;
    end
    select = [];
    % Take special care when undoing a paste of a line or an axes into a
    % uicontainer.
    if ~isempty(hParents)
        if isgraphics(hParents(i),'axes') || isgraphics(hParents(i),'polaraxes')
            selAxes = hParents(i);
        end
        if isa(hParents(i),'matlab.ui.container.Container') && isgraphics(hParents(i))
            selParent = hParents(i);
        end
        if isgraphics(hParents(i),'annotationpane')
            selParent = hParents(i).Parent;
        end
    end
    
    if isempty(selAxes)
        selAxes = matlab.graphics.primitive.world.Group.empty;
    end
    
    if isempty(selParent)
        selParent = fig;
    end
    
    obj = localAddBarChildPosProp(serialized{i});
    
    if isempty(obj)
        continue;
    end
      
    % If we have a container type, we will use the selected parent as the
    % true parent. Otherwise, use the selected axes, if it exists. If no
    % axes exists, we will create a new axes for every selected parent.
    if localIsAxesChild(obj)
        currParent = selAxes;
        if isempty(selAxes)
            for j=numel(selParent):-1:1
                currParent(j) = axes('Parent',selParent(j),'Box','on');
            end
            selAxes = currParent;
            offsetObjectsToUniqueLocation(fig,currParent,selParent);
            % Capture that the selected axes is also newly created:
            newObjs = [newObjs currParent]; %#ok<AGROW>
            toSelect = [toSelect false(size(currParent))]; %#ok<AGROW>
        end
    else
        currParent = selParent;
    end
    
    if ismethod(obj,'getTargetParent')
        currParent = obj.getTargetParent(selParent);
    end
    
    % When we have multiple parents selected, we need to have multiple
    % objects created.
    for j=2:numel(currParent)
        obj(j) = localAddBarChildPosProp(serialized{i});
    end
    
    % If we are pasting a line into the axes from which it came, this
    % should be a no-op. Remove these lines before continuing further:
    if localIsAxesChild(obj(1))
        proxyVal = getappdata(obj(1),'ScribeProxyValue');        
        for j=1:numel(currParent)            
            duplicates = findobj(currParent,'-function',@(x)(localDoesProxyMatch(x,proxyVal)));
            if ~isempty(duplicates)
                delete(obj(j).UIContextMenu);
                delete(obj(j));
            end            
        end        
        inds = ~isvalid(obj);
        obj(inds) = [];
        currParent(inds) = [];
    end
    
    if isempty(obj)
        continue;
    end
      
    % If we are pasting and the object may be over a duplicate, make sure
    % to offset the object to a unique location.
    if doOffset && isprop(obj(1),'Position') && isprop(obj(1),'Units') && numel(obj(1).Position) == 4
        offsetObjectsToUniqueLocation(fig,obj,currParent);
    end
    
    for j=1:numel(obj)
        parent = currParent(j);
        
        if ishghandle(obj(j), 'colorbar')
            % Need to set the Axes proprty for ColorBar rather than setting the Parent property
            set(obj(j), 'Axes', selAxes);
        elseif ishghandle(obj(j), 'legend')
            % When you undo the deletion of a Legend, the PlotChildren
            % initially points to a phantom tree of objects that was
            % deserialized along with the Legend.
            % We need to reattach the correct plot children to the Legend
            % This needs to be done before setting the Axes property, as
            % once you set the Axes property on the Legend the phantom tree
            % (including the phantom PlotChildren) is destroyed. g1299604
            localReattachLegendPlotChildren(obj(j), 'PlotChildren', selAxes);
            localReattachLegendPlotChildren(obj(j), 'PlotChildrenSpecified', selAxes);
            localReattachLegendPlotChildren(obj(j), 'PlotChildrenExcluded', selAxes);
            
            % Need to set the Axes proprty for Legend rather than setting the Parent property
            set(obj(j), 'Axes', selAxes);
        else
            if isa(obj(j),'matlab.graphics.shape.internal.ScribeObject')
                parent = getScribeLayer(parent);
            end
            set(obj(j),'Parent',parent);
            if isfield(serialized{i},'ChildPos') && localDoesProxyMatch(parent,serialized{i}.ParentScribeProxyValue)
                if childOrderForParent.isKey(double(parent))
                    childOrderForParent(double(parent)) = [childOrderForParent(double(parent)), serialized{i}.ChildPos];
                else
                    childOrderForParent(double(parent)) = serialized{i}.ChildPos;
                end
            end
            
            if isprop(obj(j),'UIContextMenu')
                set(obj(j).UIContextMenu,'Parent',fig);
            end
            
            % After obj is re-Parented to the axes, if this is a Legendable 
            % object, update the PlotChildrenSpecified and PlotChildrenExcluded
            % if a Legend exists.  No need to update PlotChildren itself,
            % the AutoUpdate behavior (whether on or off) will do the right thing.
            if isa(obj(j),'matlab.graphics.mixin.Legendable')
                ax = ancestor(obj(j),'matlab.graphics.axis.AbstractAxes','node');
                if ~isempty(ax) && isvalid(ax)
                    leg = ax.Legend;
                    % don't update the PlotChildrenSpecified or
                    % PlotChildrenExcluded if AutoUpdate is 'off'.  If we update
                    % PlotChildrenSpecified when AutoUpdate is 'off', those objects
                    % will re-appear in the legend when AutoUpdate is turned on.
                    if ~isempty(leg) && isvalid(leg)
                        % update pcs / pce
                        pv = getappdata(obj,'ScribeProxyValue');
                        pcs_proxyvals = getappdata(leg,'PlotChildrenSpecifiedProxyValues');
                        found = ismember(pv,pcs_proxyvals);
                        if found
                            % insert obj into its pre-deleted relative location in
                            % PlotChildren
                            tmpPCS = [leg.PlotChildrenSpecified; obj];
                            tmpPCS_proxyvals = arrayfun(@(x) getappdata(x,'ScribeProxyValue'),tmpPCS);
                            pcs_proxyvals_reduced = pcs_proxyvals(ismember(pcs_proxyvals,tmpPCS_proxyvals));
                            [~,d] = ismember(pcs_proxyvals_reduced,tmpPCS_proxyvals);
                            leg.PlotChildrenSpecified = tmpPCS(d);
                        else
                            pce_proxyvals = getappdata(leg,'PlotChildrenExcludedProxyValues');
                            found = ismember(pv,pce_proxyvals);
                            if found
                                leg.PlotChildrenExcluded(end+1) = obj;
                            end
                        end
                    end
                end
            end
        end

        % Restore axes relationships
        serialized{i} = pasteAxesRelationships(serialized{i}, obj(j));
    end

    if ~isempty(select)
        newObjs = [newObjs obj]; %#ok<AGROW>
        toSelect = [toSelect select]; %#ok<AGROW>
    else
        newObjs = [newObjs obj]; %#ok<AGROW>
        toSelect = [toSelect true(size(obj))]; %#ok<AGROW>
    end
end

targetParents = childOrderForParent.keys;
% Reorder the axes children to reflect the original position of the pasted
% objects for each axes
for i = 1:numel(targetParents)
    childPos = childOrderForParent(targetParents{i});
    targetAxes = handle(targetParents{i});        
    if ~isempty(childPos)
        %all children
        hChildren = targetAxes.Children;
        pastedChildPosI = flip(childPos);
        % the newly pasted objects will be in the beginning of the children array
        hNewChildren = hChildren(1:numel(pastedChildPosI));
        % the old objects are the rest of the children
        hOldChildren  = hChildren(numel(pastedChildPosI)+1:end);
        if (max(pastedChildPosI) <= numel(hChildren))
            iOld = setdiff(1:numel(hChildren),pastedChildPosI);
            %set the old children
            hChildren(iOld) = hOldChildren;            
            %set the new children            
            hChildren(pastedChildPosI) = hNewChildren;
            targetAxes.Children = hChildren;
        end        
    end
end

% For each pasted area, update the NumPeers and colors for the area peers.
allPastedAreas = findall(newObjs, 'flat', 'Type', 'area');
for a = allPastedAreas
    % Find the peers for the new Area
    % Querying AreaPeers will have the side-effect of updating NumPeers.
    sibAreas = a.AreaPeers;

    % Set the CData on the Areas
    n = numel(sibAreas);
    for k = 1:n
        sibAreas(k).CData_I = k;
    end
end

% If the pasted object(s) comprise(s) one or more Bars then increment
% the NumPeers count of all bars with the same BarPeerID. This will
% cause the affected groups of bars to layout correctly to accommodate
% the pasted bar(s). Note this code should be moved out of scribeccp
% into the Bar class in a future release.
for currentAxes=1:length(selAxes)
    bars = findall(selAxes(currentAxes),'type','bar','-property','BarChildPos');
    if ~isempty(bars)
        allBars = findall(selAxes(currentAxes),'type','bar');
        barPeerIDs = unique(cell2mat(get(allBars,{'BarPeerID'})));
        for kk=1:length(barPeerIDs)
            % Find the siblings of the pasted Bar objects
            allsibBars = findall(allBars,'-function',@(x) get(x,'BarPeerID')==barPeerIDs(kk));
            pastedBars = findall(allsibBars,'-property','BarChildPos');
            pastedBarChildPos = cell2mat(get(pastedBars,{'BarChildPos'}));

            % Remove the temporary dynamic property
            for jj=1:length(pastedBars)
                delete(pastedBars(jj).findprop('BarChildPos'));
            end
            % Insert the pasted Bars at the deserialized child positions
            insertBars(selAxes(currentAxes), allsibBars, pastedBars, pastedBarChildPos);

        end
    end
end

if ~isempty(newObjs)
    if updateProxyList
        % Convert found items to a row-vector
        newHandles = unique(findall(newObjs),'legacy').';
        for j = 1:length(newHandles)
            if isappdata(newHandles(j),'ScribeProxyValue')
                rmappdata(newHandles(j),'ScribeProxyValue');
            end
        end
        hMode.ModeStateData.ChangedObjectHandles = [hMode.ModeStateData.ChangedObjectHandles newHandles];
        proxyVals = now+(1:length(newHandles));
        hMode.ModeStateData.ChangedObjectProxy = [hMode.ModeStateData.ChangedObjectProxy proxyVals];
        for j = 1:length(newHandles)
            setappdata(newHandles(j),'ScribeProxyValue',proxyVals(j));
        end
    else
        % Update the proxies appropriately:
        newHandles = unique(findall(newObjs),'legacy').';
        for j = 1:length(newHandles)
            if isappdata(newHandles(j),'ScribeProxyValue')
                proxyVal = getappdata(newHandles(j),'ScribeProxyValue');
                hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == proxyVal) = newHandles(j);
            end
        end
    end
end

selectobject(newObjs(logical(toSelect)),'replace');

% Fire event for plottools to update
if isa(pm, 'matlab.graphics.internal.PlotManager') && isvalid(pm)
    evdata = matlab.scribe.internal.ScribeEvent;
    set(evdata,'ObjectsCreated',newObjs,'Figure',pm);
    notify(pm,'PlotEditPaste',evdata);
end

%-------------------------------------------------------------------------%
function res = localDoesProxyMatch(obj,val)

res = false;
% Prevent calling isappdata or getappdata on primitive objects as a
% work-around for g657435
if ~isprop(obj,'Internal') || obj.Internal
    return
end
if ~isappdata(obj,'ScribeProxyValue')
    return;
end
proxyVal = getappdata(obj,'ScribeProxyValue');
res = proxyVal == val;

%-------------------------------------------------------------------------%
function offsetObjectsToUniqueLocation(fig,obj,currParent)

pasteOffset = [10 -10 0 0];
for j=1:numel(obj)
    objPos = hgconvertunits(fig,obj(j).Position,obj(j).Units,'pixels',currParent(j));
    
    % Since handle visibility of the children may be "off", use the findall
    % function to make sure we find all the children.
    peers = findall(currParent(j),'-class',class(obj(j)));
    if ~isempty(peers)
        peerPos = get(peers,'Position');
        if ~iscell(peerPos)
            peerPos = {peerPos};
        end
        for k=1:numel(peers)
            peerPos{k} = hgconvertunits(fig,peerPos{k},get(peers(k),'Units'),'pixels',currParent(j));
        end
        while any(cellfun(@(x)(all(abs(x-objPos)<1)),peerPos))
            objPos = objPos + pasteOffset;
        end
        obj.Position = hgconvertunits(fig,objPos,'pixels',obj(j).Units,currParent(j));
    end
end

%-------------------------------------------------------------------------%
function res = localIsAxesChild(obj)

res = isa(obj,'matlab.graphics.primitive.Data') ||...
      isa(obj, 'matlab.graphics.primitive.Group');

%-------------------------------------------------------------------------%
function ccpClearBuffer(fig)
if isappdata(0, 'ScribeCopyBuffer')
    rmappdata(0, 'ScribeCopyBuffer');
end
% Since what we can and cannot do has changed, updated the edit menu.
plotedit({'update_edit_menu',fig,false});

%-------------------------------------------------------------------------%
function parentOut = getScribeLayer(parent)
parentOut = parent;
if ~isempty(parent) 
	if isa(parent,'matlab.ui.container.CanvasContainer')
    	parentOut = findAnnotationPane(parent);
    	if isempty(parentOut)
        	parentOut = parent;
    	end
	end
end

%-------------------------------------------------------------------------%
function localReattachLegendPlotChildren(hLeg, pcProp, hAxes)

% For each plot child, determine if its parent Axes is the specified Axes.
% If not, look for an object in the specified Axes with the same proxy
% value and use that object as a plot child instead.
pc = hLeg.(pcProp);
for c = 1:numel(pc)
    oldChild = pc(c);
    oldParent = ancestor(oldChild,'axes');
    proxyVal = getappdata(oldChild,'ScribeProxyValue');
    
    if ~isequal(oldParent, hAxes) && ~isempty(proxyVal)
        newChild = findobj(hAxes,'-function',@(x)(localDoesProxyMatch(x,proxyVal)));
        if isscalar(newChild) && isvalid(newChild)
            pc(c) = newChild;
        end
    end
end
hLeg.(pcProp) = pc;

%-------------------------------------------------------------------------%
function obj = localAddBarChildPosProp (serializedObj)
% If the pasted object is a Bar with peers where the child position 
% was serialized in the BarChildPos field, temporarily store the
% child position in a BarChildPos dynamic property which will be
% removed when the paste is completed. Note this code should be 
% moved out of scribeccp into the Bar class
% in a future release.   
obj = getObjectFromCopyStructure(serializedObj);

if isempty(obj)
    return;
end

if ishghandle(obj,'bar') && isfield(serializedObj,'BarChildPos')
    if ~isprop(obj,'BarChildPos')
        addprop(obj,'BarChildPos');
    end
    obj.BarChildPos = serializedObj.BarChildPos;
end


