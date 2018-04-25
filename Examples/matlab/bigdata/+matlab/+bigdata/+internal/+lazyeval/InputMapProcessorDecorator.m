%InputMapProcessorDecorator
% A decorator of the DataProcessor interface that converts the input from
% the space of input dependencies to the space of function input arguments.
%

%   Copyright 2016 The MathWorks, Inc.

classdef (Sealed) InputMapProcessorDecorator < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired;
    end
    
    properties (SetAccess = immutable)
        % The underlying processor that performs the actual processing.
        UnderlyingProcessor;
        
        % An object that represents how to convert from dependency input to
        % function handle input.
        InputFutureMap;
    end
    
    methods (Static)
        % Wrap a data processor factory to give a factory to a processor
        % that has the same underlying action but which the inputs are the
        % dependency inputs instead of the actual inputs.
        function factory = wrapFactory(dataProcessorFactory, inputFutureMap)
            factory = @createProcessor;
            function dataProcessor = createProcessor(varargin)
                import matlab.bigdata.internal.lazyeval.InputMapProcessorDecorator;
                
                dataProcessor = dataProcessorFactory(varargin{:});
                dataProcessor = InputMapProcessorDecorator(dataProcessor, inputFutureMap);
            end
        end
    end
    
     % Methods overridden in the DataProcessor interface.
    methods
        %PROCESS Process the next chunk of data.
        function [data, varargout] = process(obj, isLastOfInputsVector, varargin)
            isLastOfInputsVector = obj.InputFutureMap.mapScalars(isLastOfInputsVector);
            varargin = obj.InputFutureMap.mapData(varargin);
            
            [data, varargout{1:nargout - 1}] = obj.UnderlyingProcessor.process(isLastOfInputsVector, varargin{:});
            obj.updateState();
        end
    end
    
    methods (Access = private)
        function obj = InputMapProcessorDecorator(underlyingProcessor, inputFutureMap)
            % Private constructor for the static build function.
            
            obj.UnderlyingProcessor = underlyingProcessor;
            obj.InputFutureMap = inputFutureMap;
            obj.updateState();
        end
        
        function updateState(obj)
            % Update the DataProcessor public properties to correspond with
            % the equivalent of the underlying processor.
            
            obj.IsFinished = obj.UnderlyingProcessor.IsFinished;
            obj.IsMoreInputRequired = obj.InputFutureMap.reverseMapLogicals(obj.UnderlyingProcessor.IsMoreInputRequired);
        end
    end
end
