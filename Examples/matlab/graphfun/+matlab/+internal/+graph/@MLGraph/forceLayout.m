function [x,y,iterations] = forceLayout(G,x0,y0,iterations,kw,gravity)
% FORCELAYOUT   Force-directed node layout
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%

% Reference: T. Fruchterman and E. Reingold, "Graph drawing by
% force-directed placement", Software-Practice & Experience, vol. 21 (11),
% pp. 1129-1164, 1991.

%   Copyright 2015-2017 The MathWorks, Inc.

nn = G.NodeCount;
if ~isnumeric(iterations) || ~isreal(iterations) || ~(iterations >= 0) ...
        || ~isfinite(iterations) || fix(iterations) ~= iterations
    error(message('MATLAB:graphfun:graphbuiltin:InvalidIterations'));
end
if ~isnumeric(x0) || ~isvector(x0) || numel(x0) ~= nn || ~isreal(x0)
    error(message('MATLAB:graphfun:graphbuiltin:InvalidXCoordinates',nn));
end
if any(~isfinite(x0))
    error(message('MATLAB:graphfun:graphbuiltin:NonfiniteXCoordinates'));
end
if ~isnumeric(y0) || ~isvector(y0) || numel(y0) ~= nn || ~isreal(y0)
    error(message('MATLAB:graphfun:graphbuiltin:InvalidYCoordinates',nn));
end
if any(~isfinite(y0))
    error(message('MATLAB:graphfun:graphbuiltin:NonfiniteYCoordinates'));
end

%process Gravity
gForce = .8;
if islogical(gravity)
    if ~isscalar(gravity)
        error(message('MATLAB:graphfun:graphbuiltin:UseGravityLogical'));
    end
    doGravity = gravity;
else
    gravity = validatestring(gravity, {'on', 'off'}, '', 'UseGravity');
    doGravity = strcmp(gravity,'on');
end

x = double(full(x0(:)));
y = double(full(y0(:)));
if iterations > 0
    if doGravity
        ncomp = 1;
    else
        comp  = connectedComponents(G);
        ncomp = max([0 comp]);
    end
    if ncomp > 1
        % Apply force-directed layout for each connected component.
        A = adjacency(G, 1:numedges(G));
        [compsort, ind] = sort(comp);
        startBin = [1 find(diff(compsort))+1];
        endBin = [find(diff(compsort)) length(compsort)];
        for k = 1:ncomp
            % Extract a component's nodes and edges.
            if startBin(k) ~= endBin(k)
                nk = ind(startBin(k):endBin(k));
                if isempty(kw) % Don't index into kw if weights are empty.
                    [sk,tk] = find(tril(A(nk,nk)));
                    [x(nk),y(nk)] = layoutOneConnComp(x(nk),y(nk),sk,tk,1,gForce,doGravity,iterations);
                else
                    [sk,tk,edgeind] = find(tril(A(nk,nk)));
                    [x(nk),y(nk)] = layoutOneConnComp(x(nk),y(nk),sk,tk,kw(edgeind),gForce,doGravity,iterations);
                end
            end
        end
        % Pack the components together.
        xy = matlab.internal.graph.packLayouts([x y],comp);
        x = xy(:,1);
        y = xy(:,2);
    else
        edges = G.Edges;
        sources = edges(:,1);
        targets = edges(:,2);
        if isempty(kw)
            [x,y] = layoutOneConnComp(x,y,sources,targets,1,gForce,doGravity,iterations);
        else
            [x,y] = layoutOneConnComp(x,y,sources,targets,kw,gForce,doGravity,iterations);
        end
    end
end

%--------------------------------------------------------------------------
function [x,y] = layoutOneConnComp(x,y,sources,targets,kw,kg,doGravity,iterations)
% Force-directed layout for a graph with edges defined as (source,target)
% pairs. The node ids in sources and targets range from 1 to length(x).
nn = length(x);
if nn <= 1
    x = zeros(nn,1);
    y = zeros(nn,1);
elseif nn == 2
    x = [0; 0];
    y = [0; 1];
else
    meanside = mean([max(x)-min(x), max(y)-min(y)]);
    meanside(meanside == 0) = 1;
    % Spring constant.
    k = meanside/sqrt(nn);
    % Threshold for nudging nodes that are too close.
    gap = 0.1*meanside/sqrt(nn);
    % Cool down schedule to limit the node movement at each iteration.
    temperature = linspace(0.1*meanside,0,iterations+1);
    % Apply force-directed layout.
    oldstate = rng(0,'twister');
    dx = zeros(nn, 1);
    dy = zeros(nn, 1);
    for i = 1:iterations
        [dx,dy] = applyRepulsiveForce(x,y,dx,dy,nn,k,gap);
        [dx,dy] = applyAttractiveForce(x,y,dx,dy,nn,sources,targets,k,kw,gap);
        if(doGravity)
            [dx,dy] = applyGravityForce(x,y,dx,dy,kg);
        end
        [x,y]    = moveNodes(x,y,dx,dy,temperature(i));
    end
    rng(oldstate);
    if ~doGravity
        % Normalize coordinates.
        x = x - mean(x);
        y = y - mean(y);
        r = max(hypot(x,y)); % ~= 0
        r(r == 0) = 1;
        rnew = log(nn)/r;
        x = rnew*x;
        y = rnew*y;
    end
end
%--------------------------------------------------------------------------
function [dx,dy] = applyGravityForce(x,y,dx,dy,kg)
% Compute node displacement after applying gravity forces for each node.

dx = dx - kg*x;
dy = dy - kg*y;
%--------------------------------------------------------------------------
function [dx,dy] = applyRepulsiveForce(x,y,dx,dy,nn,k,gap)
% Compute node displacement after applying repulsive forces for each node.

gapsq = gap^2;
ksq = k^2;
for i = 1:nn
    deltax = x(i) - x;
    deltay = y(i) - y;
    distsq = deltax.^2 + deltay.^2;
    % Nudge nodes that are too close.
    ind = (distsq < gapsq);
    deltaind = randn(sum(ind),2);
    deltax(ind) = deltaind(:,1);
    deltay(ind) = deltaind(:,2);
    distsq(ind) = gapsq;
    % Compute repulsive displacement.
    tempdx = ksq*(deltax./distsq);
    tempdy = ksq*(deltay./distsq);
    tempdx(i) = 0;
    tempdy(i) = 0;
    dx(i) = sum(tempdx);
    dy(i) = sum(tempdy);
end
%--------------------------------------------------------------------------
function [dx,dy] = applyAttractiveForce(x,y,dx,dy,nn,sources,targets,k,kw,gap)
% Compute node displacement after applying attractive forces for each edge.
% Updates displacements dx and dy.
deltaex = x(sources) - x(targets);
deltaey = y(sources) - y(targets);
diste = hypot(deltaex,deltaey);
tmpdx = deltaex.*(diste/k).*kw;
tmpdy = deltaey.*(diste/k).*kw;
% Nudge nodes that are too close.
ind = (diste < gap);
r = 2+rand(sum(ind),1);
phi = 2*pi*rand(sum(ind),1);
tmpind = gap*(r.*[cos(phi),sin(phi)]);
tmpdx(ind) = tmpind(:,1);
tmpdy(ind) = tmpind(:,2);
% Update displacement.
dx = dx - accumarray(sources,tmpdx,[nn 1]);
dy = dy - accumarray(sources,tmpdy,[nn 1]);
dx = dx + accumarray(targets,tmpdx,[nn 1]);
dy = dy + accumarray(targets,tmpdy,[nn 1]);
%--------------------------------------------------------------------------
function [x,y] = moveNodes(x,y,dx,dy,temperature)
% Move nodes according to displacements and cool down temperature.
d = hypot(dx,dy);
a = min(d,temperature)./d;
a(d == 0) = 0;
x = x + a.*dx;
y = y + a.*dy;
