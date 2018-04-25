function ism = ismultigraph(G)
%ISMULTIGRAPH Determine whether a graph has multiple edges.
%
%   TF = ISMULTIGRAPH(G) returns logical 1 (true) if graph G has multiple
%   edges between the same two nodes.
%
%   See also EDGECOUNT

%   Copyright 2017 The MathWorks, Inc.

ism = ismultigraph(G.Underlying);
