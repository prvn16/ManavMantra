classdef XMLPlugin < matlab.unittest.plugins.TestRunnerPlugin & ...
                     matlab.unittest.internal.plugins.HasOutputStreamMixin
    % XMLPlugin - Plugin to produce test results in XML format
    %
    % The XMLPlugin allows one to configure the TestRunner to produce JUnit
    % style XML output. When the test output is produced using this format,
    % MATLAB Unit Test results can be integrated into other third party
    % systems that understand JUnit style XML. For example, using this
    % plugin MATLAB Unit tests can be integrated into continuous
    % integration systems like <a href="http://jenkins-ci.org/">Jenkins</a>TM or <a href="http://www.jetbrains.com/teamcity">TeamCity</a>(R).
    %
    %   XMLPlugin Methods:
    %       producingJUnitFormat - Construct a plugin that produces JUnit Style XML.
    %
    %   Examples:
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.XMLPlugin;
    %
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %       % Create a test runner
    %       runner = TestRunner.withTextOutput;
    %
    %       % Add an XMLPlugin to the TestRunner
    %       xmlFile = 'MyXMLOutput.xml';
    %       plugin = XMLPlugin.producingJUnitFormat(xmlFile);
    %       runner.addPlugin(plugin);
    %
    %       result = runner.run(suite);
    %
    %       disp(fileread(xmlFile));
    %
	% Copyright 2015 The MathWorks, Inc. 
    
    methods(Hidden, Access=protected)
        function plugin = XMLPlugin(varargin)
            plugin = plugin@matlab.unittest.internal.plugins.HasOutputStreamMixin(varargin{:});
        end
    end
    
    methods(Static)
        function plugin = producingJUnitFormat(filename)
            % producingJUnitFormat - Construct a plugin that produces JUnit Style XML Output.
            %   
            %   PLUGIN = XMLPlugin.producingJUnitFormat('XMLFILENAME') returns a plugin that
            %   produces JUnit style XML output. This output is printed to the file <XMLFILENAME>.
            %   Every time the suite is run with this plugin, the XML file is overwritten.
            %
            %   Examples:
            %       import matlab.unittest.plugins.XMLPlugin;
            %
            %       % Create a XML plugin that sends XML Output to a file
            %       plugin = XMLPlugin.producingJUnitFormat('MyXMLFile.xml');
            
            plugin = matlab.unittest.plugins.xml.JUnitXMLOutputPlugin(filename);
        end
    end
end


% LocalWords:  jenkins ci jetbrains teamcity mypackage XMLFILENAME
