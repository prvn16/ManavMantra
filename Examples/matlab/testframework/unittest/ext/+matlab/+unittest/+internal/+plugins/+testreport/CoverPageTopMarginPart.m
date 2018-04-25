classdef CoverPageTopMarginPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        PageOrientation = '';
    end
    
    methods
        function docPart = CoverPageTopMarginPart(pageOrientation)
            docPart.PageOrientation = pageOrientation;
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(docPart,testReportData)
            if testReportData.DocumentTypeIsHTML
                templateName = 'CoverPageTopMarginPart';
            elseif strcmp(docPart.PageOrientation,'portrait')
                templateName = 'CoverPageTopMarginPart_Portrait';
            else %landscape
                templateName = 'CoverPageTopMarginPart_Landscape';
            end
            delegateDocPart = testReportData.createDelegateDocumentPartFromName(templateName);
        end
    end
end