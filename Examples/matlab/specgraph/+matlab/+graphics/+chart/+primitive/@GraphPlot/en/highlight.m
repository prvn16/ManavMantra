% HIGHLIGHT   Highlight nodes and edges in plotted graph
%   HIGHLIGHT(H,NODEIDS) highlights the nodes specified in NODEIDS by
%   increasing the size of their markers. NODEIDS can specify node IDs
%   (numeric array), node names (cell array of strings), or select nodes
%   to be highlighted (logical array).
%
%   HIGHLIGHT(H,G) highlights the nodes and edges of the graph G, by
%   increasing their node marker size and edge line width, respectively.
%   G must have the same nodes and a subset of the edges of the underlying
%   graph of H. Isolated nodes with degree 0 are not highlighted.
%
%   HIGHLIGHT(H,S,T) highlights the edges specified by (S,T) pairs by
%   increasing their edge line widths. S and T can both be node IDs
%   (numeric arrays) or node names (cell arrays of character vectors).
%
%   HIGHLIGHT(H,'Edges',EDGEIDS) highlights the edges specified by indices
%   EDGEIDS into rows of the table G.Edges. EDGEIDS can specify edge IDs
%   (numeric array), or select nodes to be highlighted (logical array).
%
%   HIGHLIGHT(...,PROPNAME,VALUE) highlights nodes or edges by setting the
%   the property PROPNAME to VALUE instead of increasing the marker size or
%   edge line width. PROPNAME can be 'NodeColor', 'Marker', 'MarkerSize',
%   'EdgeColor', 'LineWidth', or 'LineStyle'.
%
%   Example:
%       % Create and plot a graph, then HIGHLIGHT nodes 1 and 3.
%       G = graph(1,2:6)
%       H = plot(G,'Layout','force')
%       highlight(H,[1 3])
%
%   Example:
%       % Create and plot a graph, then HIGHLIGHT the shortest path between
%       % nodes 28 and 56 by changing the color of the nodes and edges
%       % along the path to green.
%       G = graph(bucky)
%       H = plot(G)
%       path = shortestpath(G,28,56)
%       highlight(H,path,'NodeColor','g','EdgeColor','g')
%
%   Example:
%       % Create and plot a graph, then HIGHLIGHT both the successors and
%       % the out-going edges of node 10.
%       A = delsq(numgrid('S',6));
%       G = digraph(A,'OmitSelfLoops');
%       H = plot(G);
%       suc10 = successors(G,10)
%       highlight(H,10,'NodeColor',[0 0.75 0],'MarkerSize',8)
%       highlight(H,suc10,'NodeColor','red')
%       highlight(H,10,suc10,'EdgeColor','red','LineWidth',2)
%
%   See also LABELNODE, LABELEDGE, LAYOUT, GRAPH/PLOT, DIGRAPH/PLOT

 
%   Copyright 2015-2017 The MathWorks, Inc.

