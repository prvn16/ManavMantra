classdef TestRunProgressPlugin < matlab.unittest.plugins.TestRunnerPlugin & ...
                                 matlab.unittest.internal.plugins.HasOutputStreamMixin
    % TestRunProgressPlugin - Factory for creating test run progress plugin.
    % 
    %   The TestRunProgressPlugin factory can be used to construct a plugin to
    %   show the progress of the test run to the Command Window.
    %
    %   TestRunProgressPlugin Methods:
    %       withVerbosity - Construct a TestRunProgressPlugin with a specified verbosity.
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    properties (Constant, Access=protected)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestRunProgressPlugin');
    end
    
    properties(Constant, Hidden)
        ContentDelimiter = repmat('_', 1, 10);
    end
    
    properties(Dependent, Hidden, GetAccess=protected, SetAccess=immutable)
        Printer
    end
    
    properties(Access=private)
        InternalPrinter = [];
    end
    
    methods
        function printer = get.Printer(plugin)
            import matlab.unittest.internal.plugins.LinePrinter;
            printer = plugin.InternalPrinter;
            if isempty(printer)
                printer = LinePrinter(plugin.OutputStream);
                plugin.InternalPrinter = printer;
            end
        end
    end
    
    methods (Static)
        function plugin = withVerbosity(verbosity, varargin)
            %withVerbosity - Construct a TestRunProgressPlugin with a specified verbosity.
            %   PLUGIN = TestRunProgressPlugin.withVerbosity(VERBOSITY) returns a
            %   plugin that prints test run progress at the specified verbosity level.
            %   VERBOSITY can be specified as either a numeric value (1, 2, 3, or 4) or
            %   a value from the matlab.unittest.Verbosity enumeration.
            %
            %   PLUGIN = TestRunProgressPlugin.withVerbosity(VERBOSITY, STREAM) creates
            %   a TestRunProgressPlugin and redirects all the text output produced to
            %   the OutputStream STREAM. If this is not supplied, a ToStandardOutput
            %   stream is used.
            %
            %   See also: OutputStream
            
            import matlab.unittest.Verbosity;
            import matlab.unittest.plugins.testrunprogress.TerseProgressPlugin;
            import matlab.unittest.plugins.testrunprogress.ConciseProgressPlugin;
            import matlab.unittest.plugins.testrunprogress.DetailedProgressPlugin;
            import matlab.unittest.plugins.testrunprogress.VerboseProgressPlugin;
            
            % Validate the Verbosity input
            validateattributes(verbosity, {'numeric', 'matlab.unittest.Verbosity'}, {'scalar'}, '', 'verbosity');
            matlab.unittest.Verbosity(verbosity);
            
            if verbosity == Verbosity.Terse
                plugin = TerseProgressPlugin(varargin{:});
            elseif verbosity == Verbosity.Concise
                plugin = ConciseProgressPlugin(varargin{:});
            elseif verbosity == Verbosity.Detailed
                plugin = DetailedProgressPlugin(varargin{:});
            elseif verbosity == Verbosity.Verbose
                plugin = VerboseProgressPlugin(varargin{:});
            end
        end
    end
    
    methods(Hidden)
        function tf = supportsParallel(~)
            tf = true;
        end
        
        function plugin = applyVerbosity(plugin,verbosity)
            plugin = plugin.withVerbosity(verbosity,plugin.OutputStream);
        end
    end
    
    methods (Access=protected)
        function plugin = TestRunProgressPlugin(varargin)
            plugin@matlab.unittest.internal.plugins.HasOutputStreamMixin(varargin{:});
        end
    end
end

% LocalWords:  testrunprogress
