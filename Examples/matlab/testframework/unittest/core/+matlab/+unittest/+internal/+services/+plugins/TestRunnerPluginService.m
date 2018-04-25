classdef TestRunnerPluginService < matlab.unittest.internal.services.Service
    % TestRunnerPluginService - Interface for services that provide TestRunnerPlugins.    
    %
    %   Plugins provided by TestRunnerPluginServices are used when running 
    %   tests that utilize the MATLAB Unit Test Runner via runtests.
    %
    % See Also: matlab.unittest.internal.services.Service,
    %           matlab.unittest.internal.services.ServiceLocator,
    %           matlab.unittest.internal.services.ServiceFactory
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods (Abstract)
        % providePlugins - Provide plugins to the testing framework.
        %
        %   PLUGINS = providePlugins(SERVICE) should be implemented to return an
        %   array of zero or more TestRunnerPlugins that are to be used when
        %   running tests. The method can return an empty array in the case where
        %   it is not appropriate to return any plugins given the environmental
        %   state at the time the method is invoked. The method can also return a
        %   vector of plugins if the service needs to provide more than one plugin.
        plugins = providePlugins(service)
    end    
    
    methods (Sealed)
        function fulfill(services, liaison)
            % fulfill - Fulfill an array of TestRunnerPluginServices.
            %
            %   fulfill(SERVICES,LIAISON) fulfills an array of TestRunnerPluginServices
            %   by calling the providePlugins method on each element of the array. The
            %   plugins provided by all the services are provided to the liaison.
            
            plugins = arrayfun(@(s)makeRow(s.providePlugins), services, 'UniformOutput',false);
            liaison.Plugins = [matlab.unittest.plugins.TestRunnerPlugin.empty(1,0), plugins{:}];
        end
    end
end

function row = makeRow(anyMatrix)
row = reshape(anyMatrix, 1, []);
end
