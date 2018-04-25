classdef HTMLTestReportPlugin < matlab.unittest.plugins.TestReportPlugin & ...
                                matlab.unittest.internal.mixin.MainFileMixin
    % HTMLTestReportPlugin - Plugin to create a test report in '.html' format
    %
    %   A HTMLTestReportPlugin can only be constructed with the
    %   TestReportPlugin.producingHTML method.
    %
    %   HTMLTestReportPlugin Properties:
    %       ExcludeLoggedDiagnostics - Boolean that specifies if logged diagnostics are excluded from the report
    %       IncludeCommandWindowText - Boolean that specifies if command window text is included in the report
    %       IncludePassingDiagnostics - Boolean that specifies if diagnostics from passing events are included in the report
    %       Verbosity - Verbosity levels supported by this plugin instance
    %       MainFile - Character vector that specifies the name of the main file for the HTML report
    %
    %   Examples:
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.TestReportPlugin;
    %
    %       % Create a TestSuite array and a TestRunner
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %       runner = TestRunner.withTextOutput;
    %
    %       % Add an TestReportPlugin to the TestRunner
    %       htmlOutputFolder = 'MyTestReport';
    %       plugin = TestReportPlugin.producingHTML(htmlOutputFolder);
    %       runner.addPlugin(plugin);
    %
    %       % Run and view the report
    %       result = runner.run(suite);
    %       open(fullfile(htmlOutputFolder,'index.html'));
    %
    %   See Also:
    %       matlab.unittest.plugins.TestReportPlugin
    %       matlab.unittest.plugins.TestReportPlugin.producingHTML
    
    % Copyright 2016-2017 The MathWorks, Inc.
    properties(Hidden,SetAccess=immutable)
        ReportFolder
    end
    
    methods(Access=?matlab.unittest.plugins.TestReportPlugin)
        function plugin = HTMLTestReportPlugin(varargin)
            import matlab.unittest.internal.parentFolderResolver;
            import matlab.unittest.internal.extractParameterArguments;
            
            if mod(nargin,2) == 1 % odd
                reportFolder = parentFolderResolver(varargin{1});
                allArgs = varargin(2:end);
            else % even
                reportFolder = tempname();
                allArgs = varargin;
            end
            
            [mainFileArgs,remainingArgs] = extractParameterArguments('MainFile',allArgs{:});
            plugin = plugin@matlab.unittest.internal.mixin.MainFileMixin(mainFileArgs{:});
            plugin = plugin@matlab.unittest.plugins.TestReportPlugin(remainingArgs{:});
            
            plugin.ReportFolder = reportFolder;
        end
    end
    
    methods(Hidden,Access=protected)
        function validateReportCanBeCreated(plugin)
            import matlab.unittest.internal.validateFolderWithFileCanBeCreated;
            validateFolderWithFileCanBeCreated(plugin.ReportFolder,plugin.MainFile);
        end
        
        function reportDocument = createReportDocument(plugin,testSessionData)
            import matlab.unittest.internal.plugins.testreport.HTMLTestReportDocument;
            reportDocument = HTMLTestReportDocument(plugin.ReportFolder,testSessionData,...
                'MainFile',plugin.MainFile,'ProgressStream',plugin.ProgressStream);
        end
    end
end

% LocalWords:  unittest plugins mypackage
