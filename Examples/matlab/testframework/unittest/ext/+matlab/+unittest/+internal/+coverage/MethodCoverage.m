classdef MethodCoverage < matlab.unittest.internal.coverage.CodeSegmentCoverage
   
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = private)
        ExecutableLines
        HitCount
        Name
        Signature
    end
    
    properties (Access = private)        
        FileExecutableLines
        FileHitCount
    end
    
    methods
        function methodCoverageArray = MethodCoverage(methodInformation,fileExecutableLines,fileHitCount)
            if nargin<1
                return
            end
            validateattributes(methodInformation,{'matlab.unittest.internal.fileinformation.CodeSegmentInformation'},{});
            methodCoverageArray = repmat(methodCoverageArray,size(methodInformation));
            [methodCoverageArray.Name] = deal(methodInformation.Name);
            [methodCoverageArray.ExecutableLines] = deal(methodInformation.ExecutableLines);            
            [methodCoverageArray.Signature] = deal(methodInformation.Signature);
            [methodCoverageArray.FileExecutableLines] = deal(fileExecutableLines);
            [methodCoverageArray.FileHitCount] = deal(fileHitCount);
        end
        
         function methodHitCountArray = get.HitCount(methodCoverage)
            methodHitCountArray = zeros(size(methodCoverage.ExecutableLines));    
            
            allExecutableLines = methodCoverage.FileExecutableLines;
            allHitCounts = methodCoverage.FileHitCount;
            
            % Match lines that were hit from the methods's ExecutableLines
            % and return the hit count
            [~,executableLineIdx,executedLineIdx] = intersect(methodCoverage.ExecutableLines,allExecutableLines);
            methodHitCountArray(executableLineIdx) = allHitCounts(executedLineIdx);
         end        
    end
end

            