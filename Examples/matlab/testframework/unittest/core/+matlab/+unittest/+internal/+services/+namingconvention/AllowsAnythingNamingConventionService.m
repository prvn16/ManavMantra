classdef AllowsAnythingNamingConventionService < matlab.unittest.internal.services.namingconvention.NamingConventionService
    % This class is undocumented and will change in a future release.
    
    % AllowsAnythingNamingConventionService - Naming convention service
    %   for which all test content meets its naming convention.
    %
    % See Also: NamingConventionService, ServiceLocator
    
    % Copyright 2015 The MathWorks, Inc.
    
    methods (Access=protected)
        function meetsConvention(~, liaison)
            liaison.MeetsConvention = true;
        end
    end
end

% LocalWords:  namingconvention
