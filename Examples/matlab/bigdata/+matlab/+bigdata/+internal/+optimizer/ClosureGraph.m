%ClosureGraph An execution graph leading up to a series of partitioned arrays.
%   The primary purpose of this class is to compute a digraph of
%   closure/promise/future nodes and the connectivity between them. This
%   information can then be used by optimizers to discover optimization
%   opportunities.

% Copyright 2016-2017 The MathWorks, Inc.

classdef ClosureGraph < handle

    properties (SetAccess = private)
        % digraph linking Nodes with Edges. digraphs are value classes, so OK to make
        % this property 'GetAccess = public'.
        Graph
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % Starting points for this graph - an array of futures.
        Futures
    end

    methods
        function recalculate(obj)
        %Recalculate - recompute the graph from scratch.
            
            nodesMap = containers.Map('KeyType', 'char', ...
                                      'ValueType', 'any');
            % Calculate all the nodes and edges from the starting point
            edges = iCalcNodesAndEdges(nodesMap, obj.Futures);
            obj.Graph = iCalcGraphFromNodesAndEdges(nodesMap, edges);
        end
        
        function obj = ClosureGraph(varargin)
        %Build a ClosureGraph from a series of partitioned arrays.

            assert(all(cellfun(@(x) isa(x, 'matlab.bigdata.internal.lazyeval.LazyPartitionedArray'), ...
                               varargin)));
            % Get the value futures for all arrays
            futureCell = cell(1, nargin);
            for idx = 1:nargin
                futureCell{idx} = varargin{idx}.ValueFuture;
            end
            obj.Futures = vertcat(futureCell{:});
            recalculate(obj);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert the two maps previously constructed into a digraph.
function G = iCalcGraphFromNodesAndEdges(nodesMap, edgesArray)

    % build up the table of nodes. We need the name of each node, plus we're going
    % to add a couple of extra variables - 'IsClosure' to indicate whether a
    % node is a closure, and 'OpType' - the trailing part of the Operation class
    % name (for closures only)
    nodeNames   = keys(nodesMap);
    nodeNames   = nodeNames(:);
    numNodes    = numel(nodeNames);
    nodeObjCell = values(nodesMap);
    nodeObjCell = nodeObjCell(:);
    isClosureV  = cellfun(@isClosure, nodeObjCell);

    closureType = repmat({''}, numNodes, 1);
    closureType(isClosureV) = cellfun(@(x) class(x.Operation), ...
                                      nodeObjCell(isClosureV), ...
                                      'UniformOutput', false);
    closureType = regexprep(closureType, '.*\.', '');

    nodeTable = table(nodeNames, nodeObjCell, isClosureV, categorical(closureType), ...
                      'VariableNames', {'Name', 'NodeObj', 'IsClosure', 'OpType'});

    edgeTable = table(edgesArray, 'VariableNames', {'EndNodes'});
    G = digraph(edgeTable, nodeTable);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Given a starting list of 'nodes', walk the closure graph computing a map of
% node names to node object, and a map of edges (map source node name to list of
% destination node names). The edges are returned as an Mx2 cell array of node
% names.
function edges = iCalcNodesAndEdges(nodesMap, nodes)
    
    % We'll build up a cell array where the first column is the source node, second
    % column the destination node.
    edges       = cell(0, 2);
    nextEdgeIdx = 1;
    
    % Create the stack from all existing nodes
    stack    = num2cell(nodes);
    stackPos = numel(stack);
    
    while stackPos > 0
        % Get the next node, and bail if we've already seen it.
        
        % Pop node from stack
        node = stack{stackPos};
        stack{stackPos} = [];
        stackPos = -1 + stackPos;
        
        nodeId = node.IdStr;
        if isKey(nodesMap, nodeId)
            continue
        end
        
        % Haven't seen this node before, add it to the nodesMap, and then get the list
        % of 'supplier' (i.e. upstream) nodes.
        nodesMap(nodeId) = node;
        % Ignore duplicates of predecessors as the optimizer does not care
        % about the count of each dependency, only that they exist.
        predecessors     = node.Predecessors;

        for idx = 1:numel(predecessors)
            % Push predecessor onto the stack for consideration.
            p = predecessors(idx);
            stack{stackPos + 1} = p;
            stackPos = 1 + stackPos;

            % Append edges
            supplierNodeId        = p.IdStr;
            edges(nextEdgeIdx, :) = {supplierNodeId, nodeId};
            nextEdgeIdx           = 1 + nextEdgeIdx;
        end
        
        % Add the successors to the stack in order to include all promises
        % and futures that represent the output of a closure.
        successors       = node.Successors;
        
        for idx = 1:numel(successors)
            s = successors(idx);
            stack{stackPos + 1} = s;
            stackPos = 1 + stackPos;
        end
    end
    edges = edges(1:(nextEdgeIdx-1),:);
end
