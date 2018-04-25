function updatePrintAxesInteractivity(~, printAxes)
%UPDATEPRINTAXESINTERACTIVITY Make visual specific updates to the controls
% on the print axes.
%   A utility method which the specific visuals should override if needed.
%   By default, remove any interactive controls from the specified axes.  

%   Copyright 2012-2015 The MathWorks, Inc.

% Remove interactive behaviors from copied objects
allObjects = findall(printAxes);

% Usage of empty braces ([]) instead of empty quotes ('') for objects is  
% more robust and using '' does not work in HG2.

set(allObjects,'UIContextMenu',[]);
set(allObjects,'ButtonDownFcn','');
set(allObjects,'DeleteFcn','');
set(allObjects,'UserData',[]);
set(allObjects,'Tag','');