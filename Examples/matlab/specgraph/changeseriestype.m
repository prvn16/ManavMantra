function h2 = changeseriestype(h1, newtype)
%CHANGESERIESTYPE Change a series plot type
%  Helper function for Plot Tool. Do not call directly.

%  H2 = CHANGESERIESTYPE(H1,NEWTYPE) switches series with handle
%  H1 to a new handle with same data and type NEWTYPE. H1 can be
%  a vector or cell array of handles.

%   Copyright 1984-2016 The MathWorks, Inc.

if ~any(strcmp(newtype,{'stem','line','bar','stairs','area'}))
    error(message('MATLAB:changeseriestype:InvalidType'));
end

%This drawnow ensures that all objects are in a good state.
drawnow;

returnCellArray = false;
if iscell(h1)
    h1 = [h1{:}];
    returnCellArray = true;
end
if isempty(h1) || all(ishghandle(h1,newtype))
    h2 = h1;
    return
end
h1(~ishghandle(h1)) = [];
if isempty(h1)
    error(message('MATLAB:changeseriestype:InvalidHandle'));
end
N = length(h1);
cax = ancestor(h1(1),'axes');
javaswitchprops = com.mathworks.page.plottool.PropertyEditor.getSwitchPropMapping(class(h1));
switchprops = cell(length(javaswitchprops),1);
for k=1:length(javaswitchprops)
    switchprops{k} = char(javaswitchprops(k));
end

if N == 1
    % Get the property values (vals) that correspond to switchprops
    vals = get(h1,switchprops);
    % replace FaceColor with Color after getting value
    facecolor = strcmp(switchprops,'FaceColor');
    if any(facecolor)
        switchprops{facecolor} = 'Color';
        vals{facecolor} = ensureRGBFaceColor(cax,h1,vals{facecolor});
    end
else
    switchprops = repmat({switchprops},N,1);
    vals = cell(1,N);
    for k=1:N
        vals{k} = get(h1(k),switchprops{k});
        % replace FaceColor with Color after getting value
        props = switchprops{k};
        facecolor = strcmp(props,'FaceColor');
        if any(facecolor)
            props{facecolor} = 'Color';
            switchprops{k} = props;
            val = vals{k};
            val{facecolor} = ensureRGBFaceColor(cax,h1(k),val{facecolor});
            vals{k} = val;
        end
    end
end

% If this is an Area or Bar object then record the peer IDs so it can be
% restored to the group if the type is switched back to Area or Bar.
if N == 1
    if ishghandle(h1,'bar')
        switchprops{end+1} = 'BarPeerID';
        vals{end+1} = h1.BarPeerID;
    elseif ishghandle(h1,'area')
        switchprops{end+1} = 'AreaPeerID';
        vals{end+1} = h1.AreaPeerID;
    end
elseif N > 1 && any(ishghandle(h1,'bar') | ishghandle(h1,'area'))
    for k=1:N
        if ishghandle(h1(k),'bar')
            switchprops{k}{end+1} = 'BarPeerID';
            vals{k}{end+1} = h1(k).BarPeerID;
        elseif ishghandle(h1(k),'area')
            switchprops{k}{end+1} = 'AreaPeerID';
            vals{k}{end+1} = h1(k).AreaPeerID;
        end
    end
end

% MCOS hg objects use an instance property rather than a class property
% for oldswitchprops & oldswitchvals
oldswitch = cell(1,N);
oldswitchvals = cell(1,N);
for n=1:N
    if isprop(h1(n),'oldswitchprops')
        oldswitch{n} = h1(n).oldswitchprops;
    else
        oldswitch{n} = [];
    end
    if isprop(h1(n),'oldswitchvals')
        oldswitchvals{n} = h1(n).oldswitchvals;
    else
        oldswitchvals{n} = [];
    end
end

if N > 1
    h2 = gobjects(N,1);
    for n=1:N
        h2(n) = change_one_series(h1(n),switchprops{n},vals{n},oldswitch{n},oldswitchvals{n},newtype);
    end
else
    h2 = change_one_series(h1,switchprops,vals,oldswitch{1},oldswitchvals{1},newtype);
end
h1(h1(:) == h2(:)) = []; % don't delete objects that we want to keep

selectobject(h2,'replace')
drawnow update
delete(h1);

plotdoneevent(cax,h2);
h2 = handle(h2); % plot tools expect handles not doubles
if (returnCellArray == true && length(h2) > 1)
    orig = h2;
    h2 = cell(1, length(orig));
    for i = 1:length(orig)
        h2{i} = orig(i);
    end
end

end

function h2=change_one_series(h1,switchprops,vals,oldswitch,oldswitchvals,newtype)
% compare newtype with existing class name of h1
cls = class(handle(h1));
if strcmp(newtype,'stairs')
    newcls = 'stairseries';
else
    newcls = [newtype 'series'];
end
if strncmpi(fliplr(cls),fliplr(newcls),length(newcls))
    h2 = h1;
    return;
end

% Add back any previously cached switchprops and their values. This enables
% properties which do not apply to previous object types in a sequence of
% series type changes to be restored. For example an Area object
% transitions to a Line and then to a Bar. The original Area BaseLine
% property is not used by Line but must be cached so that it can be access
% when transitioning to Bar.
for k=1:length(oldswitch)
    prop = oldswitch{k};
    val = oldswitchvals{k};
    if ~any(strcmp(prop,switchprops))
        switchprops = [switchprops(:)',{prop}];
        vals = [vals(:)', {val}];
    end
end

% Filter out properties that have the factory values
k = 1;
while k <= length(switchprops)
    % Exclude the property from switchprops if its Mode is auto and matches
    % a non-empty default
    propname = switchprops{k};
    if strcmp('Color',propname) && ~isprop(h1,'Color') && isprop(h1,'FaceColor')
        propname = 'FaceColor';
    end
    modeprop = sprintf('%sMode',propname);
    propIsManual = isprop(h1,modeprop) && strcmpi('manual',h1.(modeprop));
    if ~propIsManual
        defaultValue = localGetDefault(h1,propname);
        if ~isempty(defaultValue) && isequal(defaultValue, vals{k})
            switchprops(k) = [];
            vals(k) = [];
            continue;
        end
    end
    k=k+1;
end

ydata = get(h1,'ydata');

% Make sure to parent the new child to the right dataspace. In yyaxis we
% may have multiple dataspaces and parenting directly to the axes will
% cause parenting to the active one. therefore we need to make sure to get
% the right childcontainer for the new object.
hParent = h1.NodeParent;

try
    if strcmp(get(h1,'xdatamode'),'manual')
        xdata = get(h1,'xdata');
        pvpairs = {'xdata',xdata,'ydata',ydata,'parent',hParent};
    else
        pvpairs = {'ydata',ydata,'parent',hParent};
    end
catch err %#ok<NASGU>
end

switch newtype
    case 'line'
        h2 = matlab.graphics.chart.primitive.Line(pvpairs{end-1:end});
        set(h2,'XDataMode',get(h1,'XDataMode'));
        set(h2,pvpairs{1:end-2});
    case 'area'
        h2 = matlab.graphics.chart.primitive.Area(pvpairs{:});
    case 'bar'
        h2 = matlab.graphics.chart.primitive.Bar(pvpairs{:});
    case 'stairs'
        h2 = matlab.graphics.chart.primitive.Stair(pvpairs{:});
    case 'stem'
        h2 = matlab.graphics.chart.primitive.Stem(pvpairs{:});
end

% Preserve the original order of the children (g1074050)
if h1 ~= h2
    % Place the new object (h2) at the position of the replaced object h1
    childrenH = hParent.Children;
    
    h1Pos = find(childrenH == h1);
    h2Pos = find(childrenH == h2);
    
    objH1 = childrenH(h1Pos);
    childrenH(h1Pos) = childrenH(h2Pos);
    childrenH(h2Pos) = objH1;
    
    set(hParent,'Children',childrenH);
end

% For Area and Bar series we need to do some additional bookkeeping to add
% the new object to existing groups, if they exist. This includes assigning
% the peer ID and setting the correct colors. This must be done after
% inserting the new object into the original child order.
switch newtype
    case 'area'
        % Find the AreaPeerID to use for the new Area.
        areaPeerID = localFindPeerID(switchprops, vals, 'AreaPeerID', 'BarPeerID');
        
        % Assign the PeerID
        matlab.graphics.chart.primitive.Area.groupAreas(h2, areaPeerID);
        
        % Find the peers for the new Area
        % Querying AreaPeers will also update NumPeers when necessary.
        sibAreas = h2.AreaPeers;
        
        % Set the CData on the Areas in reverse child order.
        n = numel(sibAreas);
        for k = 1:n
            sibAreas(k).CData_I = k;
        end
    case 'bar'
        % Find the BarPeerID to use for the new Bar.
        barPeerID = localFindPeerID(switchprops, vals, 'BarPeerID', 'AreaPeerID');
        if isempty(barPeerID)
            barPeerID = matlab.graphics.chart.primitive.utilities.incrementPeerID();
        end
        
        % Assign the PeerID so the Bar is associated with the correct group
        h2.doPostSetup(barPeerID);
        
        % Find the peers for the new Bar
        % Querying BarPeers will also update NumPeers when necessary.
        sibBars = h2.BarPeers;
        
        % Set NumPeers on the Bars.
        n = numel(sibBars);
        for k = 1:n
            sibBars(k).NumPeers = n;
        end
end

for k=1:length(switchprops)
    try
        if ~isempty(h2.findprop('FaceColor')) && strcmp(switchprops{k},'Color')
            colorMode = findprop(h1,'ColorMode');
            if isempty(colorMode)
                colorMode = findprop(h1,'FaceColorMode');
            end
            % if ColorMode is auto in the current object (h1), keep the
            % default color in h2 as well. We cannot ask fot the default
            % value of the Color property because lines dont have a default
            % vaulue for that property.
            if strcmpi(h1.(colorMode.Name),'auto')
                continue;
            end
            set(h2,'FaceColor',vals{k});
        elseif isprop(h1,'FaceColor') && strcmp(switchprops{k},'Color')
            % If FaceColor was mapped to Color above be sure that the original
            % FaceColor was not equal to its default value before setting Color on
            % the new object.
            defaultColor = localGetDefault(h1,'FaceColor');
            if isequal(defaultColor,h1.FaceColor)
                continue;
            elseif ischar(defaultColor) && isnumeric(h1.FaceColor) && ...
                    isequal(h1.FaceColor(:),ensureRGBFaceColor(ancestor(h1,'axes'),h1,defaultColor))
                continue;
            elseif isnumeric(defaultColor) && ischar(h1.FaceColor) && ...
                    isequal(defaultColor(:),ensureRGBFaceColor(ancestor(h1,'axes'),h1,h1.FaceColor))
                continue;
            elseif ~isempty(h2.findprop(switchprops{k}))
                set(h2,switchprops{k},vals{k});
            end
        elseif ~isempty(h2.findprop(switchprops{k})) && strcmp('public',h2.findprop(switchprops{k}).SetAccess)
            set(h2,switchprops{k},vals{k});
        end
    catch err %#ok<NASGU>
    end
end
if isprop(h2,'RefreshMode')
    set(h2,'RefreshMode','auto');
end

if isempty(h2.findprop('oldswitchprops'))
    p = h2.addprop('oldswitchprops');
    p.Hidden = true;
    p.Transient = true;
end
if isempty(h2.findprop('oldswitchvals'))
    p = h2.addprop('oldswitchvals');
    p.Hidden = true;
    p.Transient = true;
end

% Cache the switchprops and their values so that they can be restored if
% the series switches back to its previous type. For example if a Bar
% object with BaseLine as a switchprop transitions to a Line and then back
% to a Bar, the original BaseLine should be restored.
set(h2,'oldswitchprops',[h2.oldswitchprops;switchprops]);
set(h2,'oldswitchvals',[h2.oldswitchvals,vals]);

% Carry over the "Tag" and "UserData" properties from the original handle:
set(h2,'Tag',get(h1,'Tag'),'UserData',get(h1,'UserData'));

end

function color = ensureRGBFaceColor(ax, h, color)

% If the color is a string such as 'flat', convert it to an rgb value
% for the object h
if ischar(color)
    fig = ancestor(ax,'figure');
    cmap = get(fig,'Colormap');
    if isempty(cmap), return; end
    cachedFaceColor = h.FaceColor;
    if isequal(color,cachedFaceColor)
        fvdata = double(get(h.Face,'ColorData'));
    else
        % If the color is different from the FaceColor, temporarily
        % assign the FaceColor of the object to FaceColor and obtain the
        % resulting ColorData.
        h.FaceColor = color;
        drawnow update
        fvdata = double(get(h.Face,'ColorData'));
        h.FaceColor = cachedFaceColor;
    end
    color = fvdata(1:3)/255;
    
end

end


function defaultValue = localGetDefault(h,propName)

defaultValue = [];
if ~isprop(h,propName)
    return
end

prop = h.findprop(propName);
if prop.HasDefault
    defaultValue = prop.DefaultValue;
    return;
end

prop = h.findprop([propName '_I']);
if isempty(prop)
    return
end

if prop.HasDefault
    defaultValue = prop.DefaultValue;
end

end

function peerID = localFindPeerID(switchprops, vals, newType, otherType)
% Determine whether this object used to be a bar or area and if so, return
% the PeerID associated with that bar or area.

% For example: If the new type is an area, and this object used to be a
% bar, but was never an area, then we will use the BarPeerID as the
% AreaPeerID so that bar series that are converted to area series stay
% together (and vice versa).

% Look for the new type first
switchInd = strcmp(switchprops,newType);

if sum(switchInd) == 1
    % This object is switching back to a previous type, use the old peer ID
    peerID = vals{switchInd};
else
    % The object has no record of a peer ID for its new type (bar vs.
    % area), so look for a peer ID for the other type.
    switchInd = strcmp(switchprops, otherType);
    
    if sum(switchInd) == 1
        % We found a peer ID for the other type, so use it.
        peerID = vals{switchInd};
    else
        % This object has never been either a bar or area.
        peerID = [];
    end
end

end
