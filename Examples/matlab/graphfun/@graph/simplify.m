function [gsimple, edgeind, edgecount] = simplify(g, varargin)
%SIMPLIFY Reduce multigraph to simple graph
%
%   H = SIMPLIFY(G) returns a graph without multiple edges or self-loops.
%   When there are several edges between the same two nodes, only the first
%   edge (as defined in G.Edges) is kept. Edge properties are preserved.
%
%   H = SIMPLIFY(G, PICKMETHOD) optionally specifies a method to choose one
%   of the multiple edges between two nodes. Edge properties are preserved.
%   PICKMETHOD can be:
%
%       'first' - (default) Return the first edge
%        'last' - Return the last edge
%         'min' - Return the edge of minimal weight as defined in G.Edges
%         'max' - Return the edge of maximal weight as defined in G.Edges
%
%   H = SIMPLIFY(G, PICKMETHOD, 'PickVariable', VAR) specifies which
%   variable in the table G.Edges to use with method 'min' or 'max'. The
%   default is 'Weight'.
%
%   H = SIMPLIFY(G, AGGREGATEMETHOD) optionally specifies a method to
%   combine the edge weights of multiple edges between the same two nodes
%   into the weight of a single new edge. All other edge properties of G
%   are dropped. AGGREGATEMETHOD can be:
%
%         'sum' - Return the sum of all edge weights in the group.
%        'mean' - Return the mean value of all edge weights in the group.
%
%   H = SIMPLIFY(G, AGGREGATEMETHOD, 'AggregationVariables', VARS)
%   specifies the variables of G.Edges to be used by AGGREGATEMETHOD. All
%   other edge properties of G are dropped.
%
%   H = SIMPLIFY(G, SELFLOOPFLAG),
%   H = SIMPLIFY(G, PICKMETHOD, SELFLOOPFLAG), and 
%   H = SIMPLIFY(G, AGGREGATEMETHOD, SELFLOOPFLAG) optionally specify
%   whether self-loops are removed from the graph. SELFLOOPFLAG can be:
%
%      'omitselfloops'  -  (default) Remove self-loops 
%      'keepselfloops'  -  Keep self-loops
%
%   [H, EIND, ECOUNT] = SIMPLIFY(___) additionally returns two vectors,
%   EIND and ECOUNT, that describe the mapping of edges from G to H. The
%   edge H.Edges(EIND(i),:) is the edge in H that represents the edge
%   G.Edges(i,:) in G. Also, ECOUNT(j) gives the number of edges in G that
%   correspond to edge j in H. If there are self-loops in G which are
%   omitted in H, EIND(i) is 0 for these edges in G.
%
%   See also ISMULTIGRAPH, EDGECOUNT, NUMEDGES

%   Copyright 2017 The MathWorks, Inc.


[method, pickmethod, reducemethod, vars, omitSelfLoops] = parseInputs(g, varargin);

[mlgSimple, edgeind] = matlab.internal.graph.simplify(g.Underlying, omitSelfLoops);

if omitSelfLoops
    ind = edgeind(edgeind > 0);
    edgecount = accumarray(ind(:), 1);
else
    edgecount = accumarray(edgeind, 1);
end

if size(g.EdgeProperties, 2) == 0
    % No edge properties, early return.
    gsimple = graph(mlgSimple, [], g.NodeProperties);
    return;
end

if isempty(edgeind)
    blocks = zeros(0, 1);
else
    blocks = [0; find(diff(edgeind))];
    blocks(edgeind(blocks+1) == 0) = [];
end

% Compute EdgeProperties for gsimple
if strcmp(method, 'pick')
    switch pickmethod
        case 'first'
            ind = blocks + 1;
        case 'last'
            ind = blocks + edgecount;
        case {'min', 'max'}
            if strcmp(pickmethod, 'min')
                fhandle = @min;
            else
                fhandle = @max;
            end
            w = g.EdgeProperties{:,vars};
            ind = zeros(size(blocks));
            try
                for ii=1:length(blocks)
                    [~, locind] = fhandle(w(blocks(ii)+1:blocks(ii)+edgecount(ii)));
                    ind(ii) = blocks(ii)+locind;
                end
            catch
                varName = g.EdgeProperties.Properties.VariableNames{vars};
                error(message('MATLAB:graphfun:simplify:InvalidEdgeVarType', pickmethod, varName, class(w)));
            end
    end
    edgeprop = g.EdgeProperties(ind, :);
else % method is 'reduce'
    if strcmp(reducemethod, 'sum')
        fhandle = @sum;
    else
        fhandle = @mean;
    end
    
    epSimpleCell = cell(1, length(vars));
    for jj = 1:length(vars)
        v = vars(jj);
        varin = g.EdgeProperties{:, v};
        sz = size(varin);
        sz(1) = size(blocks, 1);
        varout = cell(sz(1), 1);
        try
            for ii=1:length(blocks)
                varout{ii} = fhandle(varin(blocks(ii)+1:blocks(ii)+edgecount(ii), :), 1, 'omitnan');
            end
        catch
            varName = g.EdgeProperties.Properties.VariableNames{v};
            error(message('MATLAB:graphfun:simplify:InvalidEdgeVarType', reducemethod, varName, class(varin)));
        end
        epSimpleCell{jj} = reshape(vertcat(varout{:}), sz);
    end
    if ~isempty(epSimpleCell)
        edgeprop = table(epSimpleCell{:}, 'VariableNames', g.EdgeProperties.Properties.VariableNames(vars));
    else
        edgeprop = []; % Let digraph construct build empty EdgeProperties table
    end
end

gsimple = graph(mlgSimple, edgeprop, g.NodeProperties);


function [method, pickmethod, reducemethod, vars, omitSelfLoops] = parseInputs(g, args)

% Default values
omitSelfLoops = true;
method = 'pick';
pickmethod = 'first';
reducemethod = [];
vars = [];
varsNeedCheck = false;
specSelfLoops = false;

if ~isempty(args)
    value = validatestring(args{1}, {'first', 'last', 'min', 'max', ...
        'sum', 'mean', 'omitselfloops', 'keepselfloops'}, 2);
    
    switch value
        case {'first', 'last'}
            method = 'pick';
            pickmethod = value;
        case {'min', 'max'}
            method = 'pick';
            pickmethod = value;
            varsNeedCheck = true;
        case {'sum', 'mean'}
            method = 'reduce';
            reducemethod = value;
            varsNeedCheck = true;
        otherwise
            % case {'omitselfloops', 'keepselfloops'}
            omitSelfLoops = strcmp(value, 'omitselfloops');
            specSelfLoops = true;
    end
    
    if length(args) > 1
        
        % Check if third input is 'omitselfloops' or 'keepselfloops'
        if specSelfLoops
            opt = validatestring(args{2}, {'AggregationVariables', 'PickVariable'}, 3);
        else
            opt = validatestring(args{2}, {'AggregationVariables', 'PickVariable', 'omitselfloops', 'keepselfloops'}, 3);
        end
        
        if ismember(opt, {'omitselfloops', 'keepselfloops'})
            omitSelfLoops = strcmp(opt, 'omitselfloops');
            nameValueStart = 3;
        else
            nameValueStart = 2;
        end
        
        for ii=nameValueStart:2:length(args)
            opt = validatestring(args{ii}, {'AggregationVariables', 'PickVariable'}, ii+1);
            if ii+1 > numel(args)
                error(message('MATLAB:graphfun:simplify:KeyWithoutValue', opt));
            end
            vars = args{ii+1};
            
            switch opt
                case 'AggregationVariables'
                    if ~strcmp(method, 'reduce')
                        error(message('MATLAB:graphfun:simplify:InvalidAggregationCombination'));
                    end
                    [valid, vars] = checkVariables(g.EdgeProperties,vars);
                    
                    if ~valid
                        if isa(vars, 'function_handle')
                            error(message('MATLAB:graphfun:simplify:InvalidAggregationFHandle'));
                        else
                            error(message('MATLAB:graphfun:simplify:InvalidAggregationVars'));
                        end
                    end
                case 'PickVariable'
                    if ~strcmp(method, 'pick') || ~any(strcmp(pickmethod, {'min', 'max'}))
                        error(message('MATLAB:graphfun:simplify:InvalidPickCombination'));
                    end
                    if isa(vars, 'logical') || isa(vars, 'function_handle')
                        % Not supported for 'PickVariable'
                        error(message('MATLAB:graphfun:simplify:InvalidPickVars'));
                    end
                    [valid, vars] = checkVariables(g.EdgeProperties,vars);
                    
                    if ~valid || ~isscalar(vars)
                        error(message('MATLAB:graphfun:simplify:InvalidPickVars'));
                    end
                    if ~iscolumn(g.EdgeProperties{:, vars})
                        error(message('MATLAB:graphfun:simplify:PickVarNotColumn'));
                    end
            end
            varsNeedCheck = false;
        end
    end
end

if varsNeedCheck
    % vars were not set by user (so are still default 'Weight'), but the
    % chosen method ('min', 'max', 'sum', 'mean') will use them.
    if hasEdgeWeights(g)
        vars = find(g.EdgeProperties.Properties.VariableNames == "Weight");
    else
        if strcmp(method, 'pick')
            error(message('MATLAB:graphfun:simplify:NoWeights', 'PickVariable'));
        else
            error(message('MATLAB:graphfun:simplify:NoWeights', 'AggregationVariables'));
        end
    end
end


function [success, dataVars] = checkVariables(A,dataVars)
% Validate PickVariables, AggregationVariables, and convert to numeric
% indices if they are valid.
% This is adapted from matlab.internal.math.checkDataVariables, used for
% the 'DataVariables' Name-Value pair in data analysis functions.

if isstring(dataVars)
    % InputVariables in varfun does not (yet) accept string
    dataVars(ismissing(dataVars)) = '';
    dataVars = cellstr(dataVars); % errors for <missing> string
elseif isnumeric(dataVars)
    % Translate from index into Edges table to index into EdgeProperties
    % table.
    dataVars = dataVars - 1;
end

% Validate DataVariables value by calling a no-op varfun
try
    varfun(@(x)x,A,'InputVariables',dataVars);
    success = true;
catch
    success = false;
end

if success
    % Return a row of numeric indices
    if isnumeric(dataVars)
        dataVars = sort(reshape(dataVars,1,[]));
    else
        % DataVariables: function handle, variable name, or logical vector
        if isa(dataVars,'function_handle')
            dataVars = varfun(dataVars,A,'OutputFormat','uniform');
        elseif ischar(dataVars) || iscellstr(dataVars)
            dataVars = ismember(A.Properties.VariableNames,dataVars);
        end
        dataVars = find(reshape(dataVars,1,[]));
    end
end
