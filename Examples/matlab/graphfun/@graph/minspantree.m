function [t, pred] = minspantree(G, varargin)
%MINSPANTREE Minimum spanning tree of a graph
%
%   [T, PRED] = minspantree(G) returns the minimum spanning tree T of
%   graph G, and the vector PRED of predecessors: PRED(I) is the node index
%   of the predecessor of node I.
%
%    [T, PRED] = minspantree(G, 'Method', METHODNAME) specifies the method
%    used to compute the minimum spanning tree:
%         'dense'  starts at node rootVertex and adds edges to the tree
%                  while traversing the graph. This is the default.
%        'sparse'  Sorts all edges by weight, and adds them to the tree if
%                  they don't cause any cycles.
%
%    [T, PRED] = minspantree(G, 'Root', rootVertex) specifies the root
%    vertex. If 'Method' is 'dense', this is the starting vertex;
%    if 'Method' is 'sparse', the root vertex is only used to compute
%    the PRED vector.
%    Default: rootVertex is Node 1
%
%    [T, PRED] = minspantree(G, 'Type', TYPE) specifies what is done if G
%    is not connected:
%          'tree'  only one tree is returned, which contains rootVertex.
%                  This is the default.
%        'forest'  a forest of minimum spanning trees is returned.
%
%   Example:
%       % Create and plot a graph. Compute and highlight its minimum
%       % spanning tree.
%       s = [1 1 1 2 5 3 6 4 7 8 8 8];
%       t = [2 3 4 5 3 6 4 7 2 6 7 5];
%       weights = [100 10 10 10 10 20 10 30 50 10 70 10];
%       G = graph(s,t,weights);
%       G.Edges
%       p = plot(G,'EdgeLabel',G.Edges.Weight);
%       tree = minspantree(G);
%       tree.Edges
%       highlight(p,tree)
%
%    See also GRAPH, SHORTESTPATH, CONNCOMP

%   Copyright 2014-2017 The MathWorks, Inc.

[restart, rootNode, usePrim] = parseFlags(G, varargin{:});

if hasEdgeWeights(G)
    w = G.EdgeProperties.Weight;
else
    w = ones(numedges(G), 1);
end

% Special case for empty graph
if numnodes(G) == 0
    t = graph();
    t.NodeProperties = G.NodeProperties;
    pred = zeros(1, 0);
    return;
end

if usePrim % Prim's method
    
    [pred, edgeind] = primMinSpanningTree(G.Underlying, w, rootNode, restart);
    ed = G.Underlying.Edges;
    t = graph(ed(edgeind, 1), ed(edgeind, 2), G.EdgeProperties(edgeind, :), G.Nodes);
    
else % Kruskal's method
    
    edgeind = kruskalMinSpanningTree(G.Underlying, w);
    ed = G.Underlying.Edges;
    t = graph(ed(edgeind, 1), ed(edgeind, 2), G.EdgeProperties(edgeind, :), G.Nodes);
    
    if nargout > 1
        if restart
            pred = zeros(1, numnodes(G));
        else
            pred = nan(1, numnodes(G));
        end
        
        % Compute bfsearch(t, rootNode, 'Flag', 'edge_to_new', 'Restart', restart);
        % directly using built-in
        labels = false(1, 6);
        labels(3) = true; % 'edge_to_new'
        edgeListOrdered = breadthFirstSearch(t.Underlying, rootNode, labels, restart, false);
        
        pred(edgeListOrdered(:, 2)) = edgeListOrdered(:, 1);
        pred(rootNode) = 0;
        
    end
    
    % Throw out edges that are not part of rootNode's component
    if ~restart
        % Check if there is only one tree spanning the whole graph,
        % in that case, no need to throw out edges.
        if numedges(t) ~= numnodes(t) - 1
            if nargout > 1
                rmNodes = isnan(pred);
            else
                c = conncomp(t);
                rmNodes = (c ~= c(rootNode));
            end
            e = t.Underlying.Edges;
            edgeind = rmNodes(e(:, 1));
            
            t = rmedge(t, e(edgeind, 1), e(edgeind, 2));
        end
    end
    
end


function [restart, rootNode, usePrim] = parseFlags(G, varargin)

restart = false;
rootNode = 1;
usePrim = true;

if numel(varargin) == 0
    return;
end

for ii=1:2:numel(varargin)
    name = varargin{ii};
    if ~graph.isvalidoption(name)
        error(message('MATLAB:graphfun:minspantree:ParseFlags'));
    end
    
    if graph.partialMatch(name, "Method")
        if ii+1 > numel(varargin)
            error(message('MATLAB:graphfun:minspantree:KeyWithoutValue', 'Method'));
        end
        value = varargin{ii+1};
        if ~graph.isvalidoption(value)
            error(message('MATLAB:graphfun:minspantree:ParseMethod'));
        end
        if graph.partialMatch(value, "dense")
            usePrim = true;
        elseif graph.partialMatch(value, "sparse")
            usePrim = false;
        else
            error(message('MATLAB:graphfun:minspantree:ParseMethod'));
        end
    elseif graph.partialMatch(name, "Root")
        if ii+1 > numel(varargin)
            error(message('MATLAB:graphfun:minspantree:KeyWithoutValue', 'Root'));
        end
        value = varargin{ii+1};
        if (isnumeric(value) && isscalar(value)) || (isrow(value) && ischar(value))
            rootNode = validateNodeID(G, value);
        else
            error(message('MATLAB:graphfun:minspantree:ParseRoot'));
        end
    elseif graph.partialMatch(name, "Type")
        if ii+1 > numel(varargin)
            error(message('MATLAB:graphfun:minspantree:KeyWithoutValue', 'Type'));
        end
        value = varargin{ii+1};
        if ~graph.isvalidoption(value)
            error(message('MATLAB:graphfun:minspantree:ParseType'));
        end
        if graph.partialMatch(value, "tree")
            restart = false;
        elseif graph.partialMatch(value, "forest")
            restart = true;
        else
            error(message('MATLAB:graphfun:minspantree:ParseType'));
        end
    else
        error(message('MATLAB:graphfun:minspantree:ParseFlags'));
    end
end

