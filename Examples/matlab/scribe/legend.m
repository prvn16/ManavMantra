function [leg,labelhandles,outH,outM] = legend(varargin)
% LEGEND Create legend
% 
% LEGEND creates a legend with descriptive labels for each plotted data
% series. For the labels, the legend uses the text from the DisplayName
% properties of the data series. If the DisplayName property is empty, then
% the legend uses a label of the form 'dataN'. The legend automatically
% updates when you add or delete data series from the axes. This command
% creates a legend for the current axes or chart returned by gca. If the
% current axes is empty, then the legend is empty. If axes do not exist,
% then this command creates one.
%
% LEGEND(label1,...,labelN) sets the labels. Specify the labels as a
% list of character vectors, such as legend('Jan','Feb','Mar').
%
% LEGEND(labels) sets the labels using a cell array of character vectors or
% a character matrix, such as legend({'Jan','Feb','Mar'}).
%
% LEGEND(subset,__) only includes items in the legend for the data series
% listed in subset. Specify subset as a vector of graphics objects.
%
% LEGEND(target,__) uses the axes, polar axes, or chart specified by target
% instead of the current axes or chart. Specify the target as the first
% input argument. 
%
% LEGEND(__,'Location',lcn) sets the legend location. For example,
% 'Location','northeast' positions the legend in the upper right corner of
% the axes. Specify the location after other input arguments.
%
% LEGEND(__,'Orientation',ornt), where ornt is 'horizontal', displays the
% legend items side-by-side. The default for ornt is 'vertical', which
% stacks the items vertically. 
%
% LEGEND(__,Name,Value) sets legend properties using one or more name-value
% pair arguments. When setting properties, include the labels in a cell
% array, such as legend({'A','B'},'FontSize',12). If you do not want to
% specify labels, then include an empty cell array, such as
% legend({},'FontSize',12). Reissuing the legend command retains
% modifications that you previously specified.
%
% LEGEND(bkgd), where bkgd is 'boxoff', removes the legend background and
% outline. The default for bkgd is 'boxon', which displays the legend
% background and outline. 
%
% lgd = LEGEND(__) returns the Legend object. Use lgd to query and set
% properties of the legend after it is created. For a list of properties,
% see Legend. 
%
% [lgd,icons,plots,txt] = LEGEND(__) additionally returns the objects used
% to create the legend icons, the objects plotted in the graph, and an
% array of the label text. This syntax is not recommended. Some
% functionality is not supported. Instead, use the lgd = legend(__) syntax
% to return the Legend object and set Legend Properties.
%
% LEGEND(vsbl) controls the visibility of the legend, where vsbl is 'hide',
% 'show', or 'toggle'. 
%
% LEGEND('off') deletes the legend.
%
%  
%     Examples:
%         x = 0:.2:12;
%         Y = [besselj(1,x); besselj(2,x); besselj(3,x)];
%         plot(x,Y);
%         legend('First','Second','Third','Location','NorthEastOutside')
%  
%         b = bar(rand(10,5),'stacked'); 
%         hold on
%         ln = plot(1:10,5*rand(10,1),'-o'); 
%         hold off
%         legend([b,ln],'Carrots','Peas','Peppers','Green Beans',...
%                   'Cucumbers','Eggplant')

%   Unsupported APIs for internal use:
%
%   LOC strings can be abbreviated NE, SO, etc or lower case.
%
%   LEGEND(LI,string1,string2,string3) creates a legend for legendinfo
%   objects LI with strings string1, etc.
%   LEGEND(LI,M) creates a legend for legendinfo objects LI where M is a
%   string matrix or cell array of strings corresponding to the legendinfo
%   objects.

%   Copyright 1984-2017 The MathWorks, Inc.

% Legend no longer supports more than one output argument
% Warn the user and ignore additional output arguments.

args = varargin;

% Continue warning that the v6 form will go away in the future.
if (nargin > 1 ...
        && istextscalar(args{1}) ...
        && ~istextscalar(args{2}) ...
        && strcmp(args{1},'v6'))
    warning(message('MATLAB:legend:DeprecatedV6Argument'));
end

%--------------------------------------------------------
% Begin building the legend
%--------------------------------------------------------
narg = nargin;

% HANDLE FINDLEGEND CASES FIRST
if narg==2 ...
        && istextscalar(args{1}) ...
        && strcmpi(args{1},'-find') ...
        && ~isempty(args{2}) ...
        && (isgraphics(args{2},'axes') || isgraphics(args{2},'polaraxes'))

    [leg,labelhandles,outH,outM] = setOutArgs(args{2});
    
    return;
end

% add flag to create compatible legend
version = 'off';
if nargout > 1
    version = 'on';
    
    % Compatible Legend not supported in UIAxes
    if narg > 0  && ...
       ~isempty(args{1}) && ...
       length(args{1})==1 && ...
       ishghandle(args{1}) && ...
       isa(handle(args{1}),'matlab.ui.control.UIAxes')

        error(message('MATLAB:legend:MultipleOutputsWithUIAxes'));

    end
end

arg = 1;

% GET AXES FROM INPUTS
ha = matlab.graphics.Graphics.empty;

% if the user passes in an axes that is not the current axes we want to be
% sure to restore the current axes before exiting.
old_currfig = get(0,'CurrentFigure');
if ~isempty(old_currfig) && ishghandle(old_currfig)
    old_currax = get(old_currfig,'CurrentAxes');
    if ~isempty(old_currax)
        ha = old_currax;
    end
end

% determine peer axes from inputs
if narg > 0  && ...
        ~isempty(args{1}) && ...
        length(args{1})==1 && ...
        ishghandle(args{1}) && ...
        (isa(handle(args{1}),'matlab.graphics.mixin.LegendTarget') || ...
             isa(handle(args{1}),'matlab.ui.control.UIAxes'))
    % legend(ax,...)
    % ha is an Axes or UIAxes at this point
    ha = handle(args{1});
    arg = arg + 1;
elseif narg > 0 && ...
        ~istextscalar(args{1}) && ...
        ~isempty(args{1}) && ...
        all(isgraphics(args{1})) % legend(children,strings,...)
    ha = [ancestor(args{1}(1),'axes') ancestor(args{1}(1),'polaraxes')];
    if isempty(ha)
        obj = args{1}(1);
        if ~isempty(obj) % Provide a better error message if we can.
            error(message('MATLAB:legend:InvalidPeerHandle', getClassName(obj)));
        else
            error(message('MATLAB:legend:InvalidPeerParameter'));
        end
    end
else
    % if no axes has been identified thus far, create one using GCA.      
    if isempty(ha)
        if strcmp(version,'on')
            % Legacy behavior for compatible legend
            warning(message('MATLAB:legend:NoCurrentAxes'));
            [leg,labelhandles,outH,outM] = setOutArgs(ha);
            return
        else
            % if ha is empty, use GCA, which will create an axes if necessary.
            ha = gca;
        end
    else
        % Chart subclass support
        % Invoke legend method with same number of outputs to defer output arg
        % error handling to the method.
        if isa(ha,'matlab.graphics.chart.Chart')
            try                
                [varargout{1:nargout}] = legend(ha,args{:}); %#ok<NASGU>
            catch e
                throw(e)
            end
            return
        end
    end
end

% cast double to MCOS handle
if ~isobject(ha)
    ha = handle(ha);
end

% PROCESS REMAINING INPUTS
if narg < arg % legend or legend(ax)
    if ~isempty(find_legend(ha)) || strcmp(version,'on')
        [leg,labelhandles,outH,outM] = setOutArgs(ha);
        return;
    end
end
    
if narg >= arg && ...
   istextscalar(args{arg}) && ...
   all(ismember(char(lower(args{arg})),{'off','deletelegend',...
                                        'resizelegend',...
                                        'toggle','show','hide',...
                                        'boxon','boxoff'}))


    switch char(lower(args{arg}))
        case {'off', 'deletelegend'}
            delete_legend(find_legend(ha));
        case 'resizelegend'
            % pass
        case 'toggle'
            l = find_legend(ha);
            if isempty(l) || strcmpi(get(l, 'Visible'), 'off')
                legend(ha, 'show');
            else
                legend(ha, 'hide');
            end
        case 'show'
            l = find_legend(ha);
            if isempty(l)
                make_legend(ha, args(arg+1:end), version);
            else
                set(l, 'Visible', 'on');
            end
        case 'hide'
            set(legend(ha), 'Visible', 'off');
        case 'boxon'
            set(legend(ha), 'Box', 'on');
        case 'boxoff'
            set(legend(ha), 'Box', 'off');
        otherwise
            assert(false,'make sure there is a case for each item in the ismember check above')
    end
else % narg > 1
    % legend(<string>,...)
    % legend(<charMatrix>,...)
    % legend(<cellStr>,...)
    % legend(p,...)
    % legend(p,<string>,...)
    % legend(p,<charMatrix>,...)
    % legend(p,<cellStr>,...)
    % legend('Location',<value>)
    % legend('Orientation',<value>)
    % legend('AutoUdpate',<value>)
    make_legend(ha,args(arg:end),version);
end

% PROCESS OUTPUTS
if nargout>0
    [leg,labelhandles,outH,outM] = setOutArgs(ha);
end

% before going, be sure to reset current figure and axes
if ~isempty(old_currfig) && ishghandle(old_currfig) && ~strcmpi(get(old_currfig,'beingdeleted'),'on')
    set(0,'CurrentFigure',old_currfig);
    if ~isempty(old_currax) && ishghandle(old_currax) && ~strcmpi(get(old_currax,'beingdeleted'),'on')
        set(old_currfig,'CurrentAxes',old_currax);
    end
end


%----------------------
% Helper functions
%----------------------

%----------------------------------------------------%
function make_legend(ha,argin,version_flag)

leg = find_legend(ha);

% Always create a new legend if the user has requested a compatible legned
% or if the existing legend is a compatible legend
if strcmp(version_flag,'on') || strcmp(get(leg,'version'),'on')
    delete(leg)
    leg = [];
end

new_legend = false;
if isempty(leg)
    new_legend = true;
    leg = matlab.graphics.illustration.Legend;
    leg.doPostSetup(version_flag);
    leg.Visible = 'off';
else
    % For existing legends, make sure the ALM is dirty as a result of this
    % legend call.
    hManager  = matlab.graphics.shape.internal.AxesLayoutManager.getManager(leg.Axes);
    doMarkDirty(hManager);
end

% process args
[autoupdate,orient,location,position,children,listen,strings,propargs] = process_inputs(ha,argin); %#ok

% check PV pairs
check_pv_args(propargs);

if ~isempty(children) || ~isempty(strings) || new_legend
    % process children and strings if either:
    %   - children or strings are passed in
    %   - a new legend is being created
    % this call removes all items from an existing legend
    set_children_and_strings(ha,leg,children,strings);
end

if new_legend
    try
        fig = ancestor(ha,'figure');
        parent = get(ha,'Parent');

        if strcmp(get(ha,'color'),'none')
            leg.Color_I = get(fig,'Color');
        else
            leg.Color_I = get(ha,'Color');
        end
        leg.TextColor_I = get(parent,'DefaultTextColor');
        leg.EdgeColor_I = get(parent,'DefaultAxesXColor');

        % apply 3D default
        if ~lcl_is2D(getGraphicsAxes(leg,ha))
            leg.Location = 'northeastoutside';
        elseif isa(ha, 'matlab.graphics.axis.PolarAxes')
            leg.Location = 'eastoutside';
        end
        
        % set the peer axes
        leg.Axes = ha;
        
        % disable AutoUpdate for plotyy
        if isplotyyaxes(ha)
            % Make sure the discovered plotyy children don't get
            % overwritten by the autoUpdateCallback during the update
            % triggered by setting AutoUpdate to 'off';
            % The callback can only see children of the primary axes.
            leg.PlotChildrenSpecified = leg.PlotChildren_I;
            leg.AutoUpdate = 'off';
        end
    catch
        delete(leg)
        return
    end
end

if ~isempty(autoupdate)
    leg.AutoUpdate = autoupdate;
end

if ~isempty(location)
    leg.Location = location;
end

if ~isempty(orient)
    leg.Orientation = orient;
end

% set the position manually, if specified
if ~isempty(position) && length(position)==4
  leg.Position = position;
end

% set other properties passed in varargin
if ~isempty(propargs)
    set(leg,propargs{:});      
end

% always make legend visible
% the purpose of make_legend is to put a legend on the figure
set(leg,'Visible','on');


%----------------------------------------------------%
function delete_legend(leg)

if ~isempty(leg) && ishghandle(leg) && ~strcmpi(get(leg,'beingdeleted'),'on')
    delete(leg);
end

%----------------------------------------------------%
function leg = find_legend(ha)

% Using the Legend property of ha, we will find the legend peered to
% the current axes.
if isempty(ha) || ~ishghandle(ha)
    leg = gobjects(0);
    return;
end

% get the graphics Axes so we can handle the plotyy case generally
leg = matlab.graphics.illustration.Legend.empty;
ha = getGraphicsAxes(leg,ha);

% If we have the submissive plotyy axes, get the real one
if isappdata(ha,'graphicsPlotyyPeer') && ...
   isvalid(getappdata(ha,'graphicsPlotyyPeer')) && ...
   strcmp(ha.Color,'none')
    ha = getappdata(ha,'graphicsPlotyyPeer');
end

leg = ha.Legend;

%-----------------------------------------------------%
function [leg,hobjs,outH,outM] = find_legend_info(ha)

leg = find_legend(ha);

if ~isempty(leg) && strcmp(leg.version,'on')
    drawnow;
    outH = leg.PlotChildren_I;
    outM = leg.String_I(:).';
    hobjs = [leg.ItemText(:); leg.ItemTokens(:)];
else
    outH = [];
    outM = [];
    hobjs = [];
end

%----------------------------------------------------%
function [autoupdate,orient,location,position,children,listen,strings,propargs] = process_inputs(ax,argin)

autoupdate = '';
orient=''; 
location='';
position=[];
children = []; 
strings = {}; 
propargs = {};
listen = false;

nargs = length(argin);
if nargs==0
    return;
end

% @TODO - we need to remove this or start deprecating it.  We have 4
% options:
% 	a) do nothing: explicitly ignore ?-DynamicLegend?, i.e. remove it from the input args and continue (16a behavior).  If we do this the 16b behavior will actually be compatible with 14a, but in spite of ?-DynamicLegend? and not because of it.
% 	b) same as a), but also WARN that this arg is not longer needed because ?AutoUpdate? ?on? is the new default behavior.
% 	c) completely ignore ?-DynamicLegend?, legend(?-DynamicLegend?) will produce one item with this string, but also WARN
% 	d) completely ignore ?-DynamicLegend?, and don?t even WARN since this was never documented syntax.
if istextscalar(argin{1}) && strcmpi(argin{1},'-DynamicLegend')
    listen = true;
    argin(1) = [];
    nargs = nargs-1;
    if nargs==0
        return;
    end
end

% Get location strings long and short form. The short form is the
% long form without any of the lower case characters.
% hard code the enumeration values until we can query the datatype directly
locations = {'North','South','East', 'West','NorthEast','SouthEast','NorthWest','SouthWest','NorthOutside','SouthOutside','EastOutside','WestOutside','NorthEastOutside','SouthEastOutside','NorthWestOutside','SouthWestOutside','Best','BestOutside','none'};
locationAbbrevs = cell(1,length(locations));
for k=1:length(locations)
    str = locations{k};
    locationAbbrevs{k} = str(str>='A' & str<='Z');
end

% Loop over inputs and determine strings, handles and options
n = 1;
foundAllStrings = false;
while n <= nargs
    if istextscalar(argin{n})
        switch lower(argin{n})
            case 'autoupdate'
                if n < nargs
                    autoupdate = argin{n+1};
                else
                    error('Unknown parameter AutoUpdate');
                end
                n = n+1; % skip AutoUpdate
            case 'orientation'
                if n < nargs && istextscalar(argin{n+1})
                    if strncmpi(argin{n+1}, 'hor', 3)
                        orient = 'horizontal';
                    elseif strncmpi(argin{n+1}, 'ver', 3)
                        orient = 'vertical';
                    else
                        error(message('MATLAB:legend:UnknownParameterOrientation'));
                    end
                else
                    error(message('MATLAB:legend:UnknownParameterOrientation'));
                end
                n = n+1; % skip orientation
            case 'location'
                if n < nargs && isnumeric(argin{n+1}) && length(argin{n+1})==4
                    % found 'Location', POS
                    position = argin{n+1};
                    location = 'none';
                elseif n < nargs && istextscalar(argin{n+1})
                    locationCmp = strcmpi(argin{n+1}, locations);
                    abbrevsCmp = strcmpi(argin{n+1}, locationAbbrevs);
                    if any(locationCmp)
                        % found 'Location', LOC
                        location = char(argin{n+1});
                    elseif any(abbrevsCmp)
                        % found 'Location', ABBREV
                        location = locations{abbrevsCmp};
                    else
                        error(message('MATLAB:legend:UnknownParameterLocation'));
                    end
                else
                    error(message('MATLAB:legend:UnknownParameterLocation'));
                end
                n = n+1; % skip location
            otherwise
                if foundAllStrings && n < nargs
                    % found a PV pair
                    if ~strcmpi(argin{n}, 'UserData') && istextscalar(argin{n+1})
                        argin{n+1} = char(argin{n+1});
                    end
                    propargs = [propargs, {char(argin{n})}, argin(n+1)]; %#ok<AGROW>
                    n = n+1;
                else
                    % found a string for legend entry
                    strings{end+1} = char(argin{n}); %#ok<AGROW> % single item string
                end
        end
    elseif isnumeric(argin{n}) && length(argin{n})==4 && ...
            (n > 1 || ~all(ishghandle(argin{n})))
        % to use position vector either it must not be the first argument,
        % or if it is, then the values must not all be handles - in which
        % case the argument will be considered to be the plot children
        % This is an undocumented API for backwards compatibility with
        % Basic Fitting.
        position = argin{n};
        fig = ancestor(ax,'figure');
        position = hgconvertunits(fig,position,'points','normalized', fig);
        center = position(1:2)+position(3:4)/2;
        % .001 is a small number so that legend will resize to fit and centered
        position = [center-.001 0.001 0.001];
        location = 'none';
    elseif iscell(argin{n}) || isstring(argin{n})
        strings = cellstr(argin{n});
        foundAllStrings = true;
    elseif n==1 && all(all(ishghandle(argin{n})))
        % found handles to put in legend
        % make sure to return objects, not doubles
        children=handle(argin{n});
    else
        error(message('MATLAB:legend:UnknownParameter'));
    end
    n = n + 1;
end
strings = strings(:).';

%----------------------------------------------------------------%
% args must be an even number of string,value pairs.
function check_pv_args(args)

n=length(args);
% check that every p is a property
for i=1:2:n
    metaClass = ?matlab.graphics.illustration.Legend;
    propNames = cellfun(@(x) (x.Name), metaClass.Properties, 'UniformOutput', false);
    if ~any(strcmpi(propNames,args{i}))
        error(message('MATLAB:legend:UnknownProperty', args{ i }));
    elseif strcmpi(args{i},'Parent')
        if ~ishghandle(args{i+1},'figure') && ~ishghandle(args{i+1},'uipanel')
            error(message('MATLAB:legend:InvalidParent', get(args{i+1},'Type')));
        end
    end
end

%----------------------------------------------------------------%
function validateLegendable(children)

% Objects input by user must be Legendable
if ~isempty(children)
    allLegendable = true;
    for i=1:numel(children)
        % isa operates on the class of the hetarray, not the individual
        % elements of the array.  So it cannot be used to check an array of
        % graphics objects against a mixin.
        if ~isa(children(i),'matlab.graphics.mixin.Legendable')
            allLegendable = false;
            break
        end
    end
    if ~allLegendable
        % @TODO - message catalog
        error(message('MATLAB:legend:ObjectsNotLegendable'));
    end
end

%----------------------------------------------------------------%
function children = getLegendableChildren(ha)

children = graph2dhelper('get_legendable_children', ha);

%----------------------------------------------------------------%
function set_children_and_strings(ha,hLeg,ch_in,str)
    
if ~isempty(ch_in)
    % check that all children from user are Legendable
    validateLegendable(ch_in);
    auto_children = false;
    ch = ch_in;
    
    % get all Legendable objects
    ch_all = getLegendableChildren(ha);
    ch_exclude = setdiff(ch_all,ch);
else
    % if isempty(ch_in), get children from axes
    ch = getLegendableChildren(ha);
    auto_children = true;
    ch_exclude = [];
end

% make sure we have column vectors
ch = ch(:);
ch_exclude = ch_exclude(:);

% if str is empty, create strings
if isempty(str)
    if auto_children && length(ch) > 50
        % only automatically add first 50 to cut down on huge lists
        ch = ch(1:50);
    end
    matlab.graphics.illustration.internal.generateDisplayNames(ch);
else
    % expand strings if possible
    % legend(p(1:2),['a';'b'])
    if (length(ch) ~= 1) && (length(str) == 1) && (size(str{1},1) > 1)
        str = cellstr(str{1});
    end

    % trim children or strings
    num_str = numel(str);
    num_ch = numel(ch);
    if num_str ~= num_ch
        if ~auto_children || length(str) > length(ch)
            warning(message('MATLAB:legend:IgnoringExtraEntries'));
        end
        if num_str > num_ch
            str = str(1:num_ch);
        else
            % user passed in more objects than strings
            % add extra objects to the exclude list
            ch_exclude = [ch_exclude; ch(num_str+1:end)];
            ch = ch(1:num_str);
        end
    end
    for k=1:length(ch)
        displayNameStr = deblank(str{k});
        % If the strings provided are a CHAR matrix, then we must split
        % them up using \n characters into a single char. g964785
        if ~isempty(displayNameStr) && ~isvector(displayNameStr)
            tempDisplayStr = deblank(displayNameStr(1,:));
            for l = 2:size(displayNameStr,1)
               tempDisplayStr = sprintf('%s\n%s', tempDisplayStr, deblank(displayNameStr(l,:)));
            end
            displayNameStr = tempDisplayStr;
        end
        ch(k).DisplayName = displayNameStr; 
    end
end

hLeg.PlotChildren_I = ch;
hLeg.PlotChildrenExcluded_I = ch_exclude;
hLeg.PlotChildrenSpecified = [];
if ~auto_children
    hLeg.PlotChildrenSpecified = ch;
end
removeAllEntries(hLeg);

%----------------------------------------------------------------%
function className = getClassName(obj)
% getClassName returns the class name with the package name omitted

className = class(obj);
idx = strfind(className,'.');
if ~isempty(idx)
    className = className(idx(end)+1:end);
end 

%----------------------------------------------------------------%
function [leg,labelhandles,outH,outM] = setOutArgs(arg)
[varargout{1:4}] = find_legend_info(arg);
    
if nargout > 0
    leg = varargout{1};
end
if nargout > 1
    labelhandles = varargout{2};
end
if nargout > 2
    outH = varargout{3};
end
if nargout > 3
    outM = varargout{4};
end

%----------------------------------------------------------------%
function tf = istextscalar(text)
tf = ischar(text) || (isstring(text) && isscalar(text));
  
%----------------------------------------------------------------%
function result = lcl_is2D(ax)
camUp = ax.Camera.UpVector;
result = isequal(ax.View,[0,90]) && isequal(abs(camUp),[0 1 0]); 

