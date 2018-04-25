classdef (Sealed, InferiorClasses = {?matlab.graphics.axis.Axes, ?matlab.ui.control.UIAxes}) graph < matlab.mixin.CustomDisplay & matlab.mixin.internal.Scalar
    %GRAPH Undirected Graph
    %   G = GRAPH builds an empty graph with no nodes and no edges.
    %
    %   G = GRAPH(A) uses the square symmetric matrix A as an adjacency matrix
    %   and constructs a weighted graph with edges corresponding to the nonzero
    %   entries of A.  The weights of the edges are taken to be the nonzero
    %   values in A.  If A is logical then no weights are added.
    %
    %   G = GRAPH(A,NAMES) additionally uses the cell array of strings NAMES as
    %   the names of the nodes in G.  NAMES must have as many elements as
    %   size(A,1).
    %
    %   G = GRAPH(A,...,TYPE) uses only a triangle of A to construct the graph.
    %   TYPE can be:
    %           'upper'  -  Use the upper triangle of A.
    %           'lower'  -  Use the lower triangle of A.
    %
    %   G = GRAPH(A,...,'OmitSelfLoops') ignores the diagonal entries of the
    %   adjacency matrix A and does not add self-loops to the graph.
    %
    %   G = GRAPH(S,T) constructs a graph with edges specified by the node
    %   pairs (S,T).  S and T must both be numeric, or both be strings or cell
    %   arrays of strings.  S and T must have the same number of elements or be
    %   scalars.
    %
    %   G = GRAPH(S,T,WEIGHTS) also specifies edge weights with the numeric
    %   array WEIGHTS.  WEIGHTS must have the same number of elements as S and
    %   T, or can be a scalar.
    %
    %   G = GRAPH(S,T,WEIGHTS,NAMES) additionally uses the cell array of
    %   strings NAMES as the names of the nodes in G.  S and T may not contain
    %   any strings that are not in NAMES.
    %
    %   G = GRAPH(S,T,WEIGHTS,NUM) specifies the number of nodes of the graph
    %   with the numeric scalar NUM.  NUM must be greater than or equal to the
    %   largest elements in S and T.
    %
    %   G = GRAPH(S,T,...,'OmitSelfLoops') does not add self-loops to the
    %   graph.  That is, any edge k such that S(k) == T(k) is not added.
    %
    %   G = GRAPH(EdgeTable) uses the table EdgeTable to define the graph.  The
    %   first variable in EdgeTable must be EndNodes, and it must be a
    %   two-column array defining the edge list of the graph.  EdgeTable can
    %   contain any number of other variables to define attributes of the graph
    %   edges.
    %
    %   G = GRAPH(EdgeTable,NodeTable) additionally uses the table NodeTable to
    %   define attributes of the graph nodes.  NodeTable can contain any number
    %   of variables to define attributes of the graph nodes.  The number of
    %   nodes in the resulting graph is the number of rows in NodeTable.
    %
    %   G = GRAPH(EdgeTable,...,'OmitSelfLoops') does not add self-loops to the
    %   graph.
    %
    %   Example:
    %       % Construct an undirected graph from an adjacency matrix.
    %       % View the edge list of the graph, and then plot the graph.
    %       A = [0 10 20 30; 10 0 2 0; 20 2 0 1; 30 0 1 0]
    %       G = graph(A)
    %       G.Edges
    %       plot(G)
    %
    %   Example:
    %       % Construct a graph using a list of the end nodes of each edge.
    %       % Also specify the weight of each edge and the name of each node.
    %       % View the Edges and Nodes tables of the graph, and then plot
    %       % G with the edge weights labeled.
    %       s = [1 1 1 2 2 3 3 4 5 5 6 7];
    %       t = [2 4 8 3 7 4 6 5 6 8 7 8];
    %       weights = [10 10 1 10 1 10 1 1 12 12 12 12];
    %       names = {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H'};
    %       G = graph(s,t,weights,names)
    %       G.Edges
    %       G.Nodes
    %       plot(G,'EdgeLabel',G.Edges.Weight)
    %
    %   Example:
    %       % Construct the same graph as in the previous example using two
    %       % tables to specify edge and node properties.
    %       s = [1 1 1 2 2 3 3 4 5 5 6 7]';
    %       t = [2 4 8 3 7 4 6 5 6 8 7 8]';
    %       weights = [10 10 1 10 1 10 1 1 12 12 12 12]';
    %       names = {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H'}';
    %       EdgeTable = table([s t],weights,'VariableNames',{'EndNodes' 'Weight'})
    %       NodeTable = table(names,'VariableNames',{'Name'})
    %       G = graph(EdgeTable,NodeTable)
    %
    %   graph properties:
    %      Edges            - Table containing edge information.
    %      Nodes            - Table containing node information.
    %
    %   graph methods:
    %      numnodes         - Number of nodes in a graph.
    %      numedges         - Number of edges in a graph.
    %      findnode         - Determine node ID given a name.
    %      findedge         - Determine edge index given node IDs.
    %      edgecount        - Determine number of edges between two nodes.
    %
    %      addnode          - Add nodes to a graph.
    %      rmnode           - Remove nodes from a graph.
    %      addedge          - Add edges to a graph.
    %      rmedge           - Remove edges from a graph.
    %
    %      ismultigraph     - Determine whether a graph has multiple edges.
    %      simplify         - Reduce multigraph to simple graph.
    %
    %      degree           - Degree of nodes in a graph.
    %      neighbors        - Neighbors of a node in a graph.
    %      outedges         - Edges connected to a node in a graph.
    %      reordernodes     - Reorder nodes in a graph.
    %      subgraph         - Extract an induced subgraph.
    %
    %      adjacency        - Adjacency matrix of a graph.
    %      incidence        - Incidence matrix of a graph.
    %      laplacian        - Graph Laplacian.
    %
    %      bfsearch         - Breadth-first search.
    %      dfsearch         - Depth-first search.
    %      shortestpath     - Compute shortest path between two nodes.
    %      shortestpathtree - Compute single source shortest paths.
    %      distances        - Compute all pairs distances.
    %      nearest          - Compute nearest neighbors of a node.
    %      maxflow          - Compute maximum flows in a graph.
    %      conncomp         - Compute connected components of a graph.
    %      biconncomp       - Compute biconnected components of a graph.
    %      bctree           - Block-cut tree of a graph.
    %      minspantree      - Compute minimum spanning tree of a graph.
    %      centrality       - Node centrality for graph G.
    %      isisomorphic     - Determine whether two graphs are isomorphic.
    %      isomorphism      - Compute an isomorphism between G and G2.
    %
    %      plot             - Plot an undirected graph.
    %
    %   See also DIGRAPH
    
    %   Copyright 2014-2017 The MathWorks, Inc.
    
    properties (Dependent)
        %EDGES - Table containing graph edges.
        %   Edges is a table with numedges(G) rows containing variables
        %   describing attributes of edges.  To add attributes to
        %   the edges of a graph, add a column to G.Edges.
        %
        %   See also GRAPH
        Edges
        %NODES - Table containing attributes for each node
        %   Nodes is a table with numnodes(G) rows containing variables
        %   describing attributes of nodes.  To add attributes to
        %   the nodes of a graph, add a column to G.Nodes.
        %
        %   See also GRAPH
        Nodes
    end
    properties (Access = private)
        %UNDERLYING - Underlying graph representation
        %   Underlying is an instance of matlab.internal.graph.MLGraph
        %   holding all graph connectivity information.
        %
        %   See also GRAPH, ADDEDGE, FINDEDGE
        Underlying
        %EDGEPROPERTIES - Table containing attributes for each edge
        %   EdgeProperties is a table with numedges(G) rows containing
        %   variables describing attributes of edges.  To add attributes to
        %   the edges of a graph, add a column to G.EdgeProperties.
        %
        %   See also GRAPH
        EdgeProperties
        %NODEPROPERTIES - Table containing attributes for each node
        %   NodeProperties is a table with numnodes(G) rows containing
        %   variables describing attributes of nodes.  To add attributes to
        %   the nodes of a graph, add a column to G.NodeProperties.
        %
        %   See also GRAPH
        NodeProperties
    end
    methods
        function G = graph(varargin)
            if nargin == 0
                G.Underlying = matlab.internal.graph.MLGraph;
                G.EdgeProperties = table;
                G.NodeProperties = table;
                return;
            end
            if isa(varargin{1}, 'matlab.internal.graph.MLGraph')
                G.Underlying = varargin{1};
                if nargin >= 2
                    if isa(varargin{2}, 'table')
                        if size(varargin{2}, 1) ~= numedges(G.Underlying)
                            error(message('MATLAB:graphfun:graph:InvalidSizeWeight'));
                        end
                        G.EdgeProperties = varargin{2};
                    elseif isequal(varargin{2}, [])
                        G.EdgeProperties = table.empty(numedges(G.Underlying), 0);
                    else
                        if numel(varargin{2}) ~= numedges(G.Underlying)
                            error(message('MATLAB:graphfun:graph:InvalidSizeWeight'));
                        end
                        G.EdgeProperties = table(varargin{2}(:), 'VariableNames', {'Weight'});
                    end
                else
                    G.EdgeProperties = table.empty(numedges(G.Underlying), 0);
                end
                if nargin >= 3
                    G.NodeProperties = graph.validateNodeProperties(varargin{3});
                    if size(G.NodeProperties, 1) ~= numnodes(G)
                        error(message('MATLAB:graphfun:graph:InvalidNodeNames'));
                    end
                else
                    G.NodeProperties = table.empty(numnodes(G.Underlying), 0);
                end
                return;
            end
            if (isnumeric(varargin{1}) || islogical(varargin{1})) ...
                    && ((nargin == 1) || ~isnumeric(varargin{2}))
                % Adjacency matrix Constructor.
                A = varargin{1};
                % Validation on A.
                if size(A,1) ~= size(A,2)
                    error(message('MATLAB:graphfun:graph:SquareAdjacency'));
                end
                if ~isfloat(A) && ~islogical(A)
                    error(message('MATLAB:graphfun:graph:InvalidAdjacencyType'));
                end
                if nargin > 4
                    error(message('MATLAB:maxrhs'));
                end
                % Set up defaults for flags.
                checksym = 0;
                omitLoops = false;
                nodePropsSet = false;
                % Second arg can be Cell Str of node names, Nodes table(?)
                % or one of trailing flags.
                if nargin > 1
                    nnames = varargin{2};
                    if iscellstr(nnames) %#ok<ISCLSTR>
                        % Always assume node names.
                        if numel(nnames) ~= size(A,1)
                            error(message('MATLAB:graphfun:graph:InvalidNodeNames'));
                        end
                        G.NodeProperties = graph.validateNodeProperties(nnames(:));
                        nodePropsSet = true;
                    elseif istable(nnames)
                        if size(nnames,1) ~= size(A,1)
                            error(message('MATLAB:graphfun:graph:InvalidNodeNames'));
                        end
                        G.NodeProperties = graph.validateNodeProperties(nnames);
                        nodePropsSet = true;
                    else
                        % Look for 'upper', 'lower', 'omitSelfLoops'.
                        [checksym, omitLoops] = validateFlag(nnames, checksym, omitLoops);
                    end
                end
                if nargin > 2
                    [checksym, omitLoops] = validateFlag(varargin{3}, checksym, omitLoops);
                end
                if nargin > 3
                    [checksym, omitLoops] = validateFlag(varargin{4}, checksym, omitLoops);
                end
                useWeights = ~islogical(A);
                if checksym == 1
                    A = triu(A) + triu(A,1).';
                elseif checksym == -1
                    A = tril(A) + tril(A,-1).';
                else
                    if isnumeric(A) && ~issymmetric(A)
                        error(message('MATLAB:graphfun:graph:SymmetricAdjacency'));
                    end
                end
                if omitLoops
                    n = size(A,1);
                    A(1:n+1:end) = 0;
                end
                G.Underlying = matlab.internal.graph.MLGraph(A);
                if useWeights
                    G.EdgeProperties = table(nonzeros(tril(A)), 'VariableNames', {'Weight'});
                else
                    G.EdgeProperties = table.empty(G.Underlying.EdgeCount,0);
                end
                if ~nodePropsSet
                    G.NodeProperties = table.empty(size(A,1),0);
                end
                return;
            end
            if istable(varargin{1})
                % Table based Constructor.
                [G.Underlying, G.EdgeProperties, G.NodeProperties] = ...
                    matlab.internal.graph.constructFromTable(...
                    @matlab.internal.graph.MLGraph, 'graph', ...
                    varargin{:});
                return;
            end
            % Finally, assume Edge List Constructor.
            if nargin == 1
                error(message('MATLAB:graphfun:graph:EdgesNeedTwoInputs'));
            end
            [G.Underlying, G.EdgeProperties, G.NodeProperties] = ...
                matlab.internal.graph.constructFromEdgeList(...
                @matlab.internal.graph.MLGraph, 'graph', ...
                varargin{:});
        end
        function G = set.Edges(G, T)
            % Remove the 'EndNodes' variable from T, and slam the rest into
            % EdgeProperties.
            if size(T, 1) ~= numedges(G)
                error(message('MATLAB:graphfun:graph:SetEdges'));
            end
            T(:,'EndNodes') = [];
            G.EdgeProperties = T;
        end
        function E = get.Edges(G)
            EndNodes = G.Underlying.Edges;
            if hasNodeNames(G)
                EndNodes = reshape(G.NodeProperties.Name(EndNodes), [], 2);
            end
            E = [table(EndNodes) G.EdgeProperties];
        end
        function G = set.Nodes(G, T)
            if size(T, 1) ~= numnodes(G)
                error(message('MATLAB:graphfun:graph:SetNodes'));
            end
            G.NodeProperties = graph.validateNodeProperties(T);
        end
        function N = get.Nodes(G)
            N = G.NodeProperties;
        end
        function G = set.EdgeProperties(G, T)
            G.EdgeProperties = graph.validateEdgeProperties(T);
        end
    end
    methods (Access = protected) % Display helper
        function propgrp = getPropertyGroups(obj)
            % Construct cheatEdges, a table with the same size as
            % Edges, to save on having to construct Edges table:
            edgesColumns = repmat({zeros(numedges(obj), 0)}, 1, size(obj.EdgeProperties, 2)+1);
            cheatEdges = table(edgesColumns{:});
            propList = struct('Edges',cheatEdges, ...
                'Nodes',obj.NodeProperties);
            propgrp = matlab.mixin.util.PropertyGroup(propList);
        end
    end
    methods (Static, Hidden) % helpers
        function T = validateNodeProperties(T)
            if istable(T)
                if size(T, 2) > 0 && any(strcmp(T.Properties.VariableNames, 'Name'))
                    if ~iscolumn(T.Name)
                        error(message('MATLAB:graphfun:graph:NodesTableNameShape'));
                    end
                    graph.validateName(T.Name);
                end
            else
                Name = graph.validateName(T);
                T = table(Name);
            end
        end
        function Name = validateName(Name)
            if ~matlab.internal.datatypes.isCharStrings(Name,true,false)
                error(message('MATLAB:graphfun:graph:InvalidNames'));
            end
            if numel(unique(Name)) ~= numel(Name)
                error(message('MATLAB:graphfun:graph:NonUniqueNames'));
            end
            Name = Name(:);
        end
        function s = validateEdgeProperties(s)
            if ~istable(s)
                error(message('MATLAB:graphfun:graph:InvalidEdgeProps'));
            end
            if size(s, 2) > 0
                varNames = s.Properties.VariableNames;
                if any(strcmp('EndNodes', varNames))
                    error(message('MATLAB:graphfun:graph:EdgePropsHasEndNodes'));
                end
                if any(strcmp('Weight', varNames))
                    w = s.Weight;
                    if ~isnumeric(w) || ~isreal(w) || issparse(w) || ...
                            ~ismember(class(w), {'double', 'single'})
                        error(message('MATLAB:graphfun:graph:InvalidWeights'));
                    end
                    if ~(iscolumn(w))
                        error(message('MATLAB:graphfun:graph:NonColumnWeights'));
                    end
                end
            end
        end
    end
    methods
        % Manipulate nodes.
        function nn = numnodes(G)
            %NUMNODES Number of nodes in a graph
            %   n = NUMNODES(G) returns the number of nodes in the graph.
            %
            %   Example:
            %       % Create a graph, and then determine the number of nodes.
            %       G = graph(bucky)
            %       n = numnodes(G)
            %
            %   See also GRAPH, NUMEDGES, ADDNODE, RMNODE
            nn = numnodes(G.Underlying);
        end
        ind = findnode(G, N);
        H = addnode(G, N);
        H = rmnode(G, N);
        d = degree(G, nodeids);
        n = neighbors(G, nodeid);
        [eid, n] = outedges(G, nodeid);
        % Manipulate edges.
        function ne = numedges(G)
            %NUMEDGES Number of edges in a graph
            %   n = NUMEDGES(G) returns the number of edges in the graph.
            %
            %   Example:
            %       % Create a graph, and then determine the number of edges.
            %       G = graph(bucky)
            %       n = numedges(G)
            %
            %   See also GRAPH, NUMNODES, ADDEDGE, RMEDGE
            ne = numedges(G.Underlying);
        end
        [t, h] = findedge(G, s, t);
        H = addedge(G, t, h, w);
        H = rmedge(G, t, h);
        A = adjacency(G, w);
        I = incidence(G);
        L = laplacian(G);
        % Algorithms
        D = distances(G, varargin);
        [path, d, edgepath] = shortestpath(G, s, t, varargin);
        [tree, d, isTreeEdge] = shortestpathtree(G, s, varargin);
        [H, ind] = reordernodes(G, order);
        H = subgraph(G, ind, varargin);
        [bins, binSize] = conncomp(G, varargin);
        [bins, cv] = biconncomp(G, varargin);
        [tree, ind] = bctree(G);
        [t, eidx] = bfsearch(G, s, varargin);
        [t, eidx] = dfsearch(G, s, varargin);
        [mf, FG, cs, ct] = maxflow(G, s, t);
        [t, pred] = minspantree(G, varargin);
        c = centrality(G, type, varargin);
        [nodeids, d] = nearest(G, s, d, varargin);
        [p, edgeperm] = isomorphism(G1, G2, varargin);
        isi = isisomorphic(G1, G2, varargin);
        c = edgecount(G, s, t);
        tf = ismultigraph(G);
        [gsimple, edgeind, edgecount] = simplify(G, FUN, varargin);
        % Plots
        p = plot(varargin);
    end
    methods (Hidden)
        % Subsasgn/Subsref
        G = subsasgn(G, S, V)
        [varargout] = subsref(G, S)
        % Functions that we need to disable.
        function G = ctranspose(varargin) %#ok<*STOUT>
            throwAsCaller(bldUndefErr('ctranspose'));
        end
        function n = length(varargin)
            throwAsCaller(bldUndefErr('length'));
        end
        function G = permute(varargin)
            throwAsCaller(bldUndefErr('permute'));
        end
        function G = reshape(varargin)
            throwAsCaller(bldUndefErr('reshape'));
        end
        function G = transpose(varargin)
            throwAsCaller(bldUndefErr('transpose'));
        end
        % Functions of digraph that are not defined for graph.
        function varargout = condensation(varargin)
            error(message('MATLAB:graphfun:graph:OnlyDigraphSupported'));
        end
        function varargout = flipedge(varargin)
            error(message('MATLAB:graphfun:graph:OnlyDigraphSupported'));
        end
        function varargout = indegree(varargin)
            error(message('MATLAB:graphfun:graph:NoInDegreeUndir'));
        end
        function varargout = inedges(varargin)
            error(message('MATLAB:graphfun:graph:NoInEdgesUndir'));
        end
        function varargout = isdag(varargin)
            error(message('MATLAB:graphfun:graph:OnlyDigraphSupported'));
        end
        function varargout = outdegree(varargin)
            error(message('MATLAB:graphfun:graph:NoOutDegreeUndir'));
        end
        function varargout = predecessors(varargin)
            error(message('MATLAB:graphfun:graph:NoPredecessorsUndir'));
        end
        function varargout = successors(varargin)
            error(message('MATLAB:graphfun:graph:NoSuccessorsUndir'));
        end
        function varargout = toposort(varargin)
            error(message('MATLAB:graphfun:graph:OnlyDigraphSupported'));
        end
        function varargout = transclosure(varargin)
            error(message('MATLAB:graphfun:graph:OnlyDigraphSupported'));
        end
        function varargout = transreduction(varargin)
            error(message('MATLAB:graphfun:graph:OnlyDigraphSupported'));
        end
        % Hidden helper to construct MLDigraph from digraph
        function mlg = MLGraph(g)
            mlg = g.Underlying;
        end
    end
    methods (Access = private)
        function v = hasNodeNames(G)
            v = size(G.NodeProperties, 2) > 0 && ...
                any(strcmp('Name', G.NodeProperties.Properties.VariableNames));
        end
        function v = hasEdgeWeights(G)
            v = size(G.EdgeProperties, 2) > 0 && ...
                any(strcmp('Weight', G.EdgeProperties.Properties.VariableNames));
        end
        function src = validateNodeID(G, s)
            src = findnode(G, s);
            if any(src == 0)
                if isnumeric(s)
                    error(message('MATLAB:graphfun:graph:InvalidNodeID', ...
                        numnodes(G)));
                else
                    if iscellstr(s) %#ok<ISCLSTR>
                        i = find(src == 0, 1);
                        s = s{i};
                    end
                    error(message('MATLAB:graphfun:graph:UnknownNodeName', s));
                end
            end
        end
        [nodeProperties, nrNewNodes] = addToNodeProperties(G, N, checkN);
        t = search(G, s, varargin);
    end
    methods (Static, Access = private)
        function v = isvalidstring(s)
            v = matlab.internal.datatypes.isCharStrings(s, false, false);
        end
        function tf = isvalidoption(name)
            % Check for options and Name-Value pairs used in graph methods
            tf = (ischar(name) && isrow(name)) || (isstring(name) && isscalar(name));
        end
        function ind = partialMatch(name, candidates)
            len = max(strlength(name), 1);
            ind = strncmpi(name, candidates, len);
        end
    end
    %%%%% PERSISTENCE BLOCK ensures correct save/load across releases  %%%%%
    %%%%% These properties are only used in methods saveobj/loadobj, for %%%
    %%%%% correct loading behavior of MATLAB through several releases.  %%%%
    properties(Access='private')
        % ** DO NOT EDIT THIS LIST OR USE THESE PROPERTIES INSIDE GRAPH **
        
        % On saving to a .mat file, this struct is used to save
        % additional fields for forward and backward compatibility.
        % Fields that are used:
        % - WarnIfLoadingPreR2018a: Setting this property to a class not
        % known prior to 18a will cause old MATLAB versions to give a
        % warning.
        % - SaveMultigraph: Save properties Underlying, EdgeProperties and
        % NodeProperties for graphs with multiple edges.
        % - versionSavedFrom: Version of graph class from which this
        % instance is saved.
        % - minCompatibleVersion: Oldest version into which this graph
        % object can successfully be loaded.
        CompatibilityHelper = struct;
        
    end
    properties(Constant, Access='private')
        % Version of the graph serialization and deserialization
        % format. This is used for managing forward compatibility. Value is
        % saved in 'versionSavedFrom' when an instance is serialized.
        %
        %   N/A : original shipping version (R2015b)
        %   2.0 : Allow multiple edges between the same two nodes (R2018a)
        version = 2.0;
    end
    methods (Hidden)
        function s = saveobj(g)
            
            % Check if graph has multiple identical edges
            if ismultigraph(g)
                % When loading in MATLAB R2018a or later: load a graph with multiple edges.
                % When loading in MATLAB up to R2017b: warn and load an empty graph
                
                % Extract properties into a struct
                MultigraphStruct = struct('Underlying', g.Underlying, ...
                    'EdgeProperties', g.EdgeProperties, ...
                    'NodeProperties', g.NodeProperties);
                
                % Save the default graph
                s = graph;
                
                % Warn in releases prior to 2018a
                s.CompatibilityHelper.WarnIfLoadingPreR2018a = matlab.internal.graph.Graph_with_multiple_edges_not_supported_prior_to_release_2018a;
                
                % Save multigraph in struct, to be extracted in loadobj for
                % R2018a and later:
                s.CompatibilityHelper.SaveMultigraph = MultigraphStruct;
            else
                s = g;
            end
            
            s.CompatibilityHelper.versionSavedFrom = graph.version;
            s.CompatibilityHelper.minCompatibleVersion = 2.0;
        end
    end
    methods(Hidden, Static)
        function g = loadobj(s)
            
            if ~isfield(s.CompatibilityHelper, 'versionSavedFrom')
                % Loading a graph from R2015b-R2017b, no versioning
                g = graph(s.Underlying, s.EdgeProperties, s.NodeProperties);
            else
                % Check if s comes from a future, incompatible version
                if graph.version < s.CompatibilityHelper.minCompatibleVersion
                    warning(message('MATLAB:graphfun:graph:IncompatibleVersion'));
                    g = graph;
                    return;
                end
                
                if isfield(s.CompatibilityHelper, 'SaveMultigraph')
                    mg = s.CompatibilityHelper.SaveMultigraph;
                    g = graph(mg.Underlying, mg.EdgeProperties, mg.NodeProperties);
                else
                    g = graph(s.Underlying, s.EdgeProperties, s.NodeProperties);
                end
            end
        end
    end
end

function me = bldUndefErr(fname)
m = message('MATLAB:UndefinedFunctionTextInputArgumentsType', fname, 'graph');
me = MException('MATLAB:UndefinedFunction', getString(m));
end

function [checksym, omitLoops] = validateFlag(fl, checksym, omitLoops)
if ~graph.isvalidoption(fl)
    error(message('MATLAB:graphfun:graph:InvalidFlagAdjacency'));
end
opt = graph.partialMatch(fl, ["upper" "lower" "OmitSelfLoops"]);
if ~any(opt)
    error(message('MATLAB:graphfun:graph:InvalidFlagAdjacency'));
end
if opt(3)
    if omitLoops
        error(message('MATLAB:graphfun:graph:DuplicateOmitSelfLoops'));
    end
    omitLoops = true;
else
    if checksym ~= 0
        error(message('MATLAB:graphfun:graph:DuplicateUpperLower'));
    end
    if opt(1)
        checksym = 1;
    else
        checksym = -1;
    end
end
end
