classdef CommandWindowTextPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(Access=private)
        HeadingPart = [];
        CommandWindowText = [];
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('CommandWindowTextPart');
        end
        
        function setupPart(docPart,testReportData)
            import matlab.unittest.internal.plugins.testreport.HeadingPart;       
            docPart.CommandWindowText = testReportData.TestSessionData.CommandWindowText;
            
            if ~docPart.isApplicablePart()
                return;
            end
            
            headingPart = HeadingPart(1,docPart.Catalog.getString('CommandWindowTextHeading')); %#ok<CPROPLC>
            headingPart.setup(testReportData);
            docPart.HeadingPart = headingPart;
        end
        
        function teardownPart(docPart)
            docPart.HeadingPart = [];
            docPart.CommandWindowText = [];
        end
        
        function bool = isApplicablePart(docPart)
            bool = ~isempty(docPart.CommandWindowText);
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillHeadingPart(docPart)
            docPart.append(docPart.HeadingPart);
        end
        
        function fillCommandWindowText(docPart)
            docPart.appendPreText(docPart.CommandWindowText)
        end
    end
end

% LocalWords:  unittest
