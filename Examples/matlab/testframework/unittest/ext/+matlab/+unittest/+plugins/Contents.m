% matlab.unittest.plugins
%
%   Plugins are used to customize or extend the TestRunner.
%
%
% Fundamental Plugin Related Interfaces
% -----------------------------------------
%   TestRunnerPlugin - Interface for extending the TestRunner.
%   QualifyingPlugin - Interface for plugins that perform qualification.
%   OutputStream     - Interface that determines where to send text output.
%
%
% Plugin Implementations
% --------------------------
%
%   Diagnostic & Progress Information:
%       DiagnosticsRecordingPlugin - Record diagnostics on test results.
%       FailureDiagnosticsPlugin   - Report diagnostics on failure.
%       LoggingPlugin              - Report diagnostic messages created by the log method.
%       TestRunProgressPlugin      - Report the progress of the test run.
%
%   Debugging & Qualification:
%       DiagnosticsValidationPlugin - Help validate diagnostic code.
%       FailOnWarningsPlugin        - Report warnings issued by tests.
%       StopOnFailuresPlugin        - Debug test failures.
%
%   Output Formats & Continuous Integration:
%       TAPPlugin - Produce a TAP Stream.
%       XMLPlugin - Produce test results in XML format.
%
%   Reporting:
%       CodeCoveragePlugin - Produce a code coverage report.
%       TestReportPlugin   - Produce a report of the test results in '.docx', '.html', or '.pdf' format.
%
%
% Output Streams
% ------------------
%   ToFile           - Write text output to a file.
%   ToStandardOutput - Display text information to the screen.
%   ToUniqueFile     - Write text output to a unique file.
%__________________________________________________________________________

%   Copyright 2015-2017 The MathWorks, Inc.

