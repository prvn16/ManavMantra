classdef PDFReportDocument < matlab.unittest.internal.dom.ReportDocument & ...
        matlab.unittest.internal.mixin.PageOrientationMixin
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        ReportFile
    end
    
    properties(Hidden,SetAccess=immutable)
        RetainIntermediateFiles = false;
    end
    
    properties(Dependent,Access=private)
        TemporaryReportFile
    end
    
    properties(Constant,Access=private)
        ArgumentParser = createArgumentParser();
    end
    
    methods
        function value = get.TemporaryReportFile(reportDoc)
            [~,fileName,fileExt] = fileparts(reportDoc.ReportFile);
            value = fullfile(reportDoc.TemporaryReportFolder,[fileName,fileExt]);
        end
    end
    
    methods(Access=protected)
        function reportDoc = PDFReportDocument(reportFile, varargin)
            import matlab.unittest.internal.validateFileNameForSaving;
            import matlab.unittest.internal.dom.PDFReportDocument;
            import matlab.unittest.internal.extractParameterArguments;
            
            reportFile = validateFileNameForSaving(reportFile,'.pdf');
            
            [retainIntermediateFilesArgs,remainingArgs] = extractParameterArguments(...
                'RetainIntermediateFiles',varargin{:});
            parser = PDFReportDocument.ArgumentParser;
            parser.parse(retainIntermediateFilesArgs{:});
            [pageOrientationArgs,remainingArgs] = extractParameterArguments('PageOrientation',remainingArgs{:});
            reportDoc = reportDoc@matlab.unittest.internal.mixin.PageOrientationMixin(pageOrientationArgs{:});
            reportDoc = reportDoc@matlab.unittest.internal.dom.ReportDocument(remainingArgs{:});
            
            reportDoc.ReportFile = reportFile;
            reportDoc.RetainIntermediateFiles = parser.Results.RetainIntermediateFiles;
        end
        
        function validateReportCanBeCreated(reportDoc)
            matlab.unittest.internal.validateFileCanBeCreated(reportDoc.ReportFile);
        end
        
        function licensedDocument = createLicensedDocument(reportDoc)
            import matlab.unittest.internal.dom.LicensedDocument;
            
            if strcmp(reportDoc.PageOrientation,'portrait')
                templateFile = LicensedDocument.Templates.PDF.LetterPortraitWithNarrowMargins;
            else % 'landscape'
                templateFile = LicensedDocument.Templates.PDF.LetterLandscapeWithNarrowMargins;
            end
            
            licensedDocument = LicensedDocument(reportDoc.TemporaryReportFile,'pdf',templateFile);
            licensedDocument.RetainFO = reportDoc.RetainIntermediateFiles;
        end
        
        function mainReportFile = copyReportFilesToFinalLocation(reportDoc)
            import matlab.unittest.internal.fileResolver;
            
            generatedFile = reportDoc.TemporaryReportFile;
            copyAndConfirm(generatedFile,reportDoc.ReportFile);
            mainReportFile = fileResolver(reportDoc.ReportFile);
            
            if reportDoc.RetainIntermediateFiles
                [tempLocation,fileName,~] = fileparts(generatedFile);
                newLocation = fileparts(mainReportFile);
                copyAndConfirm(fullfile(tempLocation,[fileName,'_FO']),...
                    fullfile(newLocation,[fileName,'_FO']));
            end
        end
        
        function txt = generateOpenCommand(~,mainReportFile)
            txt = sprintf('open(''%s'')',strrep(mainReportFile,'''',''''''));
        end
    end
end


function parser = createArgumentParser()
parser = matlab.unittest.internal.strictInputParser;
parser.addParameter('RetainIntermediateFiles', false, ...
    @(x) validateattributes(x,{'logical'},{'scalar'},'','RetainIntermediateFiles'));
end


function copyAndConfirm(source,desination)
[copySuccess,msg,msgId] = copyfile(source,desination,'f');
assert(copySuccess,msgId,'%s',msg);
end

% LocalWords:  FO
