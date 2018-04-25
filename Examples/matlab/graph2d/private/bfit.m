function bfit(figHandle, cmd)
% BFIT
%   BFIT(FIGHANDLE, 'bf') opens (or reopens) the Basic Fitting GUI and
%   stores the handle of the GUI in the appdata of the figure.
%   BFIT(FIGHANDLE, 'ds') opens (or reopens) the Data Stats GUI and stores
%   the handle of the GUI in the appdata of the figure.

%   Copyright 1984-2016 The MathWorks, Inc.
%     

ptr = get(figHandle,'pointer');
set(figHandle,'pointer','watch');
% Was it loaded from a figfile: if so, then no pointer to GUI but has Basic_Fit_Fig_Tag
% BEFORE opening GUI.
if isempty(bfitFindProp(figHandle,'Basic_Fit_GUI_Object')) ...
        && ~isempty(bfitFindProp(figHandle,'Basic_Fit_Fig_Tag')) && ...
        isappdata(figHandle,'Basic_Fit_Data_Counter')  % not a residual figure
    updatetags(figHandle);
elseif isempty(bfitFindProp(figHandle,'Data_Stats_GUI_Object')) ... % maybe just data stats was open
        && ~isempty(bfitFindProp(figHandle,'Data_Stats_Fig_Tag'))
    updateDSTags(figHandle);
else % not loaded from a figfile - clear app data if basic fit lines were copied
    axesList = findall(figHandle, '-isa', 'matlab.graphics.axis.Axes');
    for i = 1:length(axesList)
        axesChildren = getAxesChildren(axesList(i));
        for j = 1:length(axesChildren)
            if isappdata(double(axesChildren(j)), 'bfit') && ...
                    ~isappdata(double(axesChildren(j)), 'Basic_Fit_Copy_Flag')
                bfitclearappdata(axesChildren(j));
            end
        end
    end
end
switch cmd
 case 'bf'
  import com.mathworks.page.basicfit.BasicFit;
  % this is the first creation, add a callback to this file
  if (BasicFit.callbackSet() == false) 
      cb = handle(BasicFit.getCallback(),'callbackproperties');
      set(cb,'delayedCallback',@callbackHandler);
  end
  bf = BasicFit.showBasicFit(double(figHandle));
  % call drawnow to make sure the callback goes through
  drawnow
  if isempty(bfitFindProp(figHandle,'Basic_Fit_GUI_Object'))
      bfitAddProp(figHandle, 'Basic_Fit_GUI_Object');
  end
  set(handle(figHandle), 'Basic_Fit_GUI_Object', bf);
 case 'ds'
  ds = com.mathworks.page.basicfit.DataStatistics.showDataStats(double(figHandle));
  if isempty(bfitFindProp(figHandle,'Data_Stats_GUI_Object'))
      bfitAddProp(figHandle, 'Data_Stats_GUI_Object');
  end
  set(handle(figHandle), 'Data_Stats_GUI_Object', ds);
end
set(figHandle,'pointer',ptr);

%------------------------------------------------------------------------------------------------
function callbackHandler(~, callbackData)
if isempty(callbackData)
    % this is an error but we'll go quietly
    return;
end
args = callbackData.getArgs();
nlhs = callbackData.getNargout();
observer = callbackData.getObserver();

% convert args to cell array
args = cell(args);
 
args = convertFigArgToHandle(args);

out = {};
try 
    if nlhs > 0
        [out{1:nlhs}] = feval(args{1}, args{2:end});
    else
        feval(args{1}, args{2:end});
    end
    if ~isempty(observer)
        status = com.mathworks.jmi.Matlab.EXECUTION_SUCCESS;
        if nlhs > 0
            observer.completed(status, out{:});
        else
            observer.completed(status, out);
        end
    end
catch err
    errordlg(getString(message('MATLAB:graph2d:bfit:ErrordlgErrorExecuting', err.message)),...
        getString(message('MATLAB:graph2d:bfit:ErrordlgError')))
end

%------------------------------------------------------------------------------------------------
function args = convertFigArgToHandle(args)
    % first args is the function 
    switch args{1}
        case {'bfitopen', 'bfitupdate', 'bfitcleanup', 'bfitdatastatupdate'}
            args{2} = handle(args{2});
        % otherwise - nothing to convert  
    end

%------------------------------------------------------------------------------------------------
function updatetags(figHandle)
% Recreate a Tag in case the figure it was created from is open (otherwise
% they will have the same Tags).

oldTag = get(handle(figHandle),'Basic_Fit_Fig_Tag');
% Create new tag
figureTag = datenum(clock);
set(handle(figHandle), 'Basic_Fit_Fig_Tag', figureTag);
if ~isempty(bfitFindProp(figHandle,'Data_Stats_Fig_Tag')) % data stats was also opened
    set(handle(figHandle), 'Data_Stats_Fig_Tag', figureTag);
end

%for current data, if valid, check if resid is separate since we need to
%create it if it is
datahandle = double(getappdata(figHandle,'Basic_Fit_Current_Data'));
if isempty(datahandle) || isgraphics(datahandle)
    residinfo = getappdata(datahandle,'Basic_Fit_Resid_Info');
    if isequal(residinfo.figuretag,oldTag) % subplot
        residinfo.figuretag = figureTag;
        setappdata(datahandle,'Basic_Fit_Resid_Info',residinfo);
    else % separate figure
        % No residfigure, so set to empty for bfitcheckplotresiduals call
        residinfo.figuretag = [];
        residinfo.axes = [];
        setappdata(datahandle,'Basic_Fit_Resid_Info',residinfo);
        checkon = 1;
        guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
        % need to draw a new resid figure
        bfitcheckplotresiduals(checkon,datahandle,guistate.plottype,~guistate.subplot,guistate.showresid);
        residinfo = getappdata(datahandle,'Basic_Fit_Resid_Info');
    end
    currentresidtag = residinfo.figuretag;
end

% update other tags: residinfo.figuretag on each dataset
% for each data, check residinfo.figuretag and update
datasethandles = double(getappdata(figHandle,'Basic_Fit_Data_Handles')); 
datasethandles(datasethandles==datahandle) = [];      % delete current
for i=1:length(datasethandles)
    datahandle = datasethandles(i);
    residinfo = getappdata(datahandle,'Basic_Fit_Resid_Info');
    if isequal(residinfo.figuretag,oldTag)
        residinfo.figuretag = figureTag;
    else
        residinfo.figuretag = currentresidtag;
    end
    setappdata(datahandle,'Basic_Fit_Resid_Info',residinfo);
end

resetCopyFlag(figHandle);

%----------------------------------------------------------------------------------------------
function updateDSTags(figHandle)
% Recreate a Tag in case the figure it was created from is open (otherwise
% they will have the same Tags).

figureTag = datenum(clock);
set(handle(figHandle), 'Data_Stats_Fig_Tag', figureTag);
resetCopyFlag(figHandle);

%------------------------------------------------------------------------------------------------
% This method might no longer be needed since we are using appdata instead
% of properties. Keeping it for now to minimize the number of changes.
function resetCopyFlag(figHandle)
axesList = findall(figHandle, '-isa', 'matlab.graphics.axis.Axes');
for i = 1:length(axesList) 
    axesChildren = get(axesList(i),'children');
    for j = 1:length(axesChildren)
        if isappdata(double(axesChildren(j)), 'bfit') 
            setappdata(double(axesChildren(j)), 'Basic_Fit_Copy_Flag', 1);
        end
    end
end

function c = getAxesChildren(ax)
    
  c= [];
  if ishghandle(ax,'axes')
      c = findobj(allchild(ax),'flat','HandleVisibility','on');
  end
