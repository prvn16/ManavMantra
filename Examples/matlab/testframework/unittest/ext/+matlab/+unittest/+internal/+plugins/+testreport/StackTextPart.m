classdef StackTextPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        Stack
    end
    
    properties(Access=private)
        StackText = [];
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods
        function docPart = StackTextPart(stack)
            docPart.Stack = stack;
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('StackTextPart');
        end
        
        function setupPart(docPart,~)
            import matlab.unittest.internal.diagnostics.createStackInfo;
            stackInfo = createStackInfo(docPart.Stack);
            docPart.StackText = char(stackInfo.Text); %Get non-enriched version of the stack
        end
        
        function teardownPart(docPart)
            docPart.StackText = [];
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillStackLabel(docPart)
            docPart.append(docPart.Catalog.getString('StackLabel'));
        end
        
        function fillStackText(docPart)
            docPart.appendUnmodifiedText(docPart.StackText);
        end
    end
end

% LocalWords:  unittest
