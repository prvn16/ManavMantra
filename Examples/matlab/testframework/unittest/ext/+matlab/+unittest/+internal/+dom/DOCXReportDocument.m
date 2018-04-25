classdef DOCXReportDocument < matlab.unittest.internal.dom.ReportDocument & ...
        matlab.unittest.internal.mixin.PageOrientationMixin
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        ReportFile
    end
    
    properties(Dependent,Access=private)
        TemporaryReportFile
    end
    
    methods
        function value = get.TemporaryReportFile(reportDoc)
            [~,fileName,fileExt] = fileparts(reportDoc.ReportFile);
            value = fullfile(reportDoc.TemporaryReportFolder,[fileName,fileExt]);
        end
    end
    
    methods(Access=protected)
        function reportDoc = DOCXReportDocument(reportFile,varargin)
            import matlab.unittest.internal.validateFileNameForSaving;
            import matlab.unittest.internal.extractParameterArguments;
            
            reportFile = validateFileNameForSaving(reportFile,'.docx');
            
            [pageOrientationArgs,remainingArgs] = extractParameterArguments('PageOrientation',varargin{:});
            reportDoc = reportDoc@matlab.unittest.internal.mixin.PageOrientationMixin(pageOrientationArgs{:});
            reportDoc = reportDoc@matlab.unittest.internal.dom.ReportDocument(remainingArgs{:});
            
            reportDoc.ReportFile = reportFile;
        end
        
        function validateReportCanBeCreated(reportDoc)
            matlab.unittest.internal.validateFileCanBeCreated(reportDoc.ReportFile);
        end
        
        function licensedDocument = createLicensedDocument(reportDoc)
            import matlab.unittest.internal.dom.LicensedDocument;
            
            if strcmp(reportDoc.PageOrientation,'portrait')
                templateFile = LicensedDocument.Templates.DOCX.LetterPortraitWithNarrowMargins;
            else % 'landscape'
                templateFile = LicensedDocument.Templates.DOCX.LetterLandscapeWithNarrowMargins;
            end
            
            licensedDocument = LicensedDocument(reportDoc.TemporaryReportFile,'docx',templateFile);
        end
        
        function mainReportFile = copyReportFilesToFinalLocation(reportDoc)
            import matlab.unittest.internal.fileResolver;
            copyAndConfirm(reportDoc.TemporaryReportFile,reportDoc.ReportFile);
            mainReportFile = fileResolver(reportDoc.ReportFile);
        end
        
        function txt = generateOpenCommand(~,mainReportFile)
            txt = sprintf('open(''%s'')',strrep(mainReportFile,'''',''''''));
        end
    end
end


function copyAndConfirm(source,desination)
[copySuccess,msg,msgId] = copyfile(source,desination,'f');
assert(copySuccess,msgId,'%s',msg);
end