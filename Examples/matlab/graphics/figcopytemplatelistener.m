function figcopytemplatelistener(varargin)
%FIGCOPYTEMPLATELISTENER
%   FIGCOPYTEMPLATELISTENER(action, object) will add or remove listeners that will signal when 
%   a figure is added or removed, and when the current figure is changed.
%   
%   action is 'add' or 'remove' 
%   
%   object is the interested party
%   

%   Copyright 1984-2017 The MathWorks, Inc.

action = varargin{1};
if strcmp(action, 'init')
	initFigureCopyTemplate(varargin{2})

elseif strcmp(action, 'remove')    
    cleanup;
    
elseif strcmp(action, 'apply')
    applySettings;
    
elseif strcmp(action, 'restore')
    restoreSettings;
end 

%-------------------------------------------------------------------------------------
function initFigureCopyTemplate(javaObj)

%Setup a dynamic property for FigureCopyTemplate data, 
%which has three fields - JavaObj, Listeners and Registry.
%Set it to non-serializable.
if isprop(groot, 'FigCopyTemplateListenerData') == false
    prop = addprop(groot, 'FigCopyTemplateListenerData');
    prop.Hidden = 1;
    prop.Transient = 1;
end

%Rentry to add listeners might cause unnecessary addition of listeners.
%Hence cleanup before new additions
cleanup;

data = get(groot, 'FigCopyTemplateListenerData');
data.JavaObj = javaObj;
set(groot, 'FigCopyTemplateListenerData', data);

%Add listeners that get saved on the object
addListeners(javaObj);

currentFigHandlers = get(0,'Children');

%remove old figure handlers from registry
removeDeletedFigHandlesFromRegistry(currentFigHandlers);

%add new handles that figure copy template does not know about
addNewFigHandlesToRegistry(currentFigHandlers);

updateApplyAndRestoreButtons(javaObj);



%-------------------------------------------------------------------------------------
function removeDeletedFigHandlesFromRegistry(currentFigHandlers)
data = get(groot, 'FigCopyTemplateListenerData');

if (isfield(data, 'Registry') && ~isempty(data.Registry) && ~isempty(data.Registry.handles))
    registry = data.Registry;
    registry_new = [];
    for i = 1:length(registry.handles)
        idx = getFigureIdx(registry.handles(i),currentFigHandlers);
        if idx ~= -1
            if isempty(registry_new)
                registry_new.handles = registry.handles(i);
                registry_new.states = registry.states(i);
            else
               registry_new.handles(end + 1) = registry.handles(i);
               registry_new.states(end + 1) = registry.states(i);
            end
        end
    end
    data.Registry = registry_new;
    set(groot, 'FigCopyTemplateListenerData', data)
end

%-------------------------------------------------------------------------------------
function addNewFigHandlesToRegistry(currentFigHandlers)
data = get(groot, 'FigCopyTemplateListenerData');

for i = 1:length(currentFigHandlers)
    if ~isfield(data, 'Registry') || isempty(data.Registry) || isempty(data.Registry.handles)  
        registry.handles = currentFigHandlers(i);
        registry.states = 0;
    else
        registry = data.Registry;
        idx = getFigureIdx(currentFigHandlers(i),registry.handles(:));
        if idx == -1
            registry.handles(end + 1) = currentFigHandlers(i);
            registry.states(end + 1) = 0;       
        end    
    end
    data.Registry = registry;
end

set(groot, 'FigCopyTemplateListenerData', data);


%-------------------------------------------------------------------------------------
function updateApplyAndRestoreButtons(javaObj)
data = get(groot, 'FigCopyTemplateListenerData');

if ~isfield(data, 'Registry') || isempty(data.Registry) || isempty(data.Registry.handles)    
    javaObj.setButtonStates(false,false);
else
    registry = data.Registry;
    idx = getFigureIdx(get(0,'CurrentFigure'),registry.handles(:));
    if idx == -1
        javaObj.setButtonStates(false,false);
    elseif registry.states(idx) == 0
        javaObj.setButtonStates(true,false);
    elseif registry.states(idx) == 1
        javaObj.setButtonStates(true,true);
    else
        disp('Error');
    end 
end

%-------------------------------------------------------------------------------------
function cleanup
if isprop(groot, 'FigCopyTemplateListenerData')
    data = get(groot, 'FigCopyTemplateListenerData');
    if isfield(data, 'Listeners')
        listenerstruct = data.Listeners;
        fields = fieldnames(listenerstruct);
        for i=1:length(fields)
            delete(listenerstruct.(fields{i}));
        end
        data = rmfield(data, 'Listeners');
    end
    % Clean up the handle to java GUI object
    if isfield(data, 'JavaObj')
        data = rmfield(data, 'JavaObj');
    end
    set(groot, 'FigCopyTemplateListenerData', data);
end




%-------------------------------------------------------------------------------------
function addListeners(javaObj)
FigCTListeners.figureAdded = addlistener(0, 'ObjectChildAdded', @(o,e) rootChildAdded(o,e,javaObj));
FigCTListeners.figureRemoved = addlistener(0, 'ObjectChildRemoved', @(o,e) rootChildRemoved(o,e,javaObj));
FigCTListeners.GCFChanged = addlistener(0, 'CurrentFigure', 'PostSet', @(o,e) gcfChanged(o,e, javaObj));

% add listeners to existing figures
currentFigHandlers = get(0,'Children');
for i=1:length(currentFigHandlers)
    if sum(strcmp('figureRemoved2',fieldnames(FigCTListeners))) == 0
        FigCTListeners.figureRemoved2 = addlistener(currentFigHandlers(i),'ObjectBeingDestroyed',@(o,e)rootChildRemoved2(o,e,javaObj));
    else
        FigCTListeners.figureRemoved2(end + 1) = addlistener(currentFigHandlers(i),'ObjectBeingDestroyed',@(o,e)rootChildRemoved2(o,e,javaObj));
    end
end

%Save the listeners to a dynamic property of the root.
data = get(groot, 'FigCopyTemplateListenerData');
data.Listeners = FigCTListeners;
set(groot, 'FigCopyTemplateListenerData', data);
  

%-------------------------------------------------------------------------------------
function applySettings
data = get(groot, 'FigCopyTemplateListenerData');
javaObj = data.JavaObj;
registry = data.Registry;
cFig = get(0,'CurrentFigure');
idx = getFigureIdx(cFig,registry.handles(:));
if registry.states(idx) == 1
    jpropeditutils('jrestorefig',cFig)
end
jpropeditutils('japplyexpopts',cFig)    
registry.states(idx) = 1;
javaObj.setButtonStates(true,true);

data.Registry = registry;
data.JavaObj = javaObj;
set(groot, 'FigCopyTemplateListenerData', data);
    
%-------------------------------------------------------------------------------------    
function restoreSettings
data = get(groot, 'FigCopyTemplateListenerData');
javaObj = data.JavaObj;
cFig = get(0,'CurrentFigure');
jpropeditutils('jrestorefig',cFig)

registry = data.Registry;
idx = getFigureIdx(cFig,registry.handles(:));
registry.states(idx) = 0;
javaObj.setButtonStates(true,false);

data.Registry = registry;
data.JavaObj = javaObj;
set(groot, 'FigCopyTemplateListenerData', data);

%-------------------------------------------------------------------------------------    
% Listen for figures being added.  Only act if a figure is added.
function rootChildAdded(~, event, javaObj)
if isprop(groot, 'FigCopyTemplateListenerData')
    data = get(groot, 'FigCopyTemplateListenerData');
    FigCTListeners = data.Listeners;
    if sum(strcmp('figureRemoved2',fieldnames(FigCTListeners))) == 0
        FigCTListeners.figureRemoved2 = addlistener(event.Child,'ObjectBeingDestroyed',@(o,e)rootChildRemoved2(o,e,javaObj));
    else
        FigCTListeners.figureRemoved2(end + 1) = addlistener(event.Child,'ObjectBeingDestroyed',@(o,e)rootChildRemoved2(o,e,javaObj));
    end

    if ~isfield(data, 'Registry') || isempty(data.Registry)
        registry.handles = event.Child;
        registry.states = 0;
    else
        registry = data.Registry;
        registry.handles(end + 1) = event.Child;
        registry.states(end + 1) = 0;
    end
    data.Listeners = FigCTListeners;
    data.Registry = registry;
    data.JavaObj = javaObj;
    set(groot, 'FigCopyTemplateListenerData', data);
end
	

%-------------------------------------------------------------------------------------
% Listen for figures being removed.  Only act if a figure is removed.
function rootChildRemoved(hSrc, event, javaObj)
gcfChanged(hSrc, event, javaObj)

%-------------------------------------------------------------------------------------
% Listen for figures being removed.  Only act if a figure is removed.
function rootChildRemoved2(~, event, ~)
data = get(groot, 'FigCopyTemplateListenerData');
registry = data.Registry;

idx = getFigureIdx(event.Source,registry.handles(:));      
registry.handles = [registry.handles(1:idx-1) registry.handles(idx+1:end)];
registry.states = [registry.states(1:idx-1) registry.states(idx+1:end)];
data.Registry = registry;
set(groot, 'FigCopyTemplateListenerData', data);


%-------------------------------------------------------------------------------------
% Listen for GCF being changed. 
function gcfChanged(~, ~, javaObj)
updateApplyAndRestoreButtons(javaObj);

function idx = getFigureIdx(fig,allFigs)
idx = -1;    
for i = 1:length(allFigs)
    if fig == allFigs(i)
        idx = i;
        return
    end
end 

