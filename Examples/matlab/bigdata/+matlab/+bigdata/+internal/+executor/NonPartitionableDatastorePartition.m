%NonPartitionableDatastorePartition
% A partition that is based on a non-splittable datastore.
%
% This has the ability to construct a datastore for the current partition.

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) NonPartitionableDatastorePartition < handle
    properties (SetAccess = immutable)
        % The original datastore used to create this partition.
        OriginalDatastore;
        
        % The index of this partition with the total number of partitions.
        PartitionIndex = 1;
        
        % The number of partitions in the strategy.
        NumPartitions = 1;
    end
    
    methods
        %CREATEDATASTORE Create a datastore containing all of the data
        %associated with this partition.
        function ds = createDatastore(obj)
            import matlab.bigdata.BigDataException;
            try
                ds = copy(obj.OriginalDatastore);
                reset(ds);
            catch err
                matlab.bigdata.internal.throw(err, 'IncludeCalleeStack', true);
            end
        end
    end
    
    methods
        % The main constructor.
        function obj = NonPartitionableDatastorePartition(originalDatastore)
            obj.OriginalDatastore = originalDatastore;
        end
    end
end
