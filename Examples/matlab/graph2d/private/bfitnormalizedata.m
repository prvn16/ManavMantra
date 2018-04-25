function [evalresultsx,evalresultsy, coeffresidstrings] = bfitnormalizedata(checkon,datahandle)
% BFITNORMALIZEDATA normalize the data

%   Copyright 1984-2014 The MathWorks, Inc.

if checkon
    xdata = double(get(datahandle,'xdata'));
    normalized = [mean(xdata(~isnan(xdata))); std(xdata(~isnan(xdata)))];
    setappdata(double(datahandle),'Basic_Fit_Normalizers',normalized);
else
    normalized = [];
    setappdata(double(datahandle),'Basic_Fit_Normalizers',normalized);
end

guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
if ~isequal(guistate.normalize,checkon)
    % reset scaling warning flag so it will occur
     setappdata(double(datahandle),'Basic_Fit_Scaling_Warn',[]);
end
guistate.normalize = checkon;
setappdata(double(datahandle),'Basic_Fit_Gui_State', guistate);

axesH = ancestor(datahandle,'axes');
figHandle = ancestor(axesH, 'figure');
[fithandles, residhandles, residinfo] = bfitremovelines(figHandle,datahandle,0);
% Update appdata for line handles so legend can redraw
setgraphicappdata(double(datahandle), 'Basic_Fit_Handles',fithandles);
setgraphicappdata(double(datahandle), 'Basic_Fit_Resid_Handles',residhandles);
setappdata(double(datahandle), 'Basic_Fit_Resid_Info',residinfo);

% Get newdata info
[~, ~, ~, ~,evalresultsx,evalresultsy,~,coeffresidstrings] = ...
    bfitselectnew(figHandle, datahandle);

