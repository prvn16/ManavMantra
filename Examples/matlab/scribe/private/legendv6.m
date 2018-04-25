function [leghandle,labelhandles,outH,outM]=legendv6(varargin)
%LEGENDV6 Graph legend compatible with MATLAB 6.
%   LEGENDV6(string1,string2,string3, ...) puts a legend on the current plot
%   using the specified strings as labels. LEGENDV6 works on line graphs,
%   bar graphs, pie graphs, ribbon plots, etc.  You can label any
%   solid-colored patch or surface object.  The fontsize and fontname for
%   the legend strings matches the axes fontsize and fontname.
%
%   LEGENDV6(H,string1,string2,string3, ...) puts a legend on the plot
%   containing the handles in the vector H using the specified strings as
%   labels for the corresponding handles.
%
%   LEGENDV6(M), where M is a string matrix or cell array of strings, and
%   LEGENDV6(H,M) where H is a vector of handles to lines and patches also
%   works.
%
%   LEGENDV6(AX,...) puts a legend on the axes with handle AX.
%
%   LEGENDV6 OFF removes the legend from the current axes.
%   LEGENDV6(AX,'off') removes the legend from the axis AX.
%
%   LEGENDV6 HIDE makes legend invisible.
%   LEGENDV6(AX,'hide') makes legend on axis AX invisible.
%   LEGENDV6 SHOW makes legend visible.
%   LEGENDV6(AX,'show') makes legend on axis AX visible.
%
%   LEGENDV6 BOXOFF sets appdata property legendboxon to 'off' making
%   legend background box invisible when the legend is visible.
%   LEGENDV6(AX,'boxoff') sets appdata property legendboxon to 'off for axis AX
%   making legend background box invisible when the legend is visible.
%   LEGENDV6 BOXON sets appdata property legendboxon to 'on' making
%   legend background box visible when the legend is visible.
%   LEGENDV6(AX,'boxon') sets appdata property legendboxon to 'off for axis AX
%   making legend background box visible when the legend is visible.
%
%   LEGH = LEGENDV6 returns the handle to legend on the current axes or
%   empty if none exists.
%
%   LEGENDV6 with no arguments refreshes all the legends in the current
%   figure (if any).  LEGENDV6(LEGH) refreshes the specified legend.
%
%   LEGENDV6(...,Pos) places the legend in the specified
%   location:
%       0 = Automatic "best" placement (least conflict with data)
%       1 = Upper right-hand corner (default)
%       2 = Upper left-hand corner
%       3 = Lower left-hand corner
%       4 = Lower right-hand corner
%      -1 = To the right of the plot
%
%   To move the legend, press the left mouse button on the legend and drag
%   to the desired location. Double clicking on a label allows you to edit
%   the label.
%
%   [LEGH,OBJH,OUTH,OUTM] = LEGENDV6(...) returns a handle LEGH to the
%   legend axes; a vector OBJH containing handles for the text, lines,
%   and patches in the legend; a vector OUTH of handles to the
%   lines and patches in the plot; and a cell array OUTM containing
%   the text in the legend.
%
%   LEGENDV6 will try to install a ResizeFcn on the figure if it hasn't been
%   defined before.  This resize function will try to keep the legend the
%   same size.
%
%   Examples:
%       x = 0:.2:12;
%       plot(x,besselj(1,x),x,besselj(2,x),x,besselj(3,x));
%       legend('First','Second','Third');
%       legend('First','Second','Third',-1)
%
%       b = bar(rand(10,5),'stacked'); colormap(summer); hold on
%       x = plot(1:10,5*rand(10,1),'marker','square','markersize',12,...
%                'markeredgecolor','y','markerfacecolor',[.6 0 .6],...
%                'linestyle','-','color','r','linewidth',2); hold off
%       legend([b,x],'Carrots','Peas','Peppers','Green Beans',...
%                 'Cucumbers','Eggplant')       
%
%   See also PLOT.

%   Copyright 1984-2017 The MathWorks, Inc.

%   Private syntax:
%
%     LEGEND('DeleteLegend') is called from the deleteFcn to remove the legend.
%     LEGEND('EditLegend',h) is called from MOVEAXIS to edit the legend labels.
%     LEGEND('ShowLegendPlot',h) is called from MOVEAXIS to set the gco to
%        the plot the legend goes with.
%     LEGEND('ResizeLegend') is called from the resizeFcn to resize the legend.
%     LEGEND('RestoreSize',hLegend)  restores the legend to the size it was before
%                            a positionmode of -1 altered it.
%     LEGEND('RecordSize',hPlot)     sets the current size of the plot as the size
%                            to which it will be restored.
%
%   Obsolete syntax:
%
%     LEGENDV6(linetype1,string1,linetype2,string2, ...) specifies
%     the line types/colors for each label.
%     Linetypes can be any valid PLOT linetype specifying color,
%     marker type, and linestyle, such as 'g:o'.  

narg = nargin;
isresize(0);

%--------------------------
% Parse inputs
%--------------------------

% Determine the legend parent axes (ha) is specified
if narg > 0 && ~isempty(varargin{1}) && ishandle(varargin{1}) && ...
        strcmp(get(varargin{1}(1),'type'),'axes') % legend(ax,...)
    ha = varargin{1}(1);
    varargin(1) = []; % Remove from list
    narg = narg - 1;
    if islegend(ha) % Use the parent
        ud = get(ha,'userdata');
        if isfield(ud,'PlotHandle')
            ha = ud.PlotHandle;
        else
            warning(message('MATLAB:legendv6:NoLegendOnLegend'));
            if nargout>0, leghandle=[]; labelhandles=[]; outH=[]; outM=[]; end
            return
        end
    end
else
    ha = [];
end

if narg==0 % legend
    if nargout==1  % h = legend
        if isempty(ha)
            leghandle = find_legend(find_gca);
        else
            leghandle = find_legend(ha);
        end
    elseif nargout==0 % legend
        if isempty(ha)
            update_all_legends
        else
            update_legend(find_legend(ha));
        end
    else % [h,objh,...] = legend
        if isempty(ha)
            [leghandle,labelhandles,outH,outM] = find_legend(find_gca);
        else
            [leghandle,labelhandles,outH,outM] = find_legend(ha);
        end
        if nargout>3 && ischar(outM), outM = cellstr(outM); end
    end
    return
    
elseif narg==1 && strcmp(varargin{1},'DeleteLegend')  % legend('DeleteLegend')
    % Should only be called by the deleteFcn
    cbo = gcbo;
    if strcmp(get(gcbo,'BeingDeleted'),'on'), return, end
    % If called from DeleteProxy, delete the legend axes
    if strcmp(get(cbo,'tag'),'LegendDeleteProxy') 
        ax = get(cbo,'userdata');
        if ishandle(ax)
            ud = get(ax,'userdata');
            % Do a sanity check before deleting legend
            if isfield(ud,'DeleteProxy') && ...
                    isequal(ud.DeleteProxy,cbo) && ...
                    ishandle(ax)
                delete(ax);
            end
        end
    else
        delete_legend(cbo)
    end
    if nargout>0, error(message('MATLAB:legendv6:TooManyOutputs')); end
    return
    
elseif narg==1 && strcmp(varargin{1},'ResizeLegend')  % legend('ResizeLegend')
    % Obtain figure handle from gcbf
    isresize(1);
    resize_all_legends(gcbf)
    isresize(0);
    if nargout>0, error(message('MATLAB:legendv6:TooManyOutputs')); end
    return
    
elseif narg==2 && strcmp(varargin{1},'ResizeLegend') % legend('ResizeLegend',fig_handle)
    h=varargin{2};
    if islegend(h)
        resize_legend(h);
    else
        % Explicitly passing the figure handle
        isresize(1);
        resize_all_legends(varargin{2})
        isresize(0);
        if nargout>0
            error(message('MATLAB:legendv6:TooManyOutputs'));
        end
    end
    return;
    
    % Legend off
elseif narg==1 && strcmp(varargin{1},'off')  % legend('off') or legend(AX,'off')
    if isempty(ha)
        delete_legend(find_legend(find_gca))
    else
        delete_legend(find_legend(ha))
    end   
    if nargout>0, error(message('MATLAB:legendv6:TooManyOutputs')); end
    return
    
    % Legend hide or legend(ax,'hide')
elseif narg==1 && strcmp(varargin{1},'hide')
    if isempty(ha)
        leg = find_legend(find_gca);
    else
        leg = find_legend(ha);
    end
    
    % if legend axes are already invisible but 
    % some of it's children are visible
    % then make children invisible
    if strcmp(get(leg,'visible'),'off')
        legch = get(leg,'children');
        if any(strcmp(get(legch,'visible'),'on'))
            set(legch,'visible','off');
        end
    else
        set(leg,'visible','off')
    end
    
    return
    
    % Legend show or legend(ax,'show')
elseif narg==1 && strcmp(varargin{1},'show')
    if isempty(ha)
        leg = find_legend(find_gca);
    else
        leg = find_legend(ha);
    end
    
    legch = get(leg,'children');
    
    % get legendboxon from appdata if there, otherwise it's on.
    if isappdata(leg,'legendboxon')
        legboxon = getappdata(leg,'legendboxon');
    else 
        legboxon = 'on';
    end
    
    % set legend axes visibility 
    if strcmp(legboxon,'on')
        set(leg,'visible','on');
    else
        set(leg,'visible','off');
    end
    % make sure children are visible
    set(legch,'visible','on');
    
    return
    
    % Legend boxoff or legend(ax,'boxoff')
elseif narg==1 && strcmp(varargin{1},'boxoff')
    if isempty(ha)
        leg = find_legend(find_gca);
    else
        leg = find_legend(ha);
    end
    % set legendboxon appdata to off
    setappdata(leg,'legendboxon','off');
    
    legch = get(leg,'children');
    
    % check for legend hidden
    if strcmp(get(leg,'visible'),'off') && ...
            ~any(strcmp(get(legch,'visible'),'on'))
        return
    else
        % make legend axis invisible
        set(leg,'visible','off');
        % make children visible
        set(legch,'visible','on');
    end
    
    return
    
    % Legend boxon or legend(ax,'boxon')
elseif narg==1 && strcmp(varargin{1},'boxon')
    if isempty(ha)
        leg = find_legend(find_gca);
    else
        leg = find_legend(ha);
    end
    
    % set legendboxon appdata to off
    setappdata(leg,'legendboxon','on');
    
    legch = get(leg,'children');
    
    % check for legend hidden
    if strcmp(get(leg,'visible'),'off') && ...
            ~any(strcmp(get(legch,'visible'),'on'))
        return
    else
        % make legend axis visible
        set(leg,'visible','on');
        % make sure children are visible
        set(legch,'visible','on');
    end
    
    return
    
elseif narg==2 && strcmp(varargin{1},'ShowLegendPlot')
    show_plot(varargin{2})
    return
    
elseif narg==2 && strcmp(varargin{1},'EditLegend')
    edit_legend(varargin{2})
    return
    
elseif narg==1 && islegend(varargin{1}) % legend(legh)
    [hl,labelhandles,outH,outM] = update_legend(varargin{1});
    if nargout>0, leghandle = hl; end
    if nargout>3 && ischar(outM), outM = cellstr(outM); end
    return
    
elseif narg==2 && strcmp(varargin{1},'RestoreSize')
    restore_size(varargin{2});
    return
    
elseif narg==2 && strcmp(varargin{1},'RecordSize')
    record_size(varargin{2});
    return;
    
    % elseif narg==1 & iscell(varargin) & ~iscellstr(varargin{1}) & ischar(varargin{1})
    %     error('MATLAB:legendv6:UnknownUsage','Unknown usage.');
    %     return;
end


% Look for legendpos code
if isa(varargin{end},'double')
    legendpos = varargin{end};
    varargin(end) = [];
else
    legendpos = [];
end

% Determine the active children (kids) and the strings (lstrings)
if narg < 1
    error(message('MATLAB:legendv6:TooFewInputs'));
elseif ishandle(varargin{1}) % legend(h,strings,...)
    kids = varargin{1};
    if isempty(ha)
        ha=get(varargin{1}(1),'Parent');
        if ~strcmp(get(ha,'type'),'axes')
            error(message('MATLAB:legendv6:HandleMustBeAxesOrAxesChild'));
        end
    end
    if narg==1, error(message('MATLAB:legendv6:StringRequiredPerHandle')); end
    lstrings = getstrings(varargin(2:end));
else % legend(strings,...) or legend(linetype,string,...)
    if isempty(ha), ha=find_gca; end
    kids = getchildren(ha);
    lstrings = getstrings(varargin);
end

% Set default legendpos
if isempty(legendpos)
    if ~isequal(get(ha,'view'),[0 90])
        legendpos = -1;  % To the right of axis is default for 3-D
    else
        legendpos = 1;   % Upper right is default for 2-D
    end
end

% Remove any existing legend on this plot 
if isempty(ha)
    hl = find_legend;
else
    hl = find_legend(ha);
end
if ~isempty(hl)
    ud = get(hl,{'userdata'});
    for i=1:length(ud)
        if isfield(ud{i},'PlotHandle') && ud{i}.PlotHandle == ha
            %expandplot(ha,ud{i},legendpos)
            delete_legend(hl)
        end
    end
end

if isempty(kids)
    warning(message('MATLAB:legendv6:PlotEmpty'))
    if nargout>0
        leghandle = []; labelhandles = []; outH = []; outM = [];
    end
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% make_legend
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[hl,labelhandles] = make_legend(ha,kids,lstrings,legendpos);

if nargout > 0, leghandle=hl; end
if nargout > 2, outH = kids; end
if nargout > 3
    if ischar(lstrings), lstrings = cellstr(lstrings); end
    outM = lstrings;
end


%--------------------------------
function [hl,hobjs,outH,outM] = find_legend(ha)
%FIND_LEGEND Return current legend handle or error out if none.
if nargin==0
    hFig=find_gcf;
else
    hFig=find_gcf(ha);
end

hAx = findobj(hFig,'type','axes');
hl=[];
for i=1:length(hAx)
    if islegend(hAx(i))
        hl(end+1)=hAx(i);        
    end
end
hobjs = [];

if nargin>0 && strcmp(get(ha,'type'),'axes')
    if length(ha)~=1
        error(message('MATLAB:legendv6:AxesHandleRequired'));
    end
    ud = get(hl,{'userdata'});
    for i=1:length(ud)
        if isfield(ud{i},'PlotHandle') && ud{i}.PlotHandle == ha
            hl = hl(i);
            udi = ud{i};
            hobjs = udi.LabelHandles;
            outH  = udi.handles;
            outM  = udi.lstrings;
            return
        end
    end
    hl = []; % None found
    hobjs = [];
    outH = [];
    outM = [];
end

%-------------------------------
function tf = isresize(setting)
persistent s
if nargin==1
    s = setting;
end
if nargout==1
    tf = s;
end

%--------------------------------
function hf = find_gcf(ha)
%FIND_GCF Find gcf.
%   FIND_GCF Returns the callback figure if there is one otherwise
%   it returns the current figure.
if nargin==1 && strcmp(get(ha,'type'),'axes')
    hf = get(ha,'parent');
else
    if isresize
        hf = gcbf;
        if isempty(hf)
            hf = gcf;
        end
    else
        hf = gcf;
    end 
end

%---------------------------------
function ha = find_gca(ha)
%FIND_GCA Find gca (skipping legend)
if nargin==0
    fig = find_gcf;
else
    fig = find_gcf(ha);
end
ha = get(fig,'currentaxes');
if isempty(ha), ha = gca; end
if islegend(ha)
    ud = get(ha,'userdata');
    if isfield(ud,'PlotHandle')
        ha = ud.PlotHandle;
        % Make sure legend isn't isn't the gca
        set(fig,'currentaxes',ud.PlotHandle)
    end
end

%-------------------------------
function [hl,labelhandles] = make_legend(ha,Kids,lstrings,legendpos,ud,resize)
%MAKE_LEGEND Make legend given parent axes, kids, and strings
%
%   MAKE_LEGEND(...,ud) is called from the resizeFcn.  In this case
%   just update the position of the legend pieces instead of recreating
%   it from scratch.

ud.PlotHandle = ha;
hf = get(ha,'parent'); % Parent figure
doresize = 0;
if nargin>=6 && isequal(resize,'resize'), doresize = 1; end

% Get the legend info structure from the inputs
info = legend_info(ha,hf,Kids,lstrings);

% Remember current state
hfold = find_gcf(ha);
haold = find_gca(ha);
punits=get(hf,'units');
aunits=get(ha,'units');
% Remember Figure Default Text Font Units and Size
oldFigDefaultTextFontUnits = get(hf,'DefaultTextFontUnits');
oldFigDefaultTextFontSize = get(hf,'DefaultTextFontSize');

if strncmp(get(hf,'NextPlot'),'replace',7)
    set(hf,'NextPlot','add')
    oldNextPlot = get(hf,'NextPlot');
else
    oldNextPlot = '';
end
set(ha,'units','points');
set(hf,'units','points');

if ~doresize
    textStyleSource=ha;
    tInterp = 'tex';
else
    textStyleSource=ud.LabelHandles(1);
    tInterp = get(textStyleSource,'interpreter');
end

% Determine size of legend in figure points
oldUnits= get(textStyleSource,'FontUnits');
set(textStyleSource,'FontUnits','points');
fontn = get(textStyleSource,'fontname');
fonts = get(textStyleSource,'fontsize');
fonta = get(textStyleSource,'fontangle');
fontw = get(textStyleSource,'fontweight');
set(textStyleSource,'FontUnits',oldUnits);

% Set figure Default Text Font Size and Units
% Otherwise these can interact badly with legend fontsize
set(hf,'DefaultTextFontUnits','points');
set(hf,'DefaultTextFontSize',fonts);

% Symbols are the size of 3 numbers
h = text(0,0,'123',...
    'fontname',fontn,...
    'fontsize',fonts,...
    'fontangle',fonta,...
    'fontweight',fontw,...
    'visible','off',...
    'units','points',...
    'parent',ha,...
    'interpreter',tInterp);
ext = get(h,'extent');
lsym = ext(3);
loffset = lsym/3;
delete(h);

% Make box big enough to handle longest string
h=text(0,0,{info.label},...
    'fontname',fontn,...
    'fontsize',fonts,...
    'fontangle',fonta,...
    'fontweight',fontw,...
    'units','points',...
    'visible','off',...
    'interpreter',tInterp,...
    'parent',ha);

ext = get(h,'extent');
width = ext(3);
height = ext(4)/size(get(h,'string'),1);
margin = height*0.075;
delete(h);

llen = width + loffset*3 + lsym; 
lhgt = ext(4) + 2*margin;


%We reposition an axes if its position is becoming -1 or if setting
%a position of 1,2,3,4 when the position has been -1 in the past.
repositionAxes=false;
if length(legendpos)==1
    legendpos=round(legendpos); %deal with non-integer numbers
    if legendpos<0 || legendpos>4
        legendpos=-1; %do this in case someone passes in something not in [-1,4]
        ud.NegativePositionTripped = true;
        repositionAxes=true;
        
        % Remember old axes position if resizing to -1 
        if ~doresize
            ud.PlotPosition = record_size(ha);
        end
    else
        if isfield(ud,'NegativePositionTripped') && ud.NegativePositionTripped
            repositionAxes=true;
            if isfield(ud,'PlotPosition')
                ud=rmfield(ud,'PlotPosition');
            end
        end
        ud.NegativePositionTripped=false;
    end
end

% If resizing a plot, temporarily set the
% axes position to cover a rectangle that also encompasses the old legend.
if doresize && repositionAxes
    expandplot(ha,ud,legendpos)
end

[lpos,axpos] = getposition(ha,legendpos,llen,lhgt);

ud.legendpos = legendpos;

% Shrink axes if necessary
if ~isempty(axpos)
    set(ha,'Position',axpos)
end

%
% Create legend object
%
if strcmp(get(ha,'color'),'none')
    acolor = get(hf,'color');
else
    acolor = get(ha,'color');
end

if ~doresize
    % Create legend axes and LegendDeleteProxy object (an
    % invisible text object in target axes) so that the 
    % legend will get deleted correctly.
    ud.DeleteProxy = text('parent',ha,...
        'visible','off', ...
        'tag','LegendDeleteProxy',...
        'handlevisibility','off');
    
    hl=graph2d.legend('units','points',...
        'position',lpos,...
        'box','on',...
        'drawmode', 'fast',...
        'nextplot','add',...
        'xtick',-1,...
        'ytick',-1,...
        'xticklabel','',...
        'yticklabel','',...
        'xlim',[0 1],...
        'ylim',[0 1], ...
        'clipping','on',...
        'color',acolor,...
        'tag','legend',...
        'view',[0 90],...
        'climmode',get(ha,'climmode'),...
        'clim',get(ha,'clim'),...
        'deletefcn','legend(''DeleteLegend'')',...
        'parent',hf);
    hl=double(hl);
    
    set(hl,'units','normalized')
    setappdata(hl,'NonDataObject',[]); % Used by DATACHILDREN.M
    ud.LegendPosition = get(hl,'position');
    set(ud.DeleteProxy,'deletefcn','legend(''DeleteLegend'')');
    set(ud.DeleteProxy,'userdata',hl);
else
    hl = ud.LegendHandle;
    labelhandles = ud.LabelHandles;
    set(hl,'units','points','position',lpos);
    set(hl,'units','normalized')
    ud.LegendPosition = get(hl,'position');
end

try
    %update the legend's PositionMode setting. Legends from prior to R12 do
    %not contain this property. Make sure it exists before continuing.
    if DidLegendMove(hl) && isprop(handle(hl),'PositionMode')
        set(handle(hl),'PositionMode',round(1000*legendpos)/1000);
    end
catch ex %#ok<NASGU>
end


%
% Draw text description above legend 
%
texthandles = [];
nrows = size(char(info.label),1);

% draw text one on chunk so that the text spacing is good
label = char(info.label);
top = (1-max(1,size(label,1)))/2;
if ~doresize
    texthandles = graph2d.legendtext('parent',hl,...
        'units','data',...
        'position',[1-(width+loffset)/llen,1-(1-top)/(nrows+1)],...
        'string',char(info.label),...
        'fontname',fontn,...
        'fontweight',fontw,...
        'fontsize',fonts,...
        'fontangle',fonta,...
        'ButtonDownFcn','moveaxis');
    try
        set(handle(hl),'TextHandle',texthandles);
    catch ex %#ok<NASGU>
    end
    texthandles=double(texthandles);
    jpropeditutils('jforcenavbardisplay',texthandles,0);
else
    texthandles = ud.LabelHandles(1);
    
    oldFontUnits=get(texthandles,'FontUnits');
    try
        set(texthandles,...
            'String',{info.label},...
            'units','data',...
            'position',[1-(width+loffset)/llen,1-(1-top)/(nrows+1)],...
            'fontname',fontn,...
            'fontsize',fonts,...
            'FontUnits','points');
        set(texthandles,'FontUnits',oldFontUnits);
    catch ex %#ok<NASGU>
        % make HL empty so caller knows we got toasted
        hl = [];
        return;
    end
end

% adjust text position
ext = get(texthandles,'extent');
centers = linspace(ext(4)-ext(4)/nrows,0,nrows)+ext(4)/nrows/2 + 0.4*(1-ext(4));
edges = linspace(ext(4),0,nrows+1) + 0.4*(1-ext(4));
indent = [1 1 -1 -1 1] * ext(4)/nrows/7.5;

%
% Draw lines and / or styles and labels for each legend item
%

% start handleIndex at 2 because labels and line styles follow the text object 
% from above in the handle list
handleIndex = 2;
r = 1;
objhandles = [];
nstack = length(info);

for i=1:nstack
    p = [];
    if strcmp(info(i).objtype,'line')
        
        % draw lines with markers like this: --*--
        
        % draw line
        if ~doresize
            p = graph2d.legendline('parent',hl,...
                'xdata',(loffset+[0 lsym])/llen,...
                'ydata',[centers(r) centers(r)],...
                'linestyle',info(i).linetype,...
                'marker','none',...
                'tag',singleline(info(i).label),...
                'color',info(i).edgecol, ...
                'linewidth',info(i).lnwidth,...
                'ButtonDownFcn','moveaxis',...
                'SelectionHighlight','off');
            
            p=double(p);
            
            markerHandle=line('parent',hl,...
                'xdata',(loffset+lsym/2)/llen,...
                'ydata',centers(r),...
                'color',info(i).edgecol, ...
                'HitTest','off',...
                'linestyle','none',...
                'linewidth',info(i).lnwidth,...
                'marker',info(i).marker,...
                'markeredgecolor',info(i).markedge,...
                'markerfacecolor',info(i).markface,...
                'markersize',info(i).marksize,...
                'ButtonDownFcn','moveaxis');
            
            set(handle(p),'LegendMarkerHandle',markerHandle);
            % set line handle after legendmarker handle so setting
            % marker handle won't cause change to kid line markers
            set(handle(p),'LineHandle',handle(Kids(i)));
            p=[p;markerHandle];
            
        else
            
            if handleIndex > length(ud.LabelHandles)
                % should only get here when dealing with pre R12 legends.
                continue;
            end
            
            % For legends created pre R12, don't try to draw lines where
            % linestyle is none.
            p1 = ud.LabelHandles(handleIndex);
            if isa(handle(p1),'graph2d.legendline') || ~strcmp(info(i).linetype,'none')
                set(p1,...
                    'xdata',(loffset+[0 lsym])/llen,...
                    'ydata',[centers(r) centers(r)]);
                handleIndex = handleIndex+1;
                p = p1;
            end
            
            if handleIndex > length(ud.LabelHandles)
                % should only get here when dealing with pre R12 legends.
                continue;
            end
            
            % For legends created pre R12, don't try to draw markers where
            % markerstyle is none.
            if isa(handle(p),'graph2d.legendline') || ~strcmp(info(i).marker,'none')
                p2 = ud.LabelHandles(handleIndex);
                set(p2,...
                    'xdata',(loffset+lsym/2)/llen,...
                    'ydata',centers(r));
                handleIndex = handleIndex+1;
                p = [p;p2];
            end
            
        end
        
    elseif strcmp(info(i).objtype,'patch')  || strcmp(info(i).objtype,'surface')
        % draw patches
        
        % Adjusting ydata to make a thinner box will produce nicer
        % results if you use patches with markers.
        
        % set patch xdata depending on n vertices in axes patch object
        
        if info(i).nverts == 1
            pxdata = (loffset + (lsym/2))/llen;
            pydata = (((2*edges(r)) + (1*edges(r+1)))/3) - indent;
            mksize = lsym/2.3;
        else
            pxdata = (loffset+[0 lsym lsym 0 0])/llen;
            pydata = [edges(r) edges(r) edges(r+1) edges(r+1) edges(r)]-indent;
            mksize = info(i).marksize;
        end
        
        if ~doresize
            p = graph2d.legendpatch('parent',hl,...
                'xdata',pxdata,...
                'ydata',pydata,...
                'linestyle',info(i).linetype,...
                'edgecolor',info(i).edgecol, ...
                'facecolor',info(i).facecol,...
                'linewidth',info(i).lnwidth,...
                'tag',singleline(info(i).label),...
                'marker',info(i).marker,...
                'markeredgecolor',info(i).markedge,...
                'markerfacecolor',info(i).markface,...
                'markersize',mksize,...
                'SelectionHighlight','off',...
                'ButtonDownFcn','moveaxis');
            
            set(p,'PatchHandle',handle(Kids(i)));
            p=double(p);
            
        else
            if handleIndex > length(ud.LabelHandles)
                % should only get here when dealing with pre R12 legends.
                continue;
            end
            
            p = ud.LabelHandles(handleIndex);
            set(p,'xdata',(loffset+[0 lsym lsym 0 0])/llen,...
                'ydata',[edges(r) edges(r) edges(r+1) edges(r+1) edges(r)]-indent);
            handleIndex = handleIndex+1;
        end
        
        if strcmp(info(i).facecol,'flat') || strcmp(info(i).edgecol,'flat')
            c = get(Kids(i),'cdata');
            k = find(isfinite(c),1); %findmin
            if ~isempty(k)
                set(p,'cdata',c(k)*ones(1,5),'cdatamapping',get(Kids(i),'cdatamapping'));
            end
        end
    end
    
    % p will be empty when resizing a pre R12 legend with lines using linestyle none.
    if ~isempty(p)
        objhandles = [objhandles;p];
    end
    
    r = r + max(1,size(info(i).label,1));
end

% set both of these because label handles is an output argument to this function
labelhandles = [texthandles;objhandles];
ud.LabelHandles = labelhandles;

% Clean up a bit
set(hf,'DefaultTextFontUnits',oldFigDefaultTextFontUnits);
set(hf,'DefaultTextFontSize',oldFigDefaultTextFontSize);
set(hf,'units',punits)
set(ha,'units',aunits)
if (hfold ~= hf) && ~doresize, figure(hfold); end
if ~isempty(oldNextPlot)
    set(hf,'nextplot',oldNextPlot)
end
ud.handles = Kids;
ud.lstrings = {info.label};

% wrap in try/catch in case we are doing recursive calls into make_legend
try
    set(handle(hl),'LegendStrings',ud.lstrings);
catch
end

ud.LegendHandle = hl;
set(hl,...
    'ButtonDownFcn','moveaxis',...
    'interruptible','on', ...
    'busyaction','queue',...
    'userdata',ud);

% Make legend resize itself
if isempty(get(hf,'resizefcn'))
    set(hf,'resizefcn','legend(''ResizeLegend'')')
end

if ~doresize
    PlaceLegendOnTop(hf,hl,ha)
end

% this initial setting of the udd objects PositionMode is
% needed because it could not be set during graph2d.legend
% construction - where it was set to a meaningless number (-111)
% Legends from prior to R12 do not contain this property. Make sure it 
% exists before continuing.
if isprop(handle(hl),'PositionMode')
    set(handle(hl),'PositionMode',round(1000*ud.legendpos)/1000);
end

set(hf,'currentaxes',haold);  % this should be last

%------------------------------
function PlaceLegendOnTop(hf,hl,ha)
%PlaceLegendOnTop  Make sure the legend is on top of its axes.
ord = findobj(allchild(hf),'flat','type','axes');
axpos = find(ord==ha);
legpos = find(ord==hl);
axlegdist = axpos - legpos;

% legend needs to be the next axes type child above its plotaxes
% if it's higher than that, move it back down where it belongs.
% I'm not sure if this is really needed, but it IS the old
% (expected) behavior.  Just above should be good enough
% For now I'm commenting out the stacking down.

if axlegdist>1
    %% this may be needed if legend being more than one child above its
    %% axes causes problems (overlapping axes?), but hopefully it wont
    %% since using it will cause the flashing toolbar bug to return.
    % uistack(hl,'down',axlegdist-1);
    
    % need to move legend up if its stack order number is larger
    % than (or same as - impossible?) that of the plot axes.  In fact
    % this may not even be needed, because legend is never called to
    % do anything to an old legend - it always creates a new one, which
    % will always be on top.  So this whole thing may be unnecessary.
elseif axlegdist<1
    uistack(hl,'up',1-axlegdist);
end

%------------------------------
function info = legend_info(ha,hf,Kids,lstrings)
%LEGEND_INFO Get legend info from parent axes, Kids, and strings
%   INFO = LEGEND_INFO(HA,KIDS,STRINGS) returns a structure array containing
%      objtype  -- Type of object 'line', 'patch', or 'surface'
%      label    -- label string
%      linetype -- linetype;
%      edgecol  -- edge color
%      facecol  -- face color
%      lnwidth  -- line width
%      marker   -- marker
%      marksize -- markersize
%      markedge -- marker edge color
%      markface -- marker face color (not used for 'line')

defaultlinestyle = get(hf,'DefaultLineLineStyle');
defaultlinecolor = get(hf,'DefaultLineColor');
defaultlinewidth = get(hf,'DefaultLineLineWidth');
defaultlinemarker = get(hf,'DefaultLineMarker');
defaultlinemarkersize = get(hf,'DefaultLineMarkerSize');
defaultlinemarkerfacecolor = get(hf,'DefaultLineMarkerFaceColor');
defaultlinemarkeredgecolor = get(hf,'DefaultLineMarkerEdgeColor');
defaultpatchfacecolor = get(hf,'DefaultPatchFaceColor');
defaultnverts = 4;

linetype = {};
edgecol = {};
facecol = {};
lnwidth = {};
marker = {};
marksize = {};
markedge = {};
markface = {};
nverts = {};

% These 8 variables are the important ones.  The only ambiguity is
% edgecol/facecol.  For lines, edgecol is the line color and facecol
% is unused.  For patches, edgecol/facecol mean the logical thing.

Kids = Kids(:);  %  Reshape so that we have a column vector of handles.
lstrings = lstrings(:);

% Check for valid handles
nonhandles = ~ishandle(Kids);
if any(nonhandles)
    %  warning('Some invalid handles were ignored.')
    Kids(nonhandles) = [];
end
if ~isempty(Kids)
    badhandles = ~(strcmp(get(Kids,'type'),'patch') | ...
        strcmp(get(Kids,'type'),'line')  | ...
        strcmp(get(Kids,'type'),'surface'));
    if any(badhandles)
        warning(message('MATLAB:legendv6:SomeHandlesIgnored'));
        Kids(badhandles) = [];
    end
end

% Look for obsolete syntax label(...,LineSpec,Label,LineSpec,Label)
% To reduce the number of false hits, we require at least one
% line type in the list
obsolete = 0;
if rem(length(lstrings),2)==0
    for i=1:2:length(lstrings)
        if isempty(lstrings{i})  % Empty lineSpec isn't obsolete syntax
            obsolete = 0;
            break
        end
        [L,~,~,msg] = colstyle(lstrings{i});
        if ~isempty(msg)  % If any error parsing LineSpec
            obsolete = 0;
            break
        end
        if ~isempty(L), obsolete = 1; end
    end
end

if obsolete
    warning(message('MATLAB:legendv6:LegendSyntaxObsolete'));
    
    % Every other argument is a linespec
    
    % Right now we don't check to see if a corresponding linespec is
    % actually present on the graph, we just draw it anyway as a 
    % simple line with properties color, linestyle, 1-char markertype.
    % No frills like markersize, marker colors, etc.  Exception: if
    % a patch is present with facecolor = 'rybcgkwm' and the syntax
    % legend('g','label') is used, a patch shows up in the legend
    % instead.  Since this whole functionality is being phased out and
    % you can do better things using handles, the legend may not look
    % as nice using this option.
    
    objtype = {};
    
    % Check for an even number of strings
    if rem(length(lstrings),2)~=0
        error(message('MATLAB:legendv6:InvalidLegendSyntax'))
    end
    
    for i=1:2:length(lstrings)        
        lnstr=lstrings{i};
        [lnt,lnc,lnm,msg] = colstyle(lnstr);
        
        if isempty(msg) && ~isempty(lnstr) % Valid linespec
            % Check for line style
            if (isempty(lnt))
                linetype=[linetype,{defaultlinestyle}];
            else
                linetype=[linetype,{lnt}];
            end
            % Check for line color
            if (isempty(lnc))
                edgecol=[edgecol,{defaultlinecolor}];
                facecol=[facecol,{defaultpatchfacecolor}];
                objtype = [objtype,{'line'}];
            else   
                colspec = ctorgb(lnc);
                edgecol=[edgecol,{colspec}];
                facecol=[facecol,{colspec}];
                if ~isempty(findobj('type','patch','facecolor',colspec)) || ...
                        ~isempty(findobj('type','surface','facecolor',colspec))
                    objtype = [objtype,{'patch'}];
                else
                    objtype = [objtype,{'line'}];
                end
            end
            % Check for marker
            if (isempty(lnm))
                marker=[marker,{defaultlinemarker}];
            else
                marker=[marker,{lnm}];
            end
            % Set remaining properties
            lnwidth = [lnwidth,{defaultlinewidth}];
            marksize = [marksize,{defaultlinemarkersize}];
            markedge = [markedge,{defaultlinemarkeredgecolor}];
            markface = [markface,{defaultlinemarkerfacecolor}];
            nverts = [nverts,{defaultnverts}];
        else
            % Set everything to defaults
            linetype=[linetype,{defaultlinestyle}];
            edgecol=[edgecol,{defaultlinecolor}];
            facecol=[facecol,{defaultpatchfacecolor}];
            marker=[marker,{defaultlinemarker}];
            lnwidth = [lnwidth,{defaultlinewidth}];
            marksize = [marksize,{defaultlinemarkersize}];
            markedge = [markedge,{defaultlinemarkeredgecolor}];
            markface = [markface,{defaultlinemarkerfacecolor}];
            nverts = [nverts,{defaultnverts}];
            objtype = [objtype,{'line'}];
        end
    end
    lstrings = lstrings(2:2:end);
    
else % Normal syntax
    objtype = get(Kids,{'type'});
    nk = length(Kids);
    nstack = length(lstrings);
    n = min(nstack,nk);
    
    % Treat empty strings as a single space
    for i=1:nstack
        if isempty(lstrings{i})
            lstrings{i} = ' ';
        end
    end
    
    % Truncate kids if necessary to match the number of strings
    objtype = objtype(1:n);
    Kids = Kids(1:n);
    
    for i=1:n
        linetype = [linetype,get(Kids(i),{'LineStyle'})];
        if strcmp(objtype{i},'line')
            edgecol = [edgecol,get(Kids(i),{'Color'})];            
            facecol = [facecol,{'none'}];
            nverts = [nverts,{defaultnverts}];
        elseif strcmp(objtype{i},'patch') || strcmp(objtype{i},'surface')
            [e,f] = patchcol(Kids(i));
            edgecol = [edgecol,{e}];
            facecol = [facecol,{f}];
            nverts = [nverts,{length(get(Kids(i),'xdata'))}];
        end
        lnwidth = [lnwidth,get(Kids(i),{'LineWidth'})];
        marker = [marker,get(Kids(i),{'Marker'})];
        marksize = [marksize,get(Kids(i),{'MarkerSize'})];
        markedge = [markedge,get(Kids(i),{'MarkerEdgeColor'})];
        markface = [markface,get(Kids(i),{'MarkerFaceColor'})];
    end
    
    if n < nstack      % More strings than handles
        objtype(end+1:nstack) = {'none'};
        linetype(end+1:nstack) = {'none'};
        edgecol(end+1:nstack) = {'none'};
        facecol(end+1:nstack) = {'none'};
        lnwidth(end+1:nstack) = {defaultlinewidth};
        marker(end+1:nstack) = {'none'};
        marksize(end+1:nstack) = {defaultlinemarkersize};
        markedge(end+1:nstack) = {'auto'};
        markface(end+1:nstack) = {'auto'};
        nverts(end+1:nstack) = {defaultnverts};
    end
end

% Limit markersize to axes fontsize
fonts = get(ha,'fontsize');
marksize([marksize{:}]' > fonts & strcmp(objtype(:),'line')) = {fonts};  
marksize([marksize{:}]' > fonts/2 & strcmp(objtype(:),'patch')) = {fonts/2};  

% Package everything into the info structure
info = struct('objtype',objtype(:),'label',lstrings(:),...
    'linetype',linetype(:),'edgecol',edgecol(:),...
    'facecol',facecol(:),'lnwidth',lnwidth(:),'marker',marker(:),...
    'marksize',marksize(:),'markedge',markedge(:),'markface',markface(:),'nverts',nverts(:));


%-----------------------------
function update_all_legends
%UPDATE_ALL_LEGENDS Update all legends on this figure
legh = find_legend;
for i=1:length(legh)
    update_legend(legh(i));
end

%-------------------------------
function [hl,objh,outH,outM] = update_legend(legh)
%UPDATE_LEGEND Update an existing legend
if isempty(legh)
    hl = [];
    objh = [];
    return
end
if length(legh)~=1
    error(message('MATLAB:legendv6:TooManyLegends'))
end

ud = get(legh,'userdata');
if ~isfield(ud,'LegendPosition')
    warning(message('MATLAB:legendv6:NoLegendToUpdate'))
    hl = []; objh = [];
    return
end

moved = DidLegendMove(legh);

units = get(legh,'units');
set(legh,'units','points')
oldpos = get(legh,'position');

% Delete old legend
delete_legend(legh)

% Make a new one
if moved || length(ud.legendpos)==4
    [hl,objh] = make_legend(ud.PlotHandle,ud.handles,ud.lstrings,oldpos);
else
    [hl,objh] = make_legend(ud.PlotHandle,ud.handles,ud.lstrings,ud.legendpos);
end
set(hl,'units',units)
outH = ud.handles;
outM = ud.lstrings;

%----------------------------------------------
function moved = DidLegendMove(legh)
% Check to see if the legend has been moved
ud = get(legh,'userdata');
if isstruct(ud) && isfield(ud,'LegendPosition')
    units = get(legh,'units');
    set(legh,'units','normalized')
    pos = get(legh,'position');
    set(legh,'units','pixels')
    tol = pos ./ get(legh,'position')/2;
    if any(abs(ud.LegendPosition - pos) > max(tol(3:4)))
        moved = 1;
    else
        moved = 0;
    end
    set(legh,'units',units)
else
    moved = 1;
end

%----------------------------------------------
function moved = DidAxesMove(legh)
% Check to see if the axes has been moved
ud = get(legh,'userdata');
ax = ud.PlotHandle;
if isfield(ud,'PlotPosition')
    units = get(ax,'units');
    set(ax,'units','normalized')
    pos = get(ax,'position');
    set(ax,'units','pixels')
    tol = pos ./ get(ax,'position')/2;
    if any(abs(ud.PlotPosition - pos) > max(tol(3:4)))
        moved = 1;
    else
        moved = 0;
    end
    set(ax,'units',units)
else
    moved = 0;
end

%----------------------------
function resize_all_legends(fig)
%RESIZE_ALL_LEGENDS Resize all legends in this figure
legh = find_legend(fig);
for i=1:length(legh)
    resize_legend(legh(i));
end

%----------------------------
function resize_legend(legh)
%RESIZE_LEGEND Resize all legend in this figure

ud = get(legh,'userdata');
units = get(legh,'units');
set(legh,'units','normalized')
%normalizedPosition=get(legh,'Position');

if ~isfield(ud,'LegendPosition') || ~ishandle(ud.LegendHandle)
    warning(message('MATLAB:legendv6:NoLegendToUpdate'))
    return
end

moved = DidLegendMove(legh);

set(legh,'units','points')
oldpos = get(legh,'position');

%if DidAxesMove(legh)
%if the axes were manually moved, then legend is no longer associated
%with the axes by relative position and should have its positionmode 
%set to a 4-element vector.  This code fixes bug 82060, but I have 
%left it commented out because it would introduce a backwards 
%incompatibility with R11.
%ud.legendpos=normalizedPosition;
%ud.NegativePositionTripped=logical(0);
%ud=rmfield(ud,'PlotPosition');
%end

% Update the legend
if moved || length(ud.legendpos)==4
    [hl,~] = make_legend(ud.PlotHandle,ud.handles,ud.lstrings,oldpos,ud,'resize');
else
    [hl,~] = make_legend(ud.PlotHandle,ud.handles,ud.lstrings,ud.legendpos,ud,'resize');
end
% make_legend returns empty on error
if ~isempty(hl)
    set(hl,'units',units)
end

%----------------------------
function delete_legend(ax)
%DELETE_LEGEND Remove legend from plot
if isempty(ax) || ~ishandle(ax), return, end
ax = ax(1);
hf = get(ax,'parent');

% Remove auto-resize
resizefcn = get(hf,'resizefcn');
if isequal(resizefcn,'legend(''ResizeLegend'')')
    set(hf,'resizefcn','')
end

ud=get(ax,'UserData');
restore_size(ax,ud);

if isfield(ud,'DeleteProxy') && ishandle(ud.DeleteProxy)
    delete(ud.DeleteProxy)
end
%-------------------------------
function [lpos,axpos] = getposition(ha,legendpos,llen,lhgt)
%GETPOS Get position vector from legendpos code
stickytol=1;
cap=get(ha,'position');
edge = 5; % 5 Point edge -- this number also used in make_legend

if length(legendpos)==4
    % Keep the top at the same place
    Pos = [legendpos(1) legendpos(2)+legendpos(4)-lhgt];
else
    switch legendpos
    case 0
        Pos = lscan(ha,llen,lhgt);
    case 1
        Pos = [cap(1)+cap(3)-llen-edge cap(2)+cap(4)-lhgt-edge];
    case 2
        Pos = [cap(1)+edge cap(2)+cap(4)-lhgt-edge];
    case 3
        Pos = [cap(1)+edge cap(2)+edge];
    case 4
        Pos = [cap(1)+cap(3)-llen-edge cap(2)+edge];
    otherwise
        Pos = -1;
    end
end

if isequal(Pos,-1)
    axpos=[cap(1) cap(2) cap(3)-llen-.03 cap(4)];
    lpos=[cap(1)+cap(3)-llen+edge cap(4)+cap(2)-lhgt llen lhgt];
    if any(axpos<0) || any(lpos<0)
        warning(message('MATLAB:legendv6:InsufficientSpaceToDrawLegend'))
        if any(axpos<0), axpos = []; end
    end
else
    axpos=[];
    lpos=[Pos(1) Pos(2) llen lhgt];
end

%--------------------------------------------
function Pos = lscan(ha,wdt,hgt)
%LSCAN  Scan for good legend location.

debug = 0; % Set to 1 for debugging

% Calculate tile size
cap=get(ha,'Position'); % In Point coordinates
xlim=get(ha,'Xlim');
ylim=get(ha,'Ylim');
H=ylim(2)-ylim(1);
W=xlim(2)-xlim(1);

dh = 0.03*H;
dw = 0.03*W;
Hgt = hgt*H/cap(4);
Wdt = wdt*W/cap(3);
Thgt = H/max(1,floor(H/(Hgt+dh)));
Twdt = W/max(1,floor(W/(Wdt+dw)));
dh = (Thgt - Hgt)/2;
dw = (Twdt - Wdt)/2;

% Get data, points and text

Kids=get(ha,'children');
Xdata=[];Ydata=[];
for i=1:length(Kids)
    type = get(Kids(i),'type');
    if strcmp(type,'line')
        xk = get(Kids(i),'Xdata');
        yk = get(Kids(i),'Ydata');
        n = length(xk);
        if n < 100 && n > 1
            xk = interp1(xk,linspace(1,n,200));
            yk = interp1(yk,linspace(1,n,200));
        end
        Xdata=[Xdata,xk];
        Ydata=[Ydata,yk];
    elseif strcmp(type,'patch') || strcmp(type,'surface')
        xk = get(Kids(i),'Xdata');
        yk = get(Kids(i),'Ydata');
        Xdata=[Xdata,xk(:)'];
        Ydata=[Ydata,yk(:)'];
    elseif strcmp(get(Kids(i),'type'),'text')
        tmpunits = get(Kids(i),'units');
        set(Kids(i),'units','data')
        tmp=get(Kids(i),'Position');
        ext=get(Kids(i),'Extent');
        set(Kids(i),'units',tmpunits);
        Xdata=[Xdata,[tmp(1) tmp(1)+ext(3)]];
        Ydata=[Ydata,[tmp(2) tmp(2)+ext(4)]];
    end
end
in = isfinite(Xdata) & isfinite(Ydata);
Xdata = Xdata(in);
Ydata = Ydata(in);

% Determine # of data points under each "tile"
xp = (0:Twdt:W-Twdt) + xlim(1);
yp = (0:Thgt:H-Thgt) + ylim(1);
wtol = Twdt / 100;
htol = Thgt / 100;
for j=1:length(yp)
    if debug, line([xlim(1) xlim(2)],[yp(j) yp(j)],'handlevisibility','off'); end
    for i=1:length(xp)
        if debug, line([xp(i) xp(i)],[ylim(1) ylim(2)],'handlevisibility','off'); end
        pop(j,i) = sum(sum((Xdata > xp(i)-wtol) & (Xdata < xp(i)+Twdt+wtol) & ...
            (Ydata > yp(j)-htol) & (Ydata < yp(j)+Thgt+htol)));    
    end
end

if all(pop(:) == 0), pop(1) = 1; end

% Cover up fewest points.  After this while loop, pop will
% be lowest furthest away from the data
while any(pop(:) == 0)
    newpop = filter2(ones(3),pop);
    if all(newpop(:) ~= 0)
        break;
    end
    pop = newpop;
end
if debug
    figure, 
    surface('xdata',[xp xp(end)+Twdt],'ydata', [yp yp(end)+Thgt],...
        'zdata',zeros(length(yp)+1,length(xp)+1),...
        'cdata',pop)
    figure(gpf)
end
[j,i] = find(pop == min(pop(:)));
xp =  xp - xlim(1) + dw;
yp =  yp - ylim(1) + dh;
Pos = [cap(1)+xp(i(end))*cap(3)/W
    cap(2)+yp(j(end))*cap(4)/H];

%--------------------------------
function Kids = getchildren(ha)
%GETCHILDREN Get children that can have legends
%   Note: by default, lines get labeled before patches;
%   patches get labeled before surfaces.

linekids = findobj(ha,'type','line');
surfkids = findobj(ha,'type','surface');
patchkids = findobj(ha,'type','patch');

if ~isempty(linekids)
    goodlk = ones(1,length(linekids));
    for i=1:length(linekids)
        if (isempty(get(linekids(i),'xdata')) || isallnan(get(linekids(i),'xdata'))) && ...
                (isempty(get(linekids(i),'ydata')) || isallnan(get(linekids(i),'ydata'))) && ...
                (isempty(get(linekids(i),'zdata')) || isallnan(get(linekids(i),'zdata')))
            goodlk(i) = 0;
        end
    end
    linekids = linekids(logical(goodlk));
end

if ~isempty(surfkids)
    goodsk = ones(1,length(surfkids));
    for i=1:length(surfkids)
        if (isempty(get(surfkids(i),'xdata')) || isallnan(get(surfkids(i),'xdata'))) && ...
                (isempty(get(surfkids(i),'ydata')) || isallnan(get(surfkids(i),'ydata'))) && ...
                (isempty(get(surfkids(i),'zdata')) || isallnan(get(surfkids(i),'zdata')))
            goodsk(i) = 0;
        end
    end
    surfkids = surfkids(logical(goodsk));
end

if ~isempty(patchkids)
    goodpk = ones(1,length(patchkids));
    for i=1:length(patchkids)
        if (isempty(get(patchkids(i),'xdata')) || isallnan(get(patchkids(i),'xdata'))) && ...
                (isempty(get(patchkids(i),'ydata')) || isallnan(get(patchkids(i),'ydata'))) && ...
                (isempty(get(patchkids(i),'zdata')) || isallnan(get(patchkids(i),'zdata')))
            goodpk(i) = 0;
        end
    end
    patchkids = patchkids(logical(goodpk));
end

Kids = flipud([surfkids ; patchkids ; linekids]);

% Kids = flipud([findobj(ha,'type','surface') ;...
%        findobj(ha,'type','patch') ; findobj(ha,'type','line')]);


%----------------------------
function allnan = isallnan(d)

nans = isnan(d);
allnan = all(nans(:));

%----------------------------
function s = getstrings(c)
%GETSTRINGS Get strings from legend input
%   S = GETSTRINGS(C) where C is a cell array containing the legend
%   input arguments.  Handles three cases:
%      (1) legend(M) -- string matrix
%      (2) legend(C) -- cell array of strings
%      (3) legend(string1,string2,string3,...)
%   Returns a cell array of strings
if length(c)==1 % legend(M) or legend(C)
    s = cellstr(c{1});
elseif iscellstr(c)
    s = c;
else
    error(message('MATLAB:legendv6:LabelsMustBeStrings'));
end


%-----------------------------------
function  out=ctorgb(arg)
%CTORGB Convert color string to rgb value
switch arg
case 'y', out=[1 1 0];
case 'm', out=[1 0 1];
case 'c', out=[0 1 1];
case 'r', out=[1 0 0];
case 'g', out=[0 1 0];
case 'b', out=[0 0 1];
case 'w', out=[1 1 1];
otherwise, out=[0 0 0];
end


%----------------------------------
function  [edgecol,facecol] = patchcol(h)
%PATCHCOL Return edge and facecolor from patch handle
cdat = get(h,'Cdata');
facecol = get(h,'FaceColor');
if strcmp(facecol,'interp') || strcmp(facecol,'texturemap') 
    if ~all(cdat == cdat(1))
        warning(message('MATLAB:legendv6:UnsupportedPatchFaceColor', facecol));
    end
    facecol = 'flat';
end
if strcmp(facecol,'flat')
    if size(cdat,3) == 1       % Indexed Color
        k = find(isfinite(cdat), 1);
        if isempty(k)
            facecol = 'none';
        end
    else                       % RGB values
        facecol = reshape(cdat(1,1,:),1,3);
    end
end

edgecol = get(h,'EdgeColor');
if strcmp(edgecol,'interp')
    if ~all(cdat == cdat(1))
        warning(message('MATLAB:legendv6:UnsupportedPatchEdgeColor'));
    end  
    edgecol = 'flat';
end
if strcmp(edgecol,'flat')
    if size(cdat,3) == 1      % Indexed Color
        k = find(isfinite(cdat), 1);
        if isempty(k)
            edgecol = 'none';
        end
    else                      % RGB values
        edgecol = reshape(cdat(1,1,:),1,3);
    end
end

%------------------------
function edit_legend(gco)
%Edit a legend

if ~strcmp(get(gco,'type'),'text'), return, end
legh = get(gco,'parent');

% Determine which string was clicked on
units = get(gco,'units');
set(gco,'units','data')
cp = get(legh,'currentpoint');
ext = get(gco,'extent');
nstrings = size(get(gco,'string'),1);

% The k-th string (from the top) was clicked on
k = floor((ext(4) - cp(1,2))/ext(4)*nstrings) + 1;
ud = get(legh,'userdata');
nrows = cellfun('size',ud.lstrings,1);
crows = cumsum(nrows);

% Determine which string in the cell array was clicked on
active_string = floor( ...
    interp1([0 cumsum(nrows)+1],[1:length(nrows) length(nrows)],k));
if isnan(active_string), return, end

% Disable legend buttondownfcn's
savehandle = findobj(legh,'buttondownfcn','moveaxis');
set(savehandle,'buttondownfcn','')

% Make a editable string on top of the legend string
pos = get(gco,'position');
y = ext(4) - (crows(active_string)-nrows(active_string)/2)*ext(4)/nstrings;
pos(2) = ext(2) + y;

% Coverup text
CoverHandle = copyobj(gco,legh);
color = get(legh,'color');
if ischar(color), color = get(get(legh,'parent'),'color'); end
set(CoverHandle,'color',color);

% Make editable case
TextHandle = copyobj(gco,legh);
set(TextHandle,'string',char(ud.lstrings{active_string}),'position',pos, ...
    'Editing','on')
waitfor(TextHandle,'Editing');

% Protect against the handles being destroyed during the waitfor
if ishandle(CoverHandle)
    delete(CoverHandle)
end
if ishandle(TextHandle) && ishandle(legh) && ishandle(savehandle)
    newLine = get(TextHandle,'String');
    delete(TextHandle)
    
    ud.lstrings{active_string}=newLine;
    set(legh,'UserData',ud)
    
    set(gco,'units',units)
    
    % Enable legend buttondfcn's
    set(savehandle,'buttondownfcn','moveaxis')
    resize_legend(legh);
    %update_legend(legh);
end

%-----------------------------
function show_plot(legend_ax)
%Set the axes this legend goes with to the current axes

if islegend(legend_ax)
    ud = get(legend_ax,'userdata');
    if isfield(ud,'PlotHandle')
        set(find_gcf(legend_ax),'currentaxes',ud.PlotHandle)
    end
    try
        %update the legend's PositionMode setting. Legends from prior to 
        % R12 do not contain this property. Make sure it exists 
        % before continuing.
        if DidLegendMove(legend_ax) && isprop(handle(legend_ax),'PositionMode')
            set(handle(legend_ax),...
                'PositionMode',round(1000*get(legend_ax,'Position'))/1000);
        end
    catch ex %#ok<NASGU>
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=islegend(ax)

if length(ax) ~= 1 || ~ishandle(ax) 
    tf=false;
else
    tf=isa(handle(ax),'graph2d.legend');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tOut=singleline(tIn)
%converts cellstrs and 2-d char arrays to
%\n-delimited single-line text

if ischar(tIn)
    if size(tIn,1)>1
        nRows=size(tIn,1);
        cr=newline;
        cr=cr(ones(nRows,1));
        tIn=[tIn,cr]';
        tOut=tIn(:)';
        tOut=tOut(1:end-1); %remove trailing \n
    else
        tOut=tIn;
    end
elseif iscellstr(tIn)
    tOut=singleline(char(tIn));
else
    tOut='';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function expandplot(ha,ud,legendpos)
% Expand plot to cover rectangle that includes legend
% but when a colorbar is present only expand up to
% the left edge of the colorbar minus a margin.

edge=5;

% get all the figure colorbars
cbars = findobj(get(ha,'parent'),'tag','Colorbar');
cbarfound = 0;
i=1;
% find vertical colorbar with plothandle ha
% and get its position
while ~cbarfound && i<=length(cbars)
    cbud = get(cbars(i),'userdata');
    if isfield(cbud,'PlotHandle')
        if isequal(cbud.PlotHandle,ha)
            cbpos = get(cbars(i),'Position');
            if cbpos(3)<cbpos(4) && strcmpi(get(cbars(i),'beingdeleted'),'off')  % vertical
                cbarfound=1;
                % get its position in point units
                oldunits = get(cbars(i),'units');
                set(cbars(i),'units','points');
                cbppos = get(cbars(i),'Position');
                set(cbars(i),'units',oldunits);
            end
        end
    end
    i = i+1;
end

% get axes position
oldunits = get(ha,'units');
set(ha,'units','points');
axespos = get(ha,'Position');

% get legend position
set(ud.LegendHandle,'units','points');
legpos  = get(ud.LegendHandle,'Position');

startpt = max(min(axespos(1:2),legpos(1:2)),[0 0]);
endpt   = max(axespos(1:2)+axespos(3:4), legpos(1:2)+legpos(3:4));
% adjust endpoint for vertical colorbar if one was found
if cbarfound
    endpt(1) = min(endpt(1),cbppos(1)-edge);
end
newpos = [startpt (endpt-startpt)];


legright = legpos(1) + legpos(3);
axright = axespos(1) + axespos(3);
if legendpos<0
    if cbarfound || legright>axright
        % subtract edge size
        newpos(3)=newpos(3)-edge; 
    elseif  axright>legright && (axright-legright)<edge
        % subtract edge less distance from right of legend
        % to right of axes
        newpos(3)=newpos(3) - (edge-(axright-legright));
    end
end

set(ha,'position',newpos);
set(ha,'units',oldunits);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function restore_size(hLegend,ud)

if ~islegend(hLegend)
    hLegend=find_legend(hLegend);
end

if nargin<2
    ud=get(hLegend,'UserData');
end

if isfield(ud,'PlotHandle') && ishandle(ud.PlotHandle) && ...
        isfield(ud,'PlotPosition') && ~isempty(ud.PlotPosition) && ...
        DidAxesMove(hLegend)
    
    units = get(ud.PlotHandle,'units');
    set(ud.PlotHandle,'units','normalized','position',ud.PlotPosition)
    set(ud.PlotHandle,'units',units)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=record_size(hPlot,plotSize)

if nargin<2
    oldUnits=get(hPlot,'Units');
    set(hPlot,'Units','normalized');
    plotSize=get(hPlot,'Position');
    set(hPlot,'Units',oldUnits);
end

if nargout==1
    varargout{1}=plotSize;
else
    hLegend=find_legend(hPlot);
    ud = get(hLegend,'UserData');
    if (isfield(ud,'legendpos') && ...
            length(ud.legendpos)==1 && ...
            ud.legendpos<1) || ...
            (isfield(ud,'NegativePositionTripped') && ...
            ud.NegativePositionTripped)
        ud.PlotHandle=hPlot;
        ud.PlotPosition=plotSize;
        set(hLegend,'UserData',ud);
    end
end


