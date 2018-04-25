function c = centrality(g, type, varargin)
%CENTRALITY Node centrality for graph G.
%
%   C = CENTRALITY(G, TYPE) computes the centrality C(i) for every node i.
%   The centrality measure used is specified by the string TYPE.
%   TYPE can be:
%
%         'outdegree' - number of successors of node i.
%          'indegree' - number of predecessors of node i.
%      'outcloseness' - inverse sum of distances from node i to all
%                       reachable nodes.
%       'incloseness' - inverse sum of distances from all nodes to node i,
%                       if node i is reachable from these nodes.
%       'betweenness' - number of shortest paths between other nodes that
%                       pass through node i.
%          'pagerank' - ratio of time spent at node i while randomly
%                       traversing the graph.
%              'hubs' - nodes with successors of high authority scores.
%       'authorities' - nodes with predecessors of high hub scores.
%
%   CENTRALITY(..., 'Cost', COST) specifies the cost of traveling each
%   edge of the graph G. COST is a vector of positive edge weights,
%   and COST(i) specifies the cost associated with edge findedge(G, i).
%   Only applies to types 'incloseness', 'outcloseness' and 'betweenness'.
%
%   CENTRALITY(..., 'Importance', IMP) specifies the importance of each
%   edge of the graph G. IMP is a vector of nonnegative edge weights,
%   and IMP(i) specifies the importance of edge findedge(G, i). If there
%   are multiple edges between the same two nodes, the sum of their weights
%   is used. Only applies to types 'indegree', 'outdegree', 'pagerank', 'hubs'
%   and 'authorities'.
%
%   CENTRALITY(..., 'FollowProbability', P) sets the probablity that, in
%   the pagerank algorithm, the next node in the traversal is chosen among
%   the successors of the current node, and not at random from all nodes.
%   P is a scalar between 0 and 1. Default : 0.85.
%   Only applies to type 'pagerank'.
%
%   CENTRALITY(..., 'Tolerance', TOL) gives the stopping criterion for the
%   iterative solvers. The iteration is stopped when the difference to
%   the previous iteration is less than TOL in all entries. Default: 1e-4.
%   Only applies to types 'pagerank', 'hubs' and 'authorities'.
%
%   CENTRALITY(..., 'MaxIterations', MAXIT) gives the maximum number of iterations
%   for the iterative solvers. Default: 100.
%   Only applies to types 'pagerank', 'hubs' and 'authorities'.
%
%   See also DIGRAPH, GRAPH/CENTRALITY

%   Copyright 2015-2017 The MathWorks, Inc.

type = validatestring(type, {'outdegree', 'indegree', 'betweenness', ...
    'outcloseness', 'incloseness', 'hubs', 'authorities', 'pagerank'});

names = {'Cost', 'Importance', 'Tolerance', 'MaxIterations', 'FollowProbability'};

wc = [];
wi = [];
tol = 1e-4;
maxit = 100;
damp = 0.85;


for ii=1:2:numel(varargin)
    opt = validatestring(varargin{ii}, names);
    
    if ii+1 > numel(varargin)
        error(message('MATLAB:graphfun:centrality:KeyWithoutValue', opt));
    end
    
    switch opt
        case 'Cost'
            if ~any(strcmp(type, {'betweenness', 'outcloseness', 'incloseness'}))
                error(message('MATLAB:graphfun:centrality:InvCombCostDir'));
            end
            wc = varargin{ii+1};
            validateattributes(wc, {'double'}, ...
                {'vector', 'real', 'positive', 'numel', numedges(g)}, '', 'Cost');
            wc = full(wc(:));
        case 'Importance'
            if ~any(strcmp(type, {'outdegree', 'indegree', 'hubs', 'authorities', 'pagerank'}))
                error(message('MATLAB:graphfun:centrality:InvCombImpDir'));
            end
            wi = varargin{ii+1};
            validateattributes(wi, {'double'}, ...
                {'vector', 'real', 'nonnegative', 'numel', numedges(g)}, '', 'Importance');
            wi = full(wi(:));
        case  'Tolerance'
            if ~any(strcmp(type, {'hubs', 'authorities', 'pagerank'}))
                error(message('MATLAB:graphfun:centrality:InvCombTolDir'));
            end
            tol = varargin{ii+1};
            validateattributes(tol, {'double'}, {'scalar', 'real', 'nonnegative'}, '', 'Tolerance')
        case  'MaxIterations'
            if ~any(strcmp(type, {'hubs', 'authorities', 'pagerank'}))
                error(message('MATLAB:graphfun:centrality:InvCombMaxitDir'));
            end
            maxit = varargin{ii+1};
            validateattributes(maxit, {'double'}, {'scalar', 'real', 'positive', 'integer'}, '', 'MaxIterations')
        case  'FollowProbability'
            if ~any(strcmp(type, {'pagerank'}))
                error(message('MATLAB:graphfun:centrality:InvCombDamping'));
            end
            damp = varargin{ii+1};
            validateattributes(damp, {'double'}, {'scalar', 'real', 'nonnegative', '<=', 1}, '', 'FollowProbability')
    end
end


switch type
    case 'outdegree'
        
        if ~isempty(wi)
            n = numnodes(g);
            [s, ~] = findedge(g);
            c = accumarray(s, wi, [n 1]);
        else
            c = outdegree(g);
        end
        
    case 'indegree'
        
        if ~isempty(wi)
            n = numnodes(g);
            [~, t] = findedge(g);
            c = accumarray(t, wi, [n 1]);
        else
            c = indegree(g);
        end
        
    case 'betweenness'
        
        c = betweennessCentrality(g.Underlying, wc);
        
    case {'incloseness', 'outcloseness'}
        
        if strcmp(type, 'incloseness')
            [distSum, nrReachable] = inClosenessCentrality(g.Underlying, wc);
        else
            [distSum, nrReachable] = outClosenessCentrality(g.Underlying, wc);
        end
        
        nrReachable = nrReachable - 1; % do not count starting node
        c = (nrReachable/(numnodes(g) - 1)).^2 ./ distSum;
        c(nrReachable==0) = 0;
        
    case {'hubs', 'authorities'}
        
        n = numnodes(g);
        
        if ~ismultigraph(g)
            if isempty(wi)
                At = adjacency(g.Underlying, 'transp');
            else
                At = adjacency(g.Underlying, wi, 'transp');
            end
        else
            ed = g.Underlying.Edges;
            if isempty(wi)
                At = sparse(ed(:, 2), ed(:, 1), 1, n, n);
            else
                At = sparse(ed(:, 2), ed(:, 1), wi, n, n);
            end
        end
        
        % Compute hubs and authorities for each weakly connected component
        % separately:
        bins = conncomp(g, 'Type', 'weak');
        hubs = nan(n, 1);
        auth = nan(n, 1);
        for ii=1:max(bins)
            
            ind = bins == ii;
            ni = nnz(ind);
            
            if ni == 1
                h = 1;
                a = 1;
            else
                [h, a] = hitsIteration(At(ind, ind), maxit, tol);
            end
            
            hubs(ind) = h * (ni/n);
            auth(ind) = a * (ni/n);
            
        end
        
        if strcmp(type, 'hubs')
            c = hubs;
        else
            c = auth;
        end
        
    case 'pagerank'
        
        n = numnodes(g);
        
        if ~ismultigraph(g)
            if isempty(wi)
                At = adjacency(g.Underlying, 'transp');
            else
                At = adjacency(g.Underlying, wi, 'transp');
            end
        else
            ed = g.Underlying.Edges;
            if isempty(wi)
                At = sparse(ed(:, 2), ed(:, 1), 1, n, n);
            else
                At = sparse(ed(:, 2), ed(:, 1), wi, n, n);
            end
        end
        
        d = full(sum(At, 1))';
        snks = d == 0;
        d(snks) = 1; % do 0/1 instead of 0/0 in first term of formula
        
        % Iterative computation
        cnew = ones(n, 1)/n;
        for ii=1:maxit
            c = cnew;
            cnew = damp*At*(c./d) + damp/n*sum(c(snks)) + (1 - damp)/n;
            if norm(c - cnew, inf) <= tol
                break;
            end
        end
        
        if ~(norm(c - cnew, inf) <= tol)
            warning(message('MATLAB:graphfun:centrality:PageRankNoConv'));
        end
        c = cnew;
        
end

function [hubs, authorities] = hitsIteration(M, maxit, tol)

hubs = ones(size(M, 1), 1);
hubs = hubs / sum(hubs);

authorities = M*hubs;
authorities = authorities / sum(authorities);
changeauthorities = inf;

for jj=1:maxit
    
    newhubs = M'*authorities;
    newhubs = newhubs / sum(newhubs);
    changehubs = norm(hubs - newhubs, inf);
    hubs = newhubs;
    if changeauthorities <= tol && changehubs <= tol
        break;
    end
    
    newauthorities = M*hubs;
    newauthorities = newauthorities / sum(newauthorities);
    changeauthorities = norm(authorities - newauthorities, inf);
    authorities = newauthorities;
    if changeauthorities <= tol && changehubs <= tol
        break;
    end
end

if ~(changeauthorities <= tol && changehubs <= tol)
    warning(message('MATLAB:graphfun:centrality:HITSNoConv'));
end
