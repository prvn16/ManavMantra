classdef(HandleCompatible) ReportData
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        %DocumentType - The type of the report that will generated
        DocumentType
    end
    
    properties(Dependent,SetAccess=immutable)
        DocumentTypeIsDOCX
        DocumentTypeIsHTML
        DocumentTypeIsPDF
    end
    
    methods
        function reportData = ReportData(documentType)
            import matlab.unittest.internal.dom.ReportData;
            validateattributes(documentType,{'char','string'},{'scalartext'});
            mustBeMember(documentType,{'docx','html','pdf'});
            reportData.DocumentType = char(documentType);
        end
        
        function bool = get.DocumentTypeIsDOCX(reportData)
            bool = strcmp(reportData.DocumentType,'docx');
        end
        
        function bool = get.DocumentTypeIsHTML(reportData)
            bool = strcmp(reportData.DocumentType,'html');
        end
        
        function bool = get.DocumentTypeIsPDF(reportData)
            bool = strcmp(reportData.DocumentType,'pdf');
        end
    end
end

% LocalWords:  scalartext
