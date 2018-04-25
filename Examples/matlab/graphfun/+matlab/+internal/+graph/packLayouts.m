function xy = packLayouts(xy,comp)
%packLayouts Pack different layouts into a rectangle
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%
%   XY = packLayouts(XY,COMPCELL,COMP) Packs a collection of different
%   layouts into a rectangle, such that the layouts don't overlap. XY has
%   size NUMNODES-by-2 and contains the node coordinates. COMPCELL is a
%   cell array where cell k contains the nodes forming layout k. COMP is a
%   vector of length NUMNODES specifying the layout number for each node.

%   Copyright 2015-2017 The MathWorks, Inc.

% Stack components left-justified on a vertical strip of fixed width.
[xy,complevel,wmax,levelh] = packIntoStripFFDH(xy,comp);
% We now have a TALL strip of width wmax. Make it as square as possible.
xy = foldStripIntoSquare(xy,complevel,wmax,levelh,comp);

%--------------------------------------------------------------------------
function [xy,complevel,wmax,levelh] = packIntoStripFFDH(xy,comp)
% Stack components left-justified on a vertical strip of fixed width, i.e.,
% First-Fit Decreasing-Height (FFDH) strip packing. Reference:
%   E. G. Coffman, Jr., M. R. Garey, D. S. Johnson, and R. E. Tarjan,
%   "Performance Bounds for Level-Oriented Two-Dimensional Packing
%   Algorithms", SIAM J. Comput., 9(4), pp. 808-826, 1980.
ncomp = max(comp);
% Bounding boxes for each connected component.
[minx, maxx] = fastAccumarrayMinMax(comp, xy(:, 1));
[miny, maxy] = fastAccumarrayMinMax(comp, xy(:, 2));
minxy = [minx miny];
maxxy = [maxx maxy];
wh = maxxy - minxy; % [width, height]

% Prefer tall boxes
ind = wh(:,1) > wh(:,2);
wh(ind, :) = wh(ind, [2 1]);
minxy(ind, :) = minxy(ind, [2 1]);
xy(ind(comp), :) = xy(ind(comp), [2 1]);

% Bounding boxes with lower left corners at (0,0).
xy = xy - minxy(comp, :);

% Pad boxes so boundary nodes don't overlap with neighboring boxes.
padxy = 0.15*max(wh,[],1);
padxy( padxy == 0 ) = 0.5;
xy = xy + padxy;
wh = wh + 2*padxy;
% Sort boxes according to decreasing height.
[~,hind] = sort(wh(:,2),'descend');
wmax = max(wh(:,1));
% Place highest bounding box left-justified on the first level.
complevel = zeros(ncomp,1);
dxy = zeros(ncomp, 2);
complevel(hind(1)) = 1;    % levels where the components sit
levelw(1) = wh(hind(1),1); % occupied width of each level
levelh(1) = wh(hind(1),2); % height of each level
sum_levelh = wh(hind(1),2);
anySpaceLeft = false;
% Greedy placement of remaining boxes: First-Fit Decreasing-Height packing.
% First try to place component ind in one of the existing, partially filled
% levels. If there isn't enough space, make a new level.
for ind = 2:ncomp
    compind = hind(ind);
    
    % For a partially filled strip of width wmax, find a level to place a box
    % that has width wh(compind,1) and height wh(compind,2).
    
    % Check if there is space left on existing levels
    addNewLevel = true;
    if anySpaceLeft % is there any amount of space left?
        lvl = find((wmax - levelw) >= wh(compind,1),1); % is it enough space for this component?
        if ~isempty(lvl)
            addNewLevel = false; % Found space on current levels, no need to add a new one.
        end
    end
    % Either add component to level lvl, or make a new level and add it to
    % that.
    if ~addNewLevel
        dxy(compind, :) = [levelw(lvl), sum(levelh(1:(lvl-1)))]; % x and y offset
        levelw(lvl) = levelw(lvl) + wh(compind,1); %#ok<AGROW>
        anySpaceLeft = any(wmax > levelw); % update anySpaceLeft
    else
        % Place component on left, and on top of all other levels.
        dxy(compind, 1) = 0;          % x offset
        dxy(compind, 2) = sum_levelh; % y offset
        
        % Add new level with height of current component, and currently
        % occupied width of current component.
        levelw(end+1) = wh(compind,1); %#ok<AGROW>
        levelh(end+1) = wh(compind,2); %#ok<AGROW>
        lvl = length(levelw);
        sum_levelh = sum_levelh + wh(compind,2); % Update sum of all levels
        
        % Update anySpaceLeft - true if there is space left on the new level
        anySpaceLeft = anySpaceLeft | (wmax > wh(compind,1));
    end
    complevel(compind) = lvl;
end
xy = xy + dxy(comp, :);

%--------------------------------------------------------------------------
function xy = foldStripIntoSquare(xy,complevel,stripw,levelheight,comp)
% Re-arrange a tall strip of rectangles of same width into an almost square
% shape. The rectangles are sorted according to height: highest at bottom.
levely = [0 cumsum(levelheight(1:end-1))];
striph = sum(levelheight);
c = ceil(sqrt(striph/stripw)); % stripw is never 0, because we padded
if c >= 2 % if new width is a multiple of old width
    newh = striph/c; % neww = c*stripw;
    
    % Go through all levels, determined indice of levels at which we wrap
    % around to a new strip.
    stripBoundaries = [];
    levelyOffset = 0;
    for ii=1:length(levely)
        if levely(ii) - levelyOffset > newh
            stripBoundaries(end+1) = ii; %#ok<AGROW>
            levelyOffset = levely(ii);
        end
    end
    
    % Compute x- and y- displacement for nodes on each level
    % Each strip is shifted by stripw to the right, and made to start at
    % y = 0.
    dxy = [0 0; (1:length(stripBoundaries))'*stripw, -levely(stripBoundaries)'];
    
    % Find between which boundaries each component is situated
    ind = discretize(complevel, [-inf stripBoundaries inf]);
    
    % Find the level for each node using the level of its component
    ind = ind(comp);
    
    % Shift the nodes
    xy = xy + dxy(ind, :);
end

function [minx, maxx] = fastAccumarrayMinMax(ind, x)
% This variant is faster than accumarray when there are many small
% connected components. This is the case we want to be fast, because for
% large components, the bottleneck is computing the layout of individual
% components.

v = sortrows([ind(:), x(:)]);
ind = v(:, 1);
x = v(:, 2);

% The following only works because we know that every index from 1:max(ind)
% occurs at least once in ind (because of how conncomp works).
d = find(diff(ind));
minInd = [1; d+1];
maxInd = [d; length(ind)];

minx = x(minInd);
maxx = x(maxInd);