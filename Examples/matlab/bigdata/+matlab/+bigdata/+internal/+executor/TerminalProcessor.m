%TerminalProcessor
% A processor that will ensure all of it's direct dependencies are finished.
%
% This will perform no actual processing. This will simply return true to
% IsMoreInputRequired for all non-finished inputs.
%

%   Copyright 2015-2016 The MathWorks, Inc.

classdef TerminalProcessor < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired;
    end
    
    properties (SetAccess = immutable)
        % The expected number of inputs.
        NumInputs;
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function data = process(obj, isLastOfInput, varargin)
            obj.IsFinished = all(isLastOfInput);
            obj.IsMoreInputRequired = ~isLastOfInput;
            data = [];
        end
    end
    
    methods (Static)
        % Create a data processor factory that can be used by the execution
        % environment to construct instances of this class.
        function factory = createFactory(numInputs)
            factory = @createTerminalProcessor;
            function processor = createTerminalProcessor(~)
                import matlab.bigdata.internal.executor.TerminalProcessor;
                processor = TerminalProcessor(numInputs);
            end
        end
    end
    
    methods (Access = private)
        % Private constructor for the factory method.
        function obj = TerminalProcessor(numInputs)
            obj.NumInputs = numInputs;
            obj.IsMoreInputRequired = true(1, numInputs);
        end
    end
end
