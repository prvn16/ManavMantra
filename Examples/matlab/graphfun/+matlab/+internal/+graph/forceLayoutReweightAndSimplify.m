function [G, kw] = forceLayoutReweightAndSimplify(G, w, weightEffect)
%forceLayoutReweightAndSimplify Helper function for 'force' layout
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%

%   Copyright 2017 The MathWorks, Inc.

% Returns a simple undirected graph, and a vector of weights for this graph. If there are multiple edges between a pair of nodes (in any direction), the weights of the two edges are added.

weightEffect = validatestring(weightEffect, {'none', 'direct', 'inverse'}, '', 'WeightEffect');

if strcmp(weightEffect, 'none')
    weightExp = 0;
elseif strcmp(weightEffect, 'direct')
    weightExp = -3;
else %strcmp(weightEffect, 'inverse')
    weightExp = 3;
end
%The weights cannot be set to weird stuff such as function handles in the
%first place, so the isfinite, etc. checks for weights are not yet necessary.

if isempty(w) && weightExp ~= 0
    w = 1; % For unweighted graphs, count number of edges and use as weight.
elseif ~isempty(w) && weightExp == 0
    w = []; % Remove weights completely if weightExp == 0
end

% Spring constant for attractive forces, based on weights and weightEffect
kw = [];

% Validate weights
% Weights can only be set to real scalars in the first place, so
% only validate specific values that are not allowed.
if weightExp == -3 && (any(w==0) || any(isnan(w)))
    error(message('MATLAB:graphfun:graphbuiltin:InvalidWeightsDirectWEff'))
elseif weightExp == 3 && any(~isfinite(w))
    error(message('MATLAB:graphfun:graphbuiltin:InvalidWeightsInverseWEff'))
end

%w = w.^(weightExp); % Variant "exponent first, sum second"

if isa(G, 'matlab.internal.graph.MLGraph')
    [G, eind] = matlab.internal.graph.simplify(G);
else
    % Direction of edges does not matter, since we are converting to
    % undirected.
    ed = G.Edges;
    ed = sort(ed, 2);
    [ed, ~, eind] = unique(ed, 'rows');
    G = matlab.internal.graph.MLGraph(ed(:, 1), ed(:, 2), numnodes(G));
end

if ~isempty(w)
    w = accumarray(eind, w);
    
    kw = w.^(weightExp); % Variant "sum first, exponent second"
    kw = double(kw);
    
    % Validate kw (catch NaN's or inf's after applying exponent to save on
    % unnecessary computation later).
    if any(~isfinite(kw))
        error(message('MATLAB:graphfun:graphbuiltin:WEffLayoutFailed'))
    end
end
