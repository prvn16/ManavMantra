classdef DiagnosticsPlugin < connector.internal.academy.plugins.TestIndexPlugin
    
    properties
        Details
    end
    
    methods(Access=protected)
            
        function runTestSuite(plugin, pluginData)
            structElement = struct('ScriptCode','', 'Diagnostics', '');            
            plugin.Details = repmat(structElement, size(pluginData.TestSuite));          
            runTestSuite@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);        
        end
        
        function testCase = createTestMethodInstance(plugin, pluginData)
            testCase = createTestMethodInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            testCase.addlistener('ExceptionThrown', @plugin.captureExceptionReport);
            
            testCase.addlistener('VerificationFailed', @plugin.captureFailureDiagnostics);
            testCase.addlistener('AssertionFailed', @plugin.captureFailureDiagnostics);
            testCase.addlistener('FatalAssertionFailed', @plugin.captureFailureDiagnostics);
            
            testCase.addlistener('DiagnosticLogged', @plugin.captureScriptCode);            
        end
        
    end
    
    methods(Access=private)
        function captureScriptCode(plugin, ~, eventData)
            if isa(eventData.Diagnostic, 'matlab.unittest.internal.diagnostics.ScriptContentsDiagnostic')
                plugin.Details(plugin.CurrentIndex).ScriptCode = eventData.DiagnosticResult{1};
            end
        end
        
        function captureExceptionReport(plugin, ~, eventData)
            
            diagnostics = plugin.Details(plugin.CurrentIndex).Diagnostics;
 
            % Create a trimmed exception from the real exception which removes unwanted
            % framework stack frames.
            trimmedException = matlab.unittest.internal.TrimmedException(eventData.Exception);
 
            % Append these diagnostics to any that may already be there. For now jsut
            % separate with a couple new lines for readability.
            diagnostics = sprintf('%s\n\n%s', diagnostics, ...
                trimmedException.getReport('extended','hyperlinks','off'));
            plugin.Details(plugin.CurrentIndex).Diagnostics = diagnostics;
        end
        
        function captureFailureDiagnostics(plugin, ~, eventData)
            
            diagnostics = plugin.Details(plugin.CurrentIndex).Diagnostics;
            % Append these diagnostics to any that may already be there. For now just
            % separate with a couple new lines for readability.
            diagResults = strjoin([eventData.TestDiagnosticResult, eventData.FrameworkDiagnosticResult], '\n\n');
            diagnostics = sprintf('%s\n\n%s', diagnostics, diagResults);
            plugin.Details(plugin.CurrentIndex).Diagnostics = diagnostics;
        end              
    end
end
