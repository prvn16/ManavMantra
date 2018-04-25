%PartitionedArrayExecutor
% The main interface for execution environment to expose their capabilities
% to the Lazy Evaluation Framework. All back-end implementations must
% implement this interface.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Abstract) PartitionedArrayExecutor < handle & matlab.mapreduce.internal.SoftReferableMixin
    methods (Abstract)
        %EXECUTE Execute the provided graph of tasks.
        %
        % Syntax:
        %  varargout = execute(obj,taskGraph);
        %
        % Inputs:
        %  - obj: The MCOS object instance.
        %  - taskGraph: The instance of TaskGraph to be evaluated.
        %
        % Outputs:
        %  - varargout: Each output is the gathered results of evaluating
        %  taskGraph.OutputTasks of the same index.
        %
        % Error Conditions:
        %  - If any error is issued during a call to user code an
        %  matlab:bigdata:executor:EvaluationError will be issued.
        %  - If the execution environment cannot complete the execution for
        %  any other reason, a user show-able error will be issued.
        %
        out = execute(obj, taskGraph);
        
        %COUNTNUMPASSES Count the number of passes required to execute the provided graph of tasks.
        %
        % Syntax:
        %  numPasses = countNumPasses(obj,taskGraph);
        %
        % Inputs:
        %  - obj: The MCOS object instance.
        %  - taskGraph: The instance of TaskGraph to be evaluated.
        %
        % Outputs:
        %  - numPasses: The number of passes that would be required to
        %  evaluate taskGraph.
        %
        % Error Conditions:
        %  - None.
        %
        numPasses = countNumPasses(obj, taskGraph);
        
        %NUMPARTITIONS Retrieve the number of partitions for the given
        %  partition strategy.
        %
        % Syntax:
        %   N = numPartitions(obj, partitionStrategy)
        %
        % Inputs:
        %  - obj: The MCOS object instance.
        %  - partitionStrategy: The partition strategy to convert to number
        %  of partitions.
        %
        % Outputs:
        %  - numPartitions: The number of partitions that would be used to
        %  evaluate the provided partition strategy.
        %
        % Error Conditions:
        %  - If the executor cannot calculate the number of partitions, the
        %  appropriate datastore error will be issued.
        %
        n = numPartitions(obj, partitionStrategy);
    end
    
    methods
        function executeWithHandler(obj, taskGraph, outputHandlers)
            %EXECUTEWITHHANDLER Execute the provided graph of tasks redirecting
            %  all output to the given output handler.
            %
            % Syntax:
            %  executeWithHandler(obj,taskGraph,outputHandler);
            %
            % Inputs:
            %  - obj: The MCOS object instance.
            %  - taskGraph: The instance of TaskGraph to be evaluated.
            %  - outputHandlers: An instance of matlab.bigdata.internal.executor.OutputHandler.
            %
            % Error Conditions:
            %  - If any error is issued during a call to user code an
            %  matlab:bigdata:executor:EvaluationError will be issued.
            %  - If the execution environment cannot complete the execution for
            %  any other reason, a user show-able error will be issued.
            
            % TODO(g1544242): This is a shim layer between the old syntax
            % and new. This should be removed once all back-ends support
            % the new syntax directly.
            [outputs{1:numel(taskGraph.OutputTasks)}] = obj.execute(taskGraph);
            
            for ii = 1:numel(outputs)
                outputHandlers.handleBroadcastOutput(taskGraph.OutputTasks(ii).Id, outputs{ii});
            end
        end
        
        % Check whether this executor is valid.
        function tf = checkIsValid(~)
            tf = true;
        end
        
        % Check whether this executor is valid right now.
        % This is to allow LazyPartitionedArray to avoid recreating a
        % mapreducer when we're currently just previewing data.
        function tf = checkIsValidNow(obj)
            tf = obj.checkIsValid();
        end
        
        %CHECKDATASTORESUPPORT Check whether the provided datastore is supported.
        % The default is to do nothing. Implementations will are allowed to
        % issue errors from here if the datastore is not supported.
        function checkDatastoreSupport(obj, ds) %#ok<INUSD>
        end
        
        %CHECKSAMEEXECUTOR Check whether the two executor objects represent
        % the same underlying execution environment.
        function tf = checkSameExecutor(obj1, obj2)
            tf = (obj1 == obj2);
        end
        
        %KEEPALIVE Notify to the executor that operations have just been
        %performed and it should reset any idle timeouts.
        function keepAlive(obj) %#ok<MANU>
        end
        
        %REQUIRESSEQUENCEFILEFORMAT A flag that specifies if tall/write
        %should always generate sequence files.
        function tf = requiresSequenceFileFormat(obj) %#ok<MANU>
            tf = false;
        end
        
        %SUPPORTSSINGLEPARTITION A flag that specifies if the executor
        %supports the single partition optimization.
        function tf = supportsSinglePartition(obj) %#ok<MANU>
            tf = false;
        end
    end
    
    methods (Static)
        %DEFAULT Get the default PartitionedArrayExecutor instance.
        %
        % Syntax:
        %  executor = PartitionedArrayExecutor.default();
        %
        % Outputs:
        %  - executor: The PartitionedArrayExecutor to use to evaluate a
        %  tall expression.
        %
        % Error Conditions:
        %  - Error if a failure occurs while creating the default
        %  PartitionedArrayExecutor instance.
        %
        function out = default()
            import matlab.bigdata.internal.executor.PartitionedArrayExecutor;
            import matlab.mapreduce.internal.MapReducerManager;
            
            out = PartitionedArrayExecutor.override();
            if isempty(out)
                mr = getOrCreateDefault(MapReducerManager.getCurrentManager());
                out = mr.getPartitionedArrayExecutor();
            end
        end
        
        %OVERRIDE Get or set an override for the PartitionedArrayExecutor used by tall.
        %
        % Syntax:
        %  oldExecutor = PartitionedArrayExecutor.override(newExecutor);
        %
        % Inputs:
        %  - newExecutor: The PartitionedArrayExecutor to use for tall or
        %  empty to remove the explicit override.
        %
        % Outputs:
        %  - executor: The current PartitionedArrayExecutor override or
        %  empty if there exists no explicit override.
        %
        % Error Conditions:
        %  - None.
        %
        function out = override(in)
            persistent defaultExecutor;
            
            if nargout
                out = defaultExecutor;
            end
            
            if nargin
                assert (isempty(in) || isa(in, 'matlab.bigdata.internal.executor.PartitionedArrayExecutor'));
                defaultExecutor = in;
            end
        end
        
        %GETOVERRIDE Get the PartitionedArrayExecutor override.
        %
        % If non-empty, this executor must be used for any tall array
        % evaluation.
        %
        % Syntax:
        %  executor = PartitionedArrayExecutor.getOverride() returns the
        %  current executor override if one has been set. If no override,
        %  this will return empty.
        function out = getOverride()
            out = matlab.bigdata.internal.executor.PartitionedArrayExecutor.override();
        end
        
        %CHECKDATASTORESUPPORTFORDEFAULT Check if the given datastore will
        % be supported by the current mapreducer.
        function checkDatastoreSupportForDefault(ds)
            mr = gcmr('nocreate');
            if isempty(mr)
                isDefaultParallel = false;
                if (license('test', 'distrib_computing_toolbox') ...
                        && exist('parallel.internal.bigdata.ParallelPoolExecutor', 'class') == 8)
                    try %#ok<TRYNC>
                        isDefaultParallel = parallel.internal.bigdata.ParallelPoolExecutor.isAutoCreateEnabled() || ~isempty(gcp('nocreate'));
                    end
                end
                
                if isDefaultParallel
                    parallel.internal.bigdata.ParallelPoolExecutor.errorIfDatastoreNotSupported(ds);
                end
            else
                executor = mr.getPartitionedArrayExecutor();
                executor.checkDatastoreSupport(ds);
            end
        end
        
        function incrementTotalNumPasses()
            % Increment the total number of passes state.
            
            import matlab.bigdata.internal.executor.totalNumPasses;
            totalNumPasses(totalNumPasses + 1);
        end
    end
end
