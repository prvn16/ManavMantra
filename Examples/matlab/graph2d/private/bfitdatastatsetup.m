function [x_str, y_str, xcolname, ycolname] = bfitdatastatsetup(fighandle,datahandle)
% BFITDATASTATSETUP setup appdata for data set in Data Statistics GUI.

%   Copyright 1984-2012 The MathWorks, Inc.

infarray = Inf(1,6);
axesH = ancestor(datahandle,'axes');

fighandle = handle(fighandle);
% Create a Tag property for Figure to hold a unique number (when the
%   tag was created). This tag identifies the figure without using the integer 
%   figure handle since that can't be restored safely from a figfile.
if isempty(bfitFindProp(fighandle,'Data_Stats_Fig_Tag'))
	bfitAddProp(fighandle, 'Data_Stats_Fig_Tag', 'on');
end
figureTag = datenum(clock);
set(handle(fighandle), 'Data_Stats_Fig_Tag', figureTag);

% for this axes, store it in the appdata of the fighandle: sharing with Basic Fit
axeshandles = double(getappdata(fighandle,'Basic_Fit_Axes_Handles')); 
if isempty(axeshandles) || ~any(axesH == axeshandles)
    axeshandles(end + 1) = axesH;
    setgraphicappdata(fighandle,'Basic_Fit_Axes_Handles', axeshandles)
end

% for this data set, store it in the appdata of the figure
datasethandles = double(getappdata(fighandle,'Data_Stats_Data_Handles')); 
if isempty(datasethandles) || ~any(datahandle == datasethandles)
    datasethandles(end + 1) = datahandle;
    setgraphicappdata(fighandle,'Data_Stats_Data_Handles', datasethandles);
end

setgraphicappdata(fighandle,'Data_Stats_Current_Data',datahandle);

% place to store stats
setappdata(double(datahandle),'Data_Stats_X',[]);
setappdata(double(datahandle),'Data_Stats_Y',[]);

% place to store handles of lines plotted, and
% index vector of who is currently plotted
setappdata(double(datahandle),'Data_Stats_X_Handles',infarray);  % array of handles of plots
setappdata(double(datahandle),'Data_Stats_Y_Handles',infarray);  % array of handles of plots
setappdata(double(datahandle),'Data_Stats_X_Showing', false(1,6)); % array of logicals: 1 if showing
setappdata(double(datahandle),'Data_Stats_Y_Showing', false(1,6)); % array of logicals: 1 if showing

% Add the data to the legend and put note that this is data
statappdata.type = 'data';
statappdata.index = [];
setappdata(double(datahandle),'bfit',statappdata);

% The following may have already been set. Just in case
% it hasn't though, set it now
setappdata(double(datahandle), 'Basic_Fit_Copy_Flag', 1);

bfitcreatelegend(axesH);

% compute data stats to return
[x_str, y_str] = bfitcomputedatastats(datahandle);

[xcolname, ycolname] = bfitdatastatsgetcolnames(datahandle);

