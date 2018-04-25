classdef DOCXTestReportPlugin < matlab.unittest.plugins.TestReportPlugin & ...
                                matlab.unittest.internal.mixin.PageOrientationMixin
    % DOCXTestReportPlugin - Plugin to create a test report in '.docx' format
    %
    %   A DOCXTestReportPlugin can only be constructed with the
    %   TestReportPlugin.producingDOCX method.
    %
    %   DOCXTestReportPlugin Properties:
    %       ExcludeLoggedDiagnostics - Boolean that specifies if logged diagnostics are excluded from the report
    %       IncludeCommandWindowText - Boolean that specifies if command window text is included in the report
    %       IncludePassingDiagnostics - Boolean that specifies if diagnostics from passing events are included in the report
    %       Verbosity - Verbosity levels supported by this plugin instance
    %       PageOrientation - Character vector that specifies the page orientation of the report
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
    %       docxFile = 'MyTestReport.docx';
    %       plugin = TestReportPlugin.producingDOCX(docxFile);
    %       runner.addPlugin(plugin);
    %
    %       result = runner.run(suite);
    %
    %       open(docxFile);
    %
    %   See Also:
    %       matlab.unittest.plugins.TestReportPlugin
    %       matlab.unittest.plugins.TestReportPlugin.producingDOCX
    
    % Copyright 2016-2017 The MathWorks, Inc.
    properties(Hidden,SetAccess=immutable)
        ReportFile
    end
    
    methods(Access=?matlab.unittest.plugins.TestReportPlugin)
        function plugin = DOCXTestReportPlugin(varargin)
            import matlab.unittest.internal.validateFileNameForSaving;
            import matlab.unittest.internal.extractParameterArguments;
            
            if mod(nargin,2) == 1 % odd
                reportFile = validateFileNameForSaving(varargin{1},'.docx');
                allArgs = varargin(2:end);
            else % even
                reportFile = [tempname() '.docx'];
                allArgs = varargin;
            end
            
            [pageOrientationArgs,remainingArgs] = extractParameterArguments('PageOrientation',allArgs{:});
            plugin = plugin@matlab.unittest.internal.mixin.PageOrientationMixin(pageOrientationArgs{:});
            plugin = plugin@matlab.unittest.plugins.TestReportPlugin(remainingArgs{:});
            
            plugin.ReportFile = reportFile;
        end
    end
    
    methods(Hidden,Access=protected)
        function validateReportCanBeCreated(plugin)
            matlab.unittest.internal.validateFileCanBeCreated(plugin.ReportFile);
        end
        
        function reportDocument = createReportDocument(plugin,testSessionData)
            import matlab.unittest.internal.plugins.testreport.DOCXTestReportDocument;
            reportDocument = DOCXTestReportDocument(plugin.ReportFile,testSessionData,...
                'PageOrientation',plugin.PageOrientation,'ProgressStream',plugin.ProgressStream);
        end
    end
end

% LocalWords:  unittest plugins mypackage
