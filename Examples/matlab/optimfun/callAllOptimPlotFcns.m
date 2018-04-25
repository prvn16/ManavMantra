function state = callAllOptimPlotFcns(functions,x,optimvalues,flag,varargin)
%

%callAllOptimPlotFcns Helper function that manages the plot functions.
%   STOP = callAllOptimPlotFcns(FUNCTIONS, X,OPTIMVALUES,'init') creates
%   the plot function figure if it does not exist and calls the specified
%   functions with 'init' state.
%
%   STOP = callAllOptimPlotFcns(FUNCTIONS, X,OPTIMVALUES,'iter') calls the
%   specified functions with 'iter' state. If the plot function figure
%   doesn't exist, then STOP is set to true and the function returns.
% 
%   STOP = callAllOptimPlotFcns(FUNCTIONS, X,OPTIMVALUES,'interrupt') calls
%   the specified functions with 'interrupt' state.
%
%   STOP = callAllOptimPlotFcns(FUNCTIONS, X,OPTIMVALUES,'done') calls the
%   specified functions with 'done' state. If the plot function figure
%   doesn't exist, then STOP is set to false and the function returns.
%   
%   callAllOptimPlotFcns('cleanuponstopsignal') performs clean up tasks on
%   the plot function figure if it exists. No plot functions are called by
%   this command. This call is intended to be used by algorithms to allow
%   the plot function figure to be cleaned up when the algorithm has been
%   stopped by an output or plot function.
%
%   This function is private to Optimization solvers.

%   Copyright 2006-2014 The MathWorks, Inc. 

persistent plotNo plotNames isNew fig position menuitem plotDrawNowLast

state = false;
fname = 'Optimization PlotFcns';

% If the calling algorithm has been terminated by an output/plot function,
% just need to perform the final tasks on the plot function figure. We do
% not call the plot functions when callAllOptimPlotFcns is called with
% 'cleanuponstopsignal'.
if nargin == 1 && strcmpi(functions, 'cleanuponstopsignal')
    % The plot function figure will not be available if the user did not
    % specified any plot functions or the figure has simply been closed in
    % some way.
    if ~isempty(findobj(0,'Type','figure','name',fname))
        finalizeFigure(fig, plotNames, menuitem);
    end
    return
end

if (isempty(functions)) || ...
        (strcmpi(flag,'done') && isempty(findobj(0,'Type','figure','name',fname)))
    return;
end
% Check if called with 'iter' flag and no figure is present.
if (strcmpi(flag,'iter') && isempty(findobj(0,'Type','figure','name',fname)))
    state = true;
    return;
end

functions = removeDup(functions);
% Called with 'init' flag or the figure is not present
if(strcmp(flag,'init')) || isempty(findobj(0,'Type','figure','name',fname))
    fig = findobj(0,'type','figure','name',fname);
    if isempty(fig)
        fig = figure('visible','off');
        if ~isempty(position) && ~strcmpi(get(fig,'WindowStyle'),'docked')
            set(fig,'Position',position);
        end
    end
    set(0,'CurrentFigure',fig);
    clf;
    set(fig,'numbertitle','off','name',fname,'userdata',[]);
    % Initialize the persistent variables
    [plotNames,plotNo,menuitem,isNew] = updatelist(functions);
    plotDrawNowLast = tic;
    
    % Check the state of the GUI. getRunMode == 1 when the GUI is
    % running/paused.
    try % optimtool may not be present when this function is called from deployed apps.
        optimtoolGui = javaMethodEDT('getOptimGUI','com.mathworks.toolbox.optim.OptimGUI');
        isGUIOpen = ~isempty(optimtoolGui);
        if isGUIOpen
            isGUIRunning = (javaMethodEDT('getRunMode',optimtoolGui) == 1);
        else
            isGUIRunning = false;
        end
        buttonsOK = ~(isGUIOpen && isGUIRunning);
    catch ME %#ok
        buttonsOK = true;
    end
    if buttonsOK
        % Give a stop button in the figure
        stopBtnXYLoc = [2 5];
        stopBtn = uicontrol('string',getString(message('MATLAB:optimfun:funfun:optimplots:ButtonStop')), ... 
          'Position',[stopBtnXYLoc 50 20],'callback',@buttonStop);
        % Make sure the full text of the button is shown
        stopBtnExtent = get(stopBtn,'Extent');
        stopBtnPos = [stopBtnXYLoc stopBtnExtent(3:4)+[2 2]]; % Read text extent of stop button
        % Set the position, using the initial hard coded position, if it is long enough
        set(stopBtn,'Position',max(stopBtnPos,get(stopBtn,'Position')));
        
        % Give a pause button in the figure
        pauseBtn = uicontrol('string',getString(message('MATLAB:optimfun:funfun:optimplots:ButtonPause')), ... 
          'Position',[60 5 60 15],'callback',{@buttonPauseContinue,fname});
        pauseBtnExtent = get(pauseBtn,'Extent');
        pauseBtnXYLoc = stopBtnXYLoc + [stopBtnPos(3) 0] + [10 0]; % Offset for space in between stop and pause buttons
        pauseBtnPos = [pauseBtnXYLoc pauseBtnExtent(3:4)+[3 3]];
        % Set the position, using the initial hard coded position, if it is long enough
        set(pauseBtn,'Position',max(pauseBtnPos,get(pauseBtn,'Position')));
    end
    
    set(fig,'CloseRequestFcn',@beforeClose);
    % Reset the appdata if it exist
    if isappdata(fig,'data')
        rmappdata(fig,'data')
    end
    set(gcf,'visible','on')
    shg
end
% Determine the layout size in the figure
rows  = ceil(sqrt(length(functions)));
cols  = ceil(length(functions)/rows);
% Special rule when we have three functions.
if length(functions) == 3
  rows = 3;
  cols = 1;
end
% Set the current figure to fig
set(0,'CurrentFigure',fig);

% Initialize the output argument from plot functions
state = false(length(plotNames),1);
% Call each plot function
for i = 1:length(plotNames)
    handle = subplot(rows,cols,plotNo(i));
    if isNew(i)
        % Do not delete the axis (which is the default settings)
        set(handle,'NextPlot','replacechildren');
        state(i) = feval(plotNames{i},x,optimvalues,'init',varargin{:});
        isNew(i)=false;
        if ~strcmpi(flag,'init')
            state(i) = feval(plotNames{i},x,optimvalues,flag,varargin{:});
        end
        cmenu = uicontextmenu;
        set(handle,'UIContextMenu', cmenu);
        % Provide a uicontext menu item to open the axes in a new figure
        % window
        cmenuCallback = {@mouseaction,handle,plotNames{i}};
        uimenu(cmenu,'Label', getString(message('MATLAB:optimfun:funfun:optimplots:LabelOpenPlotInNewWindow')), ...
            'Callback', cmenuCallback,'Tag','OpenInNewWindow');
        menuitem(i) = get(cmenu,'Children');
        set(menuitem(i),'Visible','off');
    else
        state(i) = feval(plotNames{i},x,optimvalues,flag,varargin{:});
    end
end
% If any state(i) is true we set the state to true
state = any(state);

% Call drawnow at most 1/30 seconds later
if toc(plotDrawNowLast) > 1/30
  drawnow
  plotDrawNowLast = tic;
end
% Check if the figure is still alive
if isempty(findobj(0,'Type','figure','name',fname))
    state = true;
    return;
end
% Remember the position
position = get(fig,'Position');

% If stop button was pressed, handle the callback
if(strcmpi('stop',getappdata(fig,'data')))
    state = true;
    setappdata(fig,'data','')
end

% Perform final tasks on the plot function figure
if strcmpi(flag,'done') || state
    finalizeFigure(fig, plotNames, menuitem);
end

%-------------------------------------------------------
% UPDATELIST updates the function list and plot numbers
%-------------------------------------------------------
function [plotNames, plotNo,menuitem, isNew] = updatelist(functions)

plotNames = functions;
plotNo   = 1:length(functions);
isNew = true(length(plotNames),1);
menuitem = zeros(length(plotNames),1);
%-----------------------------------------------------------
% REMOVEDUP remove the duplicate entries in a cell array of function handle
%-----------------------------------------------------------
function functions = removeDup(functions)
i = 1;
while i <= length(functions)
      [found,index] = foundfunc(functions{i},functions);
      if found 
        functions(index(1:end-1)) = [];
      end
    i = i+1;
end

%-------------------------------------------------------------------------
% FOUNDFUNC Finds if STR is in FUNCNAMES, returns a boolean and index
%-------------------------------------------------------------------------
function [bool,index] = foundfunc(str,funcNames)

% Initialize return arguments
bool = false;
index = 0;

% Following the advice in the MATLAB documentation (see "Comparing Function
% Handles" section), we cannot use a string comparison to compare anonymous
% functions, as this does not account for what is the anonymous function
% workspace. As such if str is anonymous function, we return that it hasn't
% been found.
funcInfo = functions(str);
if strcmpi(funcInfo.type, 'anonymous') 
    return
end

for i = 1:length(funcNames)
    if strcmpi(func2str(str),func2str(funcNames{i}))
        bool = true;
        if nargout > 1
            index(end+1) = i;
        end
    end
end
index(1) = [];
%-----------------------------------------------------------
% STOP button callback
%-----------------------------------------------------------
function buttonStop(~,~)
setappdata(gcf,'data','stop');

%-----------------------------------------------------------
% PAUSE/CONTINUE button callback
%-----------------------------------------------------------
function buttonPauseContinue(hObj,~,fname)
if length(dbstack) <=2
    return;
elseif isempty(getappdata(gcf,'data'))
    setappdata(gcf,'data','pause');
    % To avoid dynamically re-sizing the Pause/Resume button, we leave
    % the button size unchanged from it's size at creation.
    set(hObj,'String',getString(message('MATLAB:optimfun:funfun:optimplots:ButtonResume')));
else
    rmappdata(gcf,'data');
    return;
end
% If in pause state keeping looping here.
while true
    drawnow
    fig = findobj(0,'type','figure','name',fname);
    % Figure window is closed; return
    if isempty (fig)
        return;
    end
    % When 'Resume' button is pressed
    if isempty(getappdata(gcf,'data'))
        set(hObj,'String',getString(message('MATLAB:optimfun:funfun:optimplots:ButtonPause')));
        return;
    end
    % When 'Stop' button is pressed
    if strcmpi('stop',getappdata(fig,'data'))
        set(hObj,'String',getString(message('MATLAB:optimfun:funfun:optimplots:ButtonPause')));
        return;
    end
end % End while
%-----------------------------------------------------------
% MOUSEACTION callback function
%-----------------------------------------------------------
function mouseaction(~,~,axes_handle,Name)
% Determine the length of stack. If length is one then need to open a new
% figure with axes copied from the current object
callStack = dbstack;
if length(callStack) == 1 % The solver has stopped
    newFigName = func2str(Name);
    fig = findobj(0,'type','figure','name',newFigName);
    if isempty(fig) % Create a new figure
        fig = figure('numbertitle','off','name',newFigName);
    end
    set(0,'CurrentFigure',fig); clf;
    % Get the position of new axes (to be created)
    tempaxis = axes('visible','off');
    axisPosition = get(tempaxis,'Position');
    delete(tempaxis);
    % Copy the axes to the new figure
    parent = get(axes_handle,'parent');
    copiedPlot = copyobj(axes_handle,parent);
    set(copiedPlot,'parent',fig,'position',axisPosition);
    figure(fig);
    return;
end


%-----------------------------------------------------------
% BEFORECLOSE CloseRequestFcn for main figure window
%-----------------------------------------------------------
function beforeClose(obj,~)
% Determine the length of stack. If length is one then we don't
% need a question dialog; we simply delete the obj (close the figure)
if length(dbstack) ==1
    delete(obj)
    return;
end

msg = getString(message('MATLAB:optimfun:funfun:optimplots:DialogStopSolverAndCloseFigure'));
handle = questdlg(msg,getString(message('MATLAB:optimfun:funfun:optimplots:TitleCloseDialog')),...
 getString(message('MATLAB:optimfun:funfun:optimplots:DialogYes')),...
 getString(message('MATLAB:optimfun:funfun:optimplots:DialogNo')),...
 getString(message('MATLAB:optimfun:funfun:optimplots:DialogNo')));
switch handle
    case getString(message('MATLAB:optimfun:funfun:optimplots:DialogYes'))
        delete(obj)
    case getString(message('MATLAB:optimfun:funfun:optimplots:DialogNo')) 
        return;
    otherwise
        return;
end


%---------------------------------------------------------------
% FINALIZEFIGURE Perform final tasks on the plot function figure 
%---------------------------------------------------------------
function finalizeFigure(fig, plotNames, menuitem)

% reset the closerequest function
set(fig,'CloseRequestFcn','closereq');
% Enable menu item at the end
for i = 1:length(plotNames)
    set(menuitem(i),'Visible','on');
end



