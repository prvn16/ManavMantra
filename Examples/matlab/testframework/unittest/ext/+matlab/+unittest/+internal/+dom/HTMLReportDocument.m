classdef HTMLReportDocument < matlab.unittest.internal.dom.ReportDocument & ...
                              matlab.unittest.internal.mixin.MainFileMixin
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        ReportFolder
    end
    
    methods(Access=protected)
        function reportDoc = HTMLReportDocument(reportFolder,varargin)
            import matlab.unittest.internal.parentFolderResolver;
            import matlab.unittest.internal.extractParameterArguments;
            
            reportFolder = parentFolderResolver(reportFolder);
            
            [mainFileArgs,remainingArgs] = extractParameterArguments('MainFile',varargin{:});
            reportDoc = reportDoc@matlab.unittest.internal.mixin.MainFileMixin(mainFileArgs{:});
            reportDoc = reportDoc@matlab.unittest.internal.dom.ReportDocument(remainingArgs{:});
            
            reportDoc.ReportFolder = reportFolder;
        end
        
        function validateReportCanBeCreated(reportDoc)
            import matlab.unittest.internal.validateFolderWithFileCanBeCreated;
            validateFolderWithFileCanBeCreated(reportDoc.ReportFolder,reportDoc.MainFile);
        end
        
        function licensedDocument = createLicensedDocument(reportDoc)
            import matlab.unittest.internal.dom.LicensedDocument;
            
            templateFile = LicensedDocument.Templates.HTML.Standard;

            licensedDocument = LicensedDocument(...
                reportDoc.TemporaryReportFolder,'html',templateFile);
            licensedDocument.PackageType = 'unzipped';
        end
        
        function mainReportFile = copyReportFilesToFinalLocation(reportDoc)
            import matlab.unittest.internal.fileResolver;
            generatedFolder = reportDoc.TemporaryReportFolder;
            if ~strcmpi(reportDoc.MainFile,'index.html')
                movefile(fullfile(generatedFolder,'index.html'),...
                    fullfile(generatedFolder,reportDoc.MainFile));
            end
            copyAndConfirm(fullfile(generatedFolder,'*'),reportDoc.ReportFolder);
            mainReportFile = fileResolver(fullfile(reportDoc.ReportFolder,reportDoc.MainFile));
        end
        
        function txt = generateOpenCommand(~,mainReportFile)
            txt = sprintf('web(''%s'',''-new'')',strrep(mainReportFile,'''',''''''));
        end
    end
end


function copyAndConfirm(source,desination)
[copySuccess,msg,msgId] = copyfile(source,desination,'f');
assert(copySuccess,msgId,'%s',msg);
end