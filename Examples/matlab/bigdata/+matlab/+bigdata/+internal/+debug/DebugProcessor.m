%DebugProcessor
% A decorator for instances of the DataProcessor interface that both binds
% additional metadata to the data processor as well as generates events
% during processing.

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) DebugProcessor < matlab.bigdata.internal.executor.DataProcessor
    properties (SetAccess = immutable)
        % A unique ID string for this processor.
        Id
        
        % The underlying DataProcessor instance.
        Processor;
        
        % The currently evaluating partition.
        Partition;
        
        % Number of output partitions specified by the framework.
        NumOutputPartitions;
        
        % An ID string attached to all processor and processor factories
        % within the same execute invocation.
        ExecutionId;
        
        % The ExecutionTask that constructed this data processor.
        Task;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % An instance of DebugSession that will manage all listeners of
        % debug events.
        Session;
    end
    
    properties (Access = private)
        % Number of times the process methods has been invoked.
        NumProcessInvocations = 0;
    end
    
    properties (Access = private, Constant)
        % The means by which this class receives unique IDs.
        IdFactory = matlab.bigdata.internal.util.UniqueIdFactory('DebugProcessor');
    end
    
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished;
        IsMoreInputRequired;
    end
    
    methods
        function obj = DebugProcessor(processor, partition, numOutputPartitions, task, executionId, session)
            % Construct a DebugProcessor that wraps the given processor.
            obj.Id = obj.IdFactory.nextId();
            obj.Processor = processor;
            obj.Partition = partition;
            obj.NumOutputPartitions = numOutputPartitions;
            obj.Task = task;
            obj.ExecutionId = executionId;
            obj.Session = session;
            
            obj.updateState();
            
            obj.Session.notifyDebugEvent('ProcessorCreated', obj);
        end
        
        function delete(obj)
            if isvalid(obj.Session)
                obj.Session.notifyDebugEvent('ProcessorDestroyed', obj);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        %PROCESS Process the next chunk of data.
        function [varargout] = process(obj, isLastOfInputs, varargin)
            import matlab.bigdata.internal.debug.ProcessInvokeData;
            
            obj.NumProcessInvocations = obj.NumProcessInvocations + 1;
            
            invokeData = ProcessInvokeData;
            invokeData.InvokeIndex = obj.NumProcessInvocations;
            invokeData.IsLastChunk = isLastOfInputs;
            invokeData.Inputs = varargin;
            obj.Session.notifyDebugEvent('ProcessBegin', obj, invokeData);
            
            try
                [varargout{1 : nargout}] = process(obj.Processor, isLastOfInputs, varargin{:});
                invokeData.Output = varargout{1};
                if nargout >= 2
                    invokeData.OutputPartitionIndices = varargout{2};
                end
            catch err
                invokeData.Error = err;
                obj.Session.notifyDebugEvent('ProcessError', obj, invokeData);
                rethrow(err);
            end
            obj.updateState();

            obj.Session.notifyDebugEvent('ProcessReturn', obj, invokeData);
        end
    end
    
    methods (Access = private)
        function updateState(obj)
            % Update the public visible state of this object to mirror the
            % wrapped DataProcessor instance.
            obj.IsFinished = obj.Processor.IsFinished;
            obj.IsMoreInputRequired = obj.Processor.IsMoreInputRequired;
        end
    end
end
