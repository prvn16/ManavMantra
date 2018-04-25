function [bins, binSize] = conncomp(G, varargin)
%CONNCOMP Connected components
%
%   BINS = CONNCOMP(G) computes the strongly connected components of graph
%   G. BINS(i) gives the number of the component that contains node i. Two
%   nodes belong to the same component if there are paths connecting them
%   in both directions.
%
%   BINS = CONNCOMP(..., 'Type', TP) specifies the type of connected
%   components to be computed. TP can be:
%          'strong'  -  Two nodes belong to the same component if there are
%                       paths connecting them in both directions.
%                       This is the default.
%            'weak'  -  Two nodes belong to the same component if there is
%                       a path connecting them, ignoring edge directions.
%   
%   BINS = CONNCOMP(..., 'OutputForm', OUT) specifies the type of output
%   to return. OUT can be:
%          'vector'  -  Return vector bins as described above. This is the
%                       default.
%            'cell'  -  Return cell array c, with c{j} containing the
%                       nodeid's of all nodes in component j.
%
%   [BINS, BINSIZE] = CONNCOMP(...) additionally gives the size of
%   the connected components. BINSIZE(i) gives the number of nodes
%   in component i.
%
%   Example:
%       % Create and plot a digraph. Compute its strongly and weakly
%       % connected components.
%       s = [1 2 2 3 3 3 4 5 5 5 8 8];
%       t = [2 3 4 1 4 5 5 3 6 7 9 10];
%       G = digraph(s,t);
%       plot(G,'Layout','layered')
%       str_bins = conncomp(G)
%       weak_bins = conncomp(G,'Type','weak')
%
%   See also DIGRAPH, SUBGRAPH, GRAPH/CONNCOMP

%   Copyright 2014-2016 The MathWorks, Inc.

[strong, outputcell] = parseFlags(varargin{:});

if strong
    [bins, nrbins] = connectedComponents(G.Underlying);
    % bins is in reverse topological order, revert again:
    bins = nrbins - bins + 1;
else
    bins = weakConnectedComponents(G.Underlying);
end

if nargout > 1
    binSize = accumarray(bins(:), 1);
    binSize = binSize(:)';
end

if outputcell
    [~, ind] = sort(bins);
    blocksize = accumarray(bins', 1);
    bins = mat2cell(ind, 1, blocksize);
    if hasNodeNames(G)
        for ii=1:numel(bins)
            bins{ii} = G.NodeProperties.Name(bins{ii})';
        end
    end
end


function [strong, outputcell] = parseFlags(varargin)

strong = true;
outputcell = false;

for ii=1:2:numel(varargin)
    name = varargin{ii};
    if ~digraph.isvalidoption(name)
        error(message('MATLAB:graphfun:conncomp:ParseFlagsDir'));
    end
            
    if digraph.partialMatch(name, "Type")
        if ii+1 > numel(varargin)
            error(message('MATLAB:graphfun:conncomp:KeyWithoutValue', 'Type'));
        end
        value = varargin{ii+1};
        if ~digraph.isvalidoption(value)
            error(message('MATLAB:graphfun:conncomp:ParseTypeDir'));
        end

        if digraph.partialMatch(value, "strong")
            strong = true;
        elseif digraph.partialMatch(value, "weak")
            strong = false;
        else
            error(message('MATLAB:graphfun:conncomp:ParseTypeDir'));
        end
    elseif digraph.partialMatch(name, "OutputForm")
        if ii+1 > numel(varargin)
            error(message('MATLAB:graphfun:conncomp:KeyWithoutValue', 'OutputForm'));
        end
        value = varargin{ii+1};
        if ~digraph.isvalidoption(value)
            error(message('MATLAB:graphfun:conncomp:ParseOutput'));
        end
        
        if digraph.partialMatch(value, "cell")
            outputcell = true;
        elseif digraph.partialMatch(value, "vector")
            outputcell = false;
        else
            error(message('MATLAB:graphfun:conncomp:ParseOutput'));
        end
    else
        error(message('MATLAB:graphfun:conncomp:ParseFlagsDir'));
    end
end


