%DebugProcessorFactory
% Helper class for DebugSerialExecutor that wraps an individual data
% processor factory with both additional metadata and events.

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) DebugProcessorFactory < handle
    properties (SetAccess = immutable)
        % The underlying DataProcessorFactory object itself.
        Factory;
        
        % The ExecutionTask corresponding to this data processor factory.
        Task;
        
        % An ID string attached to all processor and processor factories
        % within the same execute invocation.
        ExecutionId;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % An instance of DebugSession that will manage all listeners of
        % debug events.
        Session;
    end

    methods
        function obj = DebugProcessorFactory(factory, task, executionId, session)
            % Construct an instance of DebugProcessorFactory that wraps
            % around the given data processor factory.
            
            obj.Factory = factory;
            obj.Task = task;
            obj.ExecutionId = executionId;
            obj.Session = session;
            
            obj.Session.notifyDebugEvent('ProcessorFactoryCreated', obj);
        end
        
        function processor = feval(obj, partition, varargin)
            % Construct a new data processor.
            import matlab.bigdata.internal.debug.DebugProcessor;
            
            processor = feval(obj.Factory, partition, varargin{:});
            
            numOutputPartitions = nan;
            if nargin >= 3
                numOutputPartitions = varargin{1};
            end
            processor = DebugProcessor(processor, partition, numOutputPartitions, obj.Task, obj.ExecutionId, obj.Session);
        end
        
        function delete(obj)
            if isvalid(obj.Session)
                obj.Session.notifyDebugEvent('ProcessorFactoryDestroyed', obj);
            end
        end
    end
end
