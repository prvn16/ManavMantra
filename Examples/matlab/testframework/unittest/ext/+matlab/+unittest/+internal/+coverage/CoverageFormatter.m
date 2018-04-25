classdef (Abstract)CoverageFormatter < matlab.mixin.Heterogeneous
    % Class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    methods(Abstract)        
        publishCoverageReport(formatter, coverageComposite)
        varargout = formatOverallCoverageData(coverageFormatter,overallCoverage, varargin)
        varargout = formatPackageCoverageData(coverageFormatter,packageCoverage, varargin)
        varargout = formatFileCoverageData(coverageFormatter,fileCoverage, varargin)
    end
end