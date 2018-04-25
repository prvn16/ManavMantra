%BufferedZipProcessDecorator
% A decorator of the DataProcessor interface that buffers the input so that
% the underlying processor is only called with a set of chunks that are either
% singleton or the same size in the tall dimension.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) BufferedZipProcessDecorator < matlab.bigdata.internal.executor.DataProcessor
    % Properties overridden in the DataProcessor interface.
    properties (SetAccess = private)
        IsFinished = false;
        IsMoreInputRequired;
    end
    
    properties (GetAccess = private, SetAccess = immutable)
        % The underlying processor that performs the actual processing.
        UnderlyingProcessor;
        
        % The number of outputs from the function handle.
        NumOutputs;
        
        % The buffer for all input.
        InputBuffer;
        
        % The minimum number of input parameter slices to pass to the
        % underlying processor in any one interaction. If this is not
        % possible, the underlying processor is called with empties.
        MinNumSlices = 0;
        
        % The maximum number of input parameter slices to pass to the
        % underlying processor in any one interaction. All remaining slices
        % are left in the buffer.
        MaxNumSlices = Inf;
        
        % A logical scalar that specifies if this processor should allow
        % singleton expansion in the tall dimension.
        AllowTallDimExpansion = true;
        
        % A function handle that is called when the given inputs are
        % incompatible. This will be called with syntax:
        %
        %  errorHandler(errObj, isTooShortVector, isTooLongVector)
        %
        % Where:
        %  - errObj is the error to throw.
        %  - isTooShortVector is a logical vector that is true for each
        %  input if that input was too short.
        %  - isTooLongVector is a logical vector that is true for each
        %  input if that input was too long.
        IncompatibleErrorHandler;
    end
    
    properties (Access = private)
        % A logical scalar that is set to true once this object is
        % initialized and has begun processing data.
        IsInitialized = false;
    end
    
    % Methods overridden in the DataProcessor interface.
    methods
        function [data, varargout] = process(obj, isLastOfInputsVector, varargin)
            if obj.IsFinished
                data = cell(0, obj.NumOutputs);
                varargout = {zeros(0, 1)};
                return;
            end
            
            inputBuffer = obj.InputBuffer;
            inputBuffer.add(isLastOfInputsVector, varargin{:});
            isInputTooShortVector = isLastOfInputsVector & ~inputBuffer.IsInputSingleSlice ...
                & inputBuffer.NumBufferedSlices ~= inputBuffer.LargestNumBufferedSlices;
            if any (isInputTooShortVector)
                isInputTooLongVector = inputBuffer.NumBufferedSlices == inputBuffer.LargestNumBufferedSlices;
                if all(inputBuffer.IsInputSinglePartition)
                    % We can be certain in this case that the two arrays
                    % have an incompatible size in the tall dimension.
                    
                    obj.throwSizeError(isInputTooShortVector, isInputTooLongVector);
                else
                    % Otherwise this might just be a case of different
                    % partitioning.
                    err = MException(message('MATLAB:bigdata:array:IncompatibleTallIndexing'));
                    obj.throwIncompatibleError(err, isInputTooShortVector, isInputTooLongVector);
                end
            end
            
            % There are some first time checks that we want to do once the
            % input buffer has enough data to determine the types of input
            % we are about to receive.
            if ~obj.IsInitialized
                % We require to know which inputs are single slice before
                % we can do the first time checks.
                if ~inputBuffer.HasDeterminedSingleSliceInputs
                    data = cell(0, obj.NumOutputs);
                    varargout = {zeros(0, 1)};
                    return;
                end
                
                % This is to guard against the situation where the size of
                % one partition in a partitioned tall array just so happens
                % to match the size of a non-partitioned array. Examples
                % include the output of a reduction as well as local arrays.
                if any(~inputBuffer.IsInputSinglePartition)
                    isInputInvalidBroadcastVector = inputBuffer.IsInputSinglePartition & ~inputBuffer.IsInputSingleSlice;
                    if any(isInputInvalidBroadcastVector)
                        obj.throwSizeError(isInputInvalidBroadcastVector, ~inputBuffer.IsInputSinglePartition);
                    end
                end
                
                if ~obj.AllowTallDimExpansion && any(~inputBuffer.IsInputSingleSlice) && any(inputBuffer.IsInputSingleSlice)
                    obj.throwSizeError(inputBuffer.IsInputSingleSlice, ~inputBuffer.IsInputSingleSlice);
                end
                
                obj.IsInitialized = true;
            end
            
            numSlices = min(inputBuffer.NumAvailableCompleteSlices, obj.MaxNumSlices);
            if ~all(isLastOfInputsVector) && numSlices < obj.MinNumSlices
                data = cell(0, obj.NumOutputs);
                varargout = {zeros(0, 1)};
                return;
            end
            
            data = inputBuffer.getCompleteSlices(numSlices);
            isActualLastOfInputsVector = isLastOfInputsVector & (inputBuffer.IsInputSingleSlice | inputBuffer.NumBufferedSlices == 0);
            [data, varargout{1:nargout - 1}] = obj.UnderlyingProcessor.process(isActualLastOfInputsVector, data{:});
            obj.IsFinished = obj.UnderlyingProcessor.IsFinished;
            
            % This logic exists in order to ensure inputs arrive at similar
            % data rates.
            %
            % This object indicates that it requires more data for a given
            % input if and only if the buffer for that input contains less
            % data than would be needed to consume all of the data from all
            % buffers, or to reach MaxNumSlices if that is smaller.
            requiredBufferSize = inputBuffer.LargestNumBufferedSlices;
            requiredBufferSize = min(requiredBufferSize, obj.MaxNumSlices);
            requiredBufferSize = max(requiredBufferSize, max(1, obj.MinNumSlices));
            
            isBufferTooShortVector = inputBuffer.NumBufferedSlices < requiredBufferSize;
            isMoreInputRequiredVector = ~isLastOfInputsVector & isBufferTooShortVector;
            
            % We have to map from operation inputs back to upstream
            % dependencies because this property is in terms of upstream
            % dependencies.
            obj.IsMoreInputRequired = ~obj.IsFinished & isMoreInputRequiredVector;
        end
    end
    
    methods (Static)
        % Wrap a data processor factory to give a factory to a processor
        % that has the same underlying action but which buffers the input
        % and ensures non-singleton inputs are passed in equal sized
        % chunks.
        %
        % Syntax:
        %    factory = BufferedZipProcessDecorator.wrapFactory(...
        %       numOutputs, isInputReplicated, name1, value1, ..)
        %
        % Where the name-value pairs are:
        %  - MinNumSlices - The minimum number of slices per chunk. If
        %      there aren't enough slices, the underlying processor is not
        %      called unless this is the last chunk.
        %  - MaxNumSlices - The maximum number of slices per chunk.
        %  - AllowsSingleton - Whether inputs that are singleton in the
        %      tall dimension are allowed.
        %  - IncompatibleErrorHandler - A function handle that will be
        %  invoked on any incompatible size error. If unspecified, a
        %  default handler is used.
        function factory = wrapFactory(dataProcessorFactory, numOutputs, isInputReplicated, varargin)
            factory = @createProcessor;
            options = iParseFactoryOptions(varargin{:});
            function processor = createProcessor(partition, varargin)
                import matlab.bigdata.internal.lazyeval.BufferedZipProcessDecorator;
                isInputSinglePartition = isInputReplicated | (partition.NumPartitions == 1);
                processor = feval(dataProcessorFactory, partition, varargin{:});
                processor = BufferedZipProcessDecorator(processor, numOutputs, isInputSinglePartition, options);
            end
        end
    end
    
    methods (Access = private)
        % Private constructor for the wrap construct method.
        function obj = BufferedZipProcessDecorator(underlyingProcessor, numOutputs, isInputSinglePartition, options)
            import matlab.bigdata.internal.lazyeval.InputBuffer;
            obj.UnderlyingProcessor = underlyingProcessor;
            obj.NumOutputs = numOutputs;
            obj.InputBuffer = InputBuffer(numel(isInputSinglePartition), isInputSinglePartition);
            
            obj.IsMoreInputRequired = true(1, numel(isInputSinglePartition));
            
            obj.MinNumSlices = options.MinNumSlices;
            obj.MaxNumSlices = options.MaxNumSlices;
            obj.AllowTallDimExpansion = options.AllowTallDimExpansion;
            obj.IncompatibleErrorHandler = options.IncompatibleErrorHandler;
        end
    end
    
    methods (Access = private)
        % Helper function that ensures the right error is thrown based on
        % whether this operation supports singleton expansion in the tall
        % dimension.
        function throwSizeError(obj, isTooShortVector, isTooLongVector)
            if obj.AllowTallDimExpansion
                err = MException(message('MATLAB:bigdata:array:IncompatibleTallSize'));
            else
                err = MException(message('MATLAB:bigdata:array:IncompatibleTallStrictSize'));
            end
            obj.throwIncompatibleError(err, isTooShortVector, isTooLongVector)
        end
        
        % Use the Incompatible Error Handler to throw the appropriate error
        % for an incompatible situation.
        function throwIncompatibleError(obj, err, isTooShortVector, isTooLongVector)
            feval(obj.IncompatibleErrorHandler, err, isTooShortVector, isTooLongVector);
        end
    end
end

% Parse the optional input parameters of the wrapFactory static method.
function options = iParseFactoryOptions(varargin)
if isstruct(varargin{1})
    errorStack = varargin{1};
    varargin(1) = [];
end
p = inputParser;
p.addParameter('MinNumSlices', 0);
p.addParameter('MaxNumSlices', Inf);
p.addParameter('AllowTallDimExpansion', true);
p.addParameter('IncompatibleErrorHandler', []);
p.parse(varargin{:});
options = p.Results;
if isempty(options.IncompatibleErrorHandler)
    options.IncompatibleErrorHandler = @(err, ~, ~) iDefaultIncompatibleErrorHandler(err, errorStack);
end
end

% By default, build a user-visible error with the associated submission
% stack.
function iDefaultIncompatibleErrorHandler(err, submissionStack)
import matlab.bigdata.BigDataException;
err = BigDataException.build(err);
err = attachSubmissionStack(err, submissionStack);
updateAndRethrow(err);
end
