classdef TestReportPlugin < matlab.unittest.plugins.TestRunnerPlugin
    % TestReportPlugin - Plugin to create a report of test results
    %
    % Use the TestReportPlugin to configure the TestRunner to produce a
    % test report in '.docx', '.html', or '.pdf' format. This plugin is useful
    % to produce readable, navigable, and archivable test reports.
    %
    %   TestReportPlugin Methods:
    %       producingDOCX - Construct a plugin that produces a '.docx' report
    %       producingHTML - Construct a plugin that produces a '.html' report
    %       producingPDF - Construct a plugin that produces a '.pdf' report
    %
    %   TestReportPlugin Properties:
    %       ExcludeLoggedDiagnostics - Boolean that specifies if logged diagnostics are excluded from the report
    %       IncludeCommandWindowText - Boolean that specifies if command window text is included in the report
    %       IncludePassingDiagnostics - Boolean that specifies if diagnostics from passing events are included in the report
    %       Verbosity - Verbosity levels supported by this plugin instance
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
    %       matlab.unittest.plugins.testreport.DOCXTestReportPlugin
    %       matlab.unittest.plugins.testreport.PDFTestReportPlugin
    %       matlab.unittest.plugins.testreport.HTMLTestReportPlugin
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties(SetAccess=immutable)
        % ExcludeLoggedDiagnostics - Boolean that specifies if logged diagnostics are excluded from the report
        %
        %   The ExcludeLoggedDiagnostics property is a boolean (true or false)
        %   that specifies whether logged diagnostics are excluded from the report.
        %   This property is read only and can be set only through the constructor.
        ExcludeLoggedDiagnostics
        
        % IncludeCommandWindowText - Boolean that specifies if command window text is included in the report
        %
        %   The IncludeCommandWindowText property is a boolean (true or false) that
        %   specifies whether the text that appears in the command window during
        %   test execution is included in the report. This property is read
        %   only and can be set only through the constructor.
        %
        %   If this property is set to true, then hyperlinks will be temporarily
        %   turned off in the command window during test execution.
        IncludeCommandWindowText
        
        % IncludePassingDiagnostics - Boolean that specifies if diagnostics from passing events are included in the report
        %
        %   The IncludePassingDiagnostics property is a boolean (true or false)
        %   that specifies whether diagnostics from passing events are included in
        %   the report. This property is read only and can be set only through the
        %   constructor.
        IncludePassingDiagnostics
        
        % Verbosity - Verbosity levels supported by this plugin instance
        %
        %   The Verbosity property is an array of matlab.unittest.Verbosity
        %   instances. When the ExcludeLoggedDiagnostics property is false, then
        %   only logged diagnostics that are logged at a level listed in this array
        %   will be included in the report. This property is read only and can be
        %   set only through the constructor.
        Verbosity
    end
    
    properties(Hidden, SetAccess=private)
        ProgressStream
    end
    
    properties(Access=private)
        EventRecordGatherer
    end
    
    methods(Hidden, Access=protected)
        function plugin = TestReportPlugin(varargin)           
            parser = createArgumentParser();
            parser.parse(varargin{:});
            plugin.IncludePassingDiagnostics = parser.Results.IncludingPassingDiagnostics;
            plugin.IncludeCommandWindowText = parser.Results.IncludingCommandWindowText;
            plugin.ExcludeLoggedDiagnostics = parser.Results.ExcludingLoggedDiagnostics;
            plugin.Verbosity = matlab.unittest.Verbosity(1:double(parser.Results.Verbosity));
            
            % Undocumented properties:
            plugin.ProgressStream = parser.Results.ProgressStream;
        end
    end
    
    methods(Static)
        function plugin = producingDOCX(varargin)
            % producingDOCX - Construct a plugin that produces a '.docx' report
            %
            %   PLUGIN = TestReportPlugin.producingDOCX() returns a plugin that
            %   produces a '.docx' report in the temporary folder. This syntax is
            %   equivalent to TestReportPlugin.producingDOCX([tempname '.docx']).
            %
            %   PLUGIN = TestReportPlugin.producingDOCX(DOCXFILENAME) returns a plugin
            %   that produces a '.docx' report. The output is printed to the file
            %   DOCXFILENAME. Every time the suite is run with this plugin, the file
            %   DOCXFILENAME is overwritten.
            %
            %   PLUGIN = TestReportPlugin.producingDOCX(...,'ExcludingLoggedDiagnostics',true)
            %   produces a TestReportPlugin that excludes logged diagnostics from the
            %   report.
            %
            %   PLUGIN = TestReportPlugin.producingDOCX(...,'IncludingCommandWindowText',true)
            %   produces a TestReportPlugin that includes the text that appears in the
            %   command window during test execution in the report.
            %
            %   PLUGIN = TestReportPlugin.producingDOCX(...,'IncludingPassingDiagnostics',true)
            %   produces a TestReportPlugin that includes diagnostics from passing
            %   events in the report.
            %
            %   PLUGIN = TestReportPlugin.producingDOCX(...,'Verbosity',VERBOSITY)
            %   produces a TestReportPlugin that includes diagnostics logged at
            %   level VERBOSITY or lower in the report. This name/value pair is ignored
            %   if 'ExcludingLoggedDiagnostics' is set to true.
            %
            %   PLUGIN = TestReportPlugin.producingDOCX(...,'PageOrientation',VALUE)
            %   produces a TestReportPlugin that produces a report with a page
            %   orientation specified by VALUE. VALUE can either be 'portrait'
            %   (default) or 'landscape'.
            %
            %   See Also:
            %       matlab.unittest.plugins.testreport.DOCXTestReportPlugin
            
            plugin = matlab.unittest.plugins.testreport.DOCXTestReportPlugin(varargin{:});
        end
        
        function plugin = producingHTML(varargin)
            % producingHTML - Construct a plugin that produces a '.html' report
            %
            %   PLUGIN = TestReportPlugin.producingHTML() returns a plugin that
            %   produces a '.html' report in the temporary folder. This syntax is
            %   equivalent to TestReportPlugin.producingHTML(tempname).
            %
            %   PLUGIN = TestReportPlugin.producingHTML(HTMLFOLDER) returns a plugin
            %   that produces a '.html' report. The plugin saves the report output
            %   inside of the folder specified by HTMLFOLDER with 'index.html' as the
            %   main file. Every time the suite is run with this plugin, the contents
            %   inside the specified folder may be overwritten.
            %
            %   PLUGIN = TestReportPlugin.producingHTML(...,'ExcludingLoggedDiagnostics',true)
            %   produces a TestReportPlugin that excludes logged diagnostics from the
            %   report.
            %
            %   PLUGIN = TestReportPlugin.producingHTML(...,'IncludingCommandWindowText',true)
            %   produces a TestReportPlugin that includes the text that appears in the
            %   command window during test execution in the report.
            %
            %   PLUGIN = TestReportPlugin.producingHTML(...,'IncludingPassingDiagnostics',true)
            %   produces a TestReportPlugin that includes diagnostics from passing
            %   events in the report.
            %
            %   PLUGIN = TestReportPlugin.producingHTML(...,'Verbosity',VERBOSITY)
            %   produces a TestReportPlugin that includes diagnostics logged at
            %   level VERBOSITY or lower in the report. This name/value pair is ignored
            %   if 'ExcludingLoggedDiagnostics' is set to true.
            %
            %   PLUGIN = TestReportPlugin.producingHTML(...,'MainFile',MAINFILENAME)
            %   produces a TestReportPlugin where MAINFILENAME is used as the name of
            %   the main file in the generated HTML report. By default MAINFILENAME is
            %   'index.html'. The location of the main file in a generated HTML report
            %   is fullfile(HTMLFOLDER,mainFileName).
            %
            %   See Also:
            %       matlab.unittest.plugins.testreport.HTMLTestReportPlugin
            
            plugin = matlab.unittest.plugins.testreport.HTMLTestReportPlugin(varargin{:});
        end
        
        function plugin = producingPDF(varargin)
            % producingPDF - Construct a plugin that produces a '.pdf' report
            %
            %   PLUGIN = TestReportPlugin.producingPDF() returns a plugin that
            %   produces a '.pdf' report in the temporary folder. This syntax
            %   is equivalent to TestReportPlugin.producingPDF([tempname '.pdf']).
            %
            %   PLUGIN = TestReportPlugin.producingPDF(PDFFILENAME) returns a plugin
            %   that produces a '.pdf' report. The output is printed to the file
            %   PDFFILENAME. Every time the suite is run with this plugin, the file
            %   PDFFILENAME is overwritten.
            %
            %   PLUGIN = TestReportPlugin.producingPDF(...,'ExcludingLoggedDiagnostics',true)
            %   produces a TestReportPlugin that excludes logged diagnostics from the
            %   report.
            %
            %   PLUGIN = TestReportPlugin.producingPDF(...,'IncludingCommandWindowText',true)
            %   produces a TestReportPlugin that includes the text that appears in the
            %   command window during test execution in the report.
            %
            %   PLUGIN = TestReportPlugin.producingPDF(...,'IncludingPassingDiagnostics',true)
            %   produces a TestReportPlugin that includes diagnostics from passing
            %   events in the report.
            %
            %   PLUGIN = TestReportPlugin.producingPDF(...,'Verbosity',VERBOSITY)
            %   produces a TestReportPlugin that includes diagnostics logged at
            %   level VERBOSITY or lower in the report. This name/value pair is ignored
            %   if 'ExcludingLoggedDiagnostics' is set to true.
            %
            %   PLUGIN = TestReportPlugin.producingPDF(...,'PageOrientation',VALUE)
            %   produces a TestReportPlugin that produces a report with a page
            %   orientation specified by VALUE. VALUE can either be 'portrait'
            %   (default) or 'landscape'.
            %
            %   PDF test reports are generated based on your system locale and the font
            %   families installed on your machine. When generating a report with a
            %   non-English locale, unless your machine has the 'Noto Sans CJK' font
            %   families installed, the report may have pound sign characters (#) in
            %   place of Chinese, Japanese, and Korean characters.
            %
            %   See Also:
            %       matlab.unittest.plugins.testreport.PDFTestReportPlugin
            
            plugin = matlab.unittest.plugins.testreport.PDFTestReportPlugin(varargin{:});
        end
    end
    
    methods (Access=protected)
        function runTestSuite(plugin, pluginData)
            import matlab.unittest.internal.plugins.RawOutputCollector;
            import matlab.unittest.internal.CancelableCleanup;
            
            plugin.validateReportCanBeCreated();
            
            plugin.EventRecordGatherer = plugin.createEventRecordGatherer(pluginData);
            
            rawOutputCollector = RawOutputCollector();
            if plugin.IncludeCommandWindowText
                rawOutputCollector.turnCollectingOn();
                cleanupObj = CancelableCleanup(@() plugin.generateReport(pluginData,rawOutputCollector));
            else
                cleanupObj = CancelableCleanup(@() plugin.generateReport(pluginData,rawOutputCollector));
            end
            
            plugin.runTestSuite@matlab.unittest.plugins.TestRunnerPlugin(pluginData);
            
            cleanupObj.cancel();
            cleanupObj.Task();
        end
        
        function fixture = createSharedTestFixture(plugin,pluginData)
            fixture = plugin.createSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(pluginData);
            eventLocation = pluginData.Name;
            plugin.EventRecordGatherer.addListenersToSharedTestFixture(fixture, eventLocation, pluginData.AffectedIndices);
        end
        
        function testCase = createTestClassInstance(plugin,pluginData)
            testCase = plugin.createTestClassInstance@matlab.unittest.plugins.TestRunnerPlugin(pluginData);
            eventLocation = pluginData.Name;
            plugin.EventRecordGatherer.addListenersToTestClassInstance(testCase, eventLocation, pluginData.AffectedIndices);
        end
        
        function testCase = createTestMethodInstance(plugin,pluginData)
            testCase = plugin.createTestMethodInstance@matlab.unittest.plugins.TestRunnerPlugin(pluginData);
            eventLocation = pluginData.Name;
            plugin.EventRecordGatherer.addListenersToTestMethodInstance(testCase, eventLocation, pluginData.AffectedIndices);
        end
    end
    
    methods(Abstract, Hidden, Access=protected)
        validateReportCanBeCreated(plugin)

        reportDocument = createReportDocument(testSessionData)
    end
        
    methods(Access=private)
        function recordGatherer = createEventRecordGatherer(plugin,pluginData)
            import matlab.unittest.internal.plugins.EventRecordGatherer;
            
            recordGatherer = EventRecordGatherer(numel(pluginData.TestSuite)); %#ok<CPROPLC>
            recordGatherer.VerbosityLevels = plugin.Verbosity;
            if ~plugin.IncludePassingDiagnostics
                passingEvents = ["VerificationPassed","AssertionPassed",...
                    "FatalAssertionPassed","AssumptionPassed"];
                recordGatherer.FixtureEvents = setdiff(recordGatherer.FixtureEvents, passingEvents);
                recordGatherer.TestCaseEvents = setdiff(recordGatherer.TestCaseEvents, passingEvents);
            end
            if plugin.ExcludeLoggedDiagnostics
                recordGatherer.FixtureEvents = setdiff(recordGatherer.FixtureEvents, "DiagnosticLogged");
                recordGatherer.TestCaseEvents = setdiff(recordGatherer.TestCaseEvents, "DiagnosticLogged");
            end
        end
        
        function generateReport(plugin,pluginData,rawOutputCollector)
            import matlab.unittest.internal.plugins.testreport.TestReportData;
            import matlab.unittest.internal.TestSessionData;
            
            suite = pluginData.TestSuite;
            results = pluginData.TestResult;
            eventRecordsList = plugin.EventRecordGatherer.EventRecordsCell;
            
            rawOutputCollector.turnCollectingOff();
            commandWindowText = rawOutputCollector.RawOutput;
            
            testSessionData = TestSessionData(suite,results,...
                'EventRecordsList',eventRecordsList,...
                'CommandWindowText',commandWindowText);
            
            reportDocument = plugin.createReportDocument(testSessionData);
            
            reportDocument.generateReport();
        end
    end
end

function parser = createArgumentParser()
import matlab.unittest.plugins.ToStandardOutput;

parser = matlab.unittest.internal.strictInputParser;
parser.addParameter('IncludingPassingDiagnostics', false, ...
    @(x) validateattributes(x,{'logical'},{'scalar'},'','IncludingPassingDiagnostics'));
parser.addParameter('IncludingCommandWindowText', false, ...
    @(x) validateattributes(x,{'logical'},{'scalar'},'','IncludingCommandWindowText'));
parser.addParameter('ExcludingLoggedDiagnostics', false, ...
    @(x) validateattributes(x,{'logical'},{'scalar'},'','ExcludingLoggedDiagnostics'));
parser.addParameter('Verbosity', matlab.unittest.Verbosity.Terse, @validateVerbosity);

% Undocumented Parameters:
parser.addParameter('ProgressStream',ToStandardOutput(),...
    @(x) validateattributes(x,{'matlab.unittest.plugins.OutputStream'},{'scalar'}));
end

function validateVerbosity(verbosity)
validateattributes(verbosity, {'numeric', 'matlab.unittest.Verbosity'}, {'scalar'}, '', 'Verbosity');
matlab.unittest.Verbosity(verbosity); % Validate that a numeric value is valid
end

% LocalWords:  archivable mypackage testreport DOCXFILENAME PDFFILENAME
% LocalWords:  Cancelable CPROPLC unittest plugins HTMLFOLDER MAINFILENAME Noto
% LocalWords:  CJK
