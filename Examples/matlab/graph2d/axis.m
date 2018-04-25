function [ans1, ans2, ans3] = axis(varargin)
%AXIS  Control axis scaling and appearance.
%   AXIS([XMIN XMAX YMIN YMAX]) sets scaling for the x- and y-axes
%      on the current plot.
%   AXIS([XMIN XMAX YMIN YMAX ZMIN ZMAX]) sets the scaling for the
%      x-, y- and z-axes on the current 3-D plot.
%   AXIS([XMIN XMAX YMIN YMAX ZMIN ZMAX CMIN CMAX]) sets the
%      scaling for the x-, y-, z-axes and color scaling limits on
%      the current axis (see CAXIS). 
%   V = AXIS returns a row vector containing the scaling for the
%      current plot.  If the current view is 2-D, V has four
%      components; if it is 3-D, V has six components.
%
%   AXIS AUTO  returns the axis scaling to its default, automatic
%      mode where, for each dimension, 'nice' limits are chosen based
%      on the extents of all line, surface, patch, and image children.
%   AXIS MANUAL  freezes the scaling at the current limits, so that if
%      HOLD is turned on, subsequent plots will use the same limits.
%   AXIS TIGHT  sets the axis limits to the range of the data.
%   AXIS FILL  sets the axis limits and PlotBoxAspectRatio so that
%      the axis fills the position rectangle.  This option only has
%      an effect if PlotBoxAspectRatioMode or DataAspectRatioMode are
%      manual.
%
%   AXIS IJ  puts MATLAB into its "matrix" axes mode.  The coordinate
%      system origin is at the upper left corner.  The i axis is
%      vertical and is numbered from top to bottom.  The j axis is
%      horizontal and is numbered from left to right.
%   AXIS XY  puts MATLAB into its default "Cartesian" axes mode.  The
%      coordinate system origin is at the lower left corner.  The x
%      axis is horizontal and is numbered from left to right.  The y
%      axis is vertical and is numbered from bottom to top.
%
%   AXIS EQUAL  sets the aspect ratio so that equal tick mark
%      increments on the x-,y- and z-axis are equal in size. This
%      makes SPHERE(25) look like a sphere, instead of an ellipsoid.
%   AXIS IMAGE  is the same as AXIS EQUAL except that the plot
%      box fits tightly around the data.
%   AXIS SQUARE  makes the current axis box square in size.
%   AXIS NORMAL  restores the current axis box to full size and
%       removes any restrictions on the scaling of the units.
%       This undoes the effects of AXIS SQUARE and AXIS EQUAL.
%   AXIS VIS3D  freezes aspect ratio properties to enable rotation of
%       3-D objects and overrides stretch-to-fill.
%
%   AXIS OFF  turns off all axis labeling, tick marks and background.
%   AXIS ON  turns axis labeling, tick marks and background back on.
%
%   AXIS(H,...) changes the axes handles listed in vector H.
%
%   See also AXES, GRID, SUBPLOT, XLIM, YLIM, ZLIM, RLIM

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

%get the list of axes to operate upon
if ~isempty(varargin) && allAxes(varargin{1})
    
    ax = varargin{1}(:);
    varargin=varargin(2:end);
else
    ax = gca;
    if ~isa(ax,'matlab.graphics.axis.AbstractAxes')
         error(message('MATLAB:Chart:UnsupportedConvenienceFunction', 'axis', ax.Type));
    end
end

ans1set = false;
pbarlimit = 0.1;

%---Check for bypass option (only supported for single axes)
if length(ax)==1 && isappdata(ax,'MWBYPASS_axis')
    if isempty(varargin)
        ans1 = mwbypass(ax,'MWBYPASS_axis');
        ans1set = true;
    else
        mwbypass(ax,'MWBYPASS_axis',varargin{:});
    end
elseif isempty(varargin)
    if length(ax)==1
        error(LocCheckCompatibleLimits(ax));
        ans1=LocGetLimits(ax);
        ans1set = true;
    else
        ans1=cell(length(ax),1);
        ans1set = true;
        for i=1:length(ax)
            error(LocCheckCompatibleLimits(ax(i)));
            ans1{i}=LocGetLimits(ax(i));    
        end
    end
else
    for j=1:length(ax)
        matlab.graphics.internal.markFigure(ax(j));
        for i = 1:length(varargin)
            cur_arg = varargin{i};
            names = get(ax(j),'DimensionNames');
            
            % Set limits manually with 4/6/8 element vector
            if ~ischar(cur_arg)
                error(LocCheckCompatibleLimits(ax(j)));
                LocSetLimits(ax(j),cur_arg,names);
                
                % handle AUTO, AUTO[XYZ]:
            elseif strcmp(cur_arg(1:min(4,length(cur_arg))),'auto')
                LocSetAuto(ax(j),cur_arg,names);
                
                % handle TIGHT
            elseif(strcmp(cur_arg,'tight'))
                LocSetTight(ax(j),names);
                
                % handle FILL:
            elseif(strcmp(cur_arg, 'fill'))
                if ~iscartesian(ax(j))
                    error(message('MATLAB:axis:CartesianAxes', cur_arg));
                end
                if ~isnumericAxes(ax(j))
                    error(message('MATLAB:axis:NumericAxes', cur_arg));
                end
                LocSetFill(ax(j),pbarlimit);
                
                % handle MANUAL:
            elseif(strcmp(cur_arg, 'manual'))
                LocSetManual(ax(j),names);
                
                % handle IJ:
            elseif(strcmp(cur_arg, 'ij'))
                if ~iscartesian(ax(j))
                    error(message('MATLAB:axis:CartesianAxes', cur_arg));
                end
                set(ax(j),...
                    'XDir','normal',...
                    'YDir','reverse');
                
                % handle XY:
            elseif(strcmp(cur_arg, 'xy'))
                if ~iscartesian(ax(j))
                    error(message('MATLAB:axis:CartesianAxes', cur_arg));
                end
                set(ax(j),...
                    'XDir','normal',...
                    'YDir','normal');
                
                % handle SQUARE:
            elseif(strcmp(cur_arg, 'square')) 
                if ~iscartesian(ax(j))
                    error(message('MATLAB:axis:CartesianAxes', cur_arg));
                end
                set(ax(j),...
                    'PlotBoxAspectRatio',[1 1 1],...
                    'DataAspectRatioMode','auto')
                
                % handle EQUAL:
            elseif(strcmp(cur_arg, 'equal'))
                if ~iscartesian(ax(j))
                    error(message('MATLAB:axis:CartesianAxes', cur_arg));
                end
                if ~isnumericAxes(ax(j))
                    error(message('MATLAB:axis:NumericAxes', cur_arg));
                end
                LocSetEqual(ax(j),pbarlimit);
                
                % handle IMAGE:
            elseif(strcmp(cur_arg,'image'))
                if ~iscartesian(ax(j))
                    error(message('MATLAB:axis:CartesianAxes', cur_arg));
                end
                if ~isnumericAxes(ax(j))
                    error(message('MATLAB:axis:NumericAxes', cur_arg));
                end
                LocSetImage(ax(j),pbarlimit);
                
                % handle NORMAL:
            elseif(strcmp(cur_arg, 'normal'))
                hax = handle(ax(j));
                if isprop(hax,'PlotBoxAspectRatioMode')
                    set(ax(j),'PlotBoxAspectRatioMode','auto');
                end
                if isprop(hax,'DataAspectRatioMode')
                    set(ax(j),'DataAspectRatioMode','auto');
                end
                if isprop(hax,'CameraViewAngleMode')
                    set(ax(j),'CameraViewAngleMode','auto');
                end

                % handle OFF:
            elseif(strcmp(cur_arg, 'off'))
                set(ax(j),'Visible','off');
                set(get(ax(j),'Title'),'Visible','on');
                
            % handle ON:
            elseif(strcmp(cur_arg, 'on'))
                set(ax(j),'Visible','on');
                
            % handle VIS3D:
            elseif(strcmp(cur_arg,'vis3d'))
                if ~iscartesian(ax(j))
                    error(message('MATLAB:axis:CartesianAxes', cur_arg));
                end
                set(ax(j),'CameraViewAngle',get(ax(j),'CameraViewAngle'));
                set(ax(j),'PlotBoxAspectRatio',get(ax(j),'PlotBoxAspectRatio'));
                set(ax(j),'DataAspectRatio',get(ax(j),'DataAspectRatio'));
                
            % handle STATE:
            elseif(strcmp(cur_arg, 'state'))
                if ~iscartesian(ax(j))
                    error(message('MATLAB:axis:CartesianAxes', cur_arg));
                end
                warning('MATLAB:graph2d:axis:ObsoleteState', '%s', getString(message('MATLAB:axis:ObsoleteState')));
                %note that this will keep overwriting arg1 etc if there is more
                %than one axes in the list
                [ans1,ans2,ans3]=LocGetState(ax(1));
                ans1set = true;
                
                %if nargout>1
                %    ans2=ans2q;
                %    if nargout>2
                %        ans3=ans3q;
                %    end
                %end
                
            % handle ERROR (NONE OF THE ABOVE STRINGS FOUND):
            else
                error(message('MATLAB:axis:UnknownOption', cur_arg));
            end
        end
    end
end

if nargout > 0 && ~ans1set
    nargoutchk(0, 0);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ans1=LocCheckCompatibleLimits(axH)
%returns error message or empty
ans1 = '';
names = get(axH,'DimensionNames');
v1 = get(axH,[names{1} 'Lim']);
v2 = get(axH,[names{2} 'Lim']);
if is2D(axH) 
    if isnumeric(v1) && isnumeric(v2)
        return;
    end
    if ~strcmp(class(v1),class(v2))
        ans1 = message('MATLAB:axis:Mixed2D');
    end
else
    v3 = get(axH,[names{3} 'Lim']);
    if isnumeric(v1) && isnumeric(v2) && isnumeric(v3)
        return;
    end
    if ~strcmp(class(v1),class(v2)) || ~strcmp(class(v1),class(v3))
        ans1 = message('MATLAB:axis:Mixed3D');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ans1=LocGetLimits(axH)
%returns a 4 or 6 element vector of limits for a single axis

names = get(axH,'DimensionNames');
ans1 = [get(axH,[names{1} 'Lim']) get(axH,[names{2} 'Lim'])];
if ~is2D(axH) 
    ans1 = [ans1 get(axH,[names{3} 'Lim'])];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocSetLimits(ax,lims,names)

if (length(lims) == 4) || (length(lims) == 6 || (length(lims) == 8))
    set(ax,...
        [names{1} 'Lim'],lims(1:2),...
        [names{2} 'Lim'],lims(3:4),...
        [names{1} 'LimMode'],'manual',...
        [names{2} 'LimMode'],'manual');
    
    if hasZProperties(handle(ax)) && (length(lims) == 6 || length(lims) == 8)
        set(ax,...
            [names{3} 'Lim'],lims(5:6),...
            [names{3} 'LimMode'],'manual');
    end
    
    if length(lims) == 8
        set(ax,...
            'CLim',lims(7:8),...
            'CLimMode','manual');
    end
    
    if length(lims) == 4 && ~strcmp(get(ax,'NextPlot'),'add')
        if hasCameraProperties(handle(ax))
            set(ax,'CameraPositionMode','auto',...
                'CameraTargetMode','auto',...
                'CameraUpVectorMode','auto')
        end
        set(ax,'View',[0 90]);
    elseif length(lims) == 6 && ...
            isequal(get(ax,'View'),[0 90]) && ...
            ~strcmp(get(ax,'NextPlot'),'add')
        if hasCameraProperties(handle(ax))
            set(ax,'CameraPositionMode','auto',...
                'CameraTargetMode','auto',...
                'CameraUpVectorMode','auto')
        end
        set(ax,'View',[-37.5,30]);
    end
else
    error(message('MATLAB:axis:WrongNumberElements'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocSetAuto(ax,cur_arg,names)
%called in response to axis auto[xyz]

do_all = (length(cur_arg) == length('auto'));
do_x = length(find(cur_arg == 'x'));
do_y = length(find(cur_arg == 'y'));
do_z = length(find(cur_arg == 'z'));
if(do_all || do_x)
    set(ax,[names{1} 'LimSpec'],'stretch');
    set(ax,[names{1} 'LimMode'],'auto');
else
    set(ax,[names{1} 'LimMode'],'manual');
end
if(do_all || do_y)
    set(ax,[names{2} 'LimSpec'],'stretch');
    set(ax,[names{2} 'LimMode'],'auto');
else
    set(ax,[names{2} 'LimMode'],'manual');
end
if hasZProperties(handle(ax))
    if(do_all || do_z)
        set(ax,[names{3} 'LimSpec'],'stretch');
        set(ax,[names{3} 'LimMode'],'auto');
    else
        set(ax,[names{3} 'LimMode'],'manual');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocSetManual(ax,names)
get(ax,{[names{1} 'Lim'],[names{2} 'Lim']});
hasZ = hasZProperties(handle(ax));
if hasZ
    get(ax, [names{3} 'Lim']);
end
set(ax,...
    [names{1} 'LimMode'],'manual',...
    [names{2} 'LimMode'],'manual');
if hasZ
    set(ax, [names{3} 'LimMode'], 'manual');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocSetTight(ax,names)
set(ax,[names{1} 'LimSpec'],'tight',[names{2} 'LimSpec'],'tight');
set(ax,[names{1} 'LimMode'],'auto',[names{2} 'LimMode'],'auto')
if hasZProperties(handle(ax))
    set(ax,[names{3} 'LimSpec'],'tight');
    set(ax,[names{3} 'LimMode'],'auto');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocSetFill(ax,pbarlimit)
%called in response to axis fill

if strcmp(get(ax,'PlotBoxAspectRatioMode'),'manual') || ...
        strcmp(get(ax,'DataAspectRatioMode'),'manual')
    % Check for 3-D plot
    if all(rem(get(ax,'view'),90)~=0)
        a = axis(ax);
        axis(ax,'auto');
        axis(ax,'image');
        pbar = get(ax,'PlotBoxAspectRatio');
        
        if pbar(1)~=pbarlimit, set(ax,'xlim',a(1:2)); end
        if pbar(2)~=pbarlimit, set(ax,'ylim',a(3:4)); end
        if pbar(3)~=pbarlimit, set(ax,'zlim',a(5:6)); end
        return
    end
    
    a = getpixelposition(ax);
    % Change the unconstrained axis limit to 'auto'
    % based on the axis position.  Also set the pbar.
    set(ax,'PlotBoxAspectRatio',a([3 4 4]))
    if a(3) > a(4)
        set(ax,'xlimmode','auto')
    else
        set(ax,'ylimmode','auto')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocSetEqual(ax,pbarlimit)
%called in response to axis equal

% Check for 3-D plot.  If so, use AXIS IMAGE.
if all(rem(get(ax,'view'),90)~=0)
    LocSetImage(ax,pbarlimit);
    return
end

a = getpixelposition(ax);
set(ax,'DataAspectRatio',[1 1 1]);
dx = diff(get(ax,'xlim'));
dy = diff(get(ax,'ylim'));
dz = 1;
if hasZProperties(handle(ax))
    dz = diff(get(ax,'ZLim'));
end
set(ax,'PlotBoxAspectRatioMode','auto')
pbar = get(ax,'PlotBoxAspectRatio');
set(ax,'PlotBoxAspectRatio', ...
    [a(3) a(4) dz*min(a(3),a(4))/min(dx,dy)]);

% Change the unconstrained axis limit to auto based
% on the PBAR.
if pbar(1)/a(3) < pbar(2)/a(4)
    set(ax,'xlimmode','auto')
else
    set(ax,'ylimmode','auto')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocSetImage(ax,pbarlimit)

set(ax,...
    'DataAspectRatio',[1 1 1], ...
    'PlotBoxAspectRatioMode','auto')

% Limit plotbox aspect ratio to 1 to 25 ratio.
pbar = get(ax,'PlotBoxAspectRatio');
pbar = max(pbarlimit,pbar / max(pbar));
if any(pbar(1:2) == pbarlimit)
    set(ax,'PlotBoxAspectRatio',pbar)
end

names = get(ax,'DimensionNames');
LocSetTight(ax,names);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ans1,ans2,ans3]= LocGetState(ax)

str = '';
if(strcmp(get(ax,'XLimMode'), 'auto'))
    str = 'x';
end

if(strcmp(get(ax,'YLimMode'), 'auto'))
    str = [str, 'y'];
end

if(strcmp(get(ax,'ZLimMode'), 'auto'))
    str = [str, 'z'];
end

if length(str) == 3
    ans1 = 'auto';
else
    ans1 = 'manual';
end

if strcmp(get(ax,'Visible'),'on')
    ans2 = 'on';
else
    ans2 = 'off';
end

if(strcmp(get(ax,'XDir'),'normal') && ...
        strcmp(get(ax,'YDir'),'reverse'))
    ans3 = 'ij';
else
    ans3 = 'xy';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = allAxes(h)

result = all(ishghandle(h(:))) && ...
         length(findobj(h(:),'-regexp','Type','.*axes','-depth',0)) == length(h(:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = iscartesian(h)
if isa(h,'matlab.ui.control.UIAxes')
    result = true;
else    
    ds = get(h,'DataSpace');
    result = strcmp(ds(1).isCurvilinear,'off');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = isnumericAxes(h)
result = isnumeric(get(h,'XLim'));
result = result && isnumeric(get(h,'YLim'));
if hasZProperties(handle(h))
    result = result && isnumeric(get(h,'ZLim'));
end
