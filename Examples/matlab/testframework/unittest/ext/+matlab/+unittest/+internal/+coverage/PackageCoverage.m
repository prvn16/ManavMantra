classdef PackageCoverage <  matlab.unittest.internal.coverage.ContainerCoverage
    % Class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = private)
        PackageName = char.empty;
        CoverageList matlab.unittest.internal.coverage.Coverage = matlab.unittest.internal.coverage.FileCoverage.empty(1,0)
    end

    methods
        function coverage = PackageCoverage(packageName)
            coverage.PackageName = packageName;
        end
        
        function addCoverageElement(srcCoverageElement,newCoverageElement)
            validateattributes(newCoverageElement,{'matlab.unittest.internal.coverage.Coverage'},{'row'});
            srcCoverageElement.CoverageList = [srcCoverageElement.CoverageList newCoverageElement];
        end

        function varargout = formatCoverageData(packageCoverage,formatter,varargin)
            [varargout{1:nargout}] = formatter.formatPackageCoverageData(packageCoverage,varargin{:});
        end
    end
end