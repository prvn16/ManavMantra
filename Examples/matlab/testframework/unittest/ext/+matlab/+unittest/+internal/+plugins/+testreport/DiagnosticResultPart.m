classdef DiagnosticResultPart < matlab.unittest.internal.dom.ReportDocumentPart
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        DiagnosticLabel
        FormattableDiagnosticText
        Artifacts
    end
    
    properties(Access=private)
        LeftArtifactImageParts = [];
    end
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestReportDocument');
    end
    
    methods(Access=private)
        function docPart = DiagnosticResultPart(diagLabel,formattableDiagnosticText,artifacts)
            docPart.DiagnosticLabel = diagLabel;
            docPart.FormattableDiagnosticText = formattableDiagnosticText;
            docPart.Artifacts = artifacts;
        end
    end
    
    methods(Access=protected)
        function delegateDocPart = createDelegateDocumentPart(~,testReportData)
            delegateDocPart = testReportData.createDelegateDocumentPartFromName('DiagnosticResultPart');
        end
        
        function setupPart(docPart,testReportData)
            import matlab.unittest.internal.plugins.testreport.BlankPart;
            import matlab.unittest.internal.plugins.testreport.LeftArtifactImagePart;
            
            compatibilityMask = arrayfun(@(x) isa(x,'matlab.unittest.diagnostics.FileArtifact') & ...
                docPart.isSupportedImageExtension(x.Extension,testReportData.DocumentType),...
                docPart.Artifacts);
            compatibileArtifacts = docPart.Artifacts(compatibilityMask);
            
            if isempty(compatibileArtifacts)
                docPart.LeftArtifactImageParts = BlankPart();
            else
                LeftArtifactImagePartsCell = arrayfun(@(x) LeftArtifactImagePart(char(x.FullPath)),...
                    compatibileArtifacts, 'UniformOutput', false);
                docPart.LeftArtifactImageParts = [LeftArtifactImagePartsCell{:}];
            end
            
            docPart.LeftArtifactImageParts.setup(testReportData);
        end
        
        function teardownPart(docPart)
            docPart.LeftArtifactImageParts = [];
        end
    end
    
    methods(Hidden) % Fill template holes ---------------------------------
        function fillDiagnosticLabel(docPart)
            docPart.append(docPart.DiagnosticLabel);
        end
        
        function fillDiagnosticText(docPart)
            %Get non-enriched version of the result
            diagText = deblank(char(docPart.FormattableDiagnosticText.Text));
            docPart.appendPreText(diagText);
        end
        
        function fillLeftArtifactImageParts(docPart)
            docPart.append(docPart.LeftArtifactImageParts);
        end
    end
    
    methods(Static)
        function docParts = fromFormattableDiagnosticResults(formattableResults,diagType)
            import matlab.unittest.internal.plugins.testreport.DiagnosticResultPart;
            catalog = DiagnosticResultPart.Catalog;
            
            %Remove results that have empty text
            emptyTextMask = arrayfun(@(x) strlength(x.FormattableDiagnosticText.Text)==0,...
                formattableResults);
            formattableResults(emptyTextMask) = [];
            
            count = numel(formattableResults);

            if count == 0
                docParts = DiagnosticResultPart.empty(1,0);
                return;
            elseif count == 1
                diagLabelFcn = @(k) catalog.getString([diagType 'DiagnosticLabel']);
            else
                diagLabelFcn = @(k) catalog.getString([diagType 'DiagnosticKLabel'],k);
            end
            docParts = arrayfun(@(k) DiagnosticResultPart(diagLabelFcn(k),...
                formattableResults(k).FormattableDiagnosticText,formattableResults(k).Artifacts), ...
                1:count);
        end
        
        function docPart = fromLabelAndFormattableString(diagLabel,formattableString)
            import matlab.unittest.internal.plugins.testreport.DiagnosticResultPart;
            import matlab.unittest.diagnostics.FileArtifact;
            docPart = DiagnosticResultPart(diagLabel,formattableString,FileArtifact.empty(1,0));
        end
        
        function bool = isSupportedImageExtension(extension,documentType)
            % The following is a mapping to the supported image formats according to:
            % http://www.mathworks.com/help/rptgen/ug/mlreportgen.dom.image-class.html
            if strcmp(documentType,'html')
                supportedExtensions = {'.bmp','.gif','.jpg','.png','.svg'};
            elseif strcmp(documentType,'docx')
                supportedExtensions = {'.bmp','.emf','.gif','.jpg','.png','.tif'};
            elseif strcmp(documentType,'pdf')
                supportedExtensions = {'.bmp','.gif','.jpg','.png','.svg','.tif'};
            end
            bool = ismember(lower(extension),supportedExtensions);
        end
    end
end

% LocalWords:  unittest KLabel rptgen ug mlreportgen dom svg tif
