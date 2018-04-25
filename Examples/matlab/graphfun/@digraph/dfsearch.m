function [t, eidx] = dfsearch(G, s, varargin)
%DFSEARCH Apply Depth-First Search to graph G.
%
%   v = DFSEARCH(G,s) applies depth-first search to graph G starting at
%   node s and returns the node indices in order of discovery.
%
%   [T, E] = DFSEARCH(G,s,EVENTS) customizes the output by flagging one or more
%   search events.
%   EVENTS can be:
%
%        'discovernode'  -  New node has been discovered.
%          'finishnode'  -  All edges of the node have been visited.
%           'edgetonew'  -  Edge connecting to an undiscovered node.
%    'edgetodiscovered'  -  Edge connecting to a discovered node.
%      'edgetofinished'  -  Edge connecting to a finished node.
%           'startnode'  -  Starting node (important with option 'Restart')
%     string array or
%           cell array   -  Contains a subset of flags
%           'allevents'  -  Flags all search events
%
%   Depending on the value of EVENTS, the output T changes:
%     - For 'discovernode', 'finishnode', or 'startnode', T is a vector of
%       node indices.
%     - For 'edgetonew', 'edgetodiscovered', or 'edgetofinished', T is an
%       Nx2 matrix of edges. The second output E is an Nx1 vector of edge IDs.
%     - For cell arrays, T is a table, with T.Event containing only the
%       specified flags.
%     - For 'allevents', T is a table containing all possible flagged
%       events.
%
%   When T is a table, T.Event is a categorical vector containing the event
%   flags above, in order of occurrence. If T.Event(i) describes a node,
%   T.Node(i) contains the index of the corresponding node. If T.Event(i)
%   describes an edge, T.Edge(i, :) contains the source and target node,
%   and T.EdgeIndex(i) contains the edge ID.
%   Unused elements of T.Node and T.Edge are set to NaN.
%
%   See the documentation page for a description of the Depth-First Search
%   Algorithm and these events.
%
%   T = BFSEARCH(..., 'Restart', true) restarts the search if there are
%   still undiscovered nodes after the search is finished.  The new start
%   node is the undiscovered node with the smallest index. This is repeated
%   until all nodes are discovered. The default value is false.
%
%   Example:
%       % Create and plot a digraph. Perform a depth-first search
%       % starting at node 2 and list the nodes in order of discovery.
%       s = [1 1 1 1 2 2 2 2 2 2 2 2 2 2 9 9 9 9 9];
%       t = [3 5 4 2 14 6 11 12 13 10 7 9 8 15 16 17 19 18 20];
%       G = digraph(s,t);
%       plot(G)
%       v = dfsearch(G,2)
%
%   Example:
%       % Create and plot a digraph. Perform a depth-first search
%       % starting at node 2 and list all search events in a table.
%       s = [1 1 1 2 3 3 3 4 6];
%       t = [2 4 5 5 6 7 4 1 4];
%       G = digraph(s,t);
%       plot(G)
%       E = dfsearch(G,1,'allevents')
%
%    See also BFSEARCH

%   Copyright 2014-2017 The MathWorks, Inc.

if nargout <= 1
    t = search(false, G, s, varargin{:});
else
    [t, eidx] = search(false, G, s, varargin{:});
end
