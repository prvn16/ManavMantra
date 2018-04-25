function figuredeletedlistener(fig, object)
%FIGUREDELETEDLISTENER
%   FIGUREDELETEDLISTENER(fig, object) will add or remove listeners that will signal when 
%   the specified figure is removed.
%   
%   fig is the figure  
%   
%   object is the interested party
%   

%   Copyright 1984-2017 The MathWorks, Inc.

if ~ishghandle(fig)
	return;
end
if isappdata(fig, 'Fig_Delete_Listener') 
	return;
end
%hgp = findpackage('hg');
%rootC = findclass(hgp, 'root');

FigDelListeners.figureRemoved = addlistener(fig, 'ObjectBeingDestroyed', @(o,e) figureRemoved(o,e, fig, object));

setappdata(fig, 'Fig_Delete_Listener', FigDelListeners);

%-------------------------------------------------------------------------------------

% Listen for figures being removed.
 
function figureRemoved(~, ~, fig, javaObj)
	if isappdata(fig,'Fig_Delete_Listener')
		javaObj.FigureRemoved(fig);
	end
