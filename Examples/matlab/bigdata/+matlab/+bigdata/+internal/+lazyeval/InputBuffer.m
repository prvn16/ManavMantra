%InputBuffer
% A helper class that acts as a multi-buffer for the input data to be
% passed to operations by the data processor implementations.
%
% This contains the logic to cache inputs from multiple sources until they
% are required by the current DataProcessor.
%
% This also contains the logic necessary to do balancing on the data rates
% of inputs. As soon as any back-end does caching, there is the possibility
% that two different inputs to a data processor will be calculated/read at
% different rates. Several data processors require to operate on slices
% from multiple inputs in lock-step. This class assists with this
% requirement.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) InputBuffer < handle
    properties (SetAccess = immutable)
        % This contains a flag for each input that describes whether that
        % input consists of a single partition. Effectively, will we see
        % all of that input.
        IsInputSinglePartition;
    end
    
    properties (SetAccess = private)
        % The internal buffer held by this instance.
        Buffer;
        
        % A list of logical values.
        IsBufferInitialized;
        
        % The number of slices in the buffer of each input.
        NumBufferedSlices;
        
        % A flag that is true if and only if this class has determined for
        % all inputs whether each input is guaranteed to be single slice or
        % guaranteed not to be.
        HasDeterminedSingleSliceInputs = false;
        
        % A logical per input that describes whether it is
        % guaranteed that the given input consists of only a single slice.
        IsInputSingleSlice;
    end
    
    properties (Dependent, SetAccess = private)
        % The current NumBufferedSlices for the largest non-singleton buffer.
        % This ignores buffers for inputs that are known to be single slice
        % and have finished.
        LargestNumBufferedSlices;
        
        % The maximum number of slices such that all buffered inputs
        % contain at least this many slices.
        NumAvailableCompleteSlices;
    end
    
    methods
        % The main constructor.
        function obj = InputBuffer(numInputs, isInputSinglePartition)
            assert (numInputs == numel(isInputSinglePartition), ...
                'Assertion failed: Expected number of inputs to match size of isInputSinglePartition.');
            obj.IsInputSinglePartition = isInputSinglePartition(:)';
            
            obj.Buffer = cell(1, numInputs);
            obj.IsBufferInitialized = false(1, numInputs);
            obj.NumBufferedSlices = zeros(1, numInputs);
            
            obj.IsInputSingleSlice = false(1, numInputs);
        end
        
        function val = get.LargestNumBufferedSlices(obj)
            bufferSizes = obj.NumBufferedSlices(~obj.IsInputSingleSlice);
            if isempty(bufferSizes)
                val = 0;
            else
                val = max(bufferSizes);
            end
        end
        
        function val = get.NumAvailableCompleteSlices(obj)
            if ~obj.HasDeterminedSingleSliceInputs
                val = 0;
                return;
            end
            
            val = min(obj.NumBufferedSlices(~obj.IsInputSingleSlice));
            if isempty(val)
                val = 0;
            end
        end
        
        % Demux and then add a collection of multiplexed inputs to the buffer.
        function add(obj, isLastOfInputs, varargin)
            % To differentiate between no data and [], each input is a cell
            % array with each cell containing chunks of the data.
            assert (numel(varargin) == numel(isLastOfInputs), ...
                'Assertion failed: Number of inputs must match size of isLastOfInputs.');
            assert (numel(varargin) == numel(obj.Buffer), ...
                'Assertion failed: Number of inputs must match number of buffers.');
            for ii = 1:numel(obj.Buffer)
                if obj.IsBufferInitialized(ii)
                    obj.Buffer{ii} = vertcat(obj.Buffer{ii}, varargin{ii}{:});
                elseif ~isempty(varargin{ii})
                    obj.Buffer{ii} = matlab.bigdata.internal.util.vertcatCellContents(varargin{ii});
                    obj.IsBufferInitialized(ii) = true;
                end
                obj.NumBufferedSlices(ii) = size(obj.Buffer{ii}, 1);
            end
            
            % This object needs to determine if a given input contains only
            % a single slice for the purposes of singleton expansion. It
            % does this by waiting until either isLastOfInputs is true or
            % more than a single slice of data is received.
            if ~obj.HasDeterminedSingleSliceInputs
                % Until we have determined all the single slice inputs, we
                % need to keep updating the IsInputSingleSlice property to
                % reflect the ones we do know about.
                isGuaranteedSingleSliceVector = obj.IsInputSinglePartition & isLastOfInputs & obj.NumBufferedSlices == 1;
                obj.IsInputSingleSlice = isGuaranteedSingleSliceVector;
                
                isSingleSliceDeterminedVector = isLastOfInputs | obj.NumBufferedSlices > 1 | ~obj.IsInputSinglePartition;
                obj.HasDeterminedSingleSliceInputs = all(obj.IsBufferInitialized & isSingleSliceDeterminedVector);
            end
        end
        
        % Get all inputs in the buffer.
        function inputs = getAll(obj)
            inputs = get(obj, inf);
        end
        
        % Get the first slices of the buffer for each input such that each
        % non-singleton input has the same number of slices.
        function [inputs, numSlices] = getCompleteSlices(obj, maxNumSlices)
            numSlices = min(obj.NumBufferedSlices(~obj.IsInputSingleSlice));
            if nargin >= 2
                numSlices = min(numSlices, maxNumSlices);
            end
            if isempty(numSlices)
                numSlices = 0;
            end
            inputs = get(obj, numSlices);
        end
        
        % Get the first n slices of the buffer of each input.
        function inputs = get(obj, n)
            assert (all(obj.IsBufferInitialized), ...
                'Assertion failed: Attempted to get slices of input before InputBuffer is fully initialized.');
            
            inputs = cell(size(obj.Buffer));
            for ii = 1:numel(inputs)
                if obj.IsInputSingleSlice(ii)
                    inputs{ii} = obj.Buffer{ii};
                else
                    [inputs{ii}, obj.Buffer{ii}] = iSplit(obj.Buffer{ii}, n);
                    obj.NumBufferedSlices(ii) = size(obj.Buffer{ii}, 1);
                end
            end
        end
    end
end

% Helper function for splitting an input buffer into the first n elements.
function [out, buffer] = iSplit(buffer, numSlices)
import matlab.bigdata.internal.util.indexSlices;
sz = size(buffer);
numSlices = min(numSlices, sz(1));

if numSlices == sz(1)
    out = buffer;
    buffer = indexSlices(buffer, []);
else
    out = indexSlices(buffer, 1:numSlices);
    buffer = indexSlices(buffer, numSlices + 1 : sz(1));
end
end
