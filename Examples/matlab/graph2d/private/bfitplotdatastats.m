function bfitplotdatastats(datahandle,stattype,dataselect,checkon)
% BFITPLOTDATASTATS Plot data statistics line for the Data Statistics GUI.

%   Copyright 1984-2014 The MathWorks, Inc.

% get data
xdata = double(get(datahandle,'xdata'));
ydata = double(get(datahandle,'ydata'));
axesH = ancestor(datahandle,'axes'); % need this in case subplots in figure
figH = ancestor(axesH,'figure');
xlims = get(axesH,'xlim');
ylims = get(axesH,'ylim');

bfitlistenoff(figH)
set(axesH,'xlimmode','manual');
set(axesH,'ylimmode','manual');

if isequal(dataselect,'x') % x-data selected
    xon = 1;
    data = xdata;
elseif isequal(dataselect,'y') % y-data selected
    xon = 0;
    data = ydata;
else
    error(message('MATLAB:bfitplotdatastats:DataSelectInvalidValue', dataselect))
end

appdatanameH = ['Data_Stats_',upper(dataselect),'_Handles'];
appdatanameShow = ['Data_Stats_',upper(dataselect),'_Showing'];
% get handles
stathandles = double(getappdata(double(datahandle),appdatanameH));
statshowing = getappdata(double(datahandle),appdatanameShow);

% The order is important
ind = find(strcmp(stattype,{'min','max','mean','median','mode','std','range'}));

if checkon
    % save hold and units state and set it
    fignextplot = get(figH,'nextplot');
    axesnextplot = get(axesH,'nextplot');
    axesunits = get(axesH,'units');
    set(figH,'nextplot','add');
    set(axesH,'nextplot','add');
    set(axesH,'units','normalized');
    
    tagname = [stattype,' ',dataselect];
    % compute stats
    switch stattype
    case 'max'
        dataresults = max(data);
        color = [0 0 1];        % blue
    case 'min'
        dataresults = min(data);
        color = [0 0.75 0.75];  % darker cyan
    case 'median'
        dataresults = median(data);
        color = [1 0 0];        % red
    case 'mean'
        dataresults = mean(data);
        color = [0 0.5 0];      % darker green
    case 'mode'
        dataresults = mode(data);
        color = [0 0 .6];      % darker blue
    case 'std'
        meandata = mean(data);
        stddata = std(data); 
        dataresults = [meandata - stddata, meandata + stddata;];
        color = [0.75 0 0.75];  % darker magenta
    otherwise
        error(message('MATLAB:bfitplotdatastats:InvalidStatType', stattype));
    end
    if xon
        linetype = '--';
    else
        linetype = '-.';
    end
    % plot line representing the statistic
    
    [~,hParent] = matlab.graphics.internal.plottools.getDataSpaceForChild(handle(datahandle));
    
    if xon
        stath = verticalline(dataresults,'linestyle',linetype, ...
            'Tag', tagname,...
            'color',color,'parent',hParent);
    else
        stath = horizontalline(dataresults,'linestyle',linetype, ...
            'Tag', tagname, ...
            'color',color,'parent',hParent);
    end

    bfitlisten(stath,1); %We need to add object being destroyed listener to this
        
    % code generation for plot line
    b = hggetbehavior(stath,'MCodeGeneration');
    
    % Typecasting to a handle as datahandle is a double. Set
    % MCodeIgnoreHandleFcn to false since ConstantLine has an
    % implementation for mcodeIgnoreHandle.
    set(b,'MCodeConstructorFcn',{@bfitMCodeConstructor, 'stat', handle(datahandle), [], stattype, xon},'MCodeIgnoreHandleFcn', 'false');

    stath = double(stath);
    x = get(stath,'xdata');
    y = get(stath,'ydata');
    if iscell(x)
        x = [x{:}]; 
        y = [y{:}];
    end
    adjustaxes(axesH,x,y,xlims,ylims,xon);
    if xon
        statappdata.type = 'stat x';
    else
        statappdata.type = 'stat y';
    end
    statappdata.index = ind;
    setappdata(double(stath),'bfit',statappdata);
    setappdata(double(stath), 'Basic_Fit_Copy_Flag',1);
   
    showing = true;

    % reset plot: hold and units
    set(figH,'nextplot',fignextplot);
    set(axesH,'nextplot',axesnextplot);
    set(axesH,'units',axesunits);
    
else % check off
	if ishghandle(stathandles(ind))
		delete(stathandles(ind));
		stath = Inf;
		showing = false;
	else % invalid handle, which can happen due to timing of clicking.
		% return so we don't reset appdata below
        bfitlistenon(figH)
		return;
	end
end

stathandles(ind) = stath;
statshowing(ind) = showing;
setgraphicappdata(double(datahandle),appdatanameH,stathandles);
setappdata(double(datahandle),appdatanameShow,statshowing);

bfitcreatelegend(axesH);
bfitlistenon(figH);

%-----------------------------------------------------------------
function adjustaxes(axesH,x,y,xlims,ylims,xon)
% ADJUSTAXES Adjust axes when lines are plotted very near axes limits.

if xon
    dmin = min(x);
    dmax = max(x);
    amin = xlims(1);
    amax = xlims(2);
else
    dmin = min(y);
    dmax = max(y);
    amin = ylims(1);
    amax = ylims(2);
end

if dmin <= (amin + ((amax-amin)/100))
    newamin = amin - (amax-amin)/100;
else
    newamin = amin;
end
if dmax >= (amax - ((amax-amin)/100))
    newamax = amax + (amax-amin)/100;
else
    newamax = amax;
end

if xon
    set(axesH,'xlim',[newamin newamax]);
else
    set(axesH,'ylim',[newamin newamax]);
end

