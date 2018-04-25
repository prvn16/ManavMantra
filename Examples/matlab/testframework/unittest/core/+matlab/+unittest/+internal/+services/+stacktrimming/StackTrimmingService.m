classdef StackTrimmingService < matlab.unittest.internal.services.Service
    % This class is undocumented and will change in a future release.
    
    % StackTrimmingService - Interface for stack trimming services.
    %
    % See Also: StackTrimmingLiaison, Service, ServiceLocator
    
    % Copyright 2016 The MathWorks, Inc.
    
    methods (Abstract, Access = protected)
        trimStackStart(service, liaison)
        trimStackEnd(service, liaison)
    end
    
    methods (Sealed)
        function fulfill(services, liaison)
            % fulfill - Fulfill an array of stack trimming services
            %
            %   fulfill(SERVICES) fulfills an array of stack trimming
            %   services by calling the trimStackStart and trimStackEnd
            %   methods on each element of the array until all services
            %   trim the stack
            
            for s = services(:).'
                s.trimBothEnds(liaison);
            end
        end
        
        function trimEnd(services, liaison)
            % trimEnd - Convenience method to iterate over services to
            % trim away frames below a frame to keep.
            for s = services(:).'
                s.trimStackEnd(liaison);
            end
        end
    end
    
    methods (Access = private)
        function trimBothEnds(service, liaison)
            trimStackStart(service, liaison);
            trimStackEnd(service, liaison);
        end
        
    end
end
