%PassthroughProcessor
% Data Processor that simply passes all data forward.
%
% This exists to allow NonPartitionedOperation to do pure communication
% without processing for the case where input arguments are still
% partitioned and require to be moved to a single worker.

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) PassthroughProcessor < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired;
    end
    
    properties (Access = private)
        % A logical scalar that is true if and only if this object is
        % initialized. This is always true if the number of variables being
        % passed through is 1.
        Initialized = false;
        
        % A buffer to hold chunks prior to initialization. This will be
        % empty when Initialized is true.
        Buffer = [];
        
        % A cell array of empty chunks. This exists to pad an input when
        % different inputs contain different number of cells. This will be
        % empty if there is only one variable, and until Initialized is
        % true otherwise.
        EmptyChunks = [];
        
        % The number of outputs emitted by this processor.
        NumOutputs;
    end
    
    methods (Static)
        % Create a data processor factory that can be used by the execution
        % environment to construct instances of this class.
        function factory = createFactory(numInputs, numOutputs)
            if ~nargin
                numInputs = 1;
            end
            if nargin <= 1
                numOutputs = numInputs;
            end
            
            factory = @createPassthroughProcessor;
            function dataProcessor = createPassthroughProcessor(~)
                import matlab.bigdata.internal.lazyeval.PassthroughProcessor;
                
                dataProcessor = PassthroughProcessor(numInputs, numOutputs);
            end
        end
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        %PROCESS Perform the next iteration of processing
        function out = process(obj, isLastOfInput, varargin)
            if ~obj.Initialized
                varargin = obj.initialize(varargin);
                if ~obj.Initialized
                    assert(~all(isLastOfInput), ...
                        'AssertionFailed: PassthroughOperation finished before receiving at least one chunk from each input.');
                    out = cell(0, obj.NumOutputs);
                    return;
                end
            end
            
            if numel(varargin) == 1
                out = varargin{1};
            else
                out = iPaddedHorzcat(varargin, obj.EmptyChunks);
            end
            obj.IsFinished = all(isLastOfInput);
            obj.IsMoreInputRequired = ~isLastOfInput;
        end
    end
    
    methods (Access = private)
        function obj = PassthroughProcessor(numInputs, numOutputs)
            % Private constructor for factory method.
            
            obj.IsMoreInputRequired = true(1, numInputs);
            if numInputs == 1
                % When there is only one variable, we do not need to store
                % an empty chunk of it because we do not perform padding in
                % this case.
                obj.Initialized = true;
            end
            obj.NumOutputs = numOutputs;
        end
        
        function input = initialize(obj, input)
            %INITIALIZE Attempt initialization of constant state of the
            %data processor. If there is not enough input to do this, this
            %will return after setting the IsMoreInputRequired correctly.
            
            if ~isempty(obj.Buffer)
                input = cellfun(@vertcat, obj.Buffer, input, 'UniformOutput', false);
                obj.Buffer = [];
            end
            
            numChunks = cellfun(@(x) size(x, 1), input);
            if any(numChunks == 0)
                obj.IsMoreInputRequired = (numChunks == 0);
                obj.Buffer = input;
                return;
            else
                obj.EmptyChunks = cellfun(@iGetEmptyChunk, input, 'UniformOutput', false);
                obj.Initialized = true;
            end
        end
    end
end

function out = iGetEmptyChunk(in)
% Get an empty chunk given an input to this data processor. The input will
% be a cell array of chunks.
import matlab.bigdata.internal.util.indexSlices;
out = cellfun(@(x) indexSlices(x, []), in(1, :), 'UniformOutput', false);
end

function out = iPaddedHorzcat(inputs, emptyChunks)
% A version of horzcat that pads the inputs if they are not the same
% length.

numChunks = cellfun(@(x) size(x, 1), inputs);
if ~all(numChunks == numChunks(1))
    maxNumChunks = max(numChunks);
    for ii = 1:numel(inputs)
        if numChunks(ii) ~= maxNumChunks
            inputs{ii}(end + 1 : maxNumChunks, :) = repmat(emptyChunks{ii}, maxNumChunks - numChunks(ii), 1);
        end
    end
end
out = [inputs{:}];
end
