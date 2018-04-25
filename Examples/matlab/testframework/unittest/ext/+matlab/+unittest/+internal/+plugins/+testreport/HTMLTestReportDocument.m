classdef HTMLTestReportDocument < matlab.unittest.internal.dom.HTMLReportDocument
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    properties(GetAccess=private, SetAccess=immutable)
        TestSessionData
    end
    
    methods
        function reportDoc = HTMLTestReportDocument(varargin)
            import matlab.unittest.internal.plugins.testreport.TestReportData;
            
            narginchk(1,Inf);
            
            if mod(nargin,2) == 1 % odd
                reportFolder = tempname();
                testSessionData = varargin{1};
                allArgs = varargin(2:end);
            else % even
                reportFolder = varargin{1};
                testSessionData = varargin{2};
                allArgs = varargin(3:end);
            end
            
            validateattributes(testSessionData,{'matlab.unittest.internal.TestSessionData'},{'scalar'});
            
            reportDoc = reportDoc@matlab.unittest.internal.dom.HTMLReportDocument(reportFolder,allArgs{:});
            
            reportDoc.ReportDocumentParts = [...
                matlab.unittest.internal.plugins.testreport.CoverPageSummaryPart(),...
                matlab.unittest.internal.plugins.testreport.FailureSummaryPart(),...
                matlab.unittest.internal.plugins.testreport.FilterSummaryPart(),...
                matlab.unittest.internal.plugins.testreport.SuiteOverviewPart(),...
                matlab.unittest.internal.plugins.testreport.SuiteDetailsPart(),...
                matlab.unittest.internal.plugins.testreport.CommandWindowTextPart(),...
                matlab.unittest.internal.plugins.testreport.JavascriptAddonPart()];
            
            reportDoc.TestSessionData = testSessionData;
        end
    end
    
    methods(Access=protected)
        function reportData = createReportData(reportDoc)
            import matlab.unittest.internal.plugins.testreport.TestReportData;
            reportData = TestReportData('html',reportDoc.TestSessionData);
        end
    end
end

% LocalWords:  unittest
