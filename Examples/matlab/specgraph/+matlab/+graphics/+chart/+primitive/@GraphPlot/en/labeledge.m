% LABELEDGE   Label graph edges
%   LABELEDGE(H,S,T,LABELS) labels the edges specified by (S,T) pairs with
%   the strings contained in the cell array LABELS. S and T can both be
%   node IDs (numeric arrays) or node names (cell arrays of strings). The
%   lengths of S,T and LABELS must be equal. If there are multiple edges
%   between S and T, they are all assigned the same label.
%   Modifies the EdgeLabel property of H.
%
%   LABELEDGE(H,IND,LABELS) specifies the edges with their indices IND. IND
%   must be a valid edge index, that is, an integer-valued number between 1
%   and the number of edges. The lengths of IND and LABELS must be equal.
%
%   Example:
%       % Create and plot a graph. Label edges (1,2), (1,3), and (2,3).
%       G = graph([1 1 2 2 3],[2 3 3 4 4]);
%       H = plot(G);
%       s = [1 1 2];
%       t = [2 3 3];
%       labels = {'ABC' 'DEF' 'GHI'};
%       labeledge(H,s,t,labels);
%
%   Example:
%       % Create and plot a graph. Label edges 1, 2, 3 with their weights.
%       G = graph([1 1 1 2 2],[2 3 4 2 5],[5 10 15 10 10]);
%       H = plot(G);
%       ind = [1 2 3];
%       labeledge(H,ind,G.Edges.Weight(ind));
%
%   See also LABELNODE, HIGHLIGHT, LAYOUT, GRAPH/PLOT, DIGRAPH/PLOT

 
%   Copyright 2015-2017 The MathWorks, Inc.

