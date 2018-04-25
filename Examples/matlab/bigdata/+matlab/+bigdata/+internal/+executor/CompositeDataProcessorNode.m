%CompositeDataProcessorNode
% Represents one node of the graph of processors inside a
% CompositeDataProcessor.
%
% TODO(g1530319): Change DataProcessor API to remove the need for this class.
% This class exists to bridge between the DataProcessor API and
% CompositeDataProcessor. The DataProcessor API could be changed in such a
% way that this class is not needed. CompositeDataProcessorNode is used
% primarily in a tight loop and so this would likely be beneficial for
% performance.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) CompositeDataProcessorNode < handle
    properties (GetAccess = private, SetAccess = immutable)
        % The underlying DataProcessor.
        Processor;
        
        % Specify if partition indices should be merged with the data output.
        % This will only be used for All-To-All communication for non-Spark
        % back-ends and is expected to be used as part of a pair with the
        % other node having RequireInputPartitionIndices set to true.
        RequireOutputPartitionIndices;
        
        % Specify if the partition indices of the input node were merged
        % with the data output of the direct upstream component. This will
        % only be used for All-To-All communication for non-Spark
        % back-ends and is expected to be used as part of a pair with the
        % other node having RequireOutputPartitionIndices set to true.
        RequireInputPartitionIndices;
    end
    
    properties (SetAccess = private)
        % Whether this object is finished.
        IsFinished;
        
        % Vector of logicals, whether more of each respective input is
        % required to continue the calculation.
        IsMoreInputRequired;
        
        % A cache of the output when it is empty. This is NaN until valid.
        EmptyChunk = NaN;
    end
    
    methods (Access = ?matlab.bigdata.internal.executor.CompositeDataProcessorBuilder)
        function obj = CompositeDataProcessorNode(processor, ...
                requireOutputPartitionIndices, requireInputPartitionIndices)
            obj.Processor = processor;
            obj.RequireOutputPartitionIndices = requireOutputPartitionIndices;
            obj.RequireInputPartitionIndices = requireInputPartitionIndices;
            obj.IsFinished = obj.Processor.IsFinished;
            obj.IsMoreInputRequired = true(size(obj.Processor.IsMoreInputRequired));
        end
    end
    
    methods
        function [data, partitionIndices] = process(obj, isLastOfInput, varargin)
            % Perform one iteration of the action of this node.
            import matlab.bigdata.internal.util.indexSlices;
            
            if obj.RequireInputPartitionIndices
                assert (numel(varargin) == 1, ...
                    'Assertion: RequireInputPartitionIndices expected 1 input, %i were received.', numel(varargin));
                varargin = varargin{1};
            end
            
            if obj.RequireOutputPartitionIndices
                [data, mergedPartitionIndices] = obj.Processor.process(isLastOfInput, varargin{:});
                if isnumeric(obj.EmptyChunk)
                    obj.EmptyChunk = {indexSlices(data, []), zeros(0,1)};
                end
                data = {data, mergedPartitionIndices};
            else
                if nargout >= 2
                    [data, partitionIndices] = obj.Processor.process(isLastOfInput, varargin{:});
                else
                    data = obj.Processor.process(isLastOfInput, varargin{:});
                end
                if isnumeric(obj.EmptyChunk)
                    obj.EmptyChunk = indexSlices(data, []);
                end
            end
            obj.IsFinished = obj.Processor.IsFinished;
            obj.IsMoreInputRequired = obj.Processor.IsMoreInputRequired;
        end
    end
end
