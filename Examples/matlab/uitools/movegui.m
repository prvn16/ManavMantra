function movegui(varargin)
%MOVEGUI Move a figure window to a specified position on the screen.
%    MOVEGUI(H, POSITION) moves the figure associated with handle H to
%    the specified POSITION on the screen, preserving its size.
%
%    H can be the handle to a figure, or to any object within a figure
%
%    The POSITION argument can be any one of the strings:
%     'north'     - top center edge of screen
%     'south'     - bottom center edge of screen
%     'east'      - right center edge of screen
%     'west'      - left center edge of screen
%     'northeast' - top right corner of screen
%     'northwest' - top left corner of screen
%     'southeast' - bottom right corner of screen
%     'southwest' - bottom left corner of screen
%     'center'    - center of screen
%     'onscreen'  - nearest onscreen location to current position (with an
%     additional inset of 30 pixels from the edge of the screen). If the
%     figure is bigger than the screen size, this moves the top-left corner
%     of the figure window onscreen.
%
%    The POSITION argument can also be a two-element vector [H V],
%    where depending on sign, H specifies the figure's offset from the
%    left or right edge of the screen, and V specifies the figure's
%    offset from the top or bottom of the screen, in pixels:
%     H (for h >= 0) offset of left side from left edge of screen
%     H (for h < 0)  offset of right side from right edge of screen
%     V (for v >= 0) offset of bottom edge from bottom of screen
%     V (for v < 0)  offset of top edge from top of screen
%
%    MOVEGUI(H) moves the figure associated with handle H 'onscreen'.
%
%    MOVEGUI(POSITION) moves the GCF or GCBF to the specified position.
%
%    MOVEGUI moves the GCF or GCBF 'onscreen' (useful as a string-based
%    CreateFcn callback for a saved figure, to ensure it will appear
%    onscreen when reloaded, regardless of its saved position)
%
%    MOVEGUI(H, <event data>)
%    MOVEGUI(H, <event data>, POSITION) when used as a function-handle
%    callback, moves the figure specified by H to the default position,
%    or to the specified position, safely ignoring the automatically
%    passed-in event data struct.
%
%    Example:
%    This example demonstrates MOVEGUIs usefulness as a means of ensuring
%    that a saved GUI will appear onscreen when reloaded, regardless of
%    differences between screen sizes and resolutions between the machines
%    on which it was saved and reloaded.  It creates a figure off the
%    screen, assigns MOVEGUI as its CreateFcn callback, then saves and
%    reloads the figure:
%
%    	f=figure('position', [10000, 10000, 400, 300]);
%    	f.CreateFcn = 'movegui';
%    	hgsave(f, 'onscreenfig')
%    	close(f)
%    	f2 = hgload('onscreenfig')
%
%    The following are a few variations on ways MOVEGUI can be assigned as
%    the CreateFcn, using both string and function-handle callbacks, with
%    and without extra arguments, to achieve a variety of behaviors:
%
%    	figure('CreateFcn','movegui center')
%    	figure('CreateFcn',@movegui)
%    	figure('CreateFcn',{@movegui, 'northeast'})
%    	figure('CreateFcn',{@movegui, [-100 -50]})
%
%    See also OPENFIG, GUIHANDLES, GUIDATA, GUIDE.

%   Copyright 1984-2017 The MathWorks, Inc.

POSITIONS = {'north','south','east','west',...
        'northeast','southeast','northwest','southwest',...
        'center','onscreen'};

narginchk(0, 3);

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% initialize position and figure
position = '';
fig = [];

% validate and process varargin for movegui
for i=1:nargin
    numelem = numel(varargin{i});
    if numelem == 1 && ishghandle(varargin{i})
        fig = get_parent_fig(varargin{i});
        if isempty(fig)
            error(message('MATLAB:movegui:InvalidHandle'));
        end
    elseif ischar(varargin{i})
        position = varargin{i};
        if isempty(strmatch(position,POSITIONS,'exact'))
            error(message('MATLAB:movegui:UnrecognizedPosition'));
        end
    elseif isnumeric(varargin{i}) && numelem == 2
        position = varargin{i};
    elseif ~isempty(gcbo) && i==2
        continue; % skip past the event data struct, if in a callback
    else
        error(message('MATLAB:movegio:UnrecognizedInput'));
    end
end

% if figure is empty get handle using gcf/gcbf
if isempty(fig)
    fig = gcbf;
    if(isempty(fig))
        fig = gcf;
    end
end

% assign onscreen as position when empty
if isempty(position)
    position = 'onscreen';
end

% forward function call to legacymovegui for java figure
if ~(matlab.ui.internal.isUIFigure(fig))
    % skipping event data struct since it is not used
    matlab.ui.internal.legacyMoveGUI(fig, position);
    return;
end

oldfunits = get(fig, 'Units');
set(fig, 'Units', 'pixels');

drawnow
% check figure handle validity after the call to drawnow
% (input figure handle check has already been done)
if (~ishghandle(fig,'figure'))
    return;
end

% save figure position before making adjustments
oldpos = get(fig, 'Position');

% initialize width and height adjustments
widthAdjustment = 0;
heightAdjustment = 0;

% estimated value of toolbar
toolBarEstimate = 24;

% we can't rely on outerposition to place the uifigure
% correctly.  use reasonable defaults and place using regular
% position. 

if isunix
    % reasonable defaults to calculate outer position in unix

    % border estimate for figure window
    borderEstimate = 0;
    % padding value to account backward compatibility
    paddingEstimate = 6;
    % width adjustment is border value plus padding value of window
    widthAdjustment = borderEstimate + paddingEstimate;
    % estimated value of titlebar
    titleBarEstimate = 24;
    % estimated value of menubar
    menuBarEstimate = 22;
else
    % reasonable defaults to calculate outer position in windows

    % border estimate for figure window
    borderEstimate = 8;
    % border value of both left and right side of window
    widthAdjustment = borderEstimate * 2;
    % estimated value of titlebar
    titleBarEstimate = 31;
    % estimated value of menubar
    menuBarEstimate = 22;
end

% estimate the outer position
heightAdjustment = titleBarEstimate + borderEstimate;

% check if the figure has a menubar
haveMenubar = ~isempty(findall(fig,'type','uimenu'));

% check if the figure has any toolbars 
numToolbars = length(findall(fig,'type','uitoolbar'));

if haveMenubar
    heightAdjustment = heightAdjustment + menuBarEstimate;
end

if numToolbars > 0
    heightAdjustment = heightAdjustment + toolBarEstimate * numToolbars;
end

oldpos(3) = oldpos(3) + widthAdjustment;
oldpos(4) = oldpos(4) + heightAdjustment;

fleft   = oldpos(1);
fbottom = oldpos(2);
fwidth  = oldpos(3);
fheight = oldpos(4);

old0units = get(0, 'Units');
set(0, 'Units', 'pixels');
screensize = get(0, 'ScreenSize');
monitors = get(0,'MonitorPositions');
set(0, 'Units', old0units);

% Determine which monitor contains atleast one of the corners of the figure window
% We cycle through each monitor and check the four corners of the figure. Starting with bottom left, moving clockwise. 
% If any one of the corners is found to be within a particular monitor we break the search and that monitor is used as the reference screen size for further calculations. 
for k = 1:size(monitors,1)
    monitorPos = monitors(k,:);    
    if (((fleft > monitorPos(1)) && (fleft < monitorPos(1) + monitorPos(3)) && (fbottom > monitorPos(2)) && (fbottom < monitorPos(2) + monitorPos(4))) || ... % bottom left
        ((fleft > monitorPos(1)) && (fleft < monitorPos(1) + monitorPos(3)) && (fbottom + fheight > monitorPos(2)) && (fbottom + fheight < monitorPos(2) + monitorPos(4))) || ... % left top
        ((fleft + fwidth > monitorPos(1)) && (fleft + fwidth < monitorPos(1) + monitorPos(3)) && (fbottom + fheight > monitorPos(2)) && (fbottom + fheight < monitorPos(2) + monitorPos(4))) || ... % top right 
        ((fleft + fwidth > monitorPos(1)) && (fleft + fwidth < monitorPos(1) + monitorPos(3)) && (fbottom > monitorPos(2)) && (fbottom < monitorPos(2) + monitorPos(4)))) % bottom right
        screensize = monitorPos;
        break;
    end
end

sx = screensize(1);
sy = screensize(2);
swidth = screensize(3);
sheight = screensize(4);
% make sure the figure is not bigger than the screen size
fwidth = min(fwidth, swidth);
fheight = min(fheight, sheight);

% swidth - fwidth == remaining width
rwidth  = swidth-fwidth;

% sheight - fheight == remaining height
rheight = sheight-fheight;


if isnumeric(position)
    newpos = position;
    if(newpos(1) < 0),	newpos(1) = rwidth + newpos(1); end
    if(newpos(2) < 0),	newpos(2) = rheight + newpos(2); end
else
    switch position
        case 'north',	newpos = [rwidth/2,   rheight];
        case 'south',	newpos = [rwidth/2,         0];
        case 'east',	newpos = [  rwidth, rheight/2];
        case 'west',	newpos = [       0, rheight/2];
        case 'northeast',  newpos = [  rwidth,   rheight];
        case 'southeast',  newpos = [  rwidth,         0];
        case 'northwest',  newpos = [       0,   rheight];
        case 'southwest',  newpos = [       0,         0];
        case 'center',	newpos = [rwidth/2, rheight/2];
        case 'onscreen'
            % minimum edge margin plus border estimate
            margin = 30 + borderEstimate;
            
            % Re-calculate position so that the right and bottom edges can
            % be moved on-screen if they are off.
            if fleft > sx + rwidth - margin
                fleft = sx + rwidth - margin;
            end
            if fbottom < sy + margin
                fbottom = sy + margin;
            end
            %Recalculate the position for the left and top edge now. The
            %calculation above may move the figure off screen on the left
            %or top. We contract here is to get the figure onscreen with
            %atleast the top left corner showing (within the 30 pix inset).
            if fleft < sx + margin
                fleft = sx + margin;
            end
            if fbottom > sy + rheight - margin
                fbottom = sy + rheight - margin;
            end
            newpos = [fleft, fbottom];
    end
    if ~strcmpi(position, 'onscreen')
        % adjustment needed for window border
        newpos = newpos + [sx + borderEstimate, sy + borderEstimate];
    end
end

newpos(3:4) = [fwidth, fheight];

% remove width and height adjustments added above
newpos(3) = newpos(3) - widthAdjustment;
newpos(4) = newpos(4) - heightAdjustment;
set(fig, 'Position', newpos);

set(fig, 'Units', oldfunits);

%----------------------------------------------------
function h = get_parent_fig(h)
while ~isempty(h) && ~strcmp(get(h,'Type'), 'figure')
    h = get(h, 'Parent');
end
