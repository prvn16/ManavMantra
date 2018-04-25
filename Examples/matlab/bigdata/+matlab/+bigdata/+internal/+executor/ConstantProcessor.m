%ConstantProcessor
% Data Processor that simply returns a set of constants.
%
% See LazyTaskGraph for a general description of input and outputs.
% Specifically, this does not expect to receive any inputs and will emit a
% 1 x NumConstants cell array where each cell contains a constant from the
% Constants property.
%

%   Copyright 2015-2016 The MathWorks, Inc.

classdef (Sealed) ConstantProcessor < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired = logical.empty;
    end
    
    properties (SetAccess = private)
        % The single chunk to be emitted by this data processor.
        Output;
    end
    
    methods (Static)
        % Create a data processor factory that can be used by the execution
        % environment to construct instances of this class.
        function factory = createFactory(output)
            factory = @createConstantProcessor;
            function dataProcessor = createConstantProcessor(~)
                import matlab.bigdata.internal.executor.ConstantProcessor;
                dataProcessor = ConstantProcessor(output);
            end
        end
        
        % Create a data processor factory from a function handle that
        % generates or retrieves the constant.
        function factory = createFactoryFromFunction(functionHandle)
            factory = @createConstantProcessorFromFunction;
            function dataProcessor = createConstantProcessorFromFunction(~)
                import matlab.bigdata.internal.executor.ConstantProcessor;
                output = feval(functionHandle);
                dataProcessor = ConstantProcessor(output);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function data = process(obj, ~)
            data = obj.Output;
            if ~obj.IsFinished
                obj.Output = matlab.bigdata.internal.util.calculateEmptyChunk(obj.Output);
                obj.IsFinished = true;
            end
        end
    end
    
    methods (Access = private)
        % Private constructor for factory method.
        function obj = ConstantProcessor(output)
            obj.Output = output;
        end
    end
end
