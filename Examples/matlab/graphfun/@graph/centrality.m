function c = centrality(g, type, varargin)
%CENTRALITY Node centrality for graph G.
%
%   C = CENTRALITY(G, TYPE) computes the centrality C(i) for every node i.
%   The centrality measure used is specified by the string TYPE.
%   TYPE can be:
%
%            'degree' - number of edges connected to node i.
%         'closeness' - inverse sum of distances between node i and all
%                       reachable nodes.
%       'betweenness' - Number of shortest paths between other nodes that
%                       pass through node i.
%          'pagerank' - ratio of time spent at node i while randomly
%                       traversing the graph.
%       'eigenvector' - eigenvector of largest eigenvalue of the adjacency
%                       matrix.
%
%   CENTRALITY(..., 'Cost', COST) specifies the cost of traveling each
%   edge of the graph G. COST is a vector of positive edge weights,
%   and COST(i) specifies the cost associated with edge findedge(G, i).
%   Only applies to types 'closeness' and 'betweenness'.
%
%   CENTRALITY(..., 'Importance', IMP) specifies the importance of each
%   edge of the graph G. IMP is a vector of nonnegative edge weights,
%   and IMP(i) specifies the importance of edge findedge(G, i). If there
%   are multiple edges between the same two nodes, the sum of their weights
%   is used. Only applies to types 'degree', 'pagerank' and 'eigenvector'.
%
%   CENTRALITY(..., 'FollowProbability', P) sets the probablity that, in
%   the pagerank algorithm, the next node in the traversal is chosen among
%   the neighbors of the current node, and not at random from all nodes.
%   P is a scalar between 0 and 1. Default : 0.85.
%   Only applies to type 'pagerank'.
%
%   CENTRALITY(..., 'Tolerance', TOL) gives the stopping criterion for the
%   iterative solvers. The iteration is stopped when the difference to
%   the previous iteration is less than TOL in all entries. Default: 1e-4.
%   Only applies to types 'pagerank' and 'eigenvector'.
%
%   CENTRALITY(..., 'MaxIterations', MAXIT) gives the maximum number of iterations
%   for the iterative solvers. Default: 100.
%   Only applies to types 'pagerank' and 'eigenvector'.
%
%   See also GRAPH, DIGRAPH/CENTRALITY

%   Copyright 2015-2017 The MathWorks, Inc.

type = validatestring(type, {'degree', 'betweenness', 'closeness', 'eigenvector', 'pagerank'});
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
            if ~any(strcmp(type, {'betweenness', 'closeness'}))
                error(message('MATLAB:graphfun:centrality:InvCombCostUndir'));
            end
            wc = varargin{ii+1};
            validateattributes(wc, {'double'}, ...
                {'vector', 'real', 'positive', 'numel', numedges(g)}, '', 'Cost');
            wc = full(wc(:));
        case 'Importance'
            if ~any(strcmp(type, {'degree', 'eigenvector', 'pagerank'}))
                error(message('MATLAB:graphfun:centrality:InvCombImpUndir'));
            end
            wi = varargin{ii+1};
            validateattributes(wi, {'double'}, ...
                {'vector', 'real', 'nonnegative', 'numel', numedges(g)}, '', 'Importance');
            wi = full(wi(:));
        case  'Tolerance'
            if ~any(strcmp(type, {'eigenvector', 'pagerank'}))
                error(message('MATLAB:graphfun:centrality:InvCombTolUndir'));
            end
            tol = varargin{ii+1};
            validateattributes(tol, {'double'}, {'scalar', 'real', 'nonnegative'}, '', 'Tolerance')
        case  'MaxIterations'
            if ~any(strcmp(type, {'eigenvector', 'pagerank'}))
                error(message('MATLAB:graphfun:centrality:InvCombMaxitUndir'));
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
    case 'degree'
        
        if ~isempty(wi)
            n = numnodes(g);
            [s, t] = findedge(g);
            c = accumarray(s, wi, [n 1]) + accumarray(t, wi, [n 1]);
        else
            c = degree(g);
        end
        
    case 'betweenness'
        
        c = betweennessCentrality(g.Underlying, wc);
        
    case 'closeness'
        
        [distSum, nrReachable] = closenessCentrality(g.Underlying, wc);
        
        nrReachable = nrReachable - 1; % do not count starting node
        c = (nrReachable/(numnodes(g) - 1)).^2 ./ distSum;
        c(nrReachable==0) = 0;
        
    case 'eigenvector'
        
        n = numnodes(g);
        
        if ~ismultigraph(g)
            if isempty(wi)
                A = adjacency(g.Underlying);
            else
                A = adjacency(g.Underlying, wi);
            end
        else
            ed = g.Underlying.Edges;
            if isempty(wi)
                A = sparse(ed(:, 2), ed(:, 1), 1, n, n);
            else
                A = sparse(ed(:, 2), ed(:, 1), wi, n, n);
            end
            A = A + A' - diag(diag(A));
        end
        
        opts.tol = tol;
        opts.maxit = maxit;
        
        bins = conncomp(g);
        c = nan(n, 1);
        for ii=1:max(bins)
            
            ind = bins == ii;
            ni = nnz(ind);
            
            if ni == 1
                c(ind) = ni/n;
            else
                if ni <= 100
                    [U,  D] = eig(full(A(ind, ind)));
                    [~, maxind] = max(diag(D));
                    v = U(:, maxind);
                else
                    opts.v0 = ones(ni, 1);
                    [v, ~] = eigs(A(ind, ind), [], 1, 'LA', opts);
                end
                
                v = abs(v);
                v = v/sum(v);
                
                c(ind) = v*(ni/n);
            end
        end
        
    case 'pagerank'
        
        n = numnodes(g);
        if ~ismultigraph(g)
            if isempty(wi)
                A = adjacency(g.Underlying);
            else
                A = adjacency(g.Underlying, wi);
            end
        else
            ed = g.Underlying.Edges;
            if isempty(wi)
                A = sparse(ed(:, 1), ed(:, 2), 1, n, n);
            else
                A = sparse(ed(:, 1), ed(:, 2), wi, n, n);
            end
            A = A + A' - diag(diag(A));
        end
        
        if n ~= 0
            d = full(sum(A))';
        else
            d = zeros(0, 1);
        end
        
        snks = d == 0;
        d(snks) = 1; % do 0/1 instead of 0/0 in first term of formula
        
        % Iterative computation
        cnew = ones(n, 1)/n;
        for ii=1:maxit
            c = cnew;
            cnew = damp*A*(c./d) + damp/n*sum(c(snks)) + (1 - damp)/n;
            if norm(c - cnew, inf) <= tol
                break;
            end
        end
        
        if ~(norm(c - cnew, inf) <= tol)
            warning(message('MATLAB:graphfun:centrality:PageRankNoConv'));
        end
        c = cnew;
        
end
