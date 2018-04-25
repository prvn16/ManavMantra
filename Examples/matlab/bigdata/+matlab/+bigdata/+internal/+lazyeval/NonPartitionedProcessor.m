%NonPartitionedProcessor
% Data Processor that applies a function handle to the vertical
% concatenation of all input.
%
% This will buffer all input until upstream data processors have completed,
% then apply a function handle to the vertical concatenation of the data.
%
% See LazyTaskGraph for a general description of input and outputs.
% Specifically, this will emit a single 1 x NumOutputs cell array, where
% each cell contains the full output of the corresponding operation output.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) NonPartitionedProcessor < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired;
    end
    
    properties (SetAccess = immutable)
        % The slice-wise function handle.
        FunctionHandle;
        
        % The number of outputs from the function handle.
        NumOutputs;
        
        InputFutureMap
        
        % The input buffer.
        InputBuffer;
    end
    
    methods (Static)
        % Create a data processor factory that can be used by the execution
        % environment to construct instances of this class.
        function factory = createFactory(functionHandle, numOutputs, inputFutureMap)
            
            factory = @createNonPartitionedProcessor;
            function dataProcessor = createNonPartitionedProcessor(~)
                import matlab.bigdata.internal.lazyeval.NonPartitionedProcessor;
                dataProcessor = NonPartitionedProcessor(copy(functionHandle), numOutputs, inputFutureMap);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function data = process(obj, isLastOfDependencies, varargin)
            if obj.IsFinished
                data = cell(0, obj.NumOutputs);
                return;
            end
            
            isLastOfInputs = obj.InputFutureMap.mapScalars(isLastOfDependencies);
            functionInputs = obj.InputFutureMap.mapData(varargin);
            inputBuffer = obj.InputBuffer;
            inputBuffer.add(isLastOfInputs, functionInputs{:});
            
            obj.IsFinished = all(isLastOfInputs);
            if obj.IsFinished
                functionInputs = inputBuffer.getAll();
                for ii = 1 : numel(functionInputs)
                    % Flatten unknowns. We can do this because we have the
                    % entire array at this point.
                    if matlab.bigdata.internal.UnknownEmptyArray.isUnknown(functionInputs{ii})
                        functionInputs{ii} = getSample(functionInputs{ii});
                    end
                end
                [data{1:obj.NumOutputs}] = feval(obj.FunctionHandle, functionInputs{:});
            else
                data = cell(0, obj.NumOutputs);
            end
            obj.IsMoreInputRequired = ~isLastOfDependencies;
        end
    end
    
    methods (Access = private)
        % Private constructor for factory method.
        function obj = NonPartitionedProcessor(functionHandle, numOutputs, inputFutureMap)
            import matlab.bigdata.internal.lazyeval.InputBuffer;
            obj.FunctionHandle = functionHandle;
            obj.NumOutputs = numOutputs;
            obj.InputFutureMap = inputFutureMap;
            
            isInputSinglePartition = true(1, inputFutureMap.NumOperationInputs);
            obj.InputBuffer = InputBuffer(inputFutureMap.NumOperationInputs, isInputSinglePartition);
            
            obj.IsMoreInputRequired = true(1, inputFutureMap.NumDependencies);
        end
    end
end
