classdef(Hidden) InternalTAPPlugin < matlab.unittest.plugins.TAPPlugin
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        % IncludePassingDiagnostics - Boolean that specifies whether diagnostics from passing events are included.
        %   The IncludePassingDiagnostics property is a boolean (true or false)
        %   that specifies whether diagnostics from passing events are included
        %   in the TAP stream. This property is read only and can be set only
        %   through the constructor.
        IncludePassingDiagnostics;
        
        % Verbosity - Levels supported by this plugin instance.
        %   The Verbosity property is an array of matlab.unittest.Verbosity
        %   instances. The plugin only displays diagnostics that are logged at a
        %   level listed in this array.
        Verbosity;
        
        % ExcludeLoggedDiagnostics - Boolean that specifies whether logged diagnostics are excluded from YAML.
        %   The ExcludeLoggedDiagnostics property is a boolean (true or false)
        %   that specifies whether logged diagnostics are excluded
        %   from the TAP stream. This property is read only and can be set only
        %   through the constructor.
        ExcludeLoggedDiagnostics;
    end
    
    properties(Access=protected)
        EventRecordGatherer;
    end
    
    methods(Access=protected)
        function plugin = InternalTAPPlugin(outputStream, includingPassingDiagnostics, verbosity, excludingLoggedDiagnostics)
            plugin = plugin@matlab.unittest.plugins.TAPPlugin(outputStream);
            plugin.IncludePassingDiagnostics = includingPassingDiagnostics;
            plugin.Verbosity                 = matlab.unittest.Verbosity(1:double(verbosity));
            plugin.ExcludeLoggedDiagnostics  = excludingLoggedDiagnostics;
        end
    end
    
    methods(Access=protected, Abstract)
        printFormattedDiagnostics(plugin, eventRecords);
    end
    
    methods (Access=protected)
        
        function runTestSuite(plugin, pluginData)
            import matlab.unittest.internal.plugins.LinePrinter;
            plugin.Printer = LinePrinter(plugin.OutputStream);
            
            plugin.Printer.printLine(...
                sprintf('1..%d', numel(pluginData.TestSuite)));
            plugin.EventRecordGatherer = plugin.createEventRecordGatherer(pluginData);
            runTestSuite@matlab.unittest.plugins.TAPPlugin(plugin, pluginData);
        end
        
        function fixture = createSharedTestFixture(plugin, pluginData)
            fixture = createSharedTestFixture@matlab.unittest.plugins.TAPPlugin(plugin, pluginData);
            eventLocation = pluginData.Name;
            plugin.EventRecordGatherer.addListenersToSharedTestFixture(fixture, eventLocation, pluginData.AffectedIndices);
        end
        
        function testCase = createTestClassInstance(plugin, pluginData)
            testCase = createTestClassInstance@matlab.unittest.plugins.TAPPlugin(plugin, pluginData);
            eventLocation = pluginData.Name;
            plugin.EventRecordGatherer.addListenersToTestClassInstance(testCase, eventLocation, pluginData.AffectedIndices);
        end
        
        function testCase = createTestMethodInstance(plugin, pluginData)
            testCase = createTestMethodInstance@matlab.unittest.plugins.TAPPlugin(plugin, pluginData);
            eventLocation = pluginData.Name;
            plugin.EventRecordGatherer.addListenersToTestMethodInstance(testCase, eventLocation, pluginData.AffectedIndices);
        end
        
        function reportFinalizedResult(plugin, pluginData)
            result = pluginData.TestResult;
            plugin.printTAPResult(result, pluginData.Index, result.Name);
            
            eventRecords = plugin.EventRecordGatherer.EventRecordsCell{pluginData.Index};
            plugin.printFormattedDiagnostics(eventRecords);
            
            reportFinalizedResult@matlab.unittest.plugins.TAPPlugin(plugin, pluginData);
        end
    end
    
    methods(Access=private)
        function eventRecordGatherer = createEventRecordGatherer(plugin, pluginData)
            import matlab.unittest.internal.plugins.EventRecordGatherer;
            
            eventRecordGatherer = EventRecordGatherer(numel(pluginData.TestSuite)); %#ok<CPROPLC>
            
            if ~plugin.IncludePassingDiagnostics
                passingEvents = ["VerificationPassed","AssertionPassed",...
                    "FatalAssertionPassed","AssumptionPassed"];
                eventRecordGatherer.FixtureEvents = setdiff(eventRecordGatherer.FixtureEvents, passingEvents);
                eventRecordGatherer.TestCaseEvents = setdiff(eventRecordGatherer.TestCaseEvents, passingEvents);
            end
            
            if plugin.ExcludeLoggedDiagnostics
                loggedEvent = "DiagnosticLogged";
                eventRecordGatherer.FixtureEvents = setdiff(eventRecordGatherer.FixtureEvents, loggedEvent);
                eventRecordGatherer.TestCaseEvents = setdiff(eventRecordGatherer.TestCaseEvents, loggedEvent);
            else
                eventRecordGatherer.VerbosityLevels = plugin.Verbosity;
            end
        end
    end
end

% LocalWords:  YAML CPROPLC