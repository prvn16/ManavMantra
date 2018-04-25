function I = incidence(G)
%INCIDENCE Graph incidence matrix
%   I = INCIDENCE(G) returns the graph incidence matrix. I is a sparse
%   matrix of size numnodes(G)-by-numedges(G). The j-th column of I has
%   only two non-zero entries, I(s,j) = -1 and I(t,j) = 1, where s and t
%   are the IDs of the source and target nodes defining the j-th edge of G.
%
%   Example:
%       % Create a graph, and then compute the graph incidence matrix.
%       s = [1 1 1 1 1];
%       t = [2 3 4 5 6];
%       G = graph(s,t)
%       I = incidence(G)
%
%   See also GRAPH, LAPLACIAN

%   Copyright 2014-2015 The MathWorks, Inc.

if hasSelfLoops(G.Underlying)
    error(message('MATLAB:graphfun:incidence:SelfLoops'));
end
nn = numnodes(G);
ne = numedges(G);
I = sparse(G.Underlying.Edges, (1:ne)'*[1 1], ones(ne,1)*[-1 1], nn, ne);

