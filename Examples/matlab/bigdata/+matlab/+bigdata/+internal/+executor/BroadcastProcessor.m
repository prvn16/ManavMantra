%BroadcastProcessor
% Data Processor that collects all data and when done, calls a broadcast
% function.
%

%   Copyright 2016 The MathWorks, Inc.

classdef (Sealed) BroadcastProcessor < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired = true;
    end
    
    properties (SetAccess = immutable)
        % The function to call on completion.
        BroadcastFunctionHandle;
        
        % The partition that this processor is executing over.
        Partition;
    end
    
    properties (SetAccess = private)
        % A buffer to collect all of the input before calling broadcast.
        Buffer = [];
    end
        
    
    methods (Static)
        % Create a data processor factory that can be used by the execution
        % environment to construct instances of this class.
        function factory = createFactory(functionHandle)
            factory = @createBroadcastProcessor;
            function dataProcessor = createBroadcastProcessor(partition)
                import matlab.bigdata.internal.executor.BroadcastProcessor;
                dataProcessor = BroadcastProcessor(functionHandle, partition);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function data = process(obj, isLastOfInput, data)
            if obj.IsFinished
                return;
            end
            
            if isempty(obj.Buffer)
                obj.Buffer = data;
            else
                obj.Buffer = [obj.Buffer; data];
            end
            
            if isLastOfInput
                feval(obj.BroadcastFunctionHandle, obj.Partition, obj.Buffer);
                obj.Buffer = [];
                obj.IsFinished = true;
            end
        end
    end
    
    methods (Access = private)
        % Private constructor for factory method.
        function obj = BroadcastProcessor(broadcastFunctionHandle, partition)
            obj.BroadcastFunctionHandle = broadcastFunctionHandle;
            obj.Partition = partition;
        end
    end
end
