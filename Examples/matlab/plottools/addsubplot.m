function ax = addsubplot (varargin)
% This undocumented function may be removed in a future release.
  
% ADDSUBPLOT creates a new subplot and adds it to the figure at the given location.
%    ADDSUBPLOT (fig, WHERE) creates a cartplane at the specified location.
%    ADDSUBPLOT (fig, WHERE, CMD, ...) creates an axes using the specified command
%      with optional arguments.
% For instance, ADDSUBPLOT (fig, 'Top') puts the new axes across the top of
% the figure.  Other locations are 'Bottom', 'Left', and 'Right'.
% The remaining arguments are passed to the axes being created.

% Copyright 2002-2015 The MathWorks, Inc.

%---------------------------------------------------
% Get a figure to put the plot on:
if (nargin > 0) 
     fig = varargin{1};
     if ~ishghandle (fig,'figure') && ~ishghandle (fig,'uicontainer') && ...
             ~ishghandle (fig,'uitab')
         error (message('MATLAB:addsubplot:InvalidFigureHandle'));
     end
else
     fig = figure;
end

%---------------------------------------------------
% Get the location of the new axes:

if (nargin > 1)
     where = varargin{2};
else
     where = 'Bottom';
end

%---------------------------------------------------
% Get the command with which to make the axes:

if (nargin > 2)
     axesCmd = varargin{3};
else
     axesCmd = 'axes';
end

%---------------------------------------------------
% Figure out the "squish factor," or by how much to compress the 
% existing plots:

figH = handle(fig);
children = findobj(figH.Children,...
    'flat', ...
    {'Type','axes', '-or', 'Type', 'polaraxes', '-or', ...
    '-isa', 'matlab.graphics.chart.Chart'}, ...
    'HandleVisibility', 'on', ...
    '-not','Tag','legend','-and','-not','Tag','Colorbar');
[children,plotyyAxesExist] = localRemovePlotyy(children);

% Note:  this is the same search used in plottoolfunc.

origNum = length(children);

%---------------------------------------------------
% Figure out the outer position of the new axes:

newPlotX = 0;
newPlotY = 0;
newPlotWidth = 1;
newPlotHeight = 1;
if (strcmpi (where, 'Bottom') == 1)
        newPlotHeight = 1 / (origNum + 1);
elseif (strcmpi (where, 'Top') == 1)
        newPlotHeight = 1 / (origNum + 1);
	newPlotY = 1 - newPlotHeight;
elseif (strcmpi (where, 'Left') == 1)
        newPlotWidth = 1 / (origNum + 1);
elseif (strcmpi (where, 'Right') == 1)
        newPlotWidth = 1 / (origNum + 1);
	newPlotX = 1 - newPlotWidth;
end


if origNum == 0 
    squishFactor = 1;
else
    squishFactor = origNum / (origNum + 1);
end
% TODO:  squishFactor could depend on more complicated heuristics;
% e.g. how many subplots tall is it, vs. how many total subplots



%---------------------------------------------------
% Create the new axes:

if (nargin > 3)
     thing = feval (axesCmd, varargin{4:end}, 'Parent', fig);
else
     thing = feval (axesCmd, 'Parent', fig);
end

parent = handle (get (thing, 'parent'));
if isgraphics(parent, 'axes') || isgraphics(parent, 'polaraxes') || ...
        isa(parent, 'matlab.graphics.chart.Chart')
     ax = parent;
elseif ishghandle(parent,'figure') || ishghandle(parent,'uicontainer') || ...
        ishghandle(parent,'uitab')
     ax = thing;
else
     ax = [];
end


% Storing information about existing exis positions in order to detemine
% how much of available space is left 

heights = zeros(1,origNum);
widths = zeros(1,origNum);
ys = zeros(1,origNum);
xs = zeros(1,origNum);

for i = 1:origNum
    theAxes = handle(children(i));
    origPosn =  localGetPosition(theAxes);
    xs(i) = origPosn(1);
    ys(i) = origPosn(2);
    widths(i) = origPosn(3);
    heights(i) = origPosn(4);
end

%---------------------------------------------------
% Squish all the existing axes:

    
for i = 1:origNum
    theAxes = handle(children(i));
    [origPosn,posnPropName] =  localGetPosition(theAxes);
    
    if (strcmpi (where, 'Bottom') == 1)
        
        if min(ys) - newPlotHeight > 0 % if there is enough available space to fit the new axes
            newPlotY = min(ys) - newPlotHeight;
            newPlotHeight = mean(heights);
            break; % stop here, we dont need to resize the existing axis if we can fit the new one
        else
            newHeight = (origPosn(4) * squishFactor);
            newY      = (origPosn(2) * squishFactor) + newPlotHeight;
            if plotyyAxesExist && strcmp(posnPropName,'OuterPosition')
                localSetOuterPlotyyPosition(theAxes,[origPosn(1) newY origPosn(3) newHeight]);
            else
                localSetPosition(theAxes,[origPosn(1) newY origPosn(3) newHeight],posnPropName);
            end
        end
    elseif (strcmpi (where, 'Top') == 1)
        
        [maxY,ind] = max(ys);
        if maxY + heights(ind)  + newPlotHeight < 1   % if there is enough available space to fit the new axes
            newPlotHeight = mean(heights);
            break; % stop here, we dont need to resize the existing axis if we can fit the new one
        else
            newHeight = (origPosn(4) * squishFactor);
            newY      = (origPosn(2) * squishFactor);
            if plotyyAxesExist && strcmp(posnPropName,'OuterPosition')
                localSetOuterPlotyyPosition(theAxes,[origPosn(1) newY origPosn(3) newHeight]);
            else
                localSetPosition(theAxes,[origPosn(1) newY origPosn(3) newHeight],posnPropName);
            end
        end
    elseif (strcmpi (where, 'Left') == 1)   
           
        if  min(xs) - newPlotWidth > 0 % if there is enough available space to fit the new axes
            newPlotX = min(xs) - newPlotWidth;
            newPlotWidth = mean(widths);
            break; % stop here, we dont need to resize the existing axis if we can fit the new one
        else
            newWidth = (origPosn(3) * squishFactor);
            newX     = (origPosn(1) * squishFactor) + newPlotWidth;
            
            if plotyyAxesExist && strcmp(posnPropName,'OuterPosition')
                localSetOuterPlotyyPosition(theAxes,[newX origPosn(2) newWidth origPosn(4)]);
            else
                localSetPosition(theAxes,[newX origPosn(2) newWidth origPosn(4)],posnPropName);
            end
        end
        
    elseif (strcmpi (where, 'Right') == 1)
        
        [maxX,ind] = max(xs);
        if maxX + widths(ind)  + newPlotWidth < 1  %if there is enough available space to fit the new axes
            newPlotWidth = mean(widths);
            break; % stop here, we dont need to resize the existing axis if we can fit the new one
        else
            
            newWidth = (origPosn(3) * squishFactor);
            newX     = (origPosn(1) * squishFactor);
            if plotyyAxesExist && strcmp(posnPropName,'OuterPosition')
                localSetOuterPlotyyPosition(theAxes,[newX origPosn(2) newWidth origPosn(4)]);
            else
                localSetPosition(theAxes,[newX origPosn(2) newWidth origPosn(4)],posnPropName);
            end
        end
        
        
    end
    
end
    


%---------------------------------------------------
% Finish the new axes:

if (isprop (ax, 'OuterPosition'))
    if plotyyAxesExist 
        localSetOuterPlotyyPosition(ax,[newPlotX newPlotY newPlotWidth newPlotHeight]);
    else
     localSetPosition(ax,[newPlotX newPlotY newPlotWidth newPlotHeight],'OuterPosition');
    end
else
    localSetPosition(ax,[newPlotX newPlotY newPlotWidth newPlotHeight],'Position');

end
title (ax, '');
set(ax,'Box','on');

addlistener(ax,'ObjectBeingDestroyed', @(obj,ed)doDeleteAction(fig,obj,ed));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function doDeleteAction(fig,h,eventData) %#ok

% When using MCOS graphics, avoid forcing a traversal on an axes
% that has been deleted (g834090)
pos  = localGetPosition(h);
    
children = findobj (fig, 'Type', 'axes', '-or', 'Type', 'polaraxes', ...
    '-or','-isa','matlab.graphics.chart.Chart');

% Filter out legend and colorbar from position calculations
filterFcn = @(hAxes) ( ishghandle(handle(hAxes),'legend') || ...
                       ishghandle(handle(hAxes),'colorbar')); 
I = false(size(children));
for k=1:length(I)
    I(k) = feval(filterFcn,children(k));
end
children(I) = [];

% only rescale other axes if the one being deleted stretches all
% the way vertically or horizontally
if (any(pos(3:4) > 1-10*eps)) && (length(children) > 1)
  % Remove any shadow plotyy axes from the list of children
  [children,plotyyAxesExist] = localRemovePlotyy(children); 
  positions = zeros(length(children),4);
  for i = 1:length(children)
      positions(i,:) = localGetPosition(children(i),'OuterPosition');
  end
  
  if pos(3) >=1 % Axes removed from a vertical stack
      localPositionAxes(children,positions,plotyyAxesExist,'y');
  elseif pos(4) >= 1 % Axes removed from a horizontal stack
      localPositionAxes(children,positions,plotyyAxesExist,'x');
  end

end


function localPositionAxes(children,positions,plotyyAxesExist,direction)

nchildren = length(children);
if strcmp('x',direction)
   ind = 1;
else
   ind = 2;
end

% Make sure the axes are ascending
[~,I] = sort(positions(:,ind));
positions = positions(I,:);    
minOffset = 1; 
maxOffset = 0;

% Clip the positions not to be below the bottom edge of the figure.
positions(:,1) = max(positions(:,1),0);
positions(:,2) = max(positions(:,2),0);

boundary = -inf;
extent = 0;
for i = 1:nchildren
      pos = positions(i,:);       
      minOffset = min(minOffset,pos(ind));
      maxOffset = min(maxOffset,pos(ind)+pos(ind+2));
      
      % If the next axes overlaps the top/right edge of the previous axes
      % then the extent should only be increased by the length of the
      % non-overlapping interval
      if pos(ind)>=boundary
          extent = extent+pos(ind+2);
      else          
          extent = extent+(pos(ind+2)+pos(ind))-boundary;
      end
      
      % Update the top/right boundary position
      boundary = pos(ind+2)+pos(ind);
end

% Find the mean gap and scale it by nchildren/(nchildren-1) since an axes
% has been deleted
gap = nchildren*(pos(ind+2)+pos(ind)-minOffset-extent)/(nchildren-1)^2;
extent = extent/(nchildren-1);

ct = 0;
for i = 1:nchildren
   if strcmp(get(children(i),'BeingDeleted'),'off')   
      outerpos = localGetPosition(children(i),'OuterPosition');
      outerpos(ind) = minOffset+(extent+gap)*ct;
      outerpos(ind+2) = extent;
      if plotyyAxesExist 
          % Set the Position property for MCOS graphics in the
          % presence of plotyy axes because plotyy uses listeners
          % on the Position property to maintain axes overlap and
          % setting the OuterPosition is not guaranteed to call
          % those listeners.
          localSetOuterPlotyyPosition(children(i), outerpos);
      else
          localSetPosition(children(i),outerpos,'OuterPosition');
      end
      ct=ct+1;
   end
end

function [ax,plotyyAxesExist] = localRemovePlotyy(ax)

% Remove any shadow plotyy axes from the list of children
I = true(length(ax),1);
plotyyAxesExist = false;
for i = 2:length(ax)
  if isappdata(ax(i),'graphicsPlotyyPeer') && any(getappdata(ax(i),'graphicsPlotyyPeer')==ax(1:i-1))
      I(i) = false;
      plotyyAxesExist = true;
  end
end  
ax = ax(I);


function localSetOuterPlotyyPosition(ax,pos)

outerPos = localGetPosition(ax,'OuterPosition');
sf = pos(3:4)./outerPos(3:4);
outPositionOffsets = (outerPos-localGetPosition(ax,'Position')).*([sf sf]);
localSetPosition(ax,pos-outPositionOffsets,'Position')


function [pos,posnPropName] = localGetPosition(theAxes,posnPropName)

if nargin>=2
    usesOuterPosition = strcmp(posnPropName,'OuterPosition');
else
    usesOuterPosition = isprop(theAxes, 'OuterPosition');
end
% If a LayoutManager is controlling the position of legends and colorbars
% then its StartingLayoutPositionPixels should be used to get the axes 
% position including the space occupied by the legend/colorbar
if usesOuterPosition
    posnPropName = 'OuterPosition';
    if isprop(theAxes,'LayoutManager') && isvalid(theAxes.LayoutManager) && ~isappdata(theAxes,'graphicsPlotyyPeer')
        parent = ancestor(theAxes,{'uicontainer','uipanel','figure','uitab'});
        pos = hgconvertunits(parent,theAxes.LayoutManager.StartingLayoutPositionPixels,'pixels',theAxes.Units,parent);
    else
        pos = get (theAxes, posnPropName);
    end
else
    posnPropName = 'Position';
    pos = theAxes.Position;
    % If a LayoutManager is being used expand the position to accomodate exterior legends 
    if isprop(theAxes,'LayoutManager') && isprop(theAxes,'OuterPosition') && ~isappdata(theAxes,'graphicsPlotyyPeer')
        parent = ancestor(theAxes,{'uicontainer','uipanel','figure','uitab'});
        posdiff = hgconvertunits(parent,theAxes.LayoutManager.StartingLayoutPositionPixels,'pixels',theAxes.Units,parent)-...
            theAxes.OuterPosition;
        pos = pos+posdiff;
    end      
end


function localSetPosition(theAxes,pos,posnPropName)

% Set the axes position directly.  Setting OuterPosition does not currently
% cause legend/colorbar automatic layout to toggle to manual mode.
set(theAxes, posnPropName, pos);
