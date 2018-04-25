classdef (Hidden) CoverageFormat < matlab.mixin.Heterogeneous
    %
    
    % Class is undocumented and may change in a future release.
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods (Abstract, Access = {?matlab.unittest.internal.mixin.CoverageFormatMixin,...
            ?matlab.unittest.plugins.codecoverage.CoverageFormat})
        generateCoverageReport(format,sources,profileData)
    end
end

