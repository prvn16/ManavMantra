classdef OverallCoverage < matlab.unittest.internal.coverage.ContainerCoverage
    % Class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = private)
        CoverageList matlab.unittest.internal.coverage.Coverage = matlab.unittest.internal.coverage.PackageCoverage.empty(1,0); 
    end
    
    methods         
        function addCoverageElement(srcCoverageElement,newCoverageElement)
            validateattributes(newCoverageElement,{'matlab.unittest.internal.coverage.Coverage'},{'row'});
            srcCoverageElement.CoverageList = [srcCoverageElement.CoverageList newCoverageElement];
        end
 
        function varargout = formatCoverageData(overallCoverage,formatter,varargin)
            [varargout{1:nargout}] = formatter.formatOverallCoverageData(overallCoverage,varargin{:});
        end
    end
    
    methods (Access = ?matlab.unittest.internal.coverage.FileCoverage)
        function insertCoverageElement(overallCoverage,fileCoverage)
            import matlab.unittest.internal.coverage.PackageCoverage
            
            packageName = fileCoverage.PackageName;
            pkgIndex = find(strcmp({overallCoverage.CoverageList.PackageName},packageName));
            if isempty(pkgIndex)
                packageCoverage = PackageCoverage(packageName);
                overallCoverage.addCoverageElement(packageCoverage);
            else
                packageCoverage = overallCoverage.CoverageList(pkgIndex);   
            end
            packageCoverage.addCoverageElement(fileCoverage);
        end
    end    
end