classdef FilterSummaryPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(Access=private)
        NumberFiltered = [];
        HeadingPart = [];
        FilterTableRowParts = [];
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('FilterSummaryPart');
        end
        
        function setupPart(docPart,testReportData)
            import matlab.unittest.internal.plugins.testreport.HeadingPart;
            import matlab.unittest.internal.plugins.testreport.FilterTableRowPart;

            indsFiltered = find(testReportData.TestSessionData.FilteredMask);
            docPart.NumberFiltered = numel(indsFiltered);
            
            if ~docPart.isApplicablePart()
                return;
            end
            
            docPart.HeadingPart = HeadingPart(1,docPart.Catalog.getString('FilterSummaryHeading')); %#ok<CPROPLC>
            docPart.HeadingPart.setup(testReportData);
            
            cellOfParts = arrayfun(@(ind) FilterTableRowPart(ind),indsFiltered,...
                'UniformOutput',false);
            docPart.FilterTableRowParts = [cellOfParts{:}];
            docPart.FilterTableRowParts.setup(testReportData);
        end
        
        function teardownPart(docPart)
            docPart.NumberFiltered = [];
            docPart.HeadingPart = [];
            docPart.FilterTableRowParts = [];
        end
        
        function bool = isApplicablePart(docPart)
            bool = docPart.NumberFiltered > 0;
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillHeadingPart(docPart)
            docPart.append(docPart.HeadingPart);
        end
        
        function fillFilterSummaryText(docPart)
            numFiltered = docPart.NumberFiltered;
            if numFiltered == 1
                docPart.append(docPart.Catalog.getString('SingleFilterSummaryText'));
            else
                docPart.append(docPart.Catalog.getString('FilterSummaryText',numFiltered));
            end
        end
        
        function fillTestNameColumnLabel(docPart)
            docPart.append(docPart.Catalog.getString('FilteredTestNameColumnLabel'));
        end
        
        function fillFilterTableRowParts(docPart)
            docPart.append(docPart.FilterTableRowParts);
        end
    end
end

% LocalWords:  unittest
