%ElementwiseOperation
% An operation that acts on each element of data.

% Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) ElementwiseOperation < matlab.bigdata.internal.lazyeval.SlicewiseFusableOperation
    properties (SetAccess = immutable)
        % The function handle for the operation.
        FunctionHandle;
    end
    
    methods
        % The main constructor.
        function obj = ElementwiseOperation(options, functionHandle, numInputs, numOutputs)
            supportsPreview = true;
            obj = obj@matlab.bigdata.internal.lazyeval.SlicewiseFusableOperation(numInputs, numOutputs, supportsPreview);
            obj.FunctionHandle = functionHandle;
            obj.Options = options;
            % If MaxNumSlices is Inf, this operation can be done via
            % calling the function handle on all of the data.
            obj.SupportsDirectEvaluation = isinf(functionHandle.MaxNumSlices);
        end
    end
    
    % Methods overridden in the Operation interface.
    methods
        function [varargout] = evaluate(obj, varargin)
            heights = cellfun(@(x) size(x, 1), varargin);
            if numel(unique(heights(heights ~= 1))) > 1
                matlab.bigdata.internal.throw(...
                    MException(message('MATLAB:bigdata:array:IncompatibleTallSize')));
            end
            fh = obj.getCheckedFunctionHandle();
            [varargout{1 : nargout}] = feval(fh, varargin{:});
        end
        
        function task = createExecutionTasks(obj, taskDependencies, inputFutureMap, isInputReplicated)
            import matlab.bigdata.internal.executor.ExecutionTask;
            import matlab.bigdata.internal.lazyeval.ChunkwiseProcessor;
            
            processorFactory = ChunkwiseProcessor.createFactory(...
                obj.getCheckedFunctionHandle(), obj.NumOutputs, ...
                inputFutureMap, isInputReplicated);
            
            processorFactory = obj.addGlobalState(processorFactory);
            
            task = ExecutionTask.createSimpleTask(taskDependencies, processorFactory);
        end
    end
    
    % Methods overridden in the SlicewiseFusableOperation interface.
    methods
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

function expectedSize = iGetExpectedSize(inputs)
% Get the expected size of the outputs based on the inputs.
expectedSize = size(inputs{1});
for ii = 2:numel(inputs)
    sz = size(inputs{ii});
    expectedSize(end + 1 : numel(sz)) = 1;
    expectedSize(sz ~= 1) = sz(sz ~= 1);
end
end

function iVerifyExpectedSize(expectedSize, outputs)
% Verify the outputs match the expected size.
for ii = 1:numel(outputs)
    actualSize = size(outputs{ii});
    if ~isequal(actualSize, expectedSize)
        error(message('MATLAB:bigdata:array:InvalidOutputSize', ...
            ii, mat2str(actualSize), mat2str(expectedSize)));
    end
end
end
