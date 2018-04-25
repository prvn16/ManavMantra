function [out] = linkdata(arg1,arg2)
%LINKED Automatically update graphs when variables change.
%  LINKDATA ON turns on linking for the current figure.
%  LINKDATA OFF turns it off.
%  LINKDATA by itself toggles the state.
%  LINKDATA(FIG,...) works on specified figure handle.
%
%  H = LINKDATA(FIG) returns a linkdata object with the following property: 
%
%        Enable  'on'|{'off'}
%        Specifies whether this figure is currently linked.
%
%  EXAMPLE: 
%
%  x = randn(10,1);
%  plot(x);
%  linkdata on
%
%  See also BRUSH.

%  Copyright 2007-2015 The MathWorks, Inc.

if nargin > 0
    arg1 = convertStringsToChars(arg1);
end

if nargin > 1
    arg2 = convertStringsToChars(arg2);
end

if isdeployed
    error(message('MATLAB:linkdata:nodeploy'));
end

if nargin==0
        fig = handle(gcf); % caller did not specify handle
        if nargout == 0
            state = locSetNewBooleanState(fig,'toggle');
        else
            if ~isempty(fig.findprop('LinkPlot'))
                if fig.LinkPlot
                    out = matlab.graphics.internal.LinkData('on');
                else
                    out = matlab.graphics.internal.LinkData('off');
                end
            else
                out = matlab.graphics.internal.LinkData('off');
            end
            return
        end
elseif nargin==1
    if isscalar(arg1) && ishghandle(arg1,'figure')
        fig = handle(arg1);
        if nargout == 0
            state = locSetNewBooleanState(fig,'toggle');
        else
            if ~isempty(fig.findprop('LinkPlot'))
                if fig.LinkPlot
                    out = matlab.graphics.internal.LinkData('on');
                else
                    out = matlab.graphics.internal.LinkData('off');
                end
            else
                 out = matlab.graphics.internal.LinkData('off');
            end
            return
        end     
    elseif ischar(arg1) || isstring(arg1)
        fig = handle(gcf); % caller did not specify handle
        state = locSetNewBooleanState(fig,arg1);
        if nargout > 0
            out = state;
        end
    else
        error(message('MATLAB:linkdata:InvalidSingleArg'));
    end
elseif nargin==2   
    if nargout > 0
        error(message('MATLAB:linkdata:InvalidArgsForOutput'));
    end
    if ~ishghandle(arg1)
        error(message('MATLAB:linkdata:InvalidFigure'));
    end
    fig = handle(arg1);
    state = locSetNewBooleanState(fig,arg2);
end

% There can be latency between closing a figure and java calls
if ~ishghandle(fig) || isempty(get(fig,'Parent'))
    return
end

% Remove any de-linked plots from the LinkPlotManager
h = datamanager.LinkplotManager.getInstance();
brushManager = datamanager.BrushManager.getInstance();
if ~strcmp(state.Enable,'on')
    % Clear brushing on all objects with custom linked behavior
    customLinkedObj = findall(fig,'-and','-not',{'Behavior',struct},'-function',...
        @localHasLinkedBehavior);
    
    [mfile,fcnname] = datamanager.getWorkspace(1);
    for k=1:length(customLinkedObj)
        brushManager.clearLinked(fig,get(fig,'CurrentAxes'),mfile,fcnname);
    end
    
    fig.LinkPlot = false;
    h.rmFigure(handle(fig));
    localSetFigureState(fig,'off');

    return;
end

% Find graphic objects with empty x/y data sources
ls = findobj(fig ,'-property','XDataSource','-property','YDataSource',...
       'XDataSource','','YDataSource','','Visible','on','HandleVisibility','on');
%  Exclude those with non-empty zdatasources
zDataSrcObjects = findobj(ls,'-property','ZDataSource','-function',@(x) ~isempty(x.ZDataSource));
if ~isempty(zDataSrcObjects)    
    ls = setdiff(double(ls),double(zDataSrcObjects));
end
%  Exclude those disabled with behavior objects
lsBehaviorDisabled = findobj(ls,'-and','-not',{'Behavior',struct},'-function',...
       @localHasDisabledLinkedBehavior);

if ~isempty(lsBehaviorDisabled)
    ls = setdiff(ls,lsBehaviorDisabled);
end

showSourceResolutionDlg = false;
wsVars = evalin('caller','whos');
for k=1:length(ls)
    xmatchingVarCount = 0;
    ymatchingVarCount = 0;
    zmatchingVarCount = 0;
    xdataSourceString = '';
    ydataSourceString = '';
    zdataSourceString = '';
    ydata = get(ls(k),'YData_I');
    if ~isempty(findprop(handle(ls(k)),'XDataMode')) && strcmp(get(ls(k),'XDataMode'),'auto')        
        xdata = [];
    else
        xdata = get(ls(k),'XData_I');
    end
    if ~isempty(findprop(handle(ls(k)),'ZData_I')) && ~isempty(get(ls(k),'ZData_I'))
        zdata = get(ls(k),'ZData_I');
    else
        zdata = [];
    end

    xdataSourceArray = {};
    ydataSourceArray = {};
    zdataSourceArray = {};
    
    % Note if the line is in a plotyy axes. If so, don't try to match the
    % xdata to a variable because when the plot is brushed the x,y1, and y2
    % variables will all be brushed with the result that the interaction
    % between brushed variables can produce correct but hard to explain results.
        
    lineIsInPlotYY = false;
    axloc = ancestor(ls(k),'axes');    
    if ~isempty(axloc)
        lineIsInPlotYY = isappdata(axloc,'graphicsPlotyyPeer') && ...
            ishghandle(getappdata(axloc,'graphicsPlotyyPeer'));
    end
    
    for j=1:length(wsVars)
        % Look for match vectors in the current workspace
        varData = [];

        % For xdata, check is wsVars(j) is a matrix with matching column sizes
        % or is a row vector of matching size
        if ~lineIsInPlotYY && ~isempty(xdata) && ...
                (wsVars(j).size(1)==length(xdata) || (length(wsVars(j).size)==2 && ...
                wsVars(j).size(1)==1 && wsVars(j).size(2)==length(xdata)))
             varData = evalin('caller',wsVars(j).name);
             if isTypeSupported(varData) && ndims(varData)<=2
                 if isvector(varData)
                      if isequaln(varData(:),xdata(:))
                          xdataSourceString = wsVars(j).name;
                          xmatchingVarCount = xmatchingVarCount+1;
                          xdataSourceArray{xmatchingVarCount} = xdataSourceString; %#ok<AGROW>
                      end
                 else
                     formatStr = '%s(:,%d)';
                     I = localCompareCols(varData,xdata(:)*ones(1,size(varData,2)));
                     for kk=1:length(I)
                         xdataSourceString = sprintf(formatStr,wsVars(j).name,I(kk));
                         xmatchingVarCount = xmatchingVarCount+1;
                         xdataSourceArray{xmatchingVarCount} = xdataSourceString; %#ok<AGROW>
                     end 
                 end
             end
        end
        if ~isempty(ydata) && (wsVars(j).size(1)==length(ydata) || (length(wsVars(j).size)==2 && ...
                wsVars(j).size(1)==1 && wsVars(j).size(2)==length(ydata)))
             if isempty(varData)
                 varData = evalin('caller',wsVars(j).name);
             end
             if isTypeSupported(varData) && ndims(varData)<=2
                 if isvector(varData)
                      if isequaln(varData(:),ydata(:))
                          ydataSourceString = wsVars(j).name;
                          ymatchingVarCount = ymatchingVarCount+1;
                          ydataSourceArray{ymatchingVarCount} = ydataSourceString; %#ok<AGROW>
                      end
                 else
                     formatStr = '%s(:,%d)';
                     I = localCompareCols(varData,ydata(:)*ones(1,size(varData,2)));
                     for kk=1:length(I)
                         ydataSourceString = sprintf(formatStr,wsVars(j).name,I(kk));
                         ymatchingVarCount = ymatchingVarCount+1;
                         ydataSourceArray{ymatchingVarCount} = ydataSourceString; %#ok<AGROW>
                     end 
                 end
             end
        end
        if isvector(zdata) && (wsVars(j).size(1)==length(zdata) || (length(wsVars(j).size)==2 && ...
                wsVars(j).size(1)==1 && wsVars(j).size(2)==length(zdata)))
             if isempty(varData)
                 varData = evalin('caller',wsVars(j).name);
             end
             if isTypeSupported(varData) && ndims(varData)<=2
                 if isvector(varData)
                      if isequaln(varData(:),zdata(:))
                          zdataSourceString = wsVars(j).name;
                          zmatchingVarCount = zmatchingVarCount+1;
                          zdataSourceArray{zmatchingVarCount} = zdataSourceString; %#ok<AGROW>
                      end
                 else
                     formatStr = '%s(:,%d)';
                     I = find(all(varData-zdata(:)*ones(1,size(varData,2))==0));
                     if ~isempty(I)
                         zdataSourceString = sprintf(formatStr,wsVars(j).name,I(1));
                         zmatchingVarCount = zmatchingVarCount+1;
                         zdataSourceArray{zmatchingVarCount} = zdataSourceString; %#ok<AGROW>
                     end 
                 end
             end

        elseif ~isempty(zdata) && isequal(wsVars(j).size,size(zdata))
             if isempty(varData)
                 varData = evalin('caller',wsVars(j).name);
             end
             if isTypeSupported(varData)  && ndims(varData)<=2
                   if isequaln(varData,zdata)
                       zdataSourceString = wsVars(j).name;
                       zmatchingVarCount = zmatchingVarCount+1;
                       zdataSourceArray{zmatchingVarCount} = zdataSourceString; %#ok<AGROW>
                   end
             end
        end           
    end

    % Update the x/y data source if there is an unambiguous match
    displayName = '';

    
    if zmatchingVarCount==1
        set(ls(k),'ZDataSource_I',zdataSourceString);
        setappdata(double(ls(k)),'ZDataSourceOptions',zdataSourceArray);
        displayName = zdataSourceString;
    elseif zmatchingVarCount>1
        setappdata(double(ls(k)),'ZDataSourceOptions',zdataSourceArray);
        showSourceResolutionDlg = true;
    end
    if ymatchingVarCount==1
        set(ls(k),'YDataSource_I',ydataSourceString);
        setappdata(double(ls(k)),'YDataSourceOptions',ydataSourceArray);
        if ~isempty(displayName)
            displayName = [displayName ' vs. ' ydataSourceString];  %#ok<AGROW>
        else
            displayName = ydataSourceString;
        end      
    elseif ymatchingVarCount>1
        setappdata(double(ls(k)),'YDataSourceOptions',ydataSourceArray);
        showSourceResolutionDlg = true;
    end
    if xmatchingVarCount==1
        set(ls(k),'XDataSource_I',xdataSourceString);
        setappdata(double(ls(k)),'XDataSourceOptions',xdataSourceArray);
        if ~isempty(displayName)
            displayName = [displayName ' vs. ' xdataSourceString];  %#ok<AGROW>
        else
            displayName = xdataSourceString;
        end
    elseif xmatchingVarCount>1
        setappdata(double(ls(k)),'XDataSourceOptions',xdataSourceArray);
        showSourceResolutionDlg = true;
    end
    if ~isempty(displayName) && isempty(get(ls(k),'DisplayName'))
        set(ls(k),'DisplayName',displayName);
    end
end

% If there is no ambiguity, clear Data Source App Data since it will
% not be needed by the disambiguation dialog.
if ~showSourceResolutionDlg
    for k=1:length(ls)
        if isappdata(double(ls(k)),'XDataSourceOptions')
             rmappdata(double(ls(k)),'XDataSourceOptions');
        end
        if isappdata(double(ls(k)),'YDataSourceOptions')
             rmappdata(double(ls(k)),'YDataSourceOptions');
        end
        if isappdata(double(ls(k)),'ZDataSourceOptions')
             rmappdata(double(ls(k)),'ZDataSourceOptions');
        end
    end
end

% Objects with linked data sources must have their DataSourceFcn evaluated
% in order to build any internal state which depends on the current
% DataSource.
customLinkedObj = findall(fig,'-and','-not',{'Behavior',struct},'-function',...
   @localHasLinkedBehavior);

for k=1:length(customLinkedObj)
    try
        linkBehavior = hggetbehavior(customLinkedObj(k),'linked');
        datalen = sum([linkBehavior.UsesXDataSource linkBehavior.UsesYDataSource linkBehavior.UsesZDataSource]);
        data = cell(1,datalen);
        count = 1;
        if linkBehavior.UsesXDataSource
            data{count} = evalin('caller',linkBehavior.XDataSource);
            count = count+1;
        end 
        if linkBehavior.UsesYDataSource
            data{count} = evalin('caller',linkBehavior.YDataSource);
            count = count+1;
        end 
        if linkBehavior.UsesZDataSource
            data{count} = evalin('caller',linkBehavior.ZDataSource);
        end
    catch me
        % If the linked behavior DrawFcn fails (e.g  attempting to link a
        % histogram for a non-vector matrix), abort the linking operation.
        errordlg(me.message, 'MATLAB', 'modal');
        linkdata('off')
        return
    end
end

% If there are ambiguous matches give the user a chance to resolve them
if showSourceResolutionDlg
    datamanager.sourceDialogBuilder(handle(fig),'build',...
        {@localCompleteLinking h fig wsVars},{@localCompleteLinking h fig wsVars});
    return
end

[mfile,fcnname] = datamanager.getWorkspace(1);
localCompleteLinking(h,fig,wsVars,mfile,fcnname);


function result = isTypeSupported(varData)
result =  isnumeric(varData) || isdatetime(varData) || iscalendarduration(varData) || isduration(varData);
    


function localCompleteLinking(h,fig,whoStruc,mfile,fcnname)

fig.LinkPlot = true;

% Register live plot if valid graphics are found
if nargin<=3
    [mfile,fcnname] = datamanager.getWorkspace(1);
end

h.addFigure(handle(fig),mfile,fcnname);

% Synchronize the toolbar button
localSetFigureState(fig,'on');

% Update brushing manager in case some newly linked variables are not
% initialized. This meets the requirement that all linked variables
% have a brushing manager entry.
brushManager = datamanager.BrushManager.getInstance();
brushManager.updateVars(whoStruc,mfile,fcnname);

liveplotbtn = uigettool(fig,'DataManager.Linking');
if ~isempty(liveplotbtn) && ~isempty(getappdata(liveplotbtn,'cursorCacheData'))
     set(double(fig),'Pointer',getappdata(liveplotbtn,'cursorCacheData'));
     setappdata(liveplotbtn,'cursorCacheData',[])
end

function linkState = locSetNewBooleanState(f,state)

if ~ischar(state) && ~isstring(state)
    error(message('MATLAB:linkdata:InvalidState'));
end

% Add LinkPlot property
if isempty(f.findprop('LinkPlot'))
    p = addprop(f,'LinkPlot');
    p.Transient = true;
    % Need to initialize the new LinkPlot property since it is untyped.
    f.LinkPlot = false;
end
switch state
    case 'on'
        boolState = true;
    case 'off'
        boolState = false;
    case 'toggle'
        boolState = ~get(f,'LinkPlot');
    otherwise
        error(message('MATLAB:linkdata:InvalidState'));
end

if ~boolState
    datamanager.clearUndoRedo('include',f);
    linkState = matlab.graphics.internal.LinkData('off');
else
    linkState = matlab.graphics.internal.LinkData('on');
end



function matchingCols = localCompareCols(X,Y)

% Find equal columns with equal NaNs among two matrices 
matchingCols = false(1,size(X,2));
for col=1:size(X,2)
    matchingCols(col) = isequaln(X(:,col),Y(:,col));
end
matchingCols = find(matchingCols);

function localSetFigureState(fig,state)
if strcmp(fig.InPrint, 'off')
   % enable/disable print callback 
   localAdjustPrintCallback(fig, state);
end

liveplotbtn = uigettool(fig,'DataManager.Linking');
if ~isempty(liveplotbtn)
    set(liveplotbtn,'State',state,'Enable','on')
end
liveplotmenu = findall(fig,'tag','figLinked');
if ~isempty(liveplotmenu)
    set(liveplotmenu,'Checked',state);
end

function state = localHasLinkedBehavior(h)

state = false;
bobj = hggetbehavior(h,'linked','-peek');
if isempty(bobj)
   return
end
state = islinked(bobj);

function state = localHasDisabledLinkedBehavior(h)

state = false;
b = hggetbehavior(h,'linked','-peek');
if isempty(b)
    return
end
state = ~b.Enable;

function localAdjustPrintCallback(fig, state)
    % if enabling linkdata, setup print callback to hide link bar 
    % when generating output
    bh = hggetbehavior(fig, 'Print');
    if strcmp(state, 'on')
       set(bh, 'PrePrintCallback', @linkdataPrintCallback);
       set(bh, 'PostPrintCallback', @linkdataPrintCallback);
    else
       set(bh, 'PrePrintCallback', []);
       set(bh, 'PostPrintCallback', []);
    end

function linkdataPrintCallback(H, callbackName)
   if strcmpi('PrePrintCallback', callbackName) 
        com.mathworks.page.datamgr.linkedplots.LinkPlotPanel.setUseAnimation(false)
        linkdata(H, 'off') 
        drawnow        
   else
      linkdata(H, 'on') 
      drawnow 
      com.mathworks.page.datamgr.linkedplots.LinkPlotPanel.setUseAnimation(true)
   end
