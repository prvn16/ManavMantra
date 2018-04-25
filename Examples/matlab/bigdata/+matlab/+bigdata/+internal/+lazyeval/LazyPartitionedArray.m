%LazyPartitionedArray
% An implementation of the PartitionedArray interface that sits on top of
% the lazy evaluation architecture.

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed, InferiorClasses = { ...
        ?matlab.bigdata.internal.BroadcastArray, ...
        ?matlab.bigdata.internal.FunctionHandle, ...
        ?matlab.bigdata.internal.LocalArray, ...
        ?matlab.bigdata.internal.PartitionMetadata, ...
        ?matlab.bigdata.internal.PartitionedArrayOptions}) ...
        LazyPartitionedArray < matlab.bigdata.internal.PartitionedArray
    
    properties (SetAccess = private)
        % A future to the actual evaluated data.
        ValueFuture;
        
        % The underlying object that controls how this array is
        % partitioned.
        PartitionMetadata;
    end
    
    properties (Dependent)
        % The datastore that is backing this partitioned array. This exists
        % to allow checking of compatibility between two datastore based
        % tall arrays. This will be empty for gathered arrays.
        Datastore;
    end
    
    properties (SetAccess = private, Transient)
        % The underlying execution environment backing this partitioned
        % array.
        Executor;
    end
    
    properties (Dependent)
        % A logical scalar that is true if and only if this Partitioned
        % array still has a valid PartitionedArrayExecutor.
        IsValid
    end
    
    properties (SetAccess = private, Transient)
        % Properties to support cheap preview / display / workspace browser info.
        HasPreviewData = false
        IsPreviewTruncated = false
        PreviewData = []
    end
    
    methods (Static)
        % Construct a LazyPartitionedArray instance from a datastore
        % instance.
        function obj = createFromDatastore(ds)
            import matlab.bigdata.internal.executor.PartitionedArrayExecutor;
            import matlab.bigdata.internal.lazyeval.ReadOperation;
            import matlab.bigdata.internal.PartitionMetadata;
            
            try
                ds = copy(ds);
            catch err
                matlab.bigdata.internal.throw(err, 'IncludeCalleeStack', true);
            end
            PartitionedArrayExecutor.checkDatastoreSupportForDefault(ds);
            numOutputs = 1;
            obj = iDoOperation(ReadOperation(ds, numOutputs));
            obj = iSetPartitionMetadata(PartitionMetadata(ds), obj);
        end
        
        % Construct a LazyPartitionedArray instance around a constant.
        function obj = createFromConstant(constant, executor)
            import matlab.bigdata.internal.executor.BroadcastPartitionStrategy;
            import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
            import matlab.bigdata.internal.PartitionMetadata;
            valueFuture = iParseDataInputs(constant);
            if nargin < 2
                executor = iGetCurrentExecutor();
            end
            partitionMetadata = PartitionMetadata(BroadcastPartitionStrategy());
            obj = LazyPartitionedArray(valueFuture, executor, partitionMetadata);
            
            % For constant data, we always have a preview. MATLAB's
            % copy-on-write behaviour ensures that this doesn't take any
            % extra memory.
            obj.PreviewData = constant;
            obj.HasPreviewData = true;
            obj.IsPreviewTruncated = false;
        end
    end
    
    methods (Hidden)
        function hSetMetadata(obj, metadata)
            hSetMetadata(obj.ValueFuture.Promise, metadata);
        end
        function metadata = hGetMetadata(obj)
            metadata = hGetMetadata(obj.ValueFuture.Promise);
        end
    end
    
    methods
        function varargout = gather(varargin)
            
            import matlab.bigdata.internal.lazyeval.GatherOperation;
            
            [metadatas, metadataFillingPartitionedArrays] = ...
                iGenerateMetadataFillingPartitionedArrays(varargin);
            
            allPartitionedArrays = [varargin, ...
                metadataFillingPartitionedArrays];
            
            % If there is more than one array to be gathered, we insert
            % GatherOperation closures so that the fusing optimizer can
            % fuse these into any existing aggregate operations. This is
            % not needed for broadcast arrays as those are already in a
            % gathered state.
            if numel(varargin) > 1
                gatherOperation = GatherOperation(1);
                for ii = 1:numel(varargin)
                    if ~allPartitionedArrays{ii}.PartitionMetadata.Strategy.IsBroadcast
                        allPartitionedArrays{ii} = ...
                            iDoOperation(gatherOperation, allPartitionedArrays{ii});
                    end
                end
            end
            
            [taskGraph, executor, optimUndoGuard] = getEvaluationObjects(allPartitionedArrays{:}); %#ok<ASGLU>
            if ~isempty(taskGraph)
                % Default for all outputs is to gather.
                outputHandler = iCreateGatherOutputHandler(taskGraph);
                executor.executeWithHandler(taskGraph, outputHandler);
                iCleanupOldCacheEntries(taskGraph.CacheEntryKeys);
            end
            
            iApplyMetadataResults(metadatas, allPartitionedArrays((1+nargin):end));
            
            varargout = cell(1, nargin);
            for ii = 1:nargin
                assert (allPartitionedArrays{ii}.ValueFuture.IsDone, ...
                    'Assertion failed: Output %i of gather was not complete by end of evaluation', ii);
                varargout{ii} = allPartitionedArrays{ii}.ValueFuture.Value;
            end
        end
        
        function varargout = elementfun(options, functionHandle, varargin)
            import matlab.bigdata.internal.lazyeval.ElementwiseOperation;
            [options, functionHandle, args] = iParseInputs(options, functionHandle, varargin{:});
            functionHandle = iParseFunctionHandle(functionHandle);
            op = ElementwiseOperation(options, functionHandle, numel(args), nargout);
            [varargout{1:nargout}] = iDoOperation(op, args{:});
        end
        
        function varargout = slicefun(options, functionHandle, varargin)
            import matlab.bigdata.internal.lazyeval.SlicewiseOperation;
            [options, functionHandle, args] = iParseInputs(options, functionHandle, varargin{:});
            functionHandle = iParseFunctionHandle(functionHandle);
            op = SlicewiseOperation(options, functionHandle, numel(args), nargout);
            [varargout{1:nargout}] = iDoOperation(op, args{:});
        end
        
        function varargout = filterslices(subs, varargin)
            import matlab.bigdata.internal.lazyeval.FilterOperation;
            op = FilterOperation(numel(varargin));
            [varargout{1:nargout}] = iDoOperation(op, subs, varargin{:});
        end
        
        function out = vertcatpartitions(varargin)
            import matlab.bigdata.internal.lazyeval.VertcatOperation;
            functionHandle = matlab.bigdata.internal.FunctionHandle(@deal); % To make this the first frame in error stacks
            [repartitionedArrays{1:numel(varargin)}] = matlab.bigdata.internal.lazyeval.vertcatrepartition(varargin{:});
            out = iDoOperation(VertcatOperation(functionHandle, numel(repartitionedArrays), nargout), repartitionedArrays{:});
        end
        
        function varargout = reducefun(options, functionHandle, varargin)
            [options, functionHandle, args] = iParseInputs(options, functionHandle, varargin{:});
            [varargout{1:nargout}] = aggregatefun(options, functionHandle, functionHandle, args{:});
        end
        
        function varargout = aggregatefun(options, initialFunctionHandle, reduceFunctionHandle, varargin)
            import matlab.bigdata.internal.executor.BroadcastPartitionStrategy;
            import matlab.bigdata.internal.lazyeval.AggregateOperation;
            import matlab.bigdata.internal.PartitionMetadata;
            [options, initialFunctionHandle, reduceFunctionHandle, args] = iParseInputs(options, initialFunctionHandle, reduceFunctionHandle, varargin{:});
            initialFunctionHandle = iParseFunctionHandle(initialFunctionHandle);
            reduceFunctionHandle = iParseFunctionHandle(reduceFunctionHandle);
            operation = AggregateOperation(options, initialFunctionHandle, reduceFunctionHandle, numel(args), nargout);
            [varargout{1:nargout}] = iDoOperation(operation, args{:});
            partitionMetadata = PartitionMetadata(BroadcastPartitionStrategy()); %#ok<CPROPLC>
            [varargout{:}] = iSetPartitionMetadata(partitionMetadata, varargout{:});
        end
        
        function [keys, varargout] = reducebykeyfun(options, functionHandle, keys, varargin)
            [options, functionHandle, keys, args] = iParseInputs(options, functionHandle, keys, varargin{:});
            [keys, varargout{1:nargout - 1}] = aggregatebykeyfun(options, functionHandle, functionHandle, keys, args{:});
        end
        
        function [keys, varargout] = aggregatebykeyfun(options, initialFunctionHandle, reduceFunctionHandle, keys, varargin)
            import matlab.bigdata.internal.lazyeval.AggregateByKeyOperation;
            import matlab.bigdata.internal.PartitionMetadata;
            [options, initialFunctionHandle, reduceFunctionHandle, keys, args] = iParseInputs(options, initialFunctionHandle, reduceFunctionHandle, keys, varargin{:});
            initialFunctionHandle = iParseFunctionHandle(initialFunctionHandle);
            reduceFunctionHandle = iParseFunctionHandle(reduceFunctionHandle);
            operation = AggregateByKeyOperation(options, initialFunctionHandle, reduceFunctionHandle, numel(args) + 1, nargout);
            [keys, varargout{1:nargout - 1}] = iDoOperation(operation, keys, args{:});
            [keys, varargout{:}] = iSetPartitionMetadata(PartitionMetadata([]), keys, varargout{:}); %#ok<CPROPLC>
        end
        
        function [keys, varargout] = joinbykey(xKeys, x, yKeys, y) %#ok<STOUT,INUSD>
            assert(false, 'The method PartitionedArray/joinbykey is currently not supported.');
        end
        
        %TERNARYFUN Select between one of two input arrays based on a deferred scalar logical input.
        function  out = ternaryfun(condition, ifTrue, ifFalse)
            import matlab.bigdata.internal.lazyeval.TernaryOperation;
            
            condition = matlab.bigdata.internal.broadcast(condition);
            out = iDoOperation(TernaryOperation, condition, ifTrue, ifFalse);
        end
        
        function varargout = chunkfun(options, functionHandle, varargin)
            import matlab.bigdata.internal.lazyeval.ChunkwiseOperation;
            [options, functionHandle, args] = iParseInputs(options, functionHandle, varargin{:});
            functionHandle = iParseFunctionHandle(functionHandle);
            op = ChunkwiseOperation(options, functionHandle, numel(args), nargout);
            [varargout{1:nargout}] = iDoOperation(op, args{:});
        end
        
        % FIXEDCHUNKFUN Perform a chunkfun operation that ensures all
        % chunks of a partition except the last are of a required size.
        function varargout = fixedchunkfun(options, numSlicesPerChunk, functionHandle, varargin)
            import matlab.bigdata.internal.lazyeval.FixedChunkwiseOperation;
            [options, numSlicesPerChunk, functionHandle, args] = iParseInputs(options, numSlicesPerChunk, functionHandle, varargin{:});
            functionHandle = iParseFunctionHandle(functionHandle);
            op = FixedChunkwiseOperation(options, numSlicesPerChunk, functionHandle, numel(args), nargout);
            [varargout{1:nargout}] = iDoOperation(op, args{:});
        end
        
        function varargout = partitionfun(options, functionHandle, varargin)
            import matlab.bigdata.internal.lazyeval.PartitionwiseOperation;
            [options, functionHandle, args] = iParseInputs(options, functionHandle, varargin{:});
            functionHandle = iParseFunctionHandle(functionHandle);
            op = PartitionwiseOperation(options, functionHandle, numel(args), nargout);
            [varargout{1:nargout}] = iDoOperation(op, args{:});
            for ii = 1 : numel(varargout)
                varargout{ii}.ValueFuture.Promise.setPartitionIndependent(false);
            end
        end
        
        %GENERALPARTITIONFUN For each partition, apply a function handle to
        % all of the underlying data for the partition where each input
        % might have a different number of slices.
        function varargout = generalpartitionfun(options, functionHandle, varargin)
            import matlab.bigdata.internal.lazyeval.GeneralizedPartitionwiseOperation;
            [options, functionHandle, args] = iParseInputs(options, functionHandle, varargin{:});
            functionHandle = iParseFunctionHandle(functionHandle);
            op = GeneralizedPartitionwiseOperation(options, functionHandle, numel(args), nargout);
            [varargout{1:nargout}] = iDoOperation(op, args{:});
            for ii = 1 : numel(varargout)
                varargout{ii}.ValueFuture.Promise.setPartitionIndependent(false);
            end
        end
        
        %ISPARTITIONINDEPENDENT Returns true if all underlying data is independent
        % of the partitioning of the array.
        function tf = isPartitionIndependent(varargin)
            tf = true;
            for ii = 1 : nargin
                tf = tf && varargin{ii}.ValueFuture.Promise.IsPartitionIndependent;
            end
        end
        
        %MARKPARTITIONINDEPENDENT Mark that the data underlying a PartitionedArray
        % is independent of the partitioning of the PartitionedArray.
        function varargout = markPartitionIndependent(varargin)
            for ii = 1:numel(varargin)
                varargin{ii}.ValueFuture.Promise.setPartitionIndependent(true);
            end
            varargout = varargin;
        end
        
        %MARKFORREUSE Inform the Lazy Evaluation Framework that the given
        % PartitionedArray will be reused multiple times.
        function markforreuse(varargin)
            import matlab.bigdata.internal.lazyeval.CacheOperation;
            for ii = 1:numel(varargin)
                newArray = iDoOperation(CacheOperation(), varargin{ii});
                % Copy metadata from original input to newArray
                metadata = hGetMetadata(varargin{ii}.ValueFuture.Promise);
                hSetMetadata(newArray.ValueFuture.Promise, metadata);
                varargin{ii}.ValueFuture = newArray.ValueFuture;
            end
        end

        %UPDATEFORREUSE Inform the Lazy Evaluation Framework that a
        % PartitionedArray should replace all cache entries of another.
        function updateforreuse(paOld, paNew)
            if (paOld.ValueFuture.IsDone || paNew.ValueFuture.IsDone)
                markforreuse(paNew);
                return;
            end
            
            oldOperation = paOld.ValueFuture.Promise.Closure.Operation;
            assert(isa(oldOperation, 'matlab.bigdata.internal.lazyeval.CacheOperation'), ...
                'Assertion failed: updateforreuse invoked on a tall array that was not directly cached.');
            oldKey = oldOperation.CacheEntryKey;
            
            markforreuse(paNew);
            newOperation = paNew.ValueFuture.Promise.Closure.Operation;
            newOperation.CacheEntryKey.setOldKey(oldKey);
        end
        
        %ALIGNPARTITIONS Align the partitioning of one or more LazyPartitionedArray instances.
        function [ref, varargout] = alignpartitions(ref, varargin)
            [ref, varargout{1 : nargout - 1}] = matlab.bigdata.internal.lazyeval.alignpartitions(ref, varargin{:});
        end
        
        %REPARTITION Repartition one or more LazyPartitionedArray instances to a new partition strategy.
        function varargout = repartition(partitionMetadata, partitionIndices, varargin)
            import matlab.bigdata.internal.lazyeval.RepartitionOperation;
            
            op = RepartitionOperation(partitionMetadata.Strategy, numel(varargin));
            [varargout{1 : nargout}] = iDoOperation(op, partitionIndices, varargin{:});
            
            [varargout{:}] = iSetPartitionMetadata(partitionMetadata, varargout{:});
        end
        
        %CLIENTFOREACH Stream data back to the client MATLAB Context and
        % perform an action per chunk inside the client MATLAB Context.
        function clientforeach(workerFcn, clientFcn, varargin)
            workerFcn = iParseFunctionHandle(workerFcn);
            clientFcn = iParseFunctionHandle(clientFcn);
            
            intermediate = partitionfun(iCreateForeachWorkerFcn(workerFcn), varargin{:});
            [taskGraph, executor, optimUndoGuard] = getEvaluationObjects(intermediate); %#ok<ASGLU>
            assert(~isempty(taskGraph), ...
                'Assertion failed: Clientforeach called on a closure that is already complete.');
            
            % This stream output handler will pick out the output
            % corresponding with intermediate and stream its chunks to
            % clientFcn.
            taskId = taskGraph.ClosureToTaskMap(intermediate.ValueFuture.Promise.Closure.Id).Id;
            argoutIndex = intermediate.ValueFuture.Promise.ArgoutIndex;
            clientFcn = iCreateForeachClientFcn(clientFcn);
            streamOutputHandler = iCreateStreamOutputHandler(taskId, argoutIndex, clientFcn);
            
            % We include a gather output handler so that any reduced values
            % required to be evaluated as part of the input are
            % automatically placed in a gathered state on completion.
            outputHandlers = [...
                streamOutputHandler; ...
                iCreateGatherOutputHandler(taskGraph); ...
                ];
            
            try
                executor.executeWithHandler(taskGraph, outputHandlers);
                iCleanupOldCacheEntries(taskGraph.CacheEntryKeys);
            catch err
                if ~isequal(err.identifier, 'MATLAB:bigdata:executor:ExecutionCancelled')
                    rethrow(err);
                end
            end
        end
        
        %RESIZECHUNKS Resize chunks so they are bigger than a minimum size
        % where possible.
        function varargout = resizechunks(varargin)
            import matlab.bigdata.internal.lazyeval.ChunkResizeOperation;
            
            op = ChunkResizeOperation(nargout, varargin{nargout + 1 : end});
            [varargout{1 : nargout}] = iDoOperation(op, varargin{1 : nargout});
        end
        
        % Get the executor underlying this partitioned array or error if it
        % no longer is valid.
        function executor = getExecutor(obj)
            import matlab.bigdata.internal.executor.PartitionedArrayExecutor;
            executor = PartitionedArrayExecutor.getOverride();
            if isempty(executor)
                executor = obj.Executor;
            end
        end
        
        function ds = get.Datastore(obj)
            ds = obj.PartitionMetadata.Datastore;
        end
    end
    
    methods (Hidden)
        % TODO: This is currently not in the specification.
        function varargout = clientfun(options, functionHandle, varargin)
            import matlab.bigdata.internal.executor.BroadcastPartitionStrategy
            import matlab.bigdata.internal.lazyeval.NonPartitionedOperation;
            import matlab.bigdata.internal.PartitionMetadata;
            [options, functionHandle, args] = iParseInputs(options, functionHandle, varargin{:});
            functionHandle = iParseFunctionHandle(functionHandle);
            [varargout{1:nargout}] = iDoOperation(NonPartitionedOperation(options, functionHandle, numel(args), nargout), args{:});
            partitionMetadata = PartitionMetadata(BroadcastPartitionStrategy()); %#ok<CPROPLC>
            [varargout{:}] = iSetPartitionMetadata(partitionMetadata, varargout{:});
        end
        
        % PARTITIONHEADFUN Apply a partition-wise function handle that only
        % requires the first few slices of each partition to generate the
        % complete output.
        %
        % The function handle must obey the same rules as for partitionfun.
        % On top of this, the framework will assume that full evaluation of
        % this operation is fast enough for preview.
        function varargout = partitionheadfun(functionHandle, varargin)
            import matlab.bigdata.internal.lazyeval.PartitionwiseOperation;
            options = matlab.bigdata.internal.PartitionedArrayOptions;
            functionHandle = iParseFunctionHandle(functionHandle);
            dependsOnlyOnHead = true;
            op = PartitionwiseOperation(options, functionHandle, numel(varargin), nargout, dependsOnlyOnHead);
            [varargout{1:nargout}] = iDoOperation(op, varargin{:});
            for ii = 1 : numel(varargout)
                varargout{ii}.ValueFuture.Promise.setPartitionIndependent(false);
            end
        end
        
        % STRICTSLICEFUN Perform a slicefun operation that does not support
        % singleton expansion.
        function varargout = strictslicefun(options, functionHandle, varargin)
            import matlab.bigdata.internal.lazyeval.SlicewiseOperation;
            [options, functionHandle, args] = iParseInputs(options, functionHandle, varargin{:});
            functionHandle = iParseFunctionHandle(functionHandle);
            allowsTallDimExpansion = false;
            op = SlicewiseOperation(options, functionHandle, numel(args), nargout, allowsTallDimExpansion);
            [varargout{1:nargout}] = iDoOperation(op, args{:});
        end
        
        %NUMPARTITIONS Get the number of partitions that will be used to
        %evaluate this partitioned array given no other restraints.
        function n = numpartitions(obj)
            executor = getExecutor(obj);
            n = executor.numPartitions(obj.PartitionMetadata.Strategy);
        end
    end
    
    methods (Hidden)
        % Everything to do with the cached preview data. Don't even ask about this stuff
        % if the array is gathered.
        function tf = hasCachedPreviewData(obj)
            assert(~obj.ValueFuture.IsDone, ...
                'Assertion failed: Checking for cache preview data on an array that is already complete.');
            tf = obj.HasPreviewData;
        end
        function [data, isTruncated] = getCachedPreviewData(obj)
            assert(~obj.ValueFuture.IsDone, ...
                'Assertion failed: Requested cache preview data on an array that is already complete.');
            data = obj.PreviewData;
            isTruncated = obj.IsPreviewTruncated;
        end
        function setCachedPreviewData(obj, previewData, isTruncated)
            assert(~obj.ValueFuture.IsDone, ...
                'Assertion failed: Setting cache preview data on an array that is already complete.');
            assert(~obj.HasPreviewData, ...
                'Assertion failed: Setting cache preview data on an array that already has it.');
            obj.PreviewData = previewData;
            obj.IsPreviewTruncated = isTruncated;
            obj.HasPreviewData = true;
        end
    end
    
    methods
        function tf = get.IsValid(obj)
            executor = getExecutor(obj);
            tf = executor.checkIsValidNow();
        end
        
        % Serialization of a LazyPartitionedArray object.
        function s = saveobj(obj)
            s.Version = version('-release');
            s.ValueFuture = obj.ValueFuture;
            s.PartitionMetadata = obj.PartitionMetadata;
        end
    end
    
    methods (Static)
        % Deserialization to a LazyPartitionedArray object.
        function obj = loadobj(s)
            % On load, we both check version and bind the lazy partitioned
            % array with the current executor.
            import matlab.bigdata.internal.executor.PartitionedArrayExecutorReference;
            import matlab.bigdata.internal.serial.SerialExecutor;
            import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
            
            % Prior to R2017a the version isn't stored in the file.
            ver = '2016b';
            if isfield(s, 'Version')
                ver = s.Version;
            end
            
            if isequal(ver, version('-release'))
                obj = LazyPartitionedArray(...
                    s.ValueFuture, ...
                    iGetCurrentExecutor(), ...
                    s.PartitionMetadata);
            else
                warning(message('MATLAB:bigdata:array:InvalidTallVersion', ver));
                
                % When the version information does not match, we simply
                % load the array as an invalid tall.
                serialExecutor = SerialExecutor();
                invalidExecutor = PartitionedArrayExecutorReference(serialExecutor);
                obj = LazyPartitionedArray.createFromConstant(ver, invalidExecutor);
                % We use partitionfun here because that will not be
                % evaluated immediately.
                obj = partitionfun(@(~,~) iIssueInvalidVersionError(ver), obj);
                delete(serialExecutor);
            end
        end
    end
    
    methods (Access = private)
        % Private constructor for factory purposes.
        function obj = LazyPartitionedArray(valueFuture, executor, partitionMetadata)
            import matlab.bigdata.internal.executor.PartitionedArrayExecutor;
            
            assert(isa(valueFuture, 'matlab.bigdata.internal.lazyeval.ClosureFuture') && isscalar(valueFuture));
            obj.ValueFuture = valueFuture;
            obj.Executor = executor;
            obj.PartitionMetadata = partitionMetadata;
            obj.HasPreviewData = false;
            
            % This is to ensure execution environments with idle timeouts
            % have the chance to reset the timeout when new arrays are
            % created.
            executor.keepAlive();
        end
        
        % The common error handling code for Partitioned Array evaluation.
        function wrapEvaluationError(obj, err) %#ok<INUSL>
            rethrow(err);
        end
        
        % Convert the PartitionedArray into the necessary task graph object
        % and executor object.
        function [taskGraph, executor, optimUndoGuard] = getEvaluationObjects(varargin)
            import matlab.bigdata.internal.executor.PartitionedArrayExecutor;
            import matlab.bigdata.internal.lazyeval.Closure;
            import matlab.bigdata.internal.lazyeval.LazyTaskGraph;
            import matlab.bigdata.internal.serial.SerialExecutor;
            import matlab.bigdata.internal.util.isPreviewCheap;
            
            % Before gathering, call the optimizer.
            op = matlab.bigdata.internal.Optimizer.default();
            optimUndoGuard = op.optimize(varargin{:});
            
            closures = cell(size(varargin));
            executor = PartitionedArrayExecutor.getOverride();
            for ii = 1:numel(varargin)
                if ~varargin{ii}.ValueFuture.IsDone
                    closures{ii} = varargin{ii}.ValueFuture.Promise.Closure;
                    if isempty(executor)
                        executor = getExecutor(varargin{ii});
                    end
                end
            end
            closures = vertcat(closures{:}, Closure.empty());
            
            if ~isempty(executor) && executor.supportsSinglePartition()
                isGatherCheap = true(size(varargin));
                ii=1;
                while all(isGatherCheap) && ii<=numel(varargin)
                    [~, isGatherCheap(ii)] = isPreviewCheap(varargin{ii});
                    ii = ii + 1;
                end
                if all(isGatherCheap)
                    executor = SerialExecutor('UseSinglePartition', true);
                end
            end
            
            if isempty(closures)
                taskGraph = [];
            else
                taskGraph = LazyTaskGraph(closures);
            end
        end
    end
end

% Generate a closure for the operation and return a list of
% PartitionedArray instances representing each output.
function varargout = iDoOperation(operation, varargin)
import matlab.bigdata.internal.lazyeval.ClosurePromise;
import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
[valueFutures, executor, datastore] = iParseDataInputs(varargin{:});
if isempty(executor)
    executor = iGetCurrentExecutor();
end

promises = [valueFutures.Promise, ClosurePromise.empty()];
isPartitionIndependent = all([promises.IsPartitionIndependent]);
if isPartitionIndependent && operation.SupportsDirectEvaluation && all([valueFutures.IsDone])
    % If we can evaluate immediately and cheaply, do so.
    [varargout{1:operation.NumOutputs}] = evaluate(operation, valueFutures.Value);
    for ii = 1:numel(varargout)
        promise = ClosurePromise(varargout{ii});
        varargout{ii} = LazyPartitionedArray(promise.Future, executor, datastore);
    end
else
    % Otherwise schedule the operation to be done lazily.
    closure = matlab.bigdata.internal.lazyeval.Closure(valueFutures, operation, isPartitionIndependent);
    varargout = cell(numel(closure.OutputPromises), 1);
    for ii = 1:numel(varargout)
        varargout{ii} = LazyPartitionedArray(closure.OutputPromises(ii).Future, executor, datastore);
    end
end
end

% Helper function that parses the data inputs to PartitionedArray methods.
% This will return a list of futures to each input.
function [valueFutures, executor, partitionMetadata] = iParseDataInputs(varargin)
import matlab.bigdata.internal.BroadcastArray;
import matlab.bigdata.internal.lazyeval.ClosureFuture;
import matlab.bigdata.internal.lazyeval.ClosurePromise;
import matlab.bigdata.internal.PartitionMetadata;
valueFutures = cell(size(varargin));
executor = [];
partitionMetadata = cell(size(varargin));
for ii = 1:nargin
    % Parse dispatch based on type of input.
    if isa(varargin{ii}, 'matlab.bigdata.internal.lazyeval.LazyPartitionedArray')
        valueFutures{ii} = varargin{ii}.ValueFuture;
        executor = iCheckSameExecutor(getExecutor(varargin{ii}), executor);
        partitionMetadata{ii} = varargin{ii}.PartitionMetadata;
    elseif isa(varargin{ii}, 'matlab.bigdata.internal.BroadcastArray')
        % A BroadcastArray will either contain a local array that should
        % be passed to all function calls or a PartitionedArray instance
        % that represents an array that should be passed to all function
        % calls. To support this, we simply convert the underlying array to
        % a 1 x 1 BroadcastArray instance. This instance will be passed
        % to all function calls as per the singleton expansion rules.
        
        % Parse dispatch based on type of underlying value.
        value = varargin{ii}.Value;
        if isa(value, 'matlab.bigdata.internal.lazyeval.LazyPartitionedArray')
            value = clientfun(@BroadcastArray, value);
            valueFutures{ii} = value.ValueFuture;
            executor = iCheckSameExecutor(getExecutor(value), executor);
            partitionMetadata{ii} = value.PartitionMetadata;
        else % An unwrapped local array
            % Ensure that this else branch does not accept other unsupported
            % implementation of PartitionedArray that has not been dealt
            % with explicitly by their own elseif branch.
            assert(~isa(varargin{ii}, 'matlab.bigdata.internal.PartitionedArray'), ...
                'Assertion failed: Unrecognized child of PartitionedArray interface, ''%s''.', ...
                class(varargin{ii}));
            
            promise = ClosurePromise(BroadcastArray(value));
            valueFutures{ii} = promise.Future;
        end
        
    elseif isa(varargin{ii}, 'matlab.bigdata.internal.LocalArray')
        promise = ClosurePromise(varargin{ii}.Value);
        valueFutures{ii} = promise.Future;
        
    else % An unwrapped local array
        % Ensure that this else branch does not accept other unsupported
        % implementation of PartitionedArray that has not been dealt
        % with explicitly by their own elseif branch.
        assert(~isa(varargin{ii}, 'matlab.bigdata.internal.PartitionedArray'), ...
            'Assertion failed: Unrecognized child of PartitionedArray interface, ''%s''.', ...
            class(varargin{ii}));
        
        promise = ClosurePromise(varargin{ii});
        valueFutures{ii} = promise.Future;
    end
end
valueFutures = vertcat(valueFutures{:});
if isempty(valueFutures)
    valueFutures = ClosureFuture.empty(0, 1);
end
partitionMetadata = PartitionMetadata.align(partitionMetadata{:});
end

% Get the current executor by looking at the current MapReducer.
function executor = iGetCurrentExecutor()
import matlab.bigdata.internal.executor.PartitionedArrayExecutor;
executor = PartitionedArrayExecutor.default();
end

% Check if the two executors are the same or simply return the new executor
% if a previous one does not exist.
function executor = iCheckSameExecutor(newExecutor, executor)
if isempty(executor)
    executor = newExecutor;
elseif ~checkSameExecutor(newExecutor, executor)
    error(message('MATLAB:bigdata:array:IncompatibleTallExecutor'));
end
end

% Helper function that ensures all received function handles are instances
% of the matlab.bigdata.internal.FunctionHandle class.
function functionHandle = iParseFunctionHandle(functionHandle)
import matlab.bigdata.internal.FunctionHandle;
if ~isa(functionHandle, 'matlab.bigdata.internal.FunctionHandle')
    assert (isa(functionHandle, 'function_handle'), ...
        'Assertion failed: Function handle must be a function_handle or a matlab.bigdata.internal.FunctionHandle.');
    functionHandle = FunctionHandle(functionHandle);
end
end

% Helper function that sets the partitionMetadata field of a set of LazyPartitionedArray.
function varargout = iSetPartitionMetadata(partitionMetadata, varargin)
import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
varargout = cell(size(varargin));
for ii = 1:numel(varargin)
    varargout{ii} = LazyPartitionedArray(varargin{ii}.ValueFuture, varargin{ii}.Executor, partitionMetadata);
end
end

% Given a list of partitioned arrays, get the metadata objects that can be
% filled out, and the corresponding list of partitioned arrays that will compute
% the metadata.
function [metadatas, partitionedArrays] = ...
    iGenerateMetadataFillingPartitionedArrays(inputArrays)

executorToConsider = [];

keepArray = false(1, numel(inputArrays));

for idx = 1:numel(inputArrays)
    inputArray = inputArrays{idx};
    if isempty(executorToConsider) && ~isempty(inputArray.Executor)
        executorToConsider = inputArray.Executor;
    end
    
    if ~isempty(executorToConsider)
        keepArray(idx) = isequal(inputArray.Executor, executorToConsider);
    end
end

inputArrays(~keepArray) = [];

[metadatas, partitionedArrays] = iGenerateMetadata(inputArrays, executorToConsider);

end

% Generate partitioned arrays to compute metadata. We do this for arrays that are:
% - upstream of all aggregations
% - downstream of any read
% - not adaptor-assertion operations
% - not downstream of any "depends only on head" operations
function [metadatas, metadataPartitionedArrays] = iGenerateMetadata(partitionedArrays, exec)
import matlab.bigdata.internal.lazyeval.LazyPartitionedArray

% Get the closure graph for this partitioned array.
cg           = matlab.bigdata.internal.optimizer.ClosureGraph(partitionedArrays{:});
allNodeObjs  = cg.Graph.Nodes.NodeObj;
allOpTypes   = cg.Graph.Nodes.OpType;
isClosure    = cg.Graph.Nodes.IsClosure;
allDistances = distances(cg.Graph);

% compute which closures are 'head only' closures, and nodes which are
% downstream thereof
isHeadOnlyClosure      = iFindHeadOnlyClosures(allNodeObjs, isClosure);
isDownstreamOfHeadOnly = iFindDownstreamOfAny(allDistances, isHeadOnlyClosure);

% compute which closures are 'assertion' closures.
isAssertionClosure = iFindAssertionClosures(allNodeObjs, allOpTypes, isClosure);

% compute which closures are downstream of any read operation
isClosureDownstreamOfRead = iFindDownstreamOfAnyRead(allDistances, allOpTypes, isClosure);

% compute which closures are upstream of any cache operation
isClosureUpstreamOfCache = iFindUpstreamOfCache(allDistances, allOpTypes, isClosure);

% compute which closures are upstream of all aggregations
isClosureUpstreamOfAggregate = iFindUpstreamOfAllAggregates(allDistances, ...
    allOpTypes, isClosure, isDownstreamOfHeadOnly);

% Combine all the above to select the nodes for which we'll even consider
% collecting metadata.
nodesToKeep = isClosure & ...
    ~isDownstreamOfHeadOnly & ...
    ~isAssertionClosure & ...
    isClosureDownstreamOfRead & ...
    isClosureUpstreamOfAggregate & ...
    ~isClosureUpstreamOfCache;

% Next, we need to find the promises that are immediately downstream of all
% those closures. Use the distance matrix again, and find the places where the
% distance is exactly 1.
distFromClosure = allDistances(nodesToKeep, :);
isPromiseMatrix = distFromClosure == 1;
promiseIdxs     = find(sum(isPromiseMatrix, 1));

% Finally, get the promises, and build the metadata-gathering partitioned
% arrays.
metadatas                 = cell(1, numel(promiseIdxs));
metadataPartitionedArrays = cell(1, numel(promiseIdxs));
for idx = 1:numel(promiseIdxs)
    thisPromise = allNodeObjs{promiseIdxs(idx)};
    metadatas{idx} = hGetMetadata(thisPromise);
    if ~isempty(metadatas{idx}) && ~hasGotResults(metadatas{idx})
        % Build with empty datastore - presume checks upstream will sort
        % things out.
        tmpPartitionedArray = LazyPartitionedArray(thisPromise.Future, exec, []);
        [aggFcn, redFcn] = getAggregateAndReduceFcns(metadatas{idx});
        metadataPartitionedArrays{idx} = aggregatefun(...
            aggFcn, redFcn, tmpPartitionedArray);
    end
end

% Discard those elements that turned out not to have any metadata to compute.
discard = cellfun(@isempty, metadataPartitionedArrays);
metadatas(discard) = [];
metadataPartitionedArrays(discard) = [];
end

% Find all nodes upstream of all aggregate operations - providing there are some
% aggregates. If there are no aggregates, this will return an all-false vector.
function isUpstream = iFindUpstreamOfAllAggregates(allDistances, allOpTypes, ...
    isClosure, isDownstreamOfHeadOnly)
isAggregate = false(size(isClosure));
isAggregate(isClosure) = allOpTypes(isClosure) == 'AggregateOperation';
% Disregard aggregates that are downstream of 'head only' operations as
% these do not represent a full pass through the data
isAggregate(isDownstreamOfHeadOnly) = false;
distUpToAggregate = allDistances(:, isAggregate);
isUpstreamMatrix = distUpToAggregate > 0 & ~isinf(distUpToAggregate);
isUpstream = all(isUpstreamMatrix, 2) & any(isAggregate);
end

% Find all nodes downstream of some list of nodes
function isDownstream = iFindDownstreamOfAny(allDistances, sourceNodes)
distToSource = allDistances(sourceNodes, :).';
isDownstreamMatrix = distToSource >= 0 & ~isinf(distToSource);
isDownstream = any(isDownstreamMatrix, 2);
end

% Get a vector defining whether a closure node is downstream of any read operation
function isDownstream = iFindDownstreamOfAnyRead(allDistances, allOpTypes, isClosure)
isReadClosure = false(size(isClosure));
isReadClosure(isClosure) = allOpTypes(isClosure) == 'ReadOperation';
isDownstream = iFindDownstreamOfAny(allDistances, isReadClosure);
end

% Get a vector defining whether a closure node is upstream of any cache operation
function isUpstream = iFindUpstreamOfCache(allDistances, allOpTypes, isClosure)
isCacheClosure = false(size(isClosure));
isCacheClosure(isClosure) = allOpTypes(isClosure) == 'CacheOperation';
distCacheUpToX = allDistances(:, isCacheClosure);
% Keep rows of distCacheUpToX where any column is finite and >= 0
isUpstream = any(distCacheUpToX >= 0 & ~isinf(distCacheUpToX), 2);
end

% Get a vector defining whether a node is an 'assertion' closure
function isAssertionClosure = iFindAssertionClosures(allNodeObjs, allOpTypes, isClosure)
isElementwiseClosure = false(size(isClosure));
isElementwiseClosure(isClosure) = allOpTypes(isClosure) == 'ElementwiseOperation';

isAssertionFcnh = @(clos) isequal(func2str(clos.Operation.FunctionHandle.Handle), ...
    '@(x)iAssertAdaptorInfoCorrect(x,adaptor)');

isAssertionClosure = false(size(isClosure));
isAssertionClosure(isElementwiseClosure) = cellfun(isAssertionFcnh, ...
    allNodeObjs(isElementwiseClosure));
end

% Get a vector defining whether a node is a 'head only' closure
function isHeadOnlyClosure = iFindHeadOnlyClosures(allNodeObjs, isClosure)
isHeadOnlyClosure = false(size(isClosure));
isHeadOnlyClosure(isClosure) = cellfun(@(c) c.Operation.DependsOnOnlyHead, ...
    allNodeObjs(isClosure));
end

% Apply the results of computing metadata to the metadata objects
function iApplyMetadataResults(metadatas, metadataFillingPartitionedArrays)
cellfun(@(m, mfpa) applyResult(m, mfpa.ValueFuture.Value), ...
    metadatas, metadataFillingPartitionedArrays);
end

% Helper function to lazily throw the version error. This is likely not
% reachable such a tall array is initialized with an invalid executor.
function varargout = iIssueInvalidVersionError(ver) %#ok<STOUT>
error(message('MATLAB:bigdata:array:InvalidTallVersion', ver));
end

% Get an output handler object that completes closure futures on receiving
% all of the output corresponding to each closure.
function handler = iCreateGatherOutputHandler(taskGraph)
import matlab.bigdata.internal.executor.GatheringOutputHandler;
taskToClosureMap = taskGraph.TaskToClosureMap;
handler = GatheringOutputHandler(@nHandleGatherOutput);
    function cancel = nHandleGatherOutput(taskId, argoutIndex, data)
        % Flatten unknowns. We can do this because we have the
        % entire array at this point.
        if matlab.bigdata.internal.UnknownEmptyArray.isUnknown(data)
            data = getSample(data);
        end
        closure = taskToClosureMap(taskId);
        closure.OutputPromises(argoutIndex).setValue(data);
        cancel = false;
    end
end

% Get an output handler object that streams chunks to a function handle.
function handler = iCreateStreamOutputHandler(taskId, argoutIndex, fcn)
import matlab.bigdata.internal.executor.StreamingOutputHandler;
handler = StreamingOutputHandler(taskId, argoutIndex, @nHandleStreamOutput);
    function cancel = nHandleStreamOutput(~, ~, info, data)
        hasFinished = feval(fcn, info, vertcat(data{:}, {}));
        cancel = hasFinished;
    end
end

function workerFcn = iCreateForeachWorkerFcn(fcn)
% Create a function handle that encellifies the output of the function call
% so that each output value can be passed exactly to the client function.
workerFcn = @nForeachWorkerFcn;
    function [isFinished, value] = nForeachWorkerFcn(varargin)
        [isFinished, value] = feval(fcn, varargin{:});
        if isempty(value)
            value = cell(0, 1);
        else
            value = {value};
        end
    end
end

function clientFcn = iCreateForeachClientFcn(fcn)
% Create a function handle that decellifies the input and passes each value
% one by one to the underlying function handle.
import matlab.bigdata.internal.util.StatefulFunction;
clientFcn = StatefulFunction(@nForeachClientFcn);
    function [prevChunks, isFinished] = nForeachClientFcn(prevChunks, info, chunks)
        
        % We hold the very last received chunk back in-case the next
        % invocation of this function has both IsLastChunk true and an
        % empty data.
        if isempty(prevChunks)
            prevChunks = cell(1, info.NumPartitions);
        end
        % TODO(g1562385): Removing empty chunks was an behaviour agreed for
        % progressive visualization. This ought to live elsewhere.
        chunks(cellfun(@isempty, chunks)) = [];
        chunks = [prevChunks{info.PartitionIndex}; chunks];
        prevChunks{info.PartitionIndex} = [];

        % TODO(g1562385): Avoiding calling clientFcn when no input chunks
        % was a behaviour agreed for progressive visualization. This ought
        % to live elsewhere.
        if isempty(chunks)
            isFinished = all(info.CompletedPartitions);
            return;
        end
        
        info.PartitionId = info.PartitionIndex;
        isLastChunk = info.IsLastChunk;
        info.IsLastChunk = false;
        info.CompletedPartitions(info.PartitionIndex) = false;
        
        for ii = 1 : numel(chunks) - 1
            isFinished = feval(fcn, info, chunks{ii});
            if isFinished
                return;
            end
        end
        
        if isLastChunk
            info.IsLastChunk = true;
            info.CompletedPartitions(info.PartitionIndex) = true;
            isFinished = feval(fcn, info, chunks{end});
        else
            prevChunks{info.PartitionIndex} = chunks(end);
            isFinished = false;
        end
    end
end

function [opts,varargout] = iParseInputs(varargin)
% Split and check the inputs
varargout = cell(1,nargout-1);
[opts, varargout{:}] = matlab.bigdata.internal.util.stripOptions(varargin{:});
opts = iFixRNGFactory(opts);
end

function opts = iFixRNGFactory(opts)
% If no RNG factory supplied, use the inputs to make one.
if opts.RequiresRandState && isempty(opts.RandStreamFactory)
    % Create a factory function that can build the correct RandStream
    % for the current partition when called.
    opts.RandStreamFactory = matlab.bigdata.internal.RandStreamFactory();
end
end


function iCleanupOldCacheEntries(cacheEntryKeys)
% Cleanup CacheEntryKey instances that are referenced by the OldId of
% another. These instances are to be replaced as per the contract of
% updateforreuse.
oldIds = vertcat(cacheEntryKeys.OldId, string.empty());
if ~isempty(oldIds)
    ids = vertcat(cacheEntryKeys.Id, string.empty());
    isOld = ismember(ids, oldIds);
    for idx = find(isOld)
        cacheEntryKeys(idx).markInvalid();
    end
end
end
