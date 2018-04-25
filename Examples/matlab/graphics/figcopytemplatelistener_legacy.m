function figcopytemplatelistener_legacy(action, object)
%FIGCOPYTEMPLATELISTENER
%   FIGCOPYTEMPLATELISTENER(action, object) will add or remove listeners that will signal when 
%   a figure is added or removed, and when the current figure is changed.
%   
%   action is 'add' or 'remove' 
%   
%   object is the interested party
%   

%   Copyright 1984-2017 The MathWorks, Inc.

if strcmp(action, 'add')
	hProp = 'CurrentFigure';
    %Rentry to add listeners might cause unnecessary addition of listeners.
    %Hence cleanup before new additions
    cleanupListeners;
    %Add listeners that get saved on the object
	FigCTListeners.figureAdded = addlistener(0, 'ObjectChildAdded', @(o,e) rootChildAdded(o,e,object));
	FigCTListeners.figureRemoved = addlistener(0, 'ObjectChildRemoved', @(o,e) rootChildRemoved(o,e,object));
	FigCTListeners.GCFChanged = addlistener(0, hProp, 'PostSet', @(o,e) gcfChanged(o,e, object));
    %Set the listeners as appdata on the root
    setappdata(0, 'Fig_CT_Listener', FigCTListeners);
elseif strcmp(action, 'remove')
	cleanupListeners;
end 

%-------------------------------------------------------------------------------------
function cleanupListeners
if isappdata(0, 'Fig_CT_Listener') 
        listenerstruct = getappdata(0,'Fig_CT_Listener');
		fields = fieldnames(listenerstruct);
        for i=1:length(fields)
            delete(listenerstruct.(fields{i}));
        end
        rmappdata(0,'Fig_CT_Listener');
end

%-------------------------------------------------------------------------------------

% Listen for figures being added.  Only act if a figure is added.
function rootChildAdded(~, event, javaObj)
	if isa(event.child, 'hg.figure')
		if isappdata(0,'Fig_CT_Listener')
			javaObj.CurrentFigureChanged;
		end
	end

%-------------------------------------------------------------------------------------

% Listen for figures being removed.  Only act if a figure is removed.
function rootChildRemoved(~, event, javaObj)
	if isa(event.child, 'hg.figure')
		if isappdata(0,'Fig_CT_Listener')
			fig = double(event.child);
            if ~strcmp(get(fig, 'HandleVisibility'), 'on')
                return;
            end
            
            nextfig = get(0, 'CurrentFigure');
            if (nextfig == fig) %Current figure is being deleted
                children = findall(0, 'type', 'figure', 'HandleVisibility', 'on');
                if (length(children) > 1)               
                    index = find(children == fig);
                    if (index == 1)
                        nextfig = children(2); 
                    else
                        nextfig = children(1);
                    end
                else
                    nextfig = 0;
                end
            end
            javaObj.FigureRemoved(fig, nextfig);
		end
	end

%-------------------------------------------------------------------------------------

% Listen for GCF being changed. 
function gcfChanged(~, ~, javaObj)
	if isappdata(0, 'Fig_CT_Listener')
		javaObj.CurrentFigureChanged;
	end


