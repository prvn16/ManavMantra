function bfitcleanup(fighandle, numberpanes)
% BFITCLEANUP clean up anything needed for the Basic Fitting GUI.

%   Copyright 1984-2010 The MathWorks, Inc.

% Now that Basic Fitting invokes the callback for this function 
% asynchronously, it is possible for this function to be called after a 
% Basic Fitting figure has been deleted. Check for Basic_Fit_Current_Data 
% appdata to make sure we are cleaning up a Basic Fitting figure.
if ishghandle(fighandle) && isappdata(fighandle, 'Basic_Fit_Current_Data')
    datahandle = getappdata(fighandle,'Basic_Fit_Current_Data');
    if ~isempty(datahandle)
        guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
        guistate.panes = numberpanes;
        setappdata(double(datahandle),'Basic_Fit_Gui_State', guistate);
    end
    set(handle(fighandle), 'Basic_Fit_GUI_Object', []);
% reset normalized?
end

