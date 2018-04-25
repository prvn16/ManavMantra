function [edgebins, cutvert] = biconncomp(G, varargin)
%BICONNCOMP Biconnected components
%   EDGEBINS = BICONNCOMP(G) computes the biconnected components of graph
%   G. EDGEBINS(i) gives the bin number of the biconnected component that
%   contains edge i. Each edge in G belongs to a single biconnected
%   component, whereas the nodes in G can belong to more than one
%   biconnected component. Two nodes belong to the same biconnected
%   component if they cannot be disconnected by removing any one node from
%   the graph.
%
%   [EDGEBINS, CUTVERT] = BICONNCOMP(G) additionally returns the node
%   indices CUTVERT indicating nodes that are cut vertices (also called
%   articulation points).
%
%   [EDGEBINS, CUTVERT] = BICONNCOMP(G, 'OutputForm', FORM) specifies
%   the form of output for EDGEBINS. FORM can be:
%        'vector'  -  Return a vector as described above. This is the
%                     default.
%          'cell'  -  Return a cell array C such that C{J} contains the
%                     node IDs of all nodes in component J. Nodes can be in
%                     more than one component.
%
%   Example:
%       % Create and plot a graph. Compute its biconnected components.
%       s = [1 2 2 3 3 3 4 5 5 8 8];
%       t = [2 3 4 1 4 5 5 6 7 9 10];
%       G = graph(s,t);
%       plot(G,'Layout','layered')
%       edgebins = biconncomp(G)
%
%   See also GRAPH, SUBGRAPH, DIGRAPH/CONNCOMP

%   Copyright 2016 The MathWorks, Inc.

% check if output is required in cell format
outputcell = parseFlags(varargin{:});

% call to biconnected components C++ code
[edgebins, isCutVert] = biconnectedComponents(G.Underlying);

% Compute vector of cut vertices from logical vector isCutVert
cutvert = find(isCutVert);

% When 'OutputForm' is chosen as 'cell', this function returns a cell
% where each array within the cell contains the nodes that belong to a
% particular biconnected component.
if outputcell
    numBins = max(edgebins);
    nodeBins = cell(1,numBins);
    [srcNode,tgtNode] = findedge(G);
    
    for binCntr = 1 : numBins
        % find edges that belong to this biconnected component, identify
        % the nodes that are connected via this edge, and add those nodes
        % to the cell array.
        indices = edgebins == binCntr;
        n = numnodes(G);
        sBinNodes = false(1,n);
        tBinNodes = false(1,n);
        sBinNodes(srcNode(indices)) = true;
        tBinNodes(tgtNode(indices)) = true;
        nodeBins{binCntr} = find(sBinNodes | tBinNodes);
    end
    edgebins = nodeBins;
    
    % formatting to save bins in row vector format within cells
    if hasNodeNames(G)
        for ii = 1 : numel(edgebins)
            edgebins{ii} = G.NodeProperties.Name(edgebins{ii})';
        end
    end
end

% second output required - cut vertices
if nargout == 2 && hasNodeNames(G)
    cutvert = G.NodeProperties.Name(cutvert)';
end

function outputcell = parseFlags(varargin)

outputcell = false;

if numel(varargin) == 0
    return;
end

for ii=1:2:nargin
    name = varargin{ii};
    if ~graph.isvalidoption(name)
        error(message('MATLAB:graphfun:biconncomp:ParseFlagsUndir'));
    end
    
    if graph.partialMatch(name, "OutputForm")
        if ii+1 > numel(varargin)
            error(message('MATLAB:graphfun:biconncomp:KeyWithoutValue', 'OutputForm'));
        end
        value = varargin{ii+1};
        if ~graph.isvalidoption(value)
            error(message('MATLAB:graphfun:biconncomp:ParseOutput'));
        end
        if graph.partialMatch(value, "cell")
            outputcell = true;
        elseif graph.partialMatch(value, "vector")
            outputcell = false;
        else
            error(message('MATLAB:graphfun:biconncomp:ParseOutput'));
        end
    else
        error(message('MATLAB:graphfun:biconncomp:ParseFlagsUndir'));
    end
end
