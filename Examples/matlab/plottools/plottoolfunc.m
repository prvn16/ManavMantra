function varargout = plottoolfunc (type, varargin)
% This undocumented function may be removed in a future release.
  
% PLOTTOOLFUNC:  Support function for the plot tool

%   Copyright 1984-2015 The MathWorks, Inc.

narginchk(1,inf);

% initialize varargout to something useful
varargout = {};
for i=1:nargout, varargout{i} = []; end %#ok<AGROW>

try
    switch type
        
    %case 'makePolarAxes' - The C++ source code for this is commented
    %    varargout = makePolarAxes (varargin{:});

    case 'plotExpressions'
        plotExpressions (varargin{:});
        
    case 'setSelection'
        setSelection (varargin{:});
        
    case 'prepareAxesForDnD'
        varargout = prepareAxesForDnD (varargin{:});
        
    case 'makeSubplotGrid'
        makeSubplotGrid (varargin{:});
           
    case 'setPropertyValue'
        setPropertyValue (varargin{:});
        
    case 'deleteObjects'
        scribeDeleteObjects(varargin{:});
      
    case 'getBarAreaColor'
        varargout = getBarAreaColor (varargin{:});
        
    case 'getSurfaceColor'
        varargout = getSurfaceColor (varargin{:});      
    
    case 'getHistogramColor'
         varargout = getHistogramColor (varargin{:});
         
    case 'getPatchColor'
         varargout = getPatchColor (varargin{:});
         
    case 'getPlotManager'
        pm = feval(graph2dhelper('getplotmanager'));
        jPlotManager = java (pm);
        varargout =  {jPlotManager};
        
     case 'getNearestKnownParentClass'
        varargout = getNearestKnownParentClass (varargin{:});
                      
    case 'doRefreshData'
        doRefreshData (varargin{:});
                 
    case 'setColormap'
        setColormap (varargin{:});
        
    case 'testColormap'
        varargout = testColormap (varargin{:});
        
    case 'addFigureSelectionManagerListeners'
        doAddFigureSelectionManagerListeners(varargin{:});
        
    case 'retargetSelectionManagerListeners'
        doRetargetSelectionManagerListeners(varargin{:}); 
        
    case 'enablePlotBrowserListeners'
        doEnablePlotBrowserListeners(varargin{:});
        
    case 'preventFigureClose'
         preventFigureClose(varargin{:});
         
    case 'addEventListener'
         varargout{1} = addEventListener(varargin{:});
         
    case 'enableplottoolbutton'
         enablePlotToolButton(varargin{:});
         
    case 'getclientfiguremap'
          varargout{1} = getClientFigureMap;
          
    case 'getFormattedTickLabels'
          varargout{1} = getFormattedTickLabels(varargin{:});
          
    case 'getManualTickLabels'
          varargout{1} = getManualTickLabels(varargin{:});                      
    
    case 'addPropListener'
           varargout{1} = addPropListener(varargin{:});
     
    case 'addNumericRulerListener'
           varargout{1} = addNumericRulerListener(varargin{:});
                         
    case 'getFigureClientProxy'
           varargout{1} = getFigureClientProxy(varargin{:});
           
    end

catch me
    for i=1:nargout, varargout{i} = []; end %#ok<AGROW>
    showErrorDialog(me.message);
end


%% --------------------------------------------
% function out = makePolarAxes (varargin) - - The C++ source code for this is commented
% % Arguments:  none; uses current figure
% axes;
% polar ([0 2*pi], [0 1]);
% % delete (hline);     % This line freezes MATLAB.  TODO: Fix it.
% out = {gca};



%% --------------------------------------------
function setSelection (varargin)
% Arguments:  1. figure handle
%             2. cell array of objects to select
%This function is called from Plot Browser to change object selection.

if isempty (varargin), return, end
fig = varargin{1};
objs = varargin{2};
if ~ishghandle (fig)
     return;
end



if iscell (objs)
    objs = [objs{:}];
end
selectobject (objs, 'replace');

%Make sure we always set current axes. A user may have selected an object
%other than axis and the previous call to selectobject will leave current
%axes unchanged then. Then we get into a situation when a newly selected object
%has current axis that are not his parent axis (a leftover from the
%current axis selection). It will lead to a surprising behaviour if
%subsequent Matlab calls rely on current axis being set properly.
%(see geck 435741, aii)
if ~isempty(objs)
    %If multiple objects are selected pick the last selected object.
    lastSelectedObj=objs(length(objs));
    if ~isgraphics(lastSelectedObj,'axes') && ~isgraphics(lastSelectedObj,'polaraxes')
        anc = ancestor(lastSelectedObj, 'axes');
        if isempty(anc)
            anc = ancestor(lastSelectedObj, 'polaraxes');
        end
        if ~isempty(anc)
            set(fig,'CurrentAxes', anc);
        end
    end
end

function plotExpressions(ax,plotCommand,exprs,args,varargin)
% Arguments:  1. axes handle
%             2. plot command ('bar', 'contour', etc.)
%             3. expressions to plot
%             4. other PV pairs, e.g. 'XDataSource'
%
% Right now, this is used only by the AddDataDialog class.  Therefore,
% 'hold all' is called before the plot is made.

axesHandle = double(ax);
if ~ishghandle(axesHandle)
    showErrorDialog(getString(message('MATLAB:plottools:DlgFirstArgumentToPlotExpressionsMustBeAnAxesHandle')));
    return;
end


%AII g453825. Don't use axes(axesHandle) because it changes Z order of
%plots messing up the original Z order and causing the other plot to be
%hidden behind the first one.
%axes (axesHandle);
fig=ancestor(axesHandle, 'figure');
set(fig, 'CurrentAxes', axesHandle);

evalExprs = {};
try
    for i = 1:length(exprs)
        evalExprs{end+1} = evalin('base', exprs{i}); %#ok<AGROW>
    end
catch ex
    errordlg (getString(message('MATLAB:plottools:DlgPleaseEnterAVariableNameOrAValidMExpression', ex.message)), ...
        getString(message('MATLAB:plottools:DlgUnknownDataSource')));
    return;
end
for i = 1:length(args)
    if (strncmpi (args{i}, 'makedisplaynames', 16) == 1)
        evalExprs{end+1} = evalin('base', args{i}); %#ok<AGROW>
    else        
        evalExprs{end+1} = args{i}; %#ok<AGROW>    
    end
end

axesObject = handle(axesHandle);
if ~isempty(axesObject.Children) || ...
        ~isempty(findobj(ax.Parent,'Tag','Colorbar','-function',@(x) x.Axes==ax))
    % Always use hold when the axes already has children or a colorbar
    holdStatus = ishold(axesObject);
    hold(axesObject,'all');
    feval(plotCommand, evalExprs{:});
    if ~holdStatus
        hold(axesObject,'off');
    end
else % This is a new plot
    % Even though this is a new plot we still need to preserve any
    % previous manual axes settings such as log scales of labels. 
    % Cache any manually modified settings and then restore the cached
    % values after adding the plot.
    
    % Cache axes label state which is not captured by the contents
    % of top level axes properties
    xlabelString = axesObject.XLabel.String;
    ylabelString = axesObject.YLabel.String;
    zlabelString = axesObject.ZLabel.String;
    titleString = axesObject.Title.String;
    
    % Cache all manually modified axes properties
    axC = metaclass(axesObject);
    axProps = axC.Properties;
    I = cellfun(@(x) ~isempty(regexp(x.Name,'Mode\>','once')) && strcmp('public',x.GetAccess),axProps);
    modeProps = axProps(I);
    pvPairs = {};
    for k=1:length(modeProps)
        modePropName = modeProps{k}.Name;
        propName = modePropName(1:end-4);
        propH = axesObject.findprop(propName);
        if ~isempty(propH)           
            if ~propH.Hidden && strcmp('manual',axesObject.(modePropName)) && strcmp('public',propH.GetAccess) && ...
                    strcmp('public',propH.SetAccess)
                pvPairs = [pvPairs {propName,axesObject.(propName)}]; %#ok<AGROW>
            end
        end
    end
    
    % g1531402 - if XDataSource or YDataSource is a row or a col matrix,
    % empty its evalExprs value
    XIndex = find(strcmp(evalExprs,'XDataSource'));
    YIndex = find(strcmp(evalExprs,'YDataSource'));
    evalXData = '';
    evalYData = '';
    if length(evalExprs) > (XIndex)
        evalXData = evalin('base', evalExprs{XIndex+1});
    end            
    if length(evalExprs) > (YIndex)
        evalYData = evalin('base', evalExprs{YIndex+1});
    end
    % If XDataSource is a row or cloumn vector, YDataSource should be a
    % matrix
    if (iscolumn(evalXData) || isrow(evalXData)) && ~(iscolumn(evalYData) || isrow(evalYData))
        evalExprs{XIndex+1} = '';
    end
    % If YDataSource is a row or cloumn vector, XDataSource should be a
    % matrix
    if (iscolumn(evalYData) || isrow(evalYData)) && ~(iscolumn(evalXData) || isrow(evalXData))
        evalExprs{YIndex+1} = '';
    end
    % Add the plot
    feval (plotCommand, evalExprs{:});
    
    % Restore manually modified axes properties. This is used in
    % preference to "hold on" which prevents plotting functions like
    % semilogx from setting axes scales and other properties.
    if ~isempty(pvPairs)
        set(axesObject,pvPairs{:});
    end
    
    % Restore non-empty axes labels
    if ~isempty(xlabelString)
        xlabel(axesObject,xlabelString);
    end
    if ~isempty(ylabelString)
        ylabel(axesObject,ylabelString);
    end        
    if ~isempty(zlabelString)
        zlabel(axesObject,zlabelString);
    end 
    if ~isempty(titleString)
        title(axesObject,titleString);
    end    
end


%% --------------------------------------------
function out = prepareAxesForDnD (figin,pt)
% Arguments:  1. figure handle
%             2. drop point


%g303495 This solves a problem with drag and drop from a Figure Palette.
%Java's SelectionManager.drop() assumed that there is only one figure available
%for DnD (that's how it worked in the old plot tools when figures were just
%standalone floating windows) and acted upon this figure. SelectionManager
%is bound to a figure and DnD functionality doesn't belong there in the first
%place because drop target is not known in advance. If a drop target was
%not the current figure (bound to the SelectionManager) the DnD was
%still performed on the current figure ignoring the actual drop target.
%Now we always obtain figure under the mouse pointer independently of the
%SelectionManager, activate it and make it a drop target.

%NOTE that if HandleVisibility is off for the pointerwindow the call will
%return an empty handle. In this case take whatever SelectionManager 
%gave us for a figure.

% The PointerWindow root property is deprecated for object graphics.
fig = getPointerWindow;
if ~isempty(fig) && ~isequal(0,fig)
    figure(fig);
else
    fig = figin;
end

% Make sure units=pixels, then set it back after the hit test:
oldUnits = get (fig, 'units');
set (fig, 'units', 'pixels');

% The Y axis is reversed, relative to the point Java found:
posn = get (fig, 'position');
pt(2) = posn(4) - pt(2);
% Dropped directly onto an axes. For MCOS graphics we should not use
% hittest because it will call a drawnow under the hood.
axList = findobj(fig,'-regexp','Type','.*axes');
ax = [];
for k=1:length(axList)
    axPos = hgconvertunits(fig,get(axList(k),'Position'),...
        get(axList(k),'Units'),'pixels',fig);
    if axPos(1)<=pt(1) && axPos(1)+axPos(3)>=pt(1) && axPos(2)<=pt(2) && ...
            axPos(2)+axPos(4)>=pt(2)
        ax = axList(k);
        break;
    end
end

set (fig, 'units', oldUnits);
if isempty (ax) 
    if ~isempty (get (fig, 'CurrentAxes'))
        ax = gca;                            % dropped on figure with an existing axes
    else
        ax = addsubplot (fig, 'Bottom');     % dropped on figure with no axes
        set (ax, 'Box', 'on');
    end
end
ispolar = isa(ax,'matlab.graphics.axis.PolarAxes');
set (fig, 'CurrentAxes', ax);
set (ax, 'NextPlot', 'add');
hold(ax,'all');
is3d = ~isequal (get (ax, 'View'), [0 90]);  % see also the function "is2d"
javaAx = java (handle (ax));
out = { javaAx, is3d, ispolar};


%% --------------------------------------------
function makeSubplotGrid (varargin)
% Arguments:  1. figure handle
%             2. width
%             3. height
%             4. cell array of PV pairs, used for each axes created

fig = varargin{1};
if ~ishghandle (fig)
    showErrorDialog (getString(message('MATLAB:plottools:DlgFirstArgumentMustBeAFigureHandle')));
    return;
end
width  = varargin{2};
height = varargin{3};
numPlots = width * height;
existingAxes = findDataAxes (fig);

persistent orderCounter;
if isempty(orderCounter)
    orderCounter=0;
end

% figure out which hierarchy level we're talking about.
% does this need to be within a uipanel? a nested uipanel? the figure?
siblingAxes = existingAxes;
parent = fig;
if ~isempty(existingAxes)
    parent = get (gca, 'Parent');
    ph = handle(parent);
    siblingAxes = findobj(ph.Children,...
         'flat',...
         '-regexp','Type','.*axes', ...
         '-or', '-isa', 'matlab.graphics.chart.Chart', ...
         'handlevisibility', 'on', ...
         '-not','tag','legend','-and','-not','tag','Colorbar');
     
     %g465329, order axis in accordance with their order of creation
     %We cannot rely on findobj() always returning axes in the same order because
     %axes(gca) changes the state of the parent figure including order of children.
     siblingAxes=sortAxesByOrderOfCreation(siblingAxes);
end

% if necessary, delete excess axes
if length(siblingAxes) > numPlots
    % If there are Basic fitting axes put them last on the list so that
    % they are deleted last. This is needed since other (residual) axes are
    % dependent on them and if these axes are deleted the dependent axes will be
    % deleted (g418470).
    if isappdata(fig,'Basic_Fit_Axes_All')
        ind  = ismember(siblingAxes,getappdata(fig,'Basic_Fit_Axes_All'));
        siblingAxes = siblingAxes(:);
        siblingAxes = [siblingAxes(~ind);siblingAxes(ind)];  
    end
    delete (siblingAxes(1 : (length(siblingAxes) - numPlots)));
    % Delete all invalid axes (which may number more than
    % length(siblingAxes) - numPlots if there are deletion listeners, e.g.
    % residual axes in basic fitting
    siblingAxes(~ishghandle(siblingAxes)) = [];
end

% now call "subplot", rearranging existing plots
% (but preserving the parent/child hierarchy of those plots)
for i = 1:numPlots
    if i <= length (siblingAxes)
        ax = siblingAxes(length(siblingAxes) - (i-1));
        % Temporarily turn off colorbar and legend when calling subplot,
        % and then restore them. This works around a limitation of subplot
        % when called with an axes input argument where existing axes are
        % resized ignoring the space occupied by the legend and colorbar
        leg = findall(parent,'Type','legend','-function',@(x) isequal(x.Axes,ax));
        if ~isempty(leg)
            legLocation = leg.Location;
            legPosition = leg.Position;
            legend(ax,'off')
        end
        cb = findall(parent,'Type','colorbar','-function',@(x) isequal(x.Axes,ax));
        if ~isempty(cb)
            cbLocation = cb.Location;
            cbPosition = cb.Position;
            colorbar(ax,'off')
        end
        %charts do not support subplot syntax that passes handles, so swap
        %chart out by creating an empty subplot and replacing.
        if isa(ax,'matlab.graphics.chart.Chart') && ~isa(ax,'matlab.graphics.chart.internal.SubplotPositionableChart')
            ax = insertChartIntoSubplot(ax,height,width,i,parent);
        else
            ax=subplot (height, width, i, ...
                ax, ...
                'Parent', parent);
        end
        if ~isempty(leg)
            leg = legend(ax,'show');
            leg.Location = legLocation;
            if strcmp('none',legLocation)
               leg.Position = legPosition;
            end
        end
        if ~isempty(cb)
            cb = colorbar(ax);
            cb.Location = cbLocation;
            if strcmp('manual',cbLocation)
               cb.Position = cbPosition;
            end
        end
    else
        if (nargin > 3)
            args = varargin{4};
            ax=subplot (height, width, i, args{:}, 'Parent', parent);
        else
            ax=subplot (height, width, i, 'Parent', parent);
        end
    end
    
    if ~isempty(ax) && ~isappdata(ax, 'orderOfCreation')
        setappdata(ax, 'orderOfCreation', orderCounter);
        orderCounter=orderCounter+1;
    end
        
end


% Use orderOfCreation indices in appdata to order axesArray. 
%
% Returns the axes sorted with oldest (lowest orderOfCreation) last. 
% Axes without orderOfCreation are placed before other Axes.
function sortedAxes=sortAxesByOrderOfCreation(axesArray)

nAxes=length(axesArray);
 
if nAxes==0
    return;
end

creationStamps = inf(1,nAxes);

%put order value in a separate array for further sorting
%order values are always unique
for i=1:nAxes
    ax=axesArray(i);
    if isappdata(ax,'orderOfCreation')
        order=getappdata(ax,'orderOfCreation');
        if ~isempty(order)
            creationStamps(i) = order;
        end
    end
end

[~,indicesOfSortedStamps] = sort(creationStamps,'descend');

sortedAxes = axesArray(indicesOfSortedStamps);


%% --------------------------------------------
function setPropertyValue (varargin)
% Arguments:  1. array of objects
%             2. property name
%             3. new property value
objs = varargin{1};
propname = varargin{2};
propval = varargin{3};
if iscell (objs)
    objs = [objs{:}];
end
objs(~ishghandle(objs)) = [];
set (objs, propname, propval);


%% --------------------------------------------
% deleteObjects (causes a bug with undo/redo g455311 ) was deprecated and 
% replaced by scribeDeleteObjects() instead. 
function scribeDeleteObjects(varargin)

hFig=varargin{1};
if (isempty(hFig) || ~ishghandle(hFig) || (~isa(handle(hFig),'hg.figure') && ...
        ~isa(handle(hFig),'matlab.ui.Figure')))
    return;
end
scribeccp(hFig, 'Delete');

function out = getPatchColor (varargin)

h = varargin{1};
if ~ishghandle(h)
    showErrorDialog (getString(message('MATLAB:plottools:DlgFirstArgumentToGetBarAreaColorMustBeAFigureHandle')));
    return;
end
color = get (h,'FaceColor'); 
if ischar(color) 
    fig = ancestor(h,'figure'); 
    ax = ancestor(h,'axes');
    if isempty(ax)
        ax = ancestor(h,'polaraxes');
    end
    cmap = get(handle(fig),'Colormap');
    clim = get(handle(ax),'CLim'); 
    if ishghandle(h,'patch')
        fvdata = get(h,'FaceVertexCData'); 
    else
        fvdata = get(h.Children(1),'FaceVertexCData'); 
    end
    if size(fvdata,2)==1 && (size(fvdata,1)==size(h.Faces,1) || size(fvdata,1)==size(h.Vertices,1))
        seriesnum = mean(fvdata);
        if strcmp(h.CDataMapping,'scaled')
            color = (seriesnum-clim(1))/(clim(2)-clim(1));
            ind = max(1,min(size(cmap,1),floor(1+color*size(cmap,1))));
        else
            ind = floor(max(1,min(size(cmap,1),seriesnum)));
        end
        color = cmap(ind,:);
    else %trucolor
        color = mean(fvdata,1);       
    end

end 
out = {color};


function out = getBarAreaColor (varargin)
% Arguments:  1. barseries or areaseries
h = varargin{1};
if ~ishghandle(h)
    showErrorDialog (getString(message('MATLAB:plottools:DlgFirstArgumentToGetBarAreaColorMustBeAFigureHandle')));
    return;
end
color = get (h,'FaceColor'); 
if ischar(color) 
    % For barseries/areaseries, the actual color is defined
    % in the Face. From Geometry.xml the ColorData type is:
    % ColorData property: truecolor = uint8 4xn, colormapped = float
    % vector
    drawnow update % Make sure h.Face is up to date
    % If the surface is invisible then set the icon 
    % color to the color of the axes.
    if isempty(h.Face) || strcmp(h.Visible,'off') || ...
        size(h.Face.ColorData,1)<3 || strcmp(h.Face.ColorBinding,'none')
        % Use background for no color, Colormapped, or Texturemapped
        ax = ancestor(h,'axes');
        if isempty(ax)
            ax = ancestor(h,'polaraxes');
        end
        color = hgcastvalue('matlab.graphics.datatype.MeshColor',ax.Color);
    else
        % TrueColor 
        color = (mean(h.Face.ColorData(1:3,:),2)')/256;
    end
end 
out = {color};


function out = getSurfaceColor (varargin)

% Logic for surface is the same as bar and area
out = getBarAreaColor (varargin{:});


function out = getHistogramColor(h, propName)
% Arguments:  1. Histogram, 2. Color poperty name
if ~ishghandle(h)
    showErrorDialog (getString(message('MATLAB:plottools:DlgFirstArgumentToGetBarAreaColorMustBeAFigureHandle')));
    return;
end
color = h.(propName); 
if ischar(color) 
     if strcmp(color,'auto') 
        drawnow update % Make sure primitive is up to date
        color = hgcastvalue('matlab.graphics.datatype.MeshColor',h.AutoColor);
     elseif strcmp(color,'none') 
         color = [1 1 1];
     end
elseif ischar(color)
    color = hgcastvalue('matlab.graphics.datatype.MeshColor',color);
end 
out = {color};

%% --------------------------------------------
function out = getNearestKnownParentClass (varargin)
% Arguments:  1. MATLAB object for which to find the parent class
knownClasses = {'figure', 'axes', 'graph2d.lineseries', ...
                'specgraph.barseries', 'specgraph.stemseries', ...
                'specgraph.areaseries', 'specgraph.errorbarseries', ...
                'specgraph.scattergroup', 'specgraph.contourgroup', ...
                'specgraph.quivergroup', 'graph3d.surfaceplot', ...
                'image', 'uipanel', 'uicontrol,' ...
                'scribe.line', 'scribe.arrow', 'scribe.doublearrow', ...
                'scribe.textarrow', 'scribe.textbox', 'scribe.scriberect', ...
                'scribe.scribeellipse', ...
                'line', 'text', 'rectangle', 'patch', 'surface','matlab.ui.container.Panel'};
obj = varargin{1};
out = {''};
for i = 1:length(knownClasses)
    if isa (handle(obj), knownClasses{i})
        out = knownClasses(i);
        return;
    end
end


%% --------------------------------------------
function doRefreshData (varargin)
% Arguments:  1. array of objects to refreshdata
objs = varargin{1};
if iscell (objs)
    objs = [objs{:}];
end
objs(~ishghandle(objs)) = [];
refreshdata (objs);


%% --------------------------------------------
function setColormap (varargin)
% Arguments:  1. figure
%             2. colormap name
objs = varargin{1};
if iscell (objs)
    objs = [objs{:}];
end
objs(~ishghandle(objs)) = [];
cmapName = varargin{2};
cmapSize = size(get(objs,'Colormap'),1);
cmap = feval(lower(cmapName), cmapSize);
set(objs,'Colormap',cmap);


%% --------------------------------------------
function out = testColormap (varargin)
% Arguments:  1. colormap, (an array, not a string)
cmap = (varargin{1});
if numel(cmap)<=3
    cmapToTest = cmap(:)';
    colormapLength = 1;
else
    cmapToTest = reshape(cmap, length(cmap)/3, 3);
    colormapLength = length(cmapToTest);
end

% Test preferred colormaps first (if any)
colormapName = '';
if nargin>=2 && ~isempty(varargin{2})
    preferredColormap = varargin{2};
    if isequal(cmapToTest, feval(preferredColormap, colormapLength))
        colormapName = preferredColormap;
    end
end

if isempty(colormapName)
    known_colormaps = {'parula','jet', 'hsv', 'hot', 'gray', 'bone', 'copper', 'pink', 'lines',  'cool', 'autumn', 'spring', 'winter', 'summer'};
    for n = 1:length(known_colormaps)
        if isequal(cmapToTest, feval(known_colormaps{n}, colormapLength))
            colormapName = known_colormaps{n};
            break;
        end
    end
end
out = {colormapName};


%% --------------------------------------------
function showErrorDialog (errmsg,varargin)
% Arguments:  1. string containing details about the error

if ~isempty(varargin)
    details = varargin{1};
    errordlg (sprintf ('%s\n\n%s', errmsg, details), getString(message('MATLAB:plottools:DlgMATLABError')));
else
    errordlg (sprintf ('%s', errmsg), getString(message('MATLAB:plottools:DlgMATLABError')));
end

%% --------------------------------------------
function h = getPointerWindow
pointerLocation = get(0,'PointerLocation'); 
figs = allchild(0); 
h = []; 
for n = 1:numel(figs)
    figPos = get(figs(n),'Position');
    if (pointerLocation(1) >= figPos(1)) && (pointerLocation(1) <= figPos(1) + figPos(3)) && ...
            (pointerLocation(2) >= figPos(2)) && (pointerLocation(2) <= figPos(2) + figPos(4))
        h = figs(n);
        return;
    end
end

%% --------------------------------------------
function preventFigureClose(state,fig)

% Function used by WaitBar to suppress closing of figures or Figures group
% when Plot Tools is initialized for the first time.

if strcmp(state,'set') % Prevent figure closing
    setappdata(fig,'PlotToolsCachedCloseReqFcn',get(fig,'CloseRequestFcn'));
    set(fig,'CloseRequestFcn','');
elseif strcmp(state,'restore') % Restore figure closing.
    if nargin<=1 || ~ishghandle(fig)
        fig = get(0,'CurrentFigure');
    end
    if isappdata(fig,'PlotToolsCachedCloseReqFcn')
        set(fig,'CloseRequestFcn',getappdata(fig,'PlotToolsCachedCloseReqFcn'));
        rmappdata(fig,'PlotToolsCachedCloseReqFcn')
    end
end

function enablePlotToolButton(fig, state)

onBtn  = uigettool (fig, 'Plottools.PlottoolsOn');
offBtn = uigettool (fig, 'Plottools.PlottoolsOff');
if state
    set (onBtn, 'enable', 'on');
    set (offBtn, 'enable', 'off' );
else
    set (onBtn, 'enable', 'off');
    set (offBtn, 'enable', 'on' );
end

function figureClientProxy = getFigureClientProxy(fig)

jp = javaGetFigureFrame(fig);
figureClientProxy = [];
ac = jp.getAxisComponent;
while ~isempty(ac)
    if isa(ac,'com.mathworks.hg.peer.FigureClientProxy$FigureDTClientBase')
        figureClientProxy = ac;
        return
    else
        ac = ac.getParent;
    end
end

function map = getClientFigureMap

% Return a java HashMap representing the relationship between dtclients and
% figures.
map = java.util.HashMap;
ch = allchild(groot);
for i =1:length(ch)
    % Note that fig may have been deleted during the drawnow
    if isvalid(ch(i)) && strcmp(ch(i).BeingDeleted,'off')
        fig = ch(i);
        jp = javaGetFigureFrame(fig);
        drawnow;
        
        % Note that fig may have been deleted during the drawnow
        if isempty(jp) || ~isvalid(fig)
            continue;
        end
        
        % Find FigureDTClientBase
        ac = jp.getAxisComponent;
        while ~isempty(ac)
            if isa(ac,'com.mathworks.hg.peer.FigureClientProxy$FigureDTClientBase')
                map.put(ac,fig);
                ac = []; % Stop looping
            else
                ac = ac.getParent;
            end
        end
    end
end
    
function l = addEventListener(obj,eventType,callback)

l = event.listener(obj,eventType,@(e,d) callback.run); 


function l = addPropListener(obj,propType,callback)
l = event.proplistener(obj,findprop(obj,propType),'PostSet', @(e,d) callback.run); 

function labels = getFormattedTickLabels(ruler,values)

% Use the axes ruler format string to format the tick labels based on the 
% ruler TickLabelFormat
labels = cellfun(@(x) sprintf(ruler.TickLabelFormat,x),values,...
    'UniformOutput',false);

function labels = getManualTickLabels(ax,axisProperty)

labels = get(ax,axisProperty);
% Convert nx1 char arrays to a cell array so that it is not confused 
% with a string when passed to java via the JMI
if ischar(labels) 
    if size(labels,1)>1
       labels = cellstr(labels)';
    else
       labels = {labels}; 
    end
end

function newax = insertChartIntoSubplot(ax,height,width,i,parent)
ax.Parent = [];
%create subplot
a = axes('Parent',[]);
tempAx = subplot (height, width, i, a, ...
    'Parent', parent);
drawnow;
%swap chart into subplot grid
newax = matlab.graphics.internal.swapaxes(tempAx,@(varargin)setPropsOnChart(ax,varargin{:}),true);

%helper for using swapaxes to replace an axes with an existing chart 
function newchart = setPropsOnChart(newchart, varargin)
set(newchart,varargin{:});
    
        
        
     

