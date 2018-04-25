classdef PDFTestReportPlugin < matlab.unittest.plugins.TestReportPlugin & ...
                               matlab.unittest.internal.mixin.PageOrientationMixin
    % PDFTestReportPlugin - Plugin to create a test report in '.pdf' format
    %
    %   A PDFTestReportPlugin can only be constructed with the
    %   TestReportPlugin.producingPDF method.
    %
    %   PDFTestReportPlugin Properties:
    %       ExcludeLoggedDiagnostics - Boolean that specifies if logged diagnostics are excluded from the report
    %       IncludeCommandWindowText - Boolean that specifies if command window text is included in the report
    %       IncludePassingDiagnostics - Boolean that specifies if diagnostics from passing events are included in the report
    %       Verbosity - Verbosity levels supported by this plugin instance
    %       PageOrientation - Character vector that specifies the page orientation of the report
    %   
    %   PDF test reports are generated based on your system locale and the font
    %   families installed on your machine. When generating a report with a
    %   non-English locale, unless your machine has the 'Noto Sans CJK' font
    %   families installed, the report may have pound sign characters (#) in
    %   place of Chinese, Japanese, and Korean characters.
    %   
    %   Examples:
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.TestReportPlugin;
    %
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %       % Create a test runner
    %       runner = TestRunner.withTextOutput;
    %
    %       % Add an TestReportPlugin to the TestRunner
    %       pdfFile = 'MyTestReport.pdf';
    %       plugin = TestReportPlugin.producingPDF(pdfFile);
    %       runner.addPlugin(plugin);
    %
    %       result = runner.run(suite);
    %
    %       open(pdfFile);
    %
    %   See Also:
    %       matlab.unittest.plugins.TestReportPlugin
    %       matlab.unittest.plugins.TestReportPlugin.producingPDF
    
    % Copyright 2016-2017 The MathWorks, Inc.
    properties(Hidden,SetAccess=immutable)
        ReportFile
        RetainIntermediateFiles = false;
    end
    
    properties(Constant,Access=private)
        ArgumentParser = createArgumentParser();
    end
    
    methods(Access=?matlab.unittest.plugins.TestReportPlugin)
        function plugin = PDFTestReportPlugin(varargin)
            import matlab.unittest.internal.validateFileNameForSaving;
            import matlab.unittest.plugins.testreport.PDFTestReportPlugin;
            import matlab.unittest.internal.extractParameterArguments;
            
            if mod(nargin,2) == 1 % odd
                reportFile = validateFileNameForSaving(varargin{1},'.pdf');
                allArgs = varargin(2:end);
            else % even
                reportFile = [tempname() '.pdf'];
                allArgs = varargin;
            end
            
            [retainIntermediateFilesArgs,remainingArgs] = extractParameterArguments(...
                'RetainIntermediateFiles',allArgs{:});
            parser = PDFTestReportPlugin.ArgumentParser;
            parser.parse(retainIntermediateFilesArgs{:});
            [pageOrientationArgs,remainingArgs] = extractParameterArguments('PageOrientation',remainingArgs{:});
            plugin = plugin@matlab.unittest.internal.mixin.PageOrientationMixin(pageOrientationArgs{:});
            plugin = plugin@matlab.unittest.plugins.TestReportPlugin(remainingArgs{:});
            
            plugin.ReportFile = reportFile;
            plugin.RetainIntermediateFiles = parser.Results.RetainIntermediateFiles;
        end
    end
    
    methods(Hidden,Access=protected)
        function validateReportCanBeCreated(plugin)
            matlab.unittest.internal.validateFileCanBeCreated(plugin.ReportFile);
        end
        
        function reportDocument = createReportDocument(plugin,testSessionData)
            import matlab.unittest.internal.plugins.testreport.PDFTestReportDocument;
            reportDocument = PDFTestReportDocument(plugin.ReportFile,testSessionData,...
                'PageOrientation',plugin.PageOrientation,'ProgressStream',plugin.ProgressStream,...
                'RetainIntermediateFiles',plugin.RetainIntermediateFiles);
        end
    end
end


function parser = createArgumentParser()
parser = matlab.unittest.internal.strictInputParser;
parser.addParameter('RetainIntermediateFiles', false, ...
    @(x) validateattributes(x,{'logical'},{'scalar'},'','RetainIntermediateFiles'));
end

% LocalWords:  Noto CJK unittest plugins mypackage
