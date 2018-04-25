%SlicewiseFusingOptimizer Optimizer that fuses connected sub-graphs of
% slicewise operations together.
%

% Copyright 2017 The MathWorks, Inc.

classdef SlicewiseFusingOptimizer < matlab.bigdata.internal.Optimizer
    methods
        function undoGuard = optimize(~, varargin)
        % Return FALSE to indicate no changes were made.
            closureGraph = matlab.bigdata.internal.optimizer.ClosureGraph(varargin{:});
            graph = closureGraph.Graph;
            order = toposort(graph, 'Order', 'stable');
            graph = graph.reordernodes(order);
            
            adj = adjacency(graph);
            numNodes = numnodes(graph);
            
            % Need to know the true outputs of the graph so these get
            % exposed from fused slicewise operations.
            graphFutures = cellfun(@(v) v.ValueFuture, varargin, 'UniformOutput', false);
            graphFutures = vertcat(graphFutures{:});
            isGraphSuccessor = cellfun(@(x) isFuture(x) && any(x == graphFutures), graph.Nodes.NodeObj);
            
            % All broadcasted futures are currently considered true outputs
            % of the graph.
            isAFuture = cellfun(@isFuture, graph.Nodes.NodeObj);
            partitionId = determinePartitioning(graph);
            isGraphSuccessor(isAFuture) = isGraphSuccessor(isAFuture) | partitionId(isAFuture) == 0;
            
            % This optimizer only fuses slicewise closures.
            isClosure = graph.Nodes.IsClosure;
            isSlicewiseClosure = false(numNodes, 1);
            isSlicewiseClosure(isClosure) = cellfun(@iIsSlicewiseFusable, graph.Nodes.NodeObj(isClosure));
            
            % Use non-slicewise closures as cut points and to form the
            % connected components to fuse.
            isNonSlicewiseClosure = isClosure & ~isSlicewiseClosure;
            ids = acyclicCutConnComp(graph, isNonSlicewiseClosure);
            uniqueIds = unique(ids(isSlicewiseClosure));
            
            undoGuard = matlab.bigdata.internal.optimizer.UndoGuard;
            for uniqueId = uniqueIds(:)'
                groupClosures = (ids == uniqueId) & isSlicewiseClosure;
                % The group contained 1 or less slicewise operation,
                % ignore.
                if sum(groupClosures) <= 1
                    continue;
                end
                
                % Fill out isInGroup to include the promises and futures
                % that are direct successors of closures in the group.
                isPromiseConnToGroup = adj' * groupClosures;
                isFutureConnToGroup = adj' * isPromiseConnToGroup;
                isInGroup = groupClosures | isPromiseConnToGroup | isFutureConnToGroup;
                
                % We define the successors of the sub-graph to be the futures
                % outside of the group whose promises are in the group.
                
                isClosureSuccessorConnToGraph = ~groupClosures & (adj' * isFutureConnToGroup);
                subgraphSuccessors = (adj * isClosureSuccessorConnToGraph | isGraphSuccessor) & isInGroup;
                
                % We define the predecessors to be the futures whose
                % promises are outside of the group.
                isPromisePredecessorConnToGroup = adj * groupClosures & ~isInGroup;
                isInGroup = isInGroup | isPromisePredecessorConnToGroup;
                
                iFuseSlicewiseSubgraph(undoGuard, subgraph(graph, isInGroup), ...
                    isPromisePredecessorConnToGroup(isInGroup), subgraphSuccessors(isInGroup));
            end
            
            if ~nargout
                disarm(undoGuard);
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = iIsSlicewiseFusable(closure)
% Check if a given closure can be fused with other slicewise operations.
op = closure.Operation;
tf = isa(op, 'matlab.bigdata.internal.lazyeval.SlicewiseFusableOperation') ...
        && op.isSlicewiseFusable();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iFuseSlicewiseSubgraph(undoGuard, graph, isGraphPredecessor, isGraphSuccessor)
% Fuse a graph of slicewise closures into a single slicewise closure.
%
% This assumes that:
%  1. All inputs to the graph are represented by ClosureFuture objects that
%  have isGraphPredecessor true.
%  2. For any Closure in the graph, the graph also contains all promises
%  and futures that are the direct successor of the closure.
%  3. All outputs of the graph are represented by ClosureFuture objects
%  that have isGraphSuccessor true.
%  4. The graph is already in topological order.

nodes = graph.Nodes;
nodeObjs = nodes.NodeObj;
isAFuture = cellfun(@isFuture, nodes.NodeObj);

% Ensure that all constants appear as graph predecessors. This is to ensure
% correct error handling if a constant is not a scalar.
isGraphPredecessor(isAFuture) = isGraphPredecessor(isAFuture) | cellfun(@(f) f.IsDone, nodeObjs(isAFuture));

[fh, incompatibleErrorHandler] = iCreateFusedSlicewiseFcn(graph, isGraphPredecessor, isGraphSuccessor);
fh = matlab.bigdata.internal.FunctionHandle(fh, 'CaptureErrorStack', false);

opts = matlab.bigdata.internal.PartitionedArrayOptions;
numGraphPredecessors = sum(isGraphPredecessor);
numGraphSuccessors = sum(isGraphSuccessor);

newOp = matlab.bigdata.internal.lazyeval.FusedSlicewiseOperation(opts, fh, incompatibleErrorHandler, numGraphPredecessors, numGraphSuccessors);

outputFutures = vertcat(nodeObjs{isGraphSuccessor});
originalPromises = vertcat(outputFutures.Promise);

newClosure = matlab.bigdata.internal.lazyeval.Closure(vertcat(nodeObjs{isGraphPredecessor}), newOp, [originalPromises.IsPartitionIndependent]);

optimizedPromises = vertcat(newClosure.OutputPromises);
for cidx = 1:numel(originalPromises)
    swap(originalPromises(cidx), optimizedPromises(cidx));
end
undoGuard.append(originalPromises, optimizedPromises);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fcn, incompatibleErrorHandler] = iCreateFusedSlicewiseFcn(graph, isGraphPredecessor, isGraphSuccessor)
% Create the underlying function handle in a fused slicewise operation.
% This maps a graph of slicewise closures to inputs required by iFusedFcn.
% This function is a compiler. When we talk about local variables, we are
% talking about local variables of the compiled function iFusedFcn.
adj = adjacency(graph);
nodes = graph.Nodes;
nodeObjs = nodes.NodeObj;
numNodes = height(nodes);
isAClosure = nodes.IsClosure;
numGraphPredecessors = sum(isGraphPredecessor);

% For each node, get the node index of the very last closure in the graph
% that depends on the output of the node.
nodeLastSuccessor = iGetLastUsage(adj);
nodeLastSuccessor(isGraphSuccessor) = inf;

% Compiled information to be passed to iFusedFcn. Each is a cell array per
% node (non-empty only for closures), each cell containing:
%  fcnHandles: The function handle for the node.
%  fcnInputIndices: Indices into the compiled local variable vector to be
%    used as inputs to the function handle.
%  fcnOutputIndices: Indices into the compiled local variable vector to be
%    used to store the outputs of the function handle.
%  deleteIndices: Indices into the compiled local variable vector to be
%    cleared after retrieving the inputs of the function handle.
fcnHandles = cell(numNodes, 1);
fcnInputIndices = cell(numNodes, 1);
fcnOutputIndices = cell(numNodes, 1);
deleteIndices = cell(numNodes, 1);

% This algorithm maps futures in the graph to indices of the compiled local
% variable vector in iFusedFcn. It does this by passing through the nodes
% in order and choosing the local variable indices that are free at time
% nodeIdx.
nodeIndexToLocalVarIndexMap = zeros(numNodes, 1);
nodeIndexToLocalVarIndexMap(isGraphPredecessor) = 1 : numGraphPredecessors;
% As we pass through the nodes, we track when each local variable can be
% cleared and reused.
localVarLifetimes = nodeLastSuccessor(isGraphPredecessor);
for nodeIdx = 1 : numNodes
    % This algorithm is per closure.
    if ~isAClosure(nodeIdx)
        continue;
    end
    
    % Get the node indices of the predecessor / successor futures of the
    % current closure, in the order required by the closure.
    predecessors = iGetOrderedPredecessorFutureIndices(nodeIdx, nodeObjs, adj);
    successors = iGetOrderedSuccessorFutureIndices(nodeIdx, nodeObjs, adj);
    
    % Choose which of the local variables to delete in the compiled
    % iFusedFcn after it retrieves the input of this node.
    [localVarIndicesToDelete, localVarLifetimes] ...
        = iChooseLocalVarsToDelete(nodeIdx, localVarLifetimes);
    
    % Choose which of the local variables to store the output of this node
    % in the compiled iFusedFcn.
    successorLifetimes = nodeLastSuccessor(successors);
    [newLocalVarIndices, localVarLifetimes] ...
        = iChooseLocalVarsToUseAsOutput(successorLifetimes, localVarLifetimes);
    nodeIndexToLocalVarIndexMap(successors) = newLocalVarIndices;
    
    % For performance reasons, we do not pass nodeIndexToLocalVarIndexMap
    % to iFusedFcn but these derived cell arrays.
    fcnHandles{nodeIdx} = nodeObjs{nodeIdx}.Operation.getCheckedFunctionHandle();
    fcnInputIndices{nodeIdx} = nodeIndexToLocalVarIndexMap(predecessors);
    fcnOutputIndices{nodeIdx} = nodeIndexToLocalVarIndexMap(successors);
    deleteIndices{nodeIdx} =  localVarIndicesToDelete;
end

% To optimize the compiled function, we discard all non-closure cells as
% these will all be empty.
fcnHandles(~isAClosure) = [];
fcnInputIndices(~isAClosure) = [];
fcnOutputIndices(~isAClosure) = [];
deleteIndices(~isAClosure) = [];

numLocalVariables = numel(localVarLifetimes);
globalOutputIndices = nodeIndexToLocalVarIndexMap(isGraphSuccessor);

fcn = iFusedFcn(fcnHandles, fcnInputIndices, fcnOutputIndices, deleteIndices, ...
    numLocalVariables, globalOutputIndices);

errorStacks = iGetErrorStacks(fcnHandles);
incompatibleErrorHandler = iErrorHandlerFcn(errorStacks, ...
    fcnInputIndices, fcnOutputIndices, numLocalVariables);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lastUsageIdx = iGetLastUsage(adj)
% Calculate for each node, the maximum index of its successors.
[s, t] = find(adj);
lastUsageIdx = accumarray(s(:), t(:), [size(adj,1), 1], @max);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function predecessorFutureIndices = iGetOrderedPredecessorFutureIndices(nodeIdx, nodeObjs, adj)
% Get the node indices of the predecessor futures of a closure, in the same
% order as InputFutures.

predecessorFutureIndices = find(adj(:, nodeIdx));

predecessorFutures = vertcat(nodeObjs{predecessorFutureIndices});

closure = nodeObjs{nodeIdx};
[check, order] = ismember(predecessorFutures, closure.InputFutures);
assert(all(check), 'Closure graph contains closures where the input future is not represented by a predecessor');
predecessorFutureIndices(order) = predecessorFutureIndices;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function successorFutureIndices = iGetOrderedSuccessorFutureIndices(nodeIdx, nodeObjs, adj)
% Get the node indices of the successor futures of a closure, in the same
% order as [OutputPromises.Future]. Note, these will the one-level-removed
% successors of the closure.

isSuccessorPromise = adj(nodeIdx, :)';
successorFutureIndices = find(adj' * isSuccessorPromise);

successorFutures = vertcat(nodeObjs{successorFutureIndices});

closure = nodeObjs{nodeIdx};
[check, order] = ismember(successorFutures, vertcat(closure.OutputPromises.Future));
assert(all(check), 'Closure graph contains closures where the output promise/future is not represented by a successor');
successorFutureIndices(order) = successorFutureIndices;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [deleteIndices, localVarLifetimes] = iChooseLocalVarsToDelete(nodeIdx, localVarLifetimes)
% Choose which of the local variables to delete. This will be the local
% variables who have no more usage.
isLocalVarOld = (localVarLifetimes <= nodeIdx);
isLocalVarDeleted = (localVarLifetimes < 0);
deleteIndices = find(isLocalVarOld & ~isLocalVarDeleted);
localVarLifetimes(deleteIndices) = -1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [newIndices, localVarLifetimes] = iChooseLocalVarsToUseAsOutput(neweLifetimes, localVarLifetimes)
% Choose where to store the output of a closure in the vector of local
% variables.
isLocalVarDeleted = (localVarLifetimes < 0);

numNewIndices = numel(neweLifetimes);
newIndices = find(isLocalVarDeleted, numNewIndices);
if numel(newIndices) < numNewIndices
    numAdditionalIndices = numNewIndices - numel(newIndices);
    newIndices(end + 1 : numNewIndices) = numel(localVarLifetimes) + (1 : numAdditionalIndices);
end
localVarLifetimes(newIndices) = neweLifetimes;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errorStacks = iGetErrorStacks(fcnHandles)
% Get the error stack of each function handle that is part of the fused
% operation. This is done to avoid storing two copies of the underlying
% function handle in the fused operation.
errorStacks = cellfun(@(x) x.ErrorStack, fcnHandles, 'UniformOutput', false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fh = iFusedFcn(fcnHandles, fcnInputIndices, fcnOutputIndices, ...
    deleteIndices, numLocalVariables, globalOutputIndices)
% The actual fused function to be run on MATLAB Workers.
fh = @fcn;
    function varargout = fcn(varargin)
        localVariables = cell(numLocalVariables, 1);
        localVariables(1:nargin) = varargin;
        varargin = []; %#ok<NASGU>
        for ii = 1:numel(fcnHandles)
            data = localVariables(fcnInputIndices{ii});
            localVariables(deleteIndices{ii}) = {[]};
            [data, localVariables{fcnOutputIndices{ii}(2:end)}] ...
                = feval(fcnHandles{ii}, data{:});
            localVariables{fcnOutputIndices{ii}(1)} = data;
        end
        varargout = localVariables(globalOutputIndices)';
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fh = iErrorHandlerFcn(errorStacks, fcnInputIndices, fcnOutputIndices, numLocalVariables)
% A function handle that will locate which underlying function handle is
% responsible for an incompatible size error and throw using its error
% stack.
fh = @errorFcn;

    function errorFcn(err, isTooShortVector, isTooLongVector)
        import matlab.bigdata.BigDataException;
        % This algorithm finds the first instance where inputs specified by
        % isTooShortVector meet isTooLongVector. It works by giving short
        % inputs the ID -1 and long inputs the ID 1, then forward
        % propagating until there is a conflict.
        localVariables = zeros(numLocalVariables, 1);
        localVariables(isTooShortVector) = -1;
        localVariables(isTooLongVector) = 1;
        for ii = 1:numel(errorStacks)
            data = localVariables(fcnInputIndices{ii});
            if any(data < 0) && any(data > 0)
                err = BigDataException.build(err);
                err = attachSubmissionStack(err, errorStacks{ii});
                updateAndRethrow(err);
            end
            if all(data == 0)
                out = 0;
            else
                out = unique(data(data ~= 0));
            end
            localVariables(fcnOutputIndices{ii}) = out;
        end
        % We should not be able to reach here given this optimizer only
        % fuses together connected subgraphs.
        assert(false, 'Assertion failed: Unable to determine cause of incompatible inputs');
    end
end
