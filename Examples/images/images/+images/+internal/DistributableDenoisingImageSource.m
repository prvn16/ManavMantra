classdef DistributableDenoisingImageSource < nnet.internal.cnn.DistributableMiniBatchDatasource
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (Hidden, Constant)
        CanPreserveOrder = true;
    end
    
    methods
        
        function [distributedData, subBatchSizes] = distribute( this, proportions )
        % distribute   Split the dispatcher into partitions according to
        % the given proportions

            % Distribute MiniBatchSize and PatchesPerImage according to the
            % proportions
            MiniBatchSizePortions = nnet.internal.cnn.DistributableDispatcher.partitionByWeight(this.MiniBatchSize, proportions);
            PatchesPerImagePortions = nnet.internal.cnn.DistributableDispatcher.partitionByWeight(this.PatchesPerImage, proportions);
            
            % Create an ImageDatastoreDispatcher containing each of those
            % datastores.
            % Note we always use 'truncateLast' for the endOfEpoch
            % parameters and instead deal with this in the Trainer.
            numPartitions = numel(proportions);
            distributedData = cell(numPartitions, 1);
            for p = 1:numPartitions
                distributedData{p} = denoisingImageSource(this.imds,...
                    'ChannelFormat', this.ChannelFormat, ...
                    'GaussianNoiseLevel', this.GaussianNoiseLevel,...
                    'PatchesPerImage', PatchesPerImagePortions(p),...
                    'PatchSize', [this.PatchSize(1) this.PatchSize(2)], ...
                    'BackgroundExecution', this.UseParallel);
                distributedData{p}.MiniBatchSize = MiniBatchSizePortions(p);
            end
            subBatchSizes = MiniBatchSizePortions;
        end
        
    end
end


