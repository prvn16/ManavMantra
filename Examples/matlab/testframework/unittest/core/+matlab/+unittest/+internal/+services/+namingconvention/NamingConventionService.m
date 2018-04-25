classdef NamingConventionService < matlab.unittest.internal.services.Service
    % This class is undocumented and will change in a future release.
    
    % NamingConventionService - Interface for naming convention services.
    %
    % See Also: NamingConventionLiaison, Service, ServiceLocator, ServiceFactory, TestSuiteFactory
    
    % Copyright 2015 The MathWorks, Inc.
    
    methods (Abstract, Access=protected)
        % meetsConvention - Determine if naming convention is met.
        %
        %   meetsConvention(SERVICE, LIAISON) should be implemented to analyze the
        %   content described by LIAISON. If the service determines that the
        %   content meets the service's naming convention, it should set the
        %   MeetsConvention property to true on LIAISON.
        meetsConvention(service, liaison)
    end
    
    methods (Sealed)
        function fulfill(services, liaison)
            % fulfill - Fulfill an array of naming convention services
            %
            %   fulfill(SERVICES) fulfills an array of naming convention services by
            %   calling the meetsConvention method on each element of the array until a
            %   service is found which meets the naming convention.
            
            idx = 0;
            while (idx < numel(services)) && ~liaison.MeetsConvention
                idx = idx + 1;
                services(idx).meetsConvention(liaison);
            end
        end
    end
end

