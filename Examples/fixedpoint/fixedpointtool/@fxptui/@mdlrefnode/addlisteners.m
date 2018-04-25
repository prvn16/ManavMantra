function addlisteners(h)
%ADDLISTENERS  adds listeners to this object

%   Copyright 2006-2012 The MathWorks, Inc.

try
    load_system(h.daobject.ModelName);
    h.prevModelName = h.daobject.ModelName;
    % Add listener to react to changes in name of the Model block.
    if numel(h.listeners) == 0
        h.listeners = handle.listener(h.daobject, 'NameChangeEvent', @(s,e)locfirepropertychange(h,e));
    else
        h.listeners(end+1) = handle.listener(h.daobject, 'NameChangeEvent', @(s,e)locfirepropertychange(h,e));
    end
    h.listeners(end+1) = handle.listener(h.daobject, findprop(h.daobject, 'DefaultDataLogging'), 'PropertyPostSet', @(s,e)locloggingchange(e,h));
    % Add a listener to react to changes in the ModelName parameter. By default, when a model is loaded for the first time, Simulink triggers Hierarchy changed events and the UI gets
    % updated correctly. But if you change the ModelName to a model that is already in memory, simulink will not fire any events. The client is responsible for
    % triggering the correct events.
    ed = DAStudio.EventDispatcher;
    h.listeners(end+1) = handle.listener(ed,'PropertyChangedEvent', @(s,e)locpropertychange(h,s,e));
    % We don't need listeners for now on the referenced model because we don't show it in the Tree Hierarchy.
    %h.mdlref = get_param(h.daobject.ModelName, 'Object');
    %h.listeners(4) = handle.listener(h.mdlref, 'ObjectChildAdded', @(s,e)objectadded(h,s,e));
    %h.listeners(5) = handle.listener(h.mdlref, 'ObjectChildRemoved', @(s,e)objectremoved(h,s,e));
catch e % We do not want to throw this exception here.
    return;
end

%--------------------------------------------------------------------------
function locloggingchange(e,h)
if(~strcmpi(e.NewValue, h.daobject.DefaultDataLogging))
  h.setlogging(e.NewValue);
end

%--------------------------------------------------------------------------
function locpropertychange(h,~,e)

if eq(e.Source,h.daobject)
    if ~isequal(e.Source.ModelName, h.prevModelName)
        me = fxptui.getexplorer;
        try
            load_system(e.Source.ModelName)
            mdlObj = get_param(e.Source.ModelName,'Object');
            mdlNode = find(me.getRoot,'daobject',mdlObj, '-isa','fxptui.blkdgmnode'); %#ok<*GTARG>
            if isempty(mdlNode)
                addNodeToTree(me, mdlObj);
            end
        catch exception %#ok<*NASGU>
            % Model is probably not on path - ignore and continue.   
        end
        % Unpopulate the old model if it is not referenced anywhere
        try
            [refMdls, ~] = find_mdlrefs(me.getTopNode.daobject.getFullName);
            if isempty(intersect(refMdls,h.prevModelName))
                removeModelNodes(me, h.prevModelName);
            end
        catch exception            
            % One of the referenced models is not on path.
            mdlBlks = find(me.getRoot,'-isa','fxptui.mdlrefnode','prevModelName',h.prevModelName);
            if numel(mdlBlks == 1)
                removeModelNodes(me, h.prevModelName);
            end
        end
        h.prevModelName = e.Source.ModelName;
        me.getRoot.firehierarchychanged;
    end
    h.firepropertychange;
end

%--------------------------------------------------------------------------
function locfirepropertychange(h,e)
% Update the cachedFullName and trigger a property changed event
h.CachedFullName = fxptui.getPath(e.Source.getFullName);
h.firepropertychange;

%-------------------------------------------------------------------------
function modelNames = getModelNames(me, child)
modelNames = {};
if isa(child.daobject,'Simulink.ModelReference')
    modelNames = {child.daobject.ModelName};
    mdlObj = get_param(modelNames{1},'Object');
    child = find(me.getRoot,'daobject',mdlObj, '-isa','fxptui.blkdgmnode');
end
ch = child.getHierarchicalChildren;
for i = 1:length(ch)
    modelNames = [modelNames, getModelNames(me, ch(i))]; %#ok<AGROW>
end

%--------------------------------------------------------------------
function removeModelNodes(me, mdlName)

isLoaded =  ~isempty(find_system(0, 'type', 'block_diagram', 'Name', mdlName));
if ~isLoaded; return; end
bd = get_param(mdlName,'Object');
mdlNode = find(me.getRoot,'daobject',bd, '-isa','fxptui.blkdgmnode'); %#ok<*GTARG>
children = mdlNode.getHierarchicalChildren;
modelNames = {};
for i = 1:length(children)
    modelNames = [modelNames, getModelNames(me, children(i))]; %#ok<AGROW>
end
if ~isempty(mdlNode)
    removeChild(me.getRoot, mdlNode);
end
for i = 1:length(modelNames)
    mdlObj = get_param(modelNames{i},'Object');
    mdlNode = find(me.getRoot,'daobject',mdlObj, '-isa','fxptui.blkdgmnode');
    if ~isempty(mdlNode)
        removeChild(me.getRoot, mdlNode);
    end
end

%-------------------------------------------------------------------
% [EOF]
