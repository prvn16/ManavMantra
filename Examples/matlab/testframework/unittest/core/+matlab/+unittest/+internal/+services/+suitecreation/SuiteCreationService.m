classdef SuiteCreationService < matlab.unittest.internal.services.Service
    % This class is undocumented and will change in a future release.
    
    % SuiteCreationService - Interface for suite creation services.
    %
    % See Also: SuiteCreationLiaison, Service, ServiceLocator, ServiceFactory, TestSuiteFactory
    
    % Copyright 2015 The MathWorks, Inc.
    
    methods (Abstract, Access=protected)
        % selectFactory - Select a TestSuiteFactory.
        %
        %   selectFactory(SERVICE, LIAISON) should be implemented to analyze the
        %   content described by LIAISON. If the service can identify the content
        %   and construct an appropriate TestSuiteFactory, it should do so and set
        %   that factory on LIAISON. Otherwise, the method should make no change to
        %   LIAISON.
        selectFactory(service, liaison)
    end
    
    methods (Sealed)
        function fulfill(services, liaison)
            % fulfill - Fulfill an array of suite creation services
            %
            %   fulfill(SERVICES) fulfills an array of suite creation services by
            %   calling the selectFactory method on each element of the array until a
            %   service is found which selects a TestSuiteFactory.
            
            idx = 0;
            while (idx < numel(services)) && liaison.UsingDefaultFactory
                idx = idx + 1;
                services(idx).selectFactory(liaison);
            end
        end
    end
end

