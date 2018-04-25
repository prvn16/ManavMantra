%SlicesPerPartitionFunctor Functor to count number of slices per partition.

% Copyright 2016 The MathWorks, Inc.
classdef SlicesPerPartitionFunctor < handle & matlab.mixin.Copyable
    properties
        % The count of elements so far. As this functor is copied before use
        % once per partition, this becomes the count per partition.
        Count = 0;
    end
    methods
        function [hasFinished,partitionSlices] = feval(obj,info,x)
            obj.Count = obj.Count + size(x, 1);

            % We only want to emit the result when we have counted all the
            % slices of tX for the current partition.
            hasFinished = info.IsLastChunk;
            if hasFinished
                partitionSlices = obj.Count;
                obj.Count       = 0;
            else
                partitionSlices = [];
            end
        end
    end
end
