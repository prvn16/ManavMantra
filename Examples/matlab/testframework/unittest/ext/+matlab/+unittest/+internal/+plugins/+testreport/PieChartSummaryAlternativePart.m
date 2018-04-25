classdef PieChartSummaryAlternativePart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(Access=private)
        SummaryImages = [];
        SummaryStrings = [];
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('PieChartSummaryAlternativePart');
        end
        
        function setupPart(docPart,testReportData,~)
            passedCount = nnz(testReportData.TestSessionData.PassedMask);
            filteredCount = nnz(testReportData.TestSessionData.FilteredMask);
            failedCount = nnz(testReportData.TestSessionData.FailedMask);
            unreachedCount = nnz(testReportData.TestSessionData.UnreachedMask);
            
            docPart.SummaryImages = Image.empty(1,0);
            docPart.SummaryStrings = string.empty(1,0);
            
            if passedCount > 0
                addSummaryLine('passed','NumTestsPassed',passedCount);
            end
            if filteredCount > 0
                addSummaryLine('filtered','NumTestsFiltered',filteredCount);
            end
            if failedCount > 0
                addSummaryLine('failed','NumTestsFailed',failedCount);
            end
            if unreachedCount > 0
                addSummaryLine('unreached','NumTestsUnreached',unreachedCount);
            end
            
            function addSummaryLine(iconName,msgKey,count)
                import mlreportgen.dom.Image;
                imgObj = Image(testReportData.getIconFile(iconName));
                imgObj.Width = '0.11in';
                imgObj.Height = '0.11in';
                docPart.SummaryImages(end+1) = imgObj;
                docPart.SummaryStrings(end+1) = docPart.Catalog.getString(msgKey,count);
            end
        end
        
        function teardownPart(docPart)
            docPart.SummaryImages = [];
            docPart.SummaryStrings = [];
        end
    end
    
    methods(Hidden)
        function fillSummaryLabel(docPart)
            docPart.append(docPart.Catalog.getString('SummaryLabel'));
        end
        
        function fillSummaryText(docPart)
            for k=1:numel(docPart.SummaryImages)
                if k > 1
                    docPart.appendUnmodifiedText(newline());
                end
                imgObj = docPart.SummaryImages(k);
                imgObj.Height = '18px';
                imgObj.Width = '18px';
                docPart.append(imgObj);
                docPart.appendUnmodifiedText([' ' char(docPart.SummaryStrings(k))]);
            end
        end
    end
end

% LocalWords:  unittest px
