%DecellificationProcessorDecorator
% Data Processor that decells each input.
%

%   Copyright 2016 The MathWorks, Inc.

classdef (Sealed) DecellificationProcessorDecorator < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired = true;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % The underlying processor that performs the actual processing.
        UnderlyingProcessor;
        
        % The number of outputs from the function handle.
        NumOutputs;
    end
    
    methods (Static)
        function factory = wrapFactory(underlyingFactory, numOutputs)
            % Wrap the provided data processor in a decorator that decellifies
            % the input.
            
            factory = @createDecellficationProcessorDecorator;
            function dataProcessor = createDecellficationProcessorDecorator(varargin)
                import matlab.bigdata.internal.lazyeval.DecellificationProcessorDecorator;
                dataProcessor = feval(underlyingFactory, varargin{:});
                dataProcessor = DecellificationProcessorDecorator(dataProcessor, numOutputs);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function varargout = process(obj, isLastOfDependencies, in)
            if isempty(in)
                varargout = {cell(0, obj.NumOutputs), zeros(0, 1)};
            else
                in = matlab.bigdata.internal.util.vertcatCellContents(in);
                [varargout{1 : nargout}] = obj.UnderlyingProcessor.process(false, in);
            end
            obj.IsFinished = isLastOfDependencies;
            obj.IsMoreInputRequired = ~isLastOfDependencies;
        end
    end
    
    methods (Access = private)
        % Private constructor for factory method.
        function obj = DecellificationProcessorDecorator(dataProcessor, numOutputs)
            obj.UnderlyingProcessor = dataProcessor;
            obj.NumOutputs = numOutputs;
        end
    end
end
