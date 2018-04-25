classdef ReportDocument < handle
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    
    properties(Hidden,SetAccess=immutable)
        ProgressPrinter
    end
    
    properties(Hidden,SetAccess=protected)
        %ReportDocumentParts - ReportDocumentPart instances to be included in the report
        %
        %   The ReportDocumentParts property is a vector of ReportDocumentPart
        %   instances and can only be set via the ReportDocument constructor.
        %
        %   See Also:
        %       matlab.unittest.internal.dom.ReportDocumentPart
        ReportDocumentParts (1,:) matlab.unittest.internal.dom.ReportDocumentPart
    end
    
    properties(Dependent,Hidden,GetAccess=protected,SetAccess=private)
        TemporaryReportFolder
    end
    
    properties(Hidden,GetAccess=protected,SetAccess=private)
        LicensedDocument = [];
    end
    
    properties(Dependent,Access=private)
        HasBeenSetup
    end
    
    properties(Access=private)
        HasBeenFilled = false;
        InternalTemporaryFolderFixture
        InternalReportData
    end
    
    properties(Constant,Access=private)
        ArgumentParser = createArgumentParser();
    end
    
    methods(Abstract,Access=protected)
        validateReportCanBeCreated(reportDoc);
        reportData = createReportData(reportDoc);
        licensedDocument = createLicensedDocument(reportDoc);
        mainReportFile = copyReportFilesToFinalLocation(reportDoc);
        txt = generateOpenCommand(reportDoc,mainReportFile);
    end
    
    methods
        function bool = get.HasBeenSetup(reportDoc)
            bool = ~isempty(reportDoc.LicensedDocument);
        end
        
        function folder = get.TemporaryReportFolder(reportDoc)
            folder = reportDoc.InternalTemporaryFolderFixture.Folder;
        end
        
        function delete(reportDoc)
            reportDoc.teardown();
        end
    end
    
    methods(Hidden, Access=protected)
        function reportDoc = ReportDocument(varargin)
            import matlab.unittest.internal.dom.ReportDocument;
            import matlab.unittest.internal.plugins.LinePrinter;
            
            parser = ReportDocument.ArgumentParser;
            parser.parse(varargin{:});
            
            reportDoc.ProgressPrinter = LinePrinter(parser.Results.ProgressStream);
        end
    end
    
    methods(Sealed)
        function generateReport(reportDoc)
            import matlab.unittest.internal.diagnostics.indent;
            import matlab.unittest.internal.diagnostics.CommandHyperlinkableString;
            import matlab.unittest.internal.diagnostics.MessageString;
            
            reportDoc.validateReportCanBeCreated();
            
            reportDoc.ProgressPrinter.printLine(getString(message(...
                'MATLAB:unittest:ReportDocument:GeneratingReport')));
            
            % Setup information to include in the report
            reportDoc.ProgressPrinter.printIndentedLine(getString(message(...
                'MATLAB:unittest:ReportDocument:PreparingContent')));
            reportDoc.setup();
            
            % Fill in the report with content
            reportDoc.ProgressPrinter.printIndentedLine(getString(message(...
                'MATLAB:unittest:ReportDocument:AddingContent')));
            reportDoc.fill();
            
            % Copy generated files to user specified location
            reportDoc.ProgressPrinter.printIndentedLine(getString(message(...
                'MATLAB:unittest:ReportDocument:WritingFile')));
            mainReportFile = reportDoc.copyReportFilesToFinalLocation();
            
            % Create a link to open the report
            openCmd = reportDoc.generateOpenCommand(mainReportFile);
            reportFileLinkString = CommandHyperlinkableString(mainReportFile, openCmd);
            reportDoc.ProgressPrinter.printLine(MessageString(...
                'MATLAB:unittest:ReportDocument:ReportSaved',reportFileLinkString));
            
            % Teardown to remove temporary folder
            reportDoc.teardown();
        end
    end
    
    methods(Hidden, Sealed, Access=protected)
        function setup(reportDoc)
            import matlab.unittest.fixtures.TemporaryFolderFixture;
            if ~reportDoc.HasBeenSetup
                reportDoc.InternalReportData = reportDoc.createReportData();
                reportDoc.InternalTemporaryFolderFixture = TemporaryFolderFixture();
                reportDoc.InternalTemporaryFolderFixture.setup();
                reportDoc.ReportDocumentParts.setup(reportDoc.InternalReportData);
                reportDoc.LicensedDocument = reportDoc.createLicensedDocument();
                reportDoc.HasBeenFilled = false;
            end
        end
        
        function teardown(reportDoc)
            if reportDoc.HasBeenSetup
                reportDoc.LicensedDocument = [];
                reportDoc.InternalTemporaryFolderFixture.teardown();
                reportDoc.ReportDocumentParts.teardown();
                reportDoc.InternalReportData = [];
            end
        end
        
        function fill(reportDoc)
            canBeFilled = reportDoc.HasBeenSetup & ~reportDoc.HasBeenFilled;
            assert(canBeFilled); %Internal validation
            
            keepOpenEnvironment = reportDoc.openLicensedDocument();
            licensedDocument = reportDoc.LicensedDocument;
            
            licensedDocument.moveToNextHole();
            while ~strcmp(licensedDocument.CurrentHoleId,'#end#')
                fillHole = str2func(['fill' licensedDocument.CurrentHoleId]);
                fillHole(reportDoc);
                licensedDocument.moveToNextHole();
            end
            
            delete(keepOpenEnvironment);
            reportDoc.HasBeenFilled = true;
        end
    end
    
    methods(Access=private)
        function fillReportContent(reportDoc)
            reportDoc.appendIfApplicable(reportDoc.ReportDocumentParts);
        end
        
        function appendIfApplicable(reportDoc,docParts)
            mask = docParts.isApplicable();
            reportDoc.appendReportDocumentParts(docParts(mask));
        end
        
        function appendReportDocumentParts(reportDoc,docParts)
            assert(reportDoc.HasBeenSetup); %Internal validation
            assert(all([docParts.HasBeenSetup])); %Internal validation
            
            for docPart = docParts
                if ~docPart.HasBeenFilled
                    docPart.fill();
                end
                reportDoc.LicensedDocument.append(docPart.DelegateDocumentPart);
                docPart.teardown(); %To keep a low memory footprint
            end
        end
        
        function keepOpenEnvironment = openLicensedDocument(reportDoc)
            openSuccess = reportDoc.LicensedDocument.licensedOpen();
            assert(openSuccess); %Internal validation
            keepOpenEnvironment = onCleanup(@() reportDoc.closeLicensedDocument());
        end
        
        function closeLicensedDocument(reportDoc)
            closeSuccess = reportDoc.LicensedDocument.close();
            assert(closeSuccess); %Internal validation
        end
    end
end


function parser = createArgumentParser()
import matlab.unittest.plugins.ToStandardOutput;
parser = matlab.unittest.internal.strictInputParser;
parser.addParameter('ProgressStream',ToStandardOutput(),...
    @(x) validateattributes(x,{'matlab.unittest.plugins.OutputStream'},{'scalar'}));
end

% LocalWords:  unittest dom Teardown plugins
