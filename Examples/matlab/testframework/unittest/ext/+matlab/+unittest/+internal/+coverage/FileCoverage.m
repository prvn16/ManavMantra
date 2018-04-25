classdef FileCoverage < matlab.unittest.internal.coverage.Coverage
    % Class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (Access = private)
        MethodList
        FileProfileData
        FileInformation
    end
    
    properties (Dependent,SetAccess = private)
        FullName
        FileIdentifier
        PackageName
        ExecutableLines
        HitCount
        SourceList = string.empty(1,0);
        ExecutableLineCount
        ExecutedLineCount
        MethodCoverageData matlab.unittest.internal.coverage.CodeSegmentCoverage
    end
    
    methods
        function fileCoverage = FileCoverage(fileInformation, fileProfileData)            
            fileCoverage.FileInformation = fileInformation;
            fileCoverage.FileProfileData = fileProfileData;
        end
        
        function hitCountArray = get.HitCount(fileCoverage)
            hitCountArray = zeros(size(fileCoverage.ExecutableLines));
            
            % Find all the lines executed and their hit count
            executedLinesData = vertcat(double.empty(0,3), fileCoverage.FileProfileData.ExecutedLines);
            allExecutedLines = executedLinesData(:,1)';
            allHitCounts = executedLinesData(:,2)';
            
            % Match lines that were hit to the ExecutableLines and
            % return the hit count
            [~,executableLineIdx,executedLineIdx] = intersect(fileCoverage.ExecutableLines,allExecutedLines);
            hitCountArray(executableLineIdx) = allHitCounts(executedLineIdx);
        end
        
        function executableLineCount = get.ExecutableLineCount(fileCoverage)
            executableLineCount = numel(fileCoverage.ExecutableLines);
        end
        
        function executedLineCount = get.ExecutedLineCount(fileCoverage)
            executedLineCount = nnz(fileCoverage.HitCount);
        end
        
        function methodCoverageData = get.MethodCoverageData(fileCoverage)
            import matlab.unittest.internal.coverage.MethodCoverage
            methodCoverageData = MethodCoverage(fileCoverage.MethodList,...
                fileCoverage.ExecutableLines,fileCoverage.HitCount);
        end
        
        function fullName = get.FullName(fileCoverage)
            fullName = fileCoverage.FileInformation.FullName;
        end
        
        function fileIdentifier = get.FileIdentifier(fileCoverage)
            fileIdentifier = fileCoverage.FileInformation.FileIdentifier;
        end
        
        function packageName = get.PackageName(fileCoverage)
            packageName = fileCoverage.FileInformation.PackageName;
        end
        
        function executableLines = get.ExecutableLines(fileCoverage)
            executableLines = fileCoverage.FileInformation.ExecutableLines;
        end
        
        function methodList = get.MethodList(fileCoverage)
            methodList = fileCoverage.FileInformation.MethodList;
        end
        
        function source = get.SourceList(fileCoverage)
            source = string(fileCoverage.FullName);
        end

        function varargout  = formatCoverageData(fileCoverage,formatter,varargin)
            [varargout{1:nargout}] = formatter.formatFileCoverageData(fileCoverage,varargin{:});
        end
    end
    
    methods (Sealed)
        function sourceComposite = buildPackageList(fileCoverageArray)
            import matlab.unittest.internal.coverage.OverallCoverage
            
            sourceComposite = OverallCoverage;
            
            for idx = 1:numel(fileCoverageArray)
                sourceComposite.insertCoverageElement(fileCoverageArray(idx));
            end
        end
    end
end