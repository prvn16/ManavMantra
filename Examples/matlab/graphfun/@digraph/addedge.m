function H = addedge(G, s, t, weights)
%ADDEDGE Add edges to a digraph
%   H = ADDEDGE(G,s,t) returns digraph H that is equivalent to G but with
%   edges specified by s and t added to it.  s and t must both refer to
%   string node names or numeric node indices.  If a node specified by s or
%   t is not present in the digraph G, that node is added as well.
%
%   H = ADDEDGE(G,s,t,w), where G is a weighted graph, adds edges with
%   corresponding edge weights defined by w.  w must be numeric.
%
%   H = ADDEDGE(G,EdgeTable) adds edges with attributes specified by
%   the table EdgeTable.  EdgeTable must be able to be concatenated with
%   G.Edges.
%
%   H = ADDEDGE(G,s,t,EdgeTable) adds edges with attributes specified by
%   the table EdgeTable.  EdgeTable must not contain a variable EndNodes,
%   and must be able to be concatenated with G.Edges(:, 2:end).
%
%   Example:
%       % Construct a digraph with three edges, then add two new edges.
%       G = digraph([1 2 3],[2 3 4])
%       G.Edges
%       G = addedge(G,[2 1],[4 6])
%       G.Edges
%
%   See also DIGRAPH, NUMEDGES, RMEDGE, ADDNODE

%   Copyright 2014-2017 The MathWorks, Inc.

useWeights = nargin >= 4 || istable(s);

if istable(s)
    if nargin > 2
        error(message('MATLAB:graphfun:addedge:TableMaxRHS'));
    end
    if size(s,2) < 1
        error(message('MATLAB:graphfun:addedge:TableSize'));
    end
    if ~strcmp('EndNodes', s.Properties.VariableNames{1})
        error(message('MATLAB:graphfun:addedge:TableFirstVar'));
    end
    if size(s.EndNodes,2) ~= 2 || ~(isnumeric(s.EndNodes) || ...
            iscellstr(s.EndNodes))
        error(message('MATLAB:graphfun:addedge:BadEndNodes'));
    end
    % Extract into s, t, w.
    t = s.EndNodes(:,2);
    weights = s(:,2:end);
    s = s.EndNodes(:,1);
elseif nargin >= 4 && istable(weights)
    if any(strcmp('EndNodes', weights.Properties.VariableNames))
        error(message('MATLAB:graphfun:addedge:DuplicateEndNodes'));
    end
elseif nargin < 4 && hasEdgeWeights(G)
    error(message('MATLAB:graphfun:addedge:SpecifyWeight'));
end

% Basic checks of inputs s and t
inputsAreStrings = digraph.isvalidstring(s) && digraph.isvalidstring(t);
if inputsAreStrings
    s = cellstr(s);
    t = cellstr(t);
elseif ~(isnumeric(s) && isnumeric(t))
    error(message('MATLAB:graphfun:addedge:InconsistentNodeNames'));
end

if numel(s) ~= numel(t) && ~isscalar(s) && ~isscalar(t)
    error(message('MATLAB:graphfun:graphbuiltin:EqualNumel'));
end

% Add any nodes that are not present.
if inputsAreStrings
    s = s(:);
    t = t(:);
    if numel(s) == numel(t)
        refdNodes = [s, t].';
        fromS = repmat([true; false], 1, size(refdNodes, 2));
    elseif isscalar(s)
        refdNodes = [s; t];
        fromS = false(size(refdNodes));
        fromS(1) = true;
    elseif isscalar(t)
        refdNodes = [s(1); t; s(2:end)];
        fromS = true(size(refdNodes));
        fromS(2) = false;
    end
    if hasNodeNames(G)
        % Lookup node names and add any that we might need.
        ind = findnode(G, refdNodes(:));
        [newNodes, ~, newInd] = unique(refdNodes(ind==0), 'stable');
        ind(ind==0) = newInd + numnodes(G);
    else
        [refdNodes, ~, ind] = unique(refdNodes(:), 'stable');
        ind = ind + numnodes(G);
        newNodes = refdNodes;
    end
    s = ind(fromS);
    t = ind(~fromS);
    H = G;
    H.NodeProperties = addToNodeProperties(G, newNodes, false);
else % isnumeric(s) && isnumeric(t)
    s = double(s(:));
    t = double(t(:));
    ms = validateNodeIDs(s);
    mt = validateNodeIDs(t);
    N = max(ms, mt);
    H = G;
    if N > numnodes(G)
        H.NodeProperties = addToNodeProperties(G, N-numnodes(G));
    end
end

if useWeights || size(G.EdgeProperties, 2) > 0
    [H.Underlying, p] = addedge(G.Underlying, s, t);
    
    q = true(numedges(H), 1);
    q(p) = false;
else
    H.Underlying = addedge(G.Underlying, s, t);
end

if useWeights
    EdgePropTable = G.EdgeProperties;
    if isnumeric(weights)
        if numedges(G) > 0
            if ~hasEdgeWeights(G)
                error(message('MATLAB:graphfun:addedge:NoWeights'));
            end
            EdgePropTable = expandTable(G.EdgeProperties, q);
        end
        if ~isscalar(weights) && numel(p) ~= numel(weights)
            error(message('MATLAB:graphfun:addedge:NumWeightsMismatch'));
        end
        EdgePropTable{p,'Weight'} = weights(:);
    elseif istable(weights)
        if numedges(G) > 0
            if size(G.EdgeProperties, 2) ~= size(weights, 2)
                error(message('MATLAB:table:VarDimensionMismatch'));
            end
            if ~isequal(G.EdgeProperties.Properties.VariableNames, ...
                    weights.Properties.VariableNames)
                error(message('MATLAB:table:VarDimensionMismatch'));
            end
            EdgePropTable = expandTable(G.EdgeProperties, q);
        end
        EdgePropTable(p,:) = weights;
    else
        error(message('MATLAB:graphfun:addedge:FourthInput'));
    end
else
    if size(G.EdgeProperties, 2) == 0
        EdgePropTable = table.empty(numedges(H), 0);
    else
        EdgePropTable = expandTable(G.EdgeProperties, q);
    end
end

H.EdgeProperties = EdgePropTable;
if nargout < 1
    warning(message('MATLAB:graphfun:addedge:NoOutput'));
end

function m = validateNodeIDs(ids)
if ~isreal(ids) || any(fix(ids)~=ids) || any(ids < 1)
    error(message('MATLAB:graphfun:addedge:InvalidNodeID'));
end
m = max(ids(:));

function tnew = expandTable(t, q)
% t is a table, q a logical array with nnz(q) == size(t, 1).
% Return value is a table tnew with numel(q) rows, where tnew(q) = t
% and all other rows of tnew are the result of table expansion.

tnew = t([], :);
tnew(numel(q)+1, :) = t(1, :);
tnew(numel(q)+1, :) = [];

tnew(q, :) = t;
