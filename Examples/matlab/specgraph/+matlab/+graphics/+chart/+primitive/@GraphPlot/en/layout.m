%LAYOUT Change layout of graph plot
%
%   LAYOUT(H) changes the layout of H by using an automatic choice of
%   layout method based on the structure of the graph. 
%   Modifies the XData and YData properties of H.
%
%   LAYOUT(H,METHOD) optionally specifies the layout method.
%   METHOD can be:
%       'auto'      (Default) Automatic choice of layout method based on
%                   the structure of the graph.
%       'circle'    Circular layout.
%       'force'     Force-directed layout. Uses attractive and repulsive 
%                   forces on nodes.
%       'layered'   Layered layout. Places nodes in a set of layers.
%       'subspace'  Subspace embedding layout. Uses projection onto an 
%                   embedded subspace.
%       'force3'    3-D force-directed layout.
%       'subspace3' 3-D Subspace embedding layout.
%
%   LAYOUT(H,METHOD,NAME,VALUE) uses additional options specified by one or
%   more Name-Value pair arguments. The optional argument names can be:
%       'circle'    Supports 'Center'.
%       'force'     Supports 'Iterations', 'UseGravity', 'WeightEffect',
%                   'XStart', 'YStart'.
%       'force3'    Supports 'Iterations', 'UseGravity', 'WeightEffect', 
%                   'XStart', 'YStart', 'ZStart'.
%       'layered'   Supports 'AssignLayers', 'Direction', 'Sinks',
%                   'Sources'.
%       'subspace'  Supports 'Dimension'.
%       'subspace3' Supports 'Dimension'.
%   See the reference page for a description of each Name-Value pair.
%
%   Example:
%       % Plot a graph using an automatic choice of layout method. Then
%       % change the plotted graph to a 'circle' layout.
%       G = graph(bucky)
%       H = plot(G)
%       layout(H,'circle')
%
%	Example:
%       % Plot a graph using the 'force' layout method. Then change the
%       % plotted graph to a 'layered' layout with the 'Direction' set to
%       % 'up' and 'Sources' set to node 1.
%       G = digraph(1,2:5);
%       G = addedge(G,2,6:15);
%       H = plot(G,'Layout','force')
%       layout(H,'layered','Direction','up','Sources',1)
%
%   See also HIGHLIGHT, LABELEDGE, LABELNODE, GRAPH/PLOT, DIGRAPH/PLOT

 
%   Copyright 2015-2017 The MathWorks, Inc.

