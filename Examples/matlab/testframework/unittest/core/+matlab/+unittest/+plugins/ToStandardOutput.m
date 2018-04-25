classdef ToStandardOutput < matlab.unittest.plugins.OutputStream
    %ToStandardOutput  Display text information to the screen.
    %   STREAM = ToStandardOutput creates an OutputStream that prints to the
    %   screen. STREAM can be used in a variety of plugins that can be added to
    %   a TestRunner.
    %
    %   Note: Many plugins that accept OutputStreams use a ToStandardOutput stream
    %   as their default stream. Because of this, if a stream is not supplied
    %   to these plugins their text is sent to the screen.
    %
    %   Examples:
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.FailureDiagnosticsPlugin;
    %       import matlab.unittest.plugins.ToStandardOutput;
    %
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %       % Create a test runner with no plugins
    %       runner = TestRunner.withNoPlugins;
    %
    %       % Create a FailureDiagnosticsPlugin, explicitly specifying that
    %       % its output should go to the screen.
    %       plugin = FailureDiagnosticsPlugin(ToStandardOutput);
    %
    %       % Add the plugin to the TestRunner and run the suite. Observe that
    %       % only failures produce any screen output.
    %       runner.addPlugin(plugin);
    %       result = runner.run(suite);
    %
    %   See also: fprintf, OutputStream, matlab.unittest.plugins
    
    % Copyright 2012-2017 The MathWorks, Inc.
    
    methods
        function print(~, formatStr, varargin)
            fprintf(1, formatStr, varargin{:});
        end
    end
    
    methods (Hidden)
        function printFormatted(stream, formattableStr)
            import matlab.internal.display.commandWindowWidth;
            stream.print('%s', char(wrap(formattableStr, commandWindowWidth)));
        end
    end
end

% LocalWords:  mypackage formattable
