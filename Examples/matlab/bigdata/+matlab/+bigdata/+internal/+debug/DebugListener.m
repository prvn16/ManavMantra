%DebugListener
% A collection of function handles corresponding to events that can occur
% during tall array evaluation.
%
% The parent DebugSession has no lifetime ownership of this object. Once
% all listeners of a DebugSession fall out of scope or are deleted, the
% session ends.

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) DebugListener < handle & matlab.mapreduce.internal.SoftReferableMixin
    properties
        % Function handle invoked at the beginning of execution.
        ExecuteBeginFcn = @(executionId, taskGraph) [];
        
        % Function handle invoked at the end of execution.
        ExecuteEndFcn = @(executionId, taskGraph) [];
        
        % Function handle invoked on creation of a DataProcessor factory.
        ProcessorFactoryCreatedFcn = @(processorFactory) [];
        
        % Function handle invoked on destruction of a DataProcessor factory.
        ProcessorFactoryDestroyedFcn = @(processorFactory) [];

        % Function handle invoked on creation of a DataProcessor.
        ProcessorCreatedFcn = @(processor) [];
        
        % Function handle invoked on destruction of a DataProcessor.
        ProcessorDestroyedFcn = @(processor) [];
        
        % Function handle invoked on entry of DataProcessor/process.
        ProcessBeginFcn = @(processor, invokeData) [];
        
        % Function handle invoked if error during DataProcessor/process.
        ProcessErrorFcn = @(processor, invokeData) [];
        
        % Function handle invoked on successful return of DataProcessor/process.
        ProcessReturnFcn = @(processor, invokeData) [];
        
        % Function handle invoked on each call to the Output Handler.
        OutputFcn = @(outputHandler, outputData) [];
    end
    
    methods (Access = {?matlab.bigdata.internal.debug.DebugSession})
        function obj = DebugListener()
            % Private constructor for DebugSession.
        end
    end
end
