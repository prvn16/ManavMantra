function [bins, binSize] = conncomp(G, varargin)
%CONNCOMP Connected components
%
%   BINS = CONNCOMP(G) computes the connected components of graph G.
%   BINS(i) gives the number of the component that contains node i. Two
%   nodes belong to the same component if there is a path connecting them.
%   
%   BINS = CONNCOMP(..., 'OutputForm', OUT) specifies the type of output
%   to return. OUT can be:
%          'vector'  -  Return vector bins as described above. This is the
%                       default.
%            'cell'  -  Return cell array c, with c{j} containing the
%                       nodeids of all nodes in component j.
%
%   [BINS, BINSIZE] = CONNCOMP(...) additionally gives the size of
%   the connected components. BINSIZE(i) gives the number of nodes
%   in component i.
%
%   Example:
%       % Create and plot a graph. Compute its connected components.
%       s = [1 2 2 3 3 3 4 5 5 8 8];
%       t = [2 3 4 1 4 5 5 6 7 9 10];
%       G = graph(s,t);
%       plot(G,'Layout','layered')
%       bins = conncomp(G)
%
%   See also GRAPH, SUBGRAPH, DIGRAPH/CONNCOMP

%   Copyright 2014-2016 The MathWorks, Inc.

outputcell = parseFlags(varargin{:});

bins = connectedComponents(G.Underlying);

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


function outputcell = parseFlags(varargin)

outputcell = false;

if numel(varargin) == 0
   return; 
end

for ii=1:2:nargin
    name = varargin{ii};
    if ~graph.isvalidoption(name)
        error(message('MATLAB:graphfun:conncomp:ParseFlagsUndir'));
    end
    
    if graph.partialMatch(name, "Type")
        warning(message('MATLAB:graphfun:conncomp:ParseTypeUndir'));
    elseif graph.partialMatch(name, "OutputForm")
        if ii+1 > numel(varargin)
            error(message('MATLAB:graphfun:conncomp:KeyWithoutValue', 'OutputForm'));
        end
        value = varargin{ii+1};
        if ~graph.isvalidoption(value)
            error(message('MATLAB:graphfun:conncomp:ParseOutput'));
        end
        
        if graph.partialMatch(value, "cell")
            outputcell = true;
        elseif graph.partialMatch(value, "vector")
            outputcell = false;
        else
            error(message('MATLAB:graphfun:conncomp:ParseOutput'));
        end
    else
        error(message('MATLAB:graphfun:conncomp:ParseFlagsUndir'));
    end
end
