classdef CoverPageSummaryPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        PageOrientation = '';
    end
    
    properties(Access=private)
        NumberOfTests = [];
        TotalTestingTime = [];
        AllFiltered = [];
        AnyFailed = [];
        AnyUnreached = [];
        CoverPageTopMarginPart = [];
        PieChartSummaryPart = [];
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods
        function docPart = CoverPageSummaryPart(pageOrientation)
            if nargin > 0
                docPart.PageOrientation = pageOrientation;
            end
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('CoverPageSummaryPart');
        end
        
        function setupPart(docPart,testReportData)
            import matlab.unittest.internal.plugins.testreport.BlankPart;
            import matlab.unittest.internal.plugins.testreport.CoverPageTopMarginPart;
            import matlab.unittest.internal.plugins.testreport.PieChartSummaryPart;
            import matlab.unittest.internal.plugins.testreport.PieChartSummaryAlternativePart;
            import matlab.unittest.internal.plugins.supportsFigurePrinting;
            
            docPart.NumberOfTests = testReportData.TestSessionData.NumberOfTests;
            docPart.TotalTestingTime = sum([testReportData.TestSessionData.TestResults.Duration]);
            
            docPart.AllFiltered = all(testReportData.TestSessionData.FilteredMask);
            docPart.AnyFailed = any(testReportData.TestSessionData.FailedMask);
            docPart.AnyUnreached = any(testReportData.TestSessionData.UnreachedMask);
            
            docPart.CoverPageTopMarginPart = CoverPageTopMarginPart(docPart.PageOrientation); %#ok<CPROPLC>
            docPart.CoverPageTopMarginPart.setup(testReportData);
            
            if docPart.NumberOfTests == 0
                docPart.PieChartSummaryPart = BlankPart();
            elseif supportsFigurePrinting()
                docPart.PieChartSummaryPart = PieChartSummaryPart(); %#ok<CPROPLC>
            else
                docPart.PieChartSummaryPart = PieChartSummaryAlternativePart();
            end
            docPart.PieChartSummaryPart.setup(testReportData);
        end
        
        function teardownPart(docPart)
            docPart.NumberOfTests = [];
            docPart.TotalTestingTime = [];
            docPart.AllFiltered = [];
            docPart.AnyFailed = [];
            docPart.AnyUnreached = [];
            docPart.CoverPageTopMarginPart = [];
            docPart.PieChartSummaryPart = [];
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillCoverPageTopMarginPart(docPart)
            docPart.append(docPart.CoverPageTopMarginPart);
        end
        
        function fillTitle(docPart)
            titleText = docPart.Catalog.getString('ReportTitle',['MATLAB' char(174)]);
            docPart.append(titleText);
        end
        
        function fillTimestampLabel(docPart)
            docPart.appendLabelFromKey('TimestampLabel');
        end
        
        function fillTimestamp(docPart)
            currentTime = datetime();
            docPart.append(char(currentTime));
        end
        
        function fillHostLabel(docPart)
            docPart.appendLabelFromKey('HostLabel');
        end
        
        function fillHost(docPart)
            host = matlab.unittest.internal.plugins.getHostname();
            docPart.append(host);
        end
        
        function fillPlatformLabel(docPart)
            docPart.appendLabelFromKey('PlatformLabel');
        end
        
        function fillPlatform(docPart)
            docPart.append(computer('arch'));
        end
        
        function fillMATLABVersionLabel(docPart)
            docPart.appendLabelFromKey('MATLABVersionLabel');
        end
        
        function fillMATLABVersion(docPart)
            docPart.append(version());
        end
        
        function fillNumberOfTestsLabel(docPart)
            docPart.appendLabelFromKey('NumberOfTestsLabel');
        end
        
        function fillNumberOfTests(docPart)
            numOfTestsStr = sprintf('%u',docPart.NumberOfTests);
            docPart.append(numOfTestsStr);
        end
        
        function fillTestingTimeLabel(docPart)
            docPart.appendLabelFromKey('TestingTimeLabel');
        end
        
        function fillTestingTime(docPart)
            testingTimeStr = docPart.Catalog.getString('TimeInSeconds',...
                sprintf('%.4f',docPart.TotalTestingTime));
            docPart.append(testingTimeStr);
        end
        
        function fillOverallResultLabel(docPart)
            docPart.appendLabelFromKey('OverallResultLabel');
        end
        
        function fillOverallResult(docPart)
            if docPart.NumberOfTests == 0
                overallResultText = '--';
            elseif docPart.AllFiltered
                overallResultText = docPart.Catalog.getString('AllTestsFiltered');
            elseif docPart.AnyFailed
                overallResultText = upper(docPart.Catalog.getString('Failed'));
            elseif docPart.AnyUnreached
                overallResultText = docPart.Catalog.getString('TestRunAborted');
            else
                overallResultText = upper(docPart.Catalog.getString('Passed'));
            end
            docPart.append(overallResultText);
        end
        
        function fillPieChartSummaryPart(docPart)
            docPart.append(docPart.PieChartSummaryPart);
        end
    end
    
    methods(Access=private)
        function appendLabelFromKey(docPart,msgIDKey)
            docPart.append(docPart.Catalog.getString(msgIDKey));
        end
    end
end

% LocalWords:  unittest
