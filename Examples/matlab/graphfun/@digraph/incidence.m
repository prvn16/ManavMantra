function I = incidence(G)
%INCIDENCE Digraph incidence matrix
%   I = INCIDENCE(G) returns the digraph incidence matrix. I is a sparse
%   matrix of size numnodes(G)-by-numedges(G). The j-th column of I has
%   only two non-zero entries, I(s,j) = -1 and I(t,j) = 1, where s and t
%   are the IDs of the source and target nodes defining the j-th edge of G.
%
%   Example:
%       % Create a directed graph, and then compute its incidence matrix.
%       s = [1 2 1 3 2 3 3 3];
%       t = [2 1 3 1 3 4 5 6];
%       G = digraph(s,t)
%       I = incidence(G)
%
%   See also DIGRAPH

%   Copyright 2014-2015 The MathWorks, Inc.

e = G.Underlying.Edges;
if any(diff(e, 1, 2) == 0)
    error(message('MATLAB:graphfun:incidence:SelfLoops'));
end
nn = numnodes(G);
ne = numedges(G);
I = sparse(e, (1:ne)'*[1 1], ones(ne,1)*[-1 1], nn, ne);
