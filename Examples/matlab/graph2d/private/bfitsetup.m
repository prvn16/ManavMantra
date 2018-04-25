function [axesCount,fitsShowing,bfinfo,evalresults,currentfit] = bfitsetup(fighandle,datahandle,createLegend)
% BFITSETUP setup anything needed for the Basic Fitting GUI.

%   Copyright 1984-2012 The MathWorks, Inc.

% Flag indicating if we should re/create the legend
if nargin < 3 || isempty(createLegend)
    createLegend = true;
end

emptycell = cell(12,1);
infarray = Inf(1,12);
fitsShowing = false(1,12);
currentfit = [];

guistate.normalize = 0; % Normalize Data checked
guistate.equations = 0; % Show Equations checked
guistate.digits = 2; % Number of Significant Digits
guistate.plotresids = 0; % Plot Residuals checked
guistate.plottype = 0; % Bar Plot (0) or Scatter Plot (1) or Line Plot (2) for residuals
guistate.subplot = 0; % Subplot (0) or Figure (1) for residuals
guistate.showresid = 0; % Show Norm of Residuals checked
guistate.plotresults = 0; % Plot Results checked
guistate.panes = 1; % Number of Panes showing (1,2, or 3)
guistatecell = struct2cell(guistate);
bfinfo = [guistatecell{:}];

evalresults.string = '';
evalresults.x = []; % x values
evalresults.y = []; % f(x) values
evalresults.handle = [];

axesList = findobj(fighandle, 'Type', 'axes');
if isempty(axesList)
    axesCount = 0;
else
    taglines = get(axesList,'Tag');
    notlegendind = ~(strcmp('legend',taglines));
    axesCount = length(axesList(notlegendind));
end

if isempty(datahandle)
    return;
end

% for this data set, store it in the appdata of the fighandle
datasethandles = double(getappdata(fighandle,'Basic_Fit_Data_Handles')); 
if isempty(datasethandles) || ~any(datahandle == datasethandles)
    datasethandles(end + 1) = datahandle;
    setgraphicappdata(fighandle,'Basic_Fit_Data_Handles', datasethandles);
end
setgraphicappdata(fighandle,'Basic_Fit_Current_Data',datahandle);
% Store coefficients, resids, fit handles, and if fit is showing
% each of these are indexed by (fit+1),
% i.e. the spline is index 1, shape-preserving is index 2, the 10th polynomial is index 12
setappdata(double(datahandle),'Basic_Fit_Coeff', emptycell); % cell array of pp structures
setappdata(double(datahandle),'Basic_Fit_Resids', emptycell); % cell array of residual arrays
% Handles are Inf when fit is not in the figure whether this is current data or not
setappdata(double(datahandle),'Basic_Fit_Handles', infarray); % array of handles of fits
% "Showing" is what would be showing if this were the current data, i.e.
%    corresponds to the checkboxes in the GUI
setappdata(double(datahandle),'Basic_Fit_Showing', fitsShowing); % array of logicals: 1 if showing
% This is which fit is listed in the 2nd Pane (Numerical results): last computed.
setappdata(double(datahandle),'Basic_Fit_NumResults_',currentfit);

setappdata(double(datahandle),'Basic_Fit_Gui_State', guistate);

% these are scalars, [] means not showing on the plot
setappdata(double(datahandle),'Basic_Fit_EqnTxt_Handle', []);  

% these are scalars, [] means not showing on the plot
setappdata(double(datahandle),'Basic_Fit_ResidTxt_Handle', []); % norm of residuals txt

setappdata(double(datahandle),'Basic_Fit_Resid_Handles', infarray); % array of handles of residual plots

% evaluate results info
setappdata(double(datahandle),'Basic_Fit_EvalResults',evalresults);

% assign some values
axesH = ancestor(datahandle,'axes');
figureH = ancestor(axesH, 'figure');

% Create a Tag property for Figure to hold a unique number (when the
%   tag was created). This tag identifies the figure without using the integer 
%   figure handle since that can't be restored safely from a figfile.
if isempty(bfitFindProp(figureH,'Basic_Fit_Fig_Tag'))
	bfitAddProp(figureH, 'Basic_Fit_Fig_Tag', 'on');
end
figureTag = datenum(clock);
set(handle(figureH), 'Basic_Fit_Fig_Tag', figureTag);

% residual plot info:
% this one might be the same as the plot of fits figure handle
residinfo.figuretag = figureTag; % assumed same as fit figure to start
residinfo.axes = []; % handle
setappdata(double(datahandle),'Basic_Fit_Resid_Info',residinfo);

% If normalize data, save old x data
normalized = [];
setappdata(double(datahandle),'Basic_Fit_Normalizers',normalized);

% Per data set
% do we need all these???
setgraphicappdata(double(datahandle),'Basic_Fit_Fits_Axes_Handle', axesH);
activePositionProp = get(axesH,'ActivePositionProperty');
setappdata(double(datahandle),'Basic_Fit_Fits_Axes_Position_Prop',activePositionProp);
setappdata(double(datahandle),'Basic_Fit_Fits_Axes_Position',get(axesH,activePositionProp));
setappdata(double(datahandle),'Basic_Fit_Legend_Position',[]);

setappdata(fighandle,'Basic_Fit_Fits_Axes_Count',axesCount);

% Add the data to the legend and put appdata on the data
fitappdata.type = 'data';
fitappdata.index = [];
setappdata(double(datahandle),'bfit',fitappdata);

% The following may have already been set. Just in case
% it hasn't though, set it now
setappdata(double(datahandle), 'Basic_Fit_Copy_Flag', 1);

if createLegend
    bfitcreatelegend(axesH);
end

