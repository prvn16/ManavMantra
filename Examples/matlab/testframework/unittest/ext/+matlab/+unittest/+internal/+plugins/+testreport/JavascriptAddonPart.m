classdef JavascriptAddonPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(Access=private)
        IsApplicable = [];
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('JavascriptAddonPart');
        end
        
        function setupPart(docPart,testReportData)
            docPart.IsApplicable = testReportData.DocumentTypeIsHTML;
        end
        
        function teardownPart(docPart)
            docPart.IsApplicable = [];
        end
        
        function bool = isApplicablePart(docPart)
            bool = docPart.IsApplicable;
        end
    end
end