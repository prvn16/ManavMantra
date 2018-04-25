function [order, h] = toposort(g, key, name)
%TOPOSORT Topological order of acyclic digraph
%
%   ORDER = TOPOSORT(G) returns a new order of nodes such that i < j for
%   every edge (ORDER(i), ORDER(j)) in G. The digraph G cannot have any
%   cycles.
%
%   [ORDER, H] = TOPOSORT(G) additionally returns a digraph H in the given
%   topological order.
%
%   TOPOSORT(G, 'Order', ORDER) specifies how the nodes are reordered.
%   ORDER can be:
%              'fast'   If G is already in topological order, this method
%                       may still reorder it.
%            'stable'   IND(1) is the smallest possible index, IND(2)
%                       has the smallest index possible given IND(1), and
%                       so on. If G is in topological order, H is not
%                       changed and ORDER is 1:numnodes(G).
%
%   Example:
%       % Create and plot a digraph. Compute the topological order of the
%       % nodes in the digraph.
%       s = {'Calculus I', 'Calculus I', 'Calculus II', ...
%            'Real Analysis', 'Linear Algebra', 'Calculus II', ...
%            'Multivariate Calculus', 'Multivariate Calculus', ...
%            'Differential Equations', 'Calculus II'};
%       t = {'Calculus II', 'Linear Algebra', 'Multivariate Calculus', ...
%            'Topology', 'Multivariate Calculus', 'Linear Algebra', ...
%            'Differential Equations', 'Topology', 'Topology', ...
%            'Real Analysis'};
%       G = digraph(s,t);
%       plot(G)
%       N = toposort(G)
%       G.Nodes.Name(N,:)
%
%   See also ISDAG, REORDERNODES

%   Copyright 2014-2016 The MathWorks, Inc.

use_lexicographic = false;

if nargin > 1
    if ~digraph.isvalidoption(key) || ~digraph.partialMatch(key, "Order")
        error(message('MATLAB:graphfun:toposort:ParseFlag'));
    end
    if nargin == 2
        error(message('MATLAB:graphfun:toposort:ParseType'));
    end
    if ~digraph.isvalidoption(name)
        error(message('MATLAB:graphfun:toposort:ParseType'));
    end
    if digraph.partialMatch(name, "stable")
        use_lexicographic = true;
    elseif ~digraph.partialMatch(name, "fast")
        error(message('MATLAB:graphfun:toposort:ParseType'));
    end
end

if ~use_lexicographic
    [isd, order] = dfsTopologicalSort(g.Underlying);
else
    [isd, order] = lexicographicTopologicalSort(g.Underlying);
end

if ~isd
   error(message('MATLAB:graphfun:toposort:NotDAG'));
end

if nargout > 1
    h = reordernodes(g, order);
end
