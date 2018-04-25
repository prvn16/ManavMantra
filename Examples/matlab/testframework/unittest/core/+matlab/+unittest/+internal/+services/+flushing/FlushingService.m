classdef FlushingService < matlab.unittest.internal.services.Service
    % This class is undocumented and will change in a future release.
    
    % FlushingService - Interface for flushing services such as drawnow. 
    %
    % See Also: Service, ServiceLocator, ServiceFactory, Eventually constraint
    
    % Copyright 2015 The MathWorks, Inc.
    
    
    methods(Abstract)
        % flush - Flush the designated queue
        %
        %   flush(SERVICE) should be implemented to flush the desired queue.
        flush(service)
    end
    
    methods(Sealed)
        % fulfill - Fulfill an array of flushing services 
        %
        %   fulfill(SERVICES) fulfills an array of flushing services by calling the
        %   flush method on each element of the array.
        function fulfill(services)
            for service = services(:).'
                flush(service);
            end
        end
    end
    
end
