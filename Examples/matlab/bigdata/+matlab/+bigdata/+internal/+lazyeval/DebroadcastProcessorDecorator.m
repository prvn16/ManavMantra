%DebroadcastProcessorDecorator
% Data Processor decorator that transforms each broadcast input into a
% partitioned input. This is done by passing through the full broadcasted
% data in partition 1 only, passing empties for all other partitions.
%
% Note, this does not generate a useful partitioning since all partitions
% except the first will be empty. This exists only to support fusing
% clientfun or gather with aggregates. Specifically, this class ensures
% that broadcasted inputs aren't replicated by the number of partitions
% when their ultimate destination is the client.
%

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) DebroadcastProcessorDecorator < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % The underlying DataProcessor that this decorator wraps around.
        UnderlyingProcessor
        
        % An array of indices to the inputs that are in broadcast state.
        BroadcastInputIndices
    end
    
    properties (Access = private)
        % An array of logical values that represent if the input has
        % already been skipped.
        InputHasBeenSkipped;
    end
    
    methods (Static)
        % Create a data processor factory that can be used by the execution
        % environment to construct instances of this class.
        function factory = wrapFactory(underlyingProcessorFactory, isInputReplicated)
            % This decorator is a no-op if:
            %  - None of the inputs are broadcast.
            %  - All of the inputs are broadcast, in which case there will
            %  only be a single partition.
            if any(isInputReplicated) && ~all(isInputReplicated)
                filterIndices = find(isInputReplicated);
                factory = @createDebroadcastProcessorDecorator;
            else
                factory = underlyingProcessorFactory;
            end
            
            function processor = createDebroadcastProcessorDecorator(partition)
                import matlab.bigdata.internal.lazyeval.DebroadcastProcessorDecorator;
                
                processor = feval(underlyingProcessorFactory, partition);
                % This decorator is no-op for partition 1.
                if partition.PartitionIndex ~= 1
                    processor = DebroadcastProcessorDecorator(processor, filterIndices);
                end
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        %PROCESS Perform the next iteration of processing
        function out = process(obj, isLastOfInput, varargin)
            import matlab.bigdata.internal.util.indexSlices;
            
            for idx = obj.BroadcastInputIndices(:)'
                if ~isempty(varargin{idx})
                    if obj.InputHasBeenSkipped(idx)
                        varargin{idx} = varargin{idx}([], :);
                    else
                        varargin{idx} = cellfun(@(x) {indexSlices(x, [])}, varargin{idx}(1, :));
                        obj.InputHasBeenSkipped(idx) = true;
                    end
                end
            end
            isLastOfInput = isLastOfInput | obj.InputHasBeenSkipped;
            
            out = obj.UnderlyingProcessor.process(isLastOfInput, varargin{:});
            obj.updateState();
        end
    end
    
    methods (Access = private)
        function obj = DebroadcastProcessorDecorator(underlyingProcessor, broadcastInputIndices)
            % Private constructor for factory method.
            
            obj.UnderlyingProcessor = underlyingProcessor;
            obj.BroadcastInputIndices = broadcastInputIndices;
            obj.InputHasBeenSkipped = false(size(underlyingProcessor.IsMoreInputRequired));
            obj.updateState();
        end
        
        function updateState(obj)
            % Update the DataProcessor public properties to correspond with
            % the equivalent of the underlying processor.
            
            obj.IsFinished = obj.UnderlyingProcessor.IsFinished;
            obj.IsMoreInputRequired = obj.UnderlyingProcessor.IsMoreInputRequired & ~obj.InputHasBeenSkipped;
        end
    end
end
