function legacyMoveGUI(fig, position)
%LEGACYMOVEGUI Move a java figure window to a specified position on the screen.
%    fig is the handle to figure window
%    position is the specified position to move figure window on the screen

%   Copyright 1984-2017 The MathWorks, Inc.

% continue movegui operation for javafigure
oldfunits = get(fig, 'Units');
set(fig, 'Units', 'pixels');

widthAdjustment = 0;
heightAdjustment = 0;

drawnow
% check figure handle validity after the call to drawnow
% (input figure handle check has already been done)
if (~ishghandle(fig,'figure'))
    return;
end


oldpos = get(fig, 'OuterPosition');
if isunix
    oldpos = get(fig, 'Position');
end

if matlab.ui.internal.hasDisplay
    % check if the figure has a menubar
    haveMenubar = ~isempty(findall(fig,'type','uimenu'));
    
    % check if the figure has any toolbars 
    numToolbars = length(findall(fig,'type','uitoolbar'));

    
    if isunix
        % on unix, we can't rely on outerposition to place the figure
        % correctly.  use reasonable defaults and place using regular
        % position. 
        
        % reasonable defaults to calculate outer position 
        widthAddEstimate = 6;
        topEstimate1 = 24;
        topEstimate2 = 32;

        % estimate the outer position
        widthAdjustment =  widthAddEstimate;
        heightAdjustment = topEstimate1;

        if haveMenubar
            heightAdjustment = heightAdjustment + topEstimate2;
        end

        if numToolbars > 0
            heightAdjustment = heightAdjustment + topEstimate1 * numToolbars;
        end

        oldpos(3) = oldpos(3) + widthAdjustment;
        oldpos(4) = oldpos(4) + heightAdjustment;
    else
        % detect unreasonable outer position value
        % and try to correct it
        if (haveMenubar || numToolbars > 0)
            
            innerPos = get(fig,'Position');
            heightDiff = oldpos(4) - innerPos(4);
            
            minHeightDiff = 50;
            % if the difference between inner and outer height
            % is too small, let's query outer position again
            if (heightDiff < minHeightDiff)
                drawnow; 
                % check figure handle validity after the call to drawnow
                if (~ishghandle(fig,'figure'))
                    return;
                end
                oldpos = get(fig, 'OuterPosition');
            end
        end
    end
end

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
            margin = 30; % minimum edge margin

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
       newpos = newpos + [sx, sy];
    end
end

newpos(3:4) = [fwidth, fheight];

if isunix
    % remove width and height adjustments added above
    newpos(3) = newpos(3) - widthAdjustment;
    newpos(4) = newpos(4) - heightAdjustment;
    set(fig, 'Position', newpos);
else
    set(fig, 'OuterPosition', newpos);
end
set(fig, 'Units', oldfunits);