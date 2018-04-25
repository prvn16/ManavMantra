classdef LoggingPlugin < matlab.unittest.plugins.TestRunnerPlugin
    % LoggingPlugin - Report diagnostic messages created by the log method.
    %   The LoggingPlugin provides a means to report diagnostic messages that
    %   are created by calls to the matlab.unittest.TestCase log method.
    %   Through the withVerbosity static method, the plugin can be configured
    %   to respond to messages of a particular verbosity. The withVerbosity
    %   method also accepts a number of name/value pairs for configuring the
    %   format for reporting logged messages.
    %
    %   LoggingPlugin properties:
    %       Verbosity      - Levels supported by this plugin instance.
    %       Description    - Logged diagnostic message description.
    %       HideLevel      - Boolean that indicates whether the level is printed.
    %       HideTimestamp  - Boolean that indicates whether the timestamp is printed.
    %       NumStackFrames - Number of stack frames to print.
    %
    %   LoggingPlugin methods:
    %       withVerbosity - Construct a LoggingPlugin for messages of the specified verbosity.
    %
    %   See also: matlab.unittest.TestCase/log, matlab.unittest.fixtures.Fixture/log, matlab.unittest.Verbosity
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    properties (SetAccess=private)
        % Verbosity - Levels supported by this plugin instance.
        %   The Verbosity property is an array of matlab.unittest.Verbosity
        %   instances. The plugin only reacts to diagnostics that are logged at a
        %   level listed in this array.
        Verbosity;
        
        % Description - Logged diagnostic message description.
        %   The Description property is a string or character vector which is
        %   printed alongside each logged diagnostic message. By default, the
        %   Description "Diagnostic logged" is used.
        Description;
        
        % HideLevel - Boolean that indicates whether the level is printed.
        %   The HideLevel property is a logical value which determines whether or
        %   not the verbosity level of the message is printed alongside each logged
        %   diagnostic. By default, HideLevel is false meaning that the
        %   verbosity level is printed.
        HideLevel;
        
        % HideTimestamp - Boolean that indicates whether the timestamp is printed.
        %   The HideTimestamp property is a logical value which determines whether
        %   or not the time when the logged message was generated is printed
        %   alongside each logged diagnostic. By default, HideTimestamp is false
        %   meaning that the timestamp is printed.
        HideTimestamp;
        
        % NumStackFrames - Number of stack frames to print.
        %   The NumStackFrames property is an integer that dictates the number of
        %   stack frames to print after each logged diagnostic message. By default,
        %   NumStackFrames is zero, meaning that no stack information is printed.
        %   NumStackFrames can be set to Inf to print all available stack frames.
        NumStackFrames;
    end
    
    properties (Constant, Access=private)
        Parser = createParser;
        Catalog = matlab.internal.Catalog('MATLAB:unittest:LoggingPlugin');
    end
    
    properties(Access=private)
        DiagnosticsPrinter;
    end
    
    methods (Static)
        function plugin = withVerbosity(varargin)
            % withVerbosity - Construct a LoggingPlugin for messages of the specified verbosity.
            %   PLUGIN = LoggingPlugin.withVerbosity(VERBOSITY) constructs a LoggingPlugin that
            %   reacts to messages logged at VERBOSITY or lower. VERBOSITY can be
            %   specified as a numeric value (1, 2, 3, or 4) or one of the values from
            %   the matlab.unittest.Verbosity enumeration.
            %
            %   PLUGIN = LoggingPlugin.withVerbosity(VERBOSITY, STREAM) creates a
            %   LoggingPlugin and redirects all the text output produced to the
            %   OutputStream STREAM. If this is not supplied, a ToStandardOutput stream
            %   is used.
            %
            %   PLUGIN = withVerbosity(VERBOSITY, NAME, VALUE, ...) constructs a
            %   LoggingPlugin with one or more Name/Value pairs. Specify any of the
            %   following Name/Value pairs:
            %
            %   * ExcludingLowerLevels - Boolean that indicates whether the plugin
            %                            reacts to messages logged at levels lower than
            %                            VERBOSITY. When false (default), the plugin
            %                            reacts to all messages logged at VERBOSITY or
            %                            lower. When true, the plugin only reacts to
            %                            messages logged at VERBOSITY.
            %   * Description          - String or character vector to print alongside each
            %                            logged diagnostic.
            %                            By default, the plugin uses "Diagnostic logged" as
            %                            the Description.
            %   * HideLevel            - Boolean that indicates whether the level is printed.
            %                            By default, the plugin displays the verbosity level.
            %   * HideTimestamp        - Boolean that indicates whether the timestamp is
            %                            printed. By default, the plugin displays the
            %                            timestamp.
            %   * NumStackFrames       - Number of stack frames to print. By default, the
            %                            plugin displays zero stack frames.
            %
            %   See also: OutputStream, ToStandardOutput
            
            import matlab.unittest.plugins.LoggingPlugin;
            import matlab.unittest.internal.plugins.DiagnosticsPrinter;
            
            parser = LoggingPlugin.Parser;
            parser.parse(varargin{:});
            
            plugin = LoggingPlugin();
            
            if parser.Results.ExcludingLowerLevels
                % The plugin reacts to only the specified level
                plugin.Verbosity = matlab.unittest.Verbosity(parser.Results.Verbosity);
            else
                % The plugin reacts to the specified level and all lower levels
                plugin.Verbosity = matlab.unittest.Verbosity(1:double(parser.Results.Verbosity));
            end
            
            plugin.Description = char(parser.Results.Description);
            plugin.NumStackFrames = parser.Results.NumStackFrames;
            plugin.HideLevel = parser.Results.HideLevel;
            plugin.HideTimestamp = parser.Results.HideTimestamp;
            plugin.DiagnosticsPrinter = DiagnosticsPrinter(parser.Results.Stream);
        end
    end
    
    methods(Hidden)
        function tf = supportsParallel(~)
            tf = true;
        end
        
        function plugin = applyVerbosity(plugin,verbosity)
            plugin.Verbosity = 1:double(verbosity);
        end
    end
    
    methods (Access=protected)
        function fixture = createSharedTestFixture(plugin, pluginData)
            fixture = createSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.registerDiagnosticLoggedCallback(fixture);
        end
        function testCase = createTestClassInstance(plugin, pluginData)
            testCase = createTestClassInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.registerDiagnosticLoggedCallback(testCase);
        end
        function testCase = createTestMethodInstance(plugin, pluginData)
            testCase = createTestMethodInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.registerDiagnosticLoggedCallback(testCase);
        end
    end
    
    methods (Hidden, Access=protected)
        function registerDiagnosticLoggedCallback(plugin, content)
            content.addlistener('DiagnosticLogged', @plugin.processLoggedDiagnostic);
        end
    end
    
    methods (Access=private)
        % Private constructor. Must use static methods to create an instance.
        function plugin = LoggingPlugin()
        end
        
        function processLoggedDiagnostic(plugin, ~, evd)
            % Print only those diagnostics that are logged at a level that
            % the plugin reacts to.
            if any(plugin.Verbosity == evd.Verbosity)
                plugin.printLoggedDiagnostic(evd);
            end
        end
        
        function printLoggedDiagnostic(plugin, evd)
            % Print the header using the format
            % [Level] Description (Timestamp): Message
            
            formattableResults = evd.DiagnosticResultsStore.getFormattableResults();
            
            plugin.DiagnosticsPrinter.printLoggedDiagnostics(...
                formattableResults.toFormattableStrings(), ...
                evd.Verbosity, plugin.Description, plugin.HideTimestamp, ...
                evd.Timestamp, plugin.HideLevel, plugin.NumStackFrames, evd.Stack);
        end
    end
end

function parser = createParser
import matlab.unittest.plugins.LoggingPlugin;
import matlab.unittest.plugins.ToStandardOutput;

parser = matlab.unittest.internal.strictInputParser;

parser.addRequired('Verbosity', @validateVerbosity);
parser.addOptional('Stream', ToStandardOutput, ...
    @(stream)validateattributes(stream, {'matlab.unittest.plugins.OutputStream'}, ...
    {'scalar'}, '', 'OutputStream'));
parser.addParameter('Description', LoggingPlugin.Catalog.getString('DefaultDescription'), ...
    @validateDescription);
parser.addParameter('ExcludingLowerLevels', false, ...
    @(exclude)validateattributes(exclude, {'logical'}, {'scalar'}, '', 'ExcludingLowerLevels'));
parser.addParameter('NumStackFrames', 0, @validateNumStackFrames);
parser.addParameter('HideLevel', false, ...
    @(level)validateattributes(level, {'logical'}, {'scalar'}, '', 'HideLevel'));
parser.addParameter('HideTimestamp', false, ...
    @(time)validateattributes(time, {'logical'}, {'scalar'}, '', 'HideTimestamp'));
end

function validateDescription(desc)
validateattributes(desc, {'char','string'}, {'scalartext'}, '', 'Description')
if isstring(desc) && ismissing(desc)
    error(message('MATLAB:unittest:StringInputValidation:InvalidStringPropertyValueMissingElement','Description'));
end
end

function validateVerbosity(verbosity)
validateattributes(verbosity, {'numeric', 'matlab.unittest.Verbosity'}, {'scalar'}, '', 'verbosity');
% Validate that a numeric value is valid
matlab.unittest.Verbosity(verbosity);
end

function bool = validateNumStackFrames(num)
validateattributes(num, {'numeric'}, {'scalar', 'real', 'nonnan', 'nonnegative'}, '', 'NumStackFrames');
% NumStackFrames must also be integer-valued
bool = isequal(num, round(num));
end

% LocalWords:  evd yyyy THH strs Formattable
