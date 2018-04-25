classdef DrawnowFlushingService < matlab.unittest.internal.services.flushing.FlushingService
    % This class is undocumented and will change in a future release.
    
    % DrawnowFlushingService - A drawnow FlushingService. 
    %
    % See Also: FlushingService, ServiceLocator, ServiceFactory, Eventually constraint
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    methods
        function flush(~)
            % flush - Flush using drawnow
            %
            %   flush(SERVICE) should be implemented to flush the desired queue.
            drawnow;
        end
    end
        
end
