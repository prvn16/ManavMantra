classdef TestDetailsPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(GetAccess=private,SetAccess=immutable)
        TestIndex
    end
    
    properties(Access=private)
        HeadingPart = [];
        EventListPart = [];
        LinkToTestParentOverview = [];
        TestResult = [];
        TestElement = [];
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods
        function docPart = TestDetailsPart(testIndex)
            docPart.TestIndex = testIndex;
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('TestDetailsPart');
        end
        
        function setupPart(docPart,testReportData)
            import matlab.unittest.internal.plugins.testreport.HeadingPart;
            import matlab.unittest.internal.plugins.testreport.EventListPart;
            import mlreportgen.dom.InternalLink;
            
            testIndex = docPart.TestIndex;
            docPart.TestResult = testReportData.TestSessionData.TestResults(testIndex);
            docPart.TestElement = testReportData.TestSessionData.TestSuite(testIndex);
            baseFolder = testReportData.TestSessionData.BaseFolders{testIndex};
            testParentName = testReportData.TestSessionData.TestSuite(testIndex).TestParentName;
            parameters = testReportData.TestSessionData.TestSuite(testIndex).Parameterization;
            eventRecords = testReportData.TestSessionData.EventRecordsList{testIndex};
            
            detailsLinkTarget = testReportData.LinkTargetGenerator.getDetailsLinkTargetForTestIndex(...
                testIndex);
            iconFile = testReportData.resultToIconFile(docPart.TestResult);
            headingTxt = testReportData.TestSessionData.TestSuite(testIndex).TestName;
            if ~isempty(parameters)
                headingTxt = sprintf('%s\n%s',headingTxt,...
                    docPart.convertParametersToTextForHeading(parameters));
            end
            docPart.HeadingPart = HeadingPart(4,headingTxt,detailsLinkTarget,iconFile); %#ok<CPROPLC>
            docPart.HeadingPart.setup(testReportData);
            
            docPart.EventListPart = EventListPart(eventRecords); %#ok<CPROPLC>
            docPart.EventListPart.setup(testReportData);
            
            overviewLinkTarget = testReportData.LinkTargetGenerator.getOverviewLinkTargetForBaseFolderAndTestParentName(...
                baseFolder,testParentName);
            docPart.LinkToTestParentOverview = InternalLink(overviewLinkTarget.Name,...
                docPart.Catalog.getString('OverviewLinkText'));
        end
        
        function teardownPart(docPart)
            docPart.HeadingPart = [];
            docPart.EventListPart = [];
            docPart.LinkToTestParentOverview = [];
            docPart.TestResult = [];
            docPart.TestElement = [];
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillHeadingPart(docPart)
            docPart.append(docPart.HeadingPart);
        end
        
        function fillTestDetails(docPart)
            result = docPart.TestResult;
            
            timeTxt = docPart.Catalog.getString('TimeInSeconds',...
                sprintf('%.4f',docPart.TestResult.Duration));
            if result.Passed
                testDetailText = docPart.Catalog.getString('TheTestPassed');
            elseif result.FatalAssertionFailed
                testDetailText = docPart.Catalog.getString('TheTestFailedByFatalAssertion');
            elseif result.Failed && result.Incomplete
                testDetailText = docPart.Catalog.getString('TheTestFailedAndWasIncomplete');
            elseif result.Failed
                testDetailText = docPart.Catalog.getString('TheTestFailed');
            elseif result.AssumptionFailed
                testDetailText = docPart.Catalog.getString('TheTestWasFiltered');
            else
                testDetailText = docPart.Catalog.getString('TheTestWasUnreached');
            end
            testDetailText = sprintf('%s\n%s %s',...
                testDetailText,...
                docPart.Catalog.getString('DurationLabel'),...
                timeTxt);
            docPart.appendUnmodifiedText(testDetailText);
        end
        
        function fillEventListPart(docPart)
            docPart.appendIfApplicable(docPart.EventListPart);
        end
        
        function fillOverviewLink(docPart)
            docPart.append(docPart.LinkToTestParentOverview);
        end
    end
    
    methods(Access=private)
        function txt = convertParametersToTextForHeading(docPart,parameters)
            cellOfTxts = {};
            
            classSetupParameters = parameters.filterByClass('matlab.unittest.parameters.ClassSetupParameter');
            if ~isempty(classSetupParameters)
                cellOfTxts{end+1} = sprintf('%s %s',...
                    docPart.Catalog.getString('ClassSetupParametersLabel'),...
                    makePropertiesEqualToNamesListText(classSetupParameters));
            end
            
            methodSetupParameters = parameters.filterByClass('matlab.unittest.parameters.MethodSetupParameter');
            if ~isempty(methodSetupParameters)
                cellOfTxts{end+1} = sprintf('%s %s',...
                    docPart.Catalog.getString('MethodSetupParametersLabel'),...
                    makePropertiesEqualToNamesListText(methodSetupParameters));
            end
            
            testParameters = parameters.filterByClass('matlab.unittest.parameters.TestParameter');
            if ~isempty(testParameters)
                cellOfTxts{end+1} = sprintf('%s %s',...
                    docPart.Catalog.getString('TestParametersLabel'),...
                    makePropertiesEqualToNamesListText(testParameters));
            end
            
            txt = ['        ' strjoin(cellOfTxts,sprintf('\n        '))];
        end
    end
end


function txt = makePropertiesEqualToNamesListText(parameters)
propertyEqualToNameCell = arrayfun(@(x) [x.Property '=' x.Name],parameters,...
    'UniformOutput',false);
txt = strjoin(propertyEqualToNameCell,', ');
end

% LocalWords:  unittest
