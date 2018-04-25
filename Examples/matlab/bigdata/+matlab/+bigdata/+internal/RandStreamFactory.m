%RandStreamFactory  Simple class for creating RandStreams for partitions
%based on a common base state.
%
%   Copyright 2017 The MathWorks, Inc.

classdef RandStreamFactory
    
    properties (GetAccess=private, SetAccess=immutable)
        BaseRNGState;                  
    end
    
    methods
        function obj = RandStreamFactory(rs)
            % RandStreamFactory() Create a RandStreamFactory from the
            % global tallrng state, which will be incremented.
            %
            % RandStreamFactory(rs) Create a RandStreamFactory from a
            % user-supplied RandStream, which will be incremented.
            if nargin
                % Create from RandStream
                obj.BaseRNGState = matlab.bigdata.internal.getAndIncrementRNGState(rs);
            else
                % Create default
                obj.BaseRNGState = matlab.bigdata.internal.getAndIncrementRNGState();
            end
        end

        function rs = getRandStreamForPartition(factory, partitionIndex)
            % Calculate the RandStream to use for a specific partition. Each partition
            % gets a separate stream, so just add the partition number to the base
            % index.
            state = factory.BaseRNGState;
            state.StreamIndex = state.StreamIndex + partitionIndex - 1;
            rs = matlab.bigdata.internal.rngState2Randstream(state);
        end
    end
end
