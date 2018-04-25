classdef (HandleCompatible) Service < matlab.mixin.Heterogeneous
    % This class is undocumented and will change in a future release.
    
    % Service - Interface for generic service publishing. Used in order to
    % locate and construct services across module boundaries dynamically. 
    %
    % See Also: ServiceLocator, ServiceFactory
    
    % Copyright 2015 The MathWorks, Inc.
    
    methods(Abstract)
        % fulfill - Fulfill an array of services 
        %
        %   fulfill(SERVICES, VARARGIN) should take an arbitrarily sized Service
        %   array and fulfill the services they intend to provide. This method
        %   implementation requires handling arrays of heterogeneous services and is
        %   usually implemented in intermediate Service subclasses which then
        %   prescribe their own abstract interface for the different Services of a
        %   particular type. Implementors can allow for additional input arguments
        %   in order to fulfill services on specific contextual objects.
        fulfill(services, varargin)
    end
    methods(Static, Access=protected)
        function service = getDefaultScalarElement
            service = matlab.unittest.internal.services.ServicePlaceholder;
        end
    end
    
end
