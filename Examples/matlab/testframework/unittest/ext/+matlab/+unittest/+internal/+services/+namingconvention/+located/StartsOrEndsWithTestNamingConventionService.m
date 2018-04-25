classdef StartsOrEndsWithTestNamingConventionService < matlab.unittest.internal.services.namingconvention.NamingConventionService
    % This class is undocumented and will change in a future release.
    
    % Copyright 2015 The MathWorks, Inc.
    
    methods (Access=protected)
        function meetsConvention(~, liaison)
            import matlab.unittest.internal.DefaultTestNameMatcher;
            liaison.MeetsConvention = DefaultTestNameMatcher.isTest(liaison.SimpleParentName);
        end
    end
end

% LocalWords:  namingconvention
