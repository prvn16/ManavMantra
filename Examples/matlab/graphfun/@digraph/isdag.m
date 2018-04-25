function isd = isdag(G)
%ISDAG Determine whether a digraph is acyclic.
%
%   ISDAG(G) returns true if digraph G is a Directed Acyclic
%   Graph (DAG). This is the case if it has no cycles.
%
%   Example:
%       % Create and plot a digraph, then test if it is acyclic.
%       s = [1 1 2 2 3 3 4 4 4 5];
%       t = [2 3 4 5 6 7 8 9 10 4];
%       G = digraph(s,t);
%       plot(G)
%       tf = isdag(G)
%
%   See also TOPOSORT, REORDERNODES

%   Copyright 2014-2015 The MathWorks, Inc.

isd = dfsTopologicalSort(G.Underlying);
