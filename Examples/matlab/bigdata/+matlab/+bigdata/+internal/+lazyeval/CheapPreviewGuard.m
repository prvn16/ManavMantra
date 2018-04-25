% CheapPreviewGuard
% A class that uses RAII to manage setting the serial executor with a
% single partition and no progress reporter for cheap preview.  The
% previous state is restored when this object is destroyed.

classdef CheapPreviewGuard < handle
    
    properties (SetAccess = immutable)
        Cleanups;
        
        ProgressReporter;
        
        Executor;
    end
    
    methods (Access = public)
        function obj = CheapPreviewGuard()
            obj.Cleanups = cell(2,1);
            
            % Override the current progress reporter with a null progress
            % reprorter for the lifetime of this object.
            obj.ProgressReporter = matlab.bigdata.internal.executor.NullProgressReporter();
            pr = matlab.bigdata.internal.executor.ProgressReporter.override(obj.ProgressReporter);
            obj.Cleanups{1} = onCleanup(...
                @()matlab.bigdata.internal.executor.ProgressReporter.override(pr));
            
            % Override the current executor with a single-partition serial 
            % executor for the lifetime of this object.
            obj.Executor = matlab.bigdata.internal.serial.SerialExecutor('UseSinglePartition', true);
            e = matlab.bigdata.internal.executor.PartitionedArrayExecutor.override(obj.Executor);
            obj.Cleanups{2} = onCleanup(...
                @()matlab.bigdata.internal.executor.PartitionedArrayExecutor.override(e));
        end
    end
end