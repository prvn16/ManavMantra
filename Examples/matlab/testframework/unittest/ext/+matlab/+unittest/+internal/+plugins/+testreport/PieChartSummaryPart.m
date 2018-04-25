classdef PieChartSummaryPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(Access=private)
        ImageObject = [];
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('PieChartSummaryPart');
        end
        
        function setupPart(docPart,testReportData,~)
            passedCount = nnz(testReportData.TestSessionData.PassedMask);
            filteredCount = nnz(testReportData.TestSessionData.FilteredMask);
            failedCount = nnz(testReportData.TestSessionData.FailedMask);
            unreachedCount = nnz(testReportData.TestSessionData.UnreachedMask);
            
            [fig,figEnv] = docPart.createPieChartFigure(passedCount,...
                filteredCount,failedCount,unreachedCount); %#ok<ASGLU>
            
            
            if testReportData.DocumentTypeIsHTML
                imgWidth = 4;
                imgHeight = 2;
            else
                imgWidth = 6;
                imgHeight = 3;
            end
            
            docPart.ImageObject = docPart.createImageObjectFromFigure(fig,...
                testReportData.TemporaryFilesFolder,imgWidth,imgHeight);
        end
        
        function teardownPart(docPart)
            docPart.ImageObject = [];
        end
    end
    
    methods(Hidden)
        function fillImage(docPart)
            docPart.append(docPart.ImageObject);
        end
    end
    
    methods(Hidden,Static,Access=protected)
        function [fig,figEnv] = createPieChartFigure(passedCount,filteredCount,failedCount,unreachedCount)
            import matlab.unittest.internal.plugins.testreport.PieChartSummaryPart;
            catalog = PieChartSummaryPart.Catalog;
            pieValues = [...
                passedCount,...
                filteredCount,...
                failedCount,...
                unreachedCount];
            pieKeys = {...
                catalog.getString('NumTestsPassed',pieValues(1)),...
                catalog.getString('NumTestsFiltered',pieValues(2)),...
                catalog.getString('NumTestsFailed',pieValues(3)),...
                catalog.getString('NumTestsUnreached',pieValues(4))};
            pieColors = {...
                [0,200/255,0],... %green
                [0,0,200/255],... %blue
                [200/255,0,0],... %red
                [1,1,1]}; %white
            
            [fig,figEnv] = pieChart(pieValues,pieKeys,pieColors);
        end
        
        function imgObj = createImageObjectFromFigure(fig,imageFolder,imgWidth,imgHeight)
            import mlreportgen.dom.Image;
            
            imgFile = [tempname(imageFolder) '.png'];
            printFigureToFile(fig,imgFile,imgWidth,imgHeight);
            
            imgObj = Image(imgFile);
            imgObj.Width = sprintf('%uin',imgWidth);
            imgObj.Height = sprintf('%uin',imgHeight);
        end
    end
end

function [fig,figEnv] = pieChart(pieValues,pieKeys,pieColors)
fig = figure('Visible','off');
if nargout > 1
    figEnv = onCleanup(@() close(fig));
end
ax = axes('Parent',fig);

mask = pieValues > 0;
pieValues = pieValues(mask);
pieKeys = pieKeys(mask);
pieColors = pieColors(mask);

numOfSlices = nnz(mask);
explodeMask = true(1,numOfSlices);
p = pie(ax,pieValues,explodeMask);

%Remove labels
labelsMask = arrayfun(@(x) isa(x,'matlab.graphics.primitive.Text'),p);
delete(p(labelsMask));
p(labelsMask) = [];

%Assuming that p is in the order in which I specified my
%values, change the colors:
assert(numel(p) == numOfSlices); %Internal Validation
for k=1:numOfSlices
    p(k).FaceColor = pieColors{k};
end

legend(ax,pieKeys,'Location','eastoutside','FontSize',14,'Box','off');
end

function printFigureToFile(fig,imageFile,width,height)
fig.PaperUnits = 'inches';
fig.PaperPosition = [0,0,width,height];
drawnow;
print(fig,imageFile,'-dpng','-r300');
end

% LocalWords:  unittest uin eastoutside dpng
