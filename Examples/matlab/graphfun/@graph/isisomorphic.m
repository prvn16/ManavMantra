function isIso = isisomorphic(G, G2, varargin)
%ISISOMORPHIC Determine whether two graphs are isomorphic
%   tf = ISISOMORPHIC(G,G2) returns logical 1 (true) if there is an
%   isomorphism between graphs G and G2; otherwise, it returns logical 0
%   (false). Two graphs are isomorphic if there exists a permutation vector
%   P such that REORDERNODES(G2,P) has the same structure as G.
%
%   tf = ISISOMORPHIC(..., 'NodeVariables', PROPLIST) requires the
%   permutation vector P to preserve all node properties listed in
%   PROPLIST. PROPLIST must be a char array or a cell array of strings.
%
%   tf = ISISOMORPHIC(..., 'EdgeVariables', PROPLIST) requires the
%   permutation vector P to preserve all edge properties listed in
%   PROPLIST. PROPLIST must be a char array or a cell array of strings. If
%   PROPLIST contains 'EndNodes', it is ignored.
%
%   See also GRAPH, ISOMORPHISM, DIGRAPH/ISISOMORPHIC

%   Copyright 2016 The MathWorks, Inc.

isIso = (isequal(class(G), class(G2)) && numnodes(G) == 0 && numnodes(G2) == 0) || ...
         ~isempty(isomorphism(G, G2, varargin{:}));