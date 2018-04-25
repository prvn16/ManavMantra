% LABELNODE   Label graph nodes
%   LABELNODE(H,NODEIDS,LABELS) labels the nodes specified in NODEIDS with
%   the strings contained in the cell array LABELS. NODEIDS can specify
%   node IDs (numeric array) or node names (cell array of strings). The
%   lengths of NODEIDS and LABELS must be equal.
%   Modifies the NodeLabel property of H.
%
%   Example:
%       % Create and plot a directed graph. Label nodes 1 and 2.
%       s = [1 1 2 2 3 4 5 5];
%       t = [2 3 3 4 4 5 1 2];
%       G = digraph(s,t);
%       H = plot(G);
%       labelnode(H,[1 2],{'source' 'target'});
%
%   See also LABELEDGE, HIGHLIGHT, LAYOUT, GRAPH/PLOT, DIGRAPH/PLOT

 
%   Copyright 2015 The MathWorks, Inc.

