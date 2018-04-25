function [retval] = resetplotview(hAxes,varargin)
% Internal use only. This function may be removed in a future release.

% Copyright 2003-2017 The MathWorks, Inc.

% This helper is used by zoom, pan, and tools menu
%
% RESETPLOTVIEW(AX,'InitializeCurrentView') 
%     Saves current view only if no view information already exists. 
% RESETPLOTVIEW(AX,'BestDataFitView') 
%     Reset plot view to fit all applicable data
% RESETPLOTVIEW(AX,'SaveCurrentView') 
%     Stores view state (limits, camera) 
% RESETPLOTVIEW(AX,'SaveCurrentViewPropertyOnly') 
%     Stores a new View property only
% RESETPLOTVIEW(AX,'SaveCurrentViewLimitsOnly') 
%     Stores new Limits only
% RESETPLOTVIEW(AX,'GetStoredViewStruct') 
%     Retrieves view information in the form of a structure. 
% RESETPLOTVIEW(AX,'SetViewStruct',VIEWSTRUCT)
%     Sets the view information from the supplied struct
% RESETPLOTVIEW(AX,'ApplyStoredView') 
%     Apply stored view state to axes
% RESETPLOTVIEW(AX,'ApplyStoredViewLimitsOnly') 
%     Apply axes limit in stored state to axes
% RESETPLOTVIEW(AX,'ApplyStoredViewViewAngleOnly')
%     Apply axes camera view angle in stored state to axes


if any(isempty(hAxes)) || ...
  ~any(isgraphics(hAxes,'axes') | isgraphics(hAxes,'polaraxes'))
    return;
end

axesCount = [];
hAxes = handle(hAxes);
for n = 1:length(hAxes)
    if isappdata(hAxes(n),'graphics_linkaxes') && ~isempty(getappdata(hAxes(n),'graphics_linkaxes'))
        linkInfo = getappdata(hAxes(n),'graphics_linkaxes');
        if ishandle(linkInfo)
            axesCount = [axesCount get(linkInfo,'Targets')]; %#ok<AGROW>
        end
    end
end
hAxes = unique([axesCount(:); hAxes(:)]);

for n = 1:length(hAxes)
    retval = localResetPlotView(hAxes(n),varargin{:});
end

%--------------------------------------------------%
function [retval] = localResetPlotView(hAxes,varargin)

retval = [];
if nargin<2
  localAuto(hAxes);
  return;
end

if isa(hAxes,'matlab.graphics.axis.PolarAxes')
    return;
end

KEY = 'matlab_graphics_resetplotview';

switch varargin{1}
    case 'InitializeCurrentView'
        viewinfo = getappdata(hAxes,KEY);
        if isempty(viewinfo)
            viewinfo = localCreateViewInfo(hAxes);
            setappdata(hAxes,KEY,viewinfo);                
        end
    case 'SaveCurrentView'
        viewinfo = localCreateViewInfo(hAxes);
        setappdata(hAxes,KEY,viewinfo);  
    case 'SaveCurrentViewPropertyOnly'
        viewinfo = localViewPropertyInfo(hAxes, KEY);
        setappdata(hAxes,KEY,viewinfo); 
    case 'SaveCurrentViewLimitsOnly'
        viewinfo = localLimitsInfo(hAxes, KEY);
        setappdata(hAxes,KEY,viewinfo); 
    case 'GetStoredViewStruct'
        retval = getappdata(hAxes,KEY);
    case 'SetViewStruct'
        viewinfo = varargin{2};
        setappdata(hAxes,KEY,viewinfo);
    case 'ApplyStoredView'
        viewinfo = getappdata(hAxes,KEY);
        localApplyViewInfo(hAxes,viewinfo);
    case 'ApplyStoredViewLimitsOnly'
        viewinfo = getappdata(hAxes,KEY);
        localApplyLimits(hAxes,viewinfo);
    case 'ApplyStoredViewViewAngleOnly'
        viewinfo = getappdata(hAxes,KEY);
        localApplyViewAngle(hAxes,viewinfo);
    otherwise
        error(message('MATLAB:resetplotview:invalidInput'));
end

%----------------------------------------------------%
function [viewinfo] = localApplyViewAngle(hAxes,viewinfo)

if ~isempty(viewinfo)
    set(hAxes,'CameraViewAngle',viewinfo.CameraViewAngle);
end

%----------------------------------------------------%
function [viewinfo] = localApplyLimits(hAxes,viewinfo)

if ~isempty(viewinfo)
    
names = get(hAxes,'DimensionNames');
for n = names
    if isfield(viewinfo,[n{1} 'Lim']) && isprop(hAxes,[n{1} 'Lim'])
        hAxes.([n{1} 'Lim']) = viewinfo.([n{1} 'Lim']);
        hAxes.([n{1} 'LimMode']) = viewinfo.([n{1} 'LimMode']);
    end
end
drawnow;
end

%----------------------------------------------------%
function [viewinfo] = localApplyViewInfo(hAxes,viewinfo)

if ~isempty(viewinfo)
       
    % Reset all properties whose modes were in manual
    axes_properties = {'DataAspectRatio',...
        'CameraViewAngle',...
        'PlotBoxAspectRatio',...
        'CameraPosition',...
        'CameraTarget',...
        'CameraUpVector',...
        'XLim',...
        'YLim',...
        'ZLim'};
    
    % set all modes back
    for i = 1:numel(axes_properties)
        mode = [axes_properties{i} 'Mode'];
        set(hAxes,mode,viewinfo.(mode));
    end
    set(hAxes,'View',viewinfo.View);
    
    % set any properties that were saved in manual
    for i = 1:numel(axes_properties)
        prop = axes_properties{i};
        mode = [axes_properties{i} 'Mode'];
        if strcmpi(viewinfo.(mode),'manual')
            set(hAxes,prop,viewinfo.(prop))
        end
    end
    drawnow;
end
    
%----------------------------------------------------%
function [viewinfo] = localCreateViewInfo(hAxes)         

% Store axes view state

axes_properties = {'DataAspectRatio',...
                  'CameraViewAngle',...
                  'PlotBoxAspectRatio',...
                  'CameraPosition',...
                  'CameraTarget',...
                  'CameraUpVector',...
                  'XLim',...
                  'YLim',...
                  'ZLim'};

% Save the value of each axes property and its mode
for i = 1:numel(axes_properties)
    current_prop = axes_properties{i};
    current_mode = [axes_properties{i} 'Mode'];
    viewinfo.(current_mode) = get(hAxes,current_mode);
    % Only get properties in manual since getting them in auto can trigger
    % an auto-calc
    if strcmp(get(hAxes,current_mode),'manual')
        viewinfo.(current_prop) = get(hAxes,current_prop);
    end
end

[az, el] = view(hAxes);
viewinfo.View = [az, el];

%----------------------------------------------------%
function [viewinfo] = localViewPropertyInfo(hAxes, KEY)         
% localViewPropertyInfo updates only the View property of an existing
% "viewinfo". This is used by toolboxes, such as Curve Fitting, that want 
% to preserve all property values except for View.

viewinfo = getappdata(hAxes,KEY);
if isempty(viewinfo)
    viewinfo = localCreateViewInfo(hAxes);
else
    [az, el] = view(hAxes);
    viewinfo.View = [az, el];
end

%----------------------------------------------------%
function [viewinfo] = localLimitsInfo(hAxes, KEY)   
% localLimitsInfo  updates only the Limit properties of an existing
% "viewinfo". This is used by toolboxes, such as Curve Fitting, that want
% to preserve all values except for Limits.

viewinfo = getappdata(hAxes,KEY);
names = get(hAxes,'DimensionNames');
for n = names
    if isprop(hAxes,[n{1} 'Lim'])
        viewinfo.([n{1} 'Lim']) = hAxes.([n{1} 'Lim']);
        viewinfo.([n{1} 'LimMode']) = hAxes.([n{1} 'LimMode']);
    end   
end
    

%----------------------------------------------------%
function localAuto(hAxes)

% reset 2-D axes
if is2D(hAxes)
   axis(hAxes,'auto');
% reset 3-D axes  
else
   set(hAxes,'CameraViewAngleMode','auto');
   set(hAxes,'CameraTargetMode','auto');
end
drawnow;  
