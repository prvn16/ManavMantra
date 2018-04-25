classdef ContainerCoverage < matlab.unittest.internal.coverage.Coverage
    % Class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (Abstract,SetAccess = private)
        CoverageList matlab.unittest.internal.coverage.Coverage
    end 
    
    properties (Dependent,SetAccess = private)
        ExecutableLineCount
        ExecutedLineCount
        SourceList
    end
    
    methods
        function count = get.ExecutableLineCount(overallCoverage)
            count = overallCoverage.generateExecutableLines;
        end
        
        function count = get.ExecutedLineCount(overallCoverage)
            count = overallCoverage.generateExecutedLines;
        end
        
        function sources = get.SourceList(overallCoverage)
            sources = overallCoverage.generateSourceList;
        end
    end
    
    methods (Access = private)
        function sources = generateSourceList(coverage)
            sources = [coverage.CoverageList.SourceList];
        end
        
        function count = generateExecutableLines(coverage)
            count = sum([coverage.CoverageList.ExecutableLineCount]);
        end
        
        function count = generateExecutedLines(coverage)
            count = sum([coverage.CoverageList.ExecutedLineCount]);
        end
    end
end

