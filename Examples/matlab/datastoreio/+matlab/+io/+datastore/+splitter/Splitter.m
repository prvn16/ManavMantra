classdef Splitter < matlab.mixin.Copyable
%Splitter   Abstract class that allows dividing up data read tasks.

%   Copyright 2015 The MathWorks, Inc.

    properties (GetAccess = 'public', Dependent = true)
        % Number of splits contained.
        NumSplits;
    end

    properties (GetAccess = 'public', SetAccess='protected')
        % Array containing splits for this Splitter type
        Splits;
    end
    
    methods(Static = true, Abstract = true, Access = 'public')
        % Create Splitter from args
        splitter = create(args);
    end

    methods(Static = true, Abstract = true, Access = 'public')
        % Create Splitter from existing Splits. Static method, no instance required.
        %
        % Splits passed as input must be of identical in structure to the
        % splits used by this Spltiter class.
        splitter = createFromSplits(splits);
    end
    
    methods(Abstract = true, Access = 'public')
        % Obtain a reader for split index ii
        rdr = createReader(splitter, ii);
        
        % Create Splitter from existing Splits while copying all other properties.
        %
        % Splits passed as input must be of identical in structure to the
        % splits used by this Spltiter class.
        splitterCopy = createCopyWithSplits(splitter, splits);
    end

    %
    % Subclasses must also write a copyElement() method to be truly
    % copyable. Authors must ensure that a copied Splitter behaves exactly
    % the same as the original.
    %
    
    methods(Access = 'public')
        function newSplitter = partitionBySubset(splitter, N, ii)
        %PARTITIONBYSUBSET   Return a partitioned part of the Splitter.
        %   This function will return a splitter that represents the part
        %   of the data corresponding with the partition and index chosen.

            if ~ischar(N) && ~isa(N, 'double')
                error(message('MATLAB:datastoreio:splittabledatastore:invalidPartitionStrategyType'));
            elseif ischar(N)
                validateattributes(N, {'char'}, {'nonempty', 'row'}, 'partition', 'PartitionStrategy');
                error(message('MATLAB:datastoreio:splittabledatastore:invalidPartitionStrategy', N(:)'));
            end
            validateattributes(N, {'double'}, {'scalar', 'positive', 'integer'}, 'partition', 'NumPartitions');
            validateattributes(ii, {'double'}, {'scalar', 'positive', 'integer'}, 'partition', 'Index');
            if ii > N
                error(message('MATLAB:datastoreio:splittabledatastore:invalidPartitionIndex', ii));
            end
            
            % The actual partitioning.
            splitIndices = pidgeonHole(ii, N, splitter.NumSplits);
            newSplitter = splitter.createCopyWithSplits(splitter.Splits(splitIndices));
        end
    end
    
    methods
        function ns = get.NumSplits(splitter)
            ns = numel(splitter.Splits);
        end
    end
    
end

function splitIndices = pidgeonHole(partitionIndex, numPartitions, numSplits)
% Helper function that chooses a collection of split indices based on
% a partition index and number of partitions.
    transformedSplitIndices = floor((0:numSplits - 1) * numPartitions / numSplits) + 1;    
    splitIndices = find(transformedSplitIndices == partitionIndex);
end
