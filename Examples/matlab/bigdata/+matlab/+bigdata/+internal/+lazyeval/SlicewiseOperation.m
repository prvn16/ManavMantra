%SlicewiseOperation
% An operation that acts on each slice of data.

% Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) SlicewiseOperation < matlab.bigdata.internal.lazyeval.SlicewiseFusableOperation
    properties (SetAccess = immutable)
        % The function handle for the operation.
        FunctionHandle;
        
        % A logical scalar that specifies if this slicewise operation is
        % allowed to use singleton expansion in the tall dimension.
        AllowTallDimExpansion = true;
    end
    
    methods
        % The main constructor.
        function obj = SlicewiseOperation(options, functionHandle, numInputs, numOutputs, allowTallDimExpansion)
            supportsPreview = true;
            obj = obj@matlab.bigdata.internal.lazyeval.SlicewiseFusableOperation(numInputs, numOutputs, supportsPreview);
            obj.Options = options;
            obj.FunctionHandle = functionHandle;
            if nargin >= 5
                obj.AllowTallDimExpansion = allowTallDimExpansion;
            end
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        function task = createExecutionTasks(obj, taskDependencies, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.lazyeval.ChunkwiseProcessor;
            
            isBroadcast = arrayfun(@(x)x.OutputPartitionStrategy.IsBroadcast, taskDependencies);
            if ~obj.AllowTallDimExpansion && any(isBroadcast) && ~all(isBroadcast)
                obj.FunctionHandle.throwAsFunction(MException(message('MATLAB:bigdata:array:IncompatibleTallIndexing')));
            end
            
            processorFactory = ChunkwiseProcessor.createFactory(...
                obj.getCheckedFunctionHandle(), obj.NumOutputs, ...
                inputFutureMap, isInputReplicated, obj.AllowTallDimExpansion);
            processorFactory = obj.addGlobalState(processorFactory);

            task = ExecutionTask.createSimpleTask(taskDependencies, processorFactory);
        end
    end
    
    % Methods overridden in the SlicewiseFusableOperation interface.
    methods
        function tf = isSlicewiseFusable(obj)
            tf = isSlicewiseFusable@matlab.bigdata.internal.lazyeval.SlicewiseFusableOperation(obj);
            tf = tf && obj.AllowTallDimExpansion;
        end

        function fh = getCheckedFunctionHandle(obj)
            import matlab.bigdata.internal.lazyeval.TaggedArrayFunction;
            fh = TaggedArrayFunction.wrap(obj.FunctionHandle, obj.Options);
            fh = iWrapFunctionHandle(fh);
        end
    end
end

function wrappedFcn = iWrapFunctionHandle(originalFcn)
% Wrap the given FunctionHandle object in a function handle that will
% verify the elementwise size constraints.
underlyingFcn = originalFcn.Handle;
wrappedFcn = originalFcn.copyWithNewHandle(@fcn);
    function varargout = fcn(varargin)
        expectedSize = iGetExpectedSize(varargin);
        [varargin, varargout{2 : nargout}] = feval(underlyingFcn, varargin{:});
        varargout{1} = varargin;
        iVerifyExpectedSize(expectedSize, varargout);
    end
end

function expectedTallSize = iGetExpectedSize(inputs)
% Get the expected size of the outputs based on the inputs.
for ii = 1:numel(inputs)
    expectedTallSize = size(inputs{ii}, 1);
    if expectedTallSize ~= 1
        break;
    end
end
end

function iVerifyExpectedSize(expectedTallSize, outputs)
% Verify the outputs match the expected size.
for ii = 1:numel(outputs)
    actualTallSize = size(outputs{ii}, 1);
    if ~isequal(actualTallSize, expectedTallSize)
        error(message('MATLAB:bigdata:array:InvalidOutputTallSize', ...
            ii, actualTallSize, expectedTallSize));
    end
end
end
