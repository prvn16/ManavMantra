classdef JUnitXMLOutputPlugin < matlab.unittest.plugins.XMLPlugin
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Access=private)
        EventRecordGatherer;
        JUnitXMLFormatter;
        LastClassBoundaryMarker  
        LastSuiteName 
        
        DocumentNode;               % Top Level DOM Node
        TestSuiteNode;              % <testsuite> node
        
        NumTests;                   % Total number of tests in the testsuite
        NumFailures;                % Total number of failures in the test results
        NumErrors;                  % Total number of uncaught exceptions
        NumSkipped;                 % Total number of assumption failures
        TestSuiteDuration;          % Total duration of the testsuite        
    end
    
    properties(Hidden, SetAccess=private)
        Filename;
    end
    
    methods
        function set.Filename(plugin, filename)
            import matlab.unittest.internal.folderResolver;
            validateattributes(filename,{'char','string'},{'nonempty','row','scalartext'},'','filename');
            matlab.unittest.internal.validateNonemptyText(filename);
            filename = char(filename);
            [folderName, fileName, extension] = fileparts(filename);
            if isempty(folderName)
                folderName = '.';
            end
            plugin.Filename = fullfile(folderResolver(folderName), [fileName extension]);
        end
    end
    
    methods (Access=protected)
        function runTestSuite(plugin, pluginData)
            matlab.unittest.internal.validateFileCanBeCreated(plugin.Filename);
            
            % Set initial values for properties
            plugin.setDefaultPropertyValues;
            
            % Create the testsuites and the first testsuite element
            plugin.DocumentNode = com.mathworks.xml.XMLUtils.createDocument('testsuites');
            
            % update the testsuite node and write to XML
            writeRootElement = onCleanup(@()plugin.setFinalAttributesAndPrint());            
             
            plugin.EventRecordGatherer = plugin.createEventRecordGatherer(pluginData);
            plugin.JUnitXMLFormatter = matlab.unittest.internal.plugins.xml.JUnitXMLFormatter;
            plugin.runTestSuite@matlab.unittest.plugins.XMLPlugin(pluginData);
            
        end
        
        function fixture = createSharedTestFixture(plugin, pluginData)
            fixture = createSharedTestFixture@matlab.unittest.plugins.XMLPlugin(plugin, pluginData);
            eventLocation = pluginData.Name;
            plugin.EventRecordGatherer.addListenersToSharedTestFixture(fixture, eventLocation, pluginData.AffectedIndices);
        end
        
        function testCase = createTestClassInstance(plugin, pluginData)
            testCase = createTestClassInstance@matlab.unittest.plugins.XMLPlugin(plugin, pluginData);
            eventLocation = pluginData.Name;
            plugin.EventRecordGatherer.addListenersToTestClassInstance(testCase, eventLocation, pluginData.AffectedIndices);
        end
        
        function testCase = createTestMethodInstance(plugin, pluginData)
            testCase = createTestMethodInstance@matlab.unittest.plugins.XMLPlugin(plugin, pluginData);
            eventLocation = pluginData.Name;
            plugin.EventRecordGatherer.addListenersToTestMethodInstance(testCase, eventLocation, pluginData.AffectedIndices);
        end
        
        function reportFinalizedResult(plugin, pluginData)
            
            % Update the SuiteName to be the class name
            currentSuiteName = plugin.getNames(pluginData.TestSuite.Name);
            
            if ~any(pluginData.TestSuite.ClassBoundaryMarker == plugin.LastClassBoundaryMarker)|| ...
                    ~strcmp(currentSuiteName,plugin.LastSuiteName)
                
                % Update attributes on previous testsuite node and create a
                % new testsuite node for the next class.
                plugin.finalizeLastTestSuiteAttributes();
                plugin.createAndInitializeTestSuiteNode();

                plugin.LastClassBoundaryMarker = pluginData.TestSuite.ClassBoundaryMarker;
                plugin.LastSuiteName = currentSuiteName;
            end
            
            plugin.NumTests = plugin.NumTests + 1;
            
            thisResult = pluginData.TestResult;
            testcaseElement = plugin.createTestCaseNode(thisResult);

            if thisResult.FatalAssertionFailed
                plugin.addFailureNode(testcaseElement, 'FatalAssertionFailure', pluginData.Index);
            elseif thisResult.Errored
                plugin.addErrorNode(testcaseElement, pluginData.Index);
            elseif thisResult.AssertionFailed
                plugin.addFailureNode(testcaseElement, 'AssertionFailure', pluginData.Index);
            elseif thisResult.VerificationFailed
                plugin.addFailureNode(testcaseElement, 'VerificationFailure', pluginData.Index);
            elseif thisResult.AssumptionFailed
                plugin.addSkippedNode(testcaseElement, pluginData.Index);
            else
                plugin.TestSuiteNode.appendChild(testcaseElement);
            end
            
            plugin.TestSuiteDuration = plugin.TestSuiteDuration + thisResult.Duration;
            
            reportFinalizedResult@...
                matlab.unittest.plugins.TestRunnerPlugin(plugin,pluginData);
        end

    end
    
    methods(Access=?matlab.unittest.plugins.XMLPlugin)
        function plugin = JUnitXMLOutputPlugin(filename)
            plugin = plugin@matlab.unittest.plugins.XMLPlugin;
            plugin.Filename = filename;
        end
    end
    
    methods(Access=private)
        function testcaseElement = createTestCaseNode(plugin, thisResult)
            testcaseElement = plugin.DocumentNode.createElement('testcase');
            [className,methodName] = plugin.getNames(thisResult.Name);
           
            testcaseElement.setAttribute('classname',className);
            testcaseElement.setAttribute('name',methodName);
            testcaseElement.setAttribute('time',num2str(thisResult.Duration));
        end

        function addFailureNode(plugin, testcaseElement, failureType, idx)
            failureNode = plugin.appendNodeToTestCaseElement(testcaseElement, 'failure', idx);
            failureNode.setAttribute('type', failureType);
            
            plugin.TestSuiteNode.appendChild(testcaseElement);
            plugin.NumFailures = plugin.NumFailures + 1;
        end
        
        function addSkippedNode(plugin, testcaseElement, idx)
            plugin.appendNodeToTestCaseElement(testcaseElement, 'skipped', idx);
            
            plugin.TestSuiteNode.appendChild(testcaseElement);
            plugin.NumSkipped = plugin.NumSkipped + 1;
        end
        
        function addErrorNode(plugin, testcaseElement, idx)
            plugin.appendNodeToTestCaseElement(testcaseElement, 'error', idx);
            plugin.TestSuiteNode.appendChild(testcaseElement);
            plugin.NumErrors = plugin.NumErrors + 1;
        end
        
        function childNode = appendNodeToTestCaseElement(plugin, testcaseElement, typeOfNode, idx)
            childNode = plugin.DocumentNode.createElement(typeOfNode);
            
            childNode.appendChild(plugin.createDiagnosticNode(idx));
            
            testcaseElement.appendChild(childNode);
        end
        
        function diagnosticsNode = createDiagnosticNode(plugin, idx)
            eventRecords = plugin.EventRecordGatherer.EventRecordsCell{idx};
            formattedDiagnostics = arrayfun(@plugin.getFormattedDiagnosticText,...
                eventRecords,'UniformOutput',false);
            diagnostics = strjoin(formattedDiagnostics, '');
            diagnosticsNode = plugin.DocumentNode.createTextNode(diagnostics);
        end
        
        function finalizeLastTestSuiteAttributes(plugin)
            if ~isempty(plugin.LastClassBoundaryMarker)
                plugin.TestSuiteNode.setAttribute('name', plugin.LastSuiteName);
                plugin.TestSuiteNode.setAttribute('tests',    num2str(plugin.NumTests));
                plugin.TestSuiteNode.setAttribute('failures', num2str(plugin.NumFailures));
                plugin.TestSuiteNode.setAttribute('errors',   num2str(plugin.NumErrors));
                plugin.TestSuiteNode.setAttribute('skipped',  num2str(plugin.NumSkipped));
                plugin.TestSuiteNode.setAttribute('time',     num2str(plugin.TestSuiteDuration));
            end
        end
        
        function eventRecordGatherer = createEventRecordGatherer(~, pluginData)
            import matlab.unittest.internal.plugins.EventRecordGatherer;
            
            eventRecordGatherer = EventRecordGatherer(numel(pluginData.TestSuite)); %#ok<CPROPLC>
            
            % XMLPlugin does not currently support passing event diagnostics
            passingEvents = ["VerificationPassed","AssertionPassed",...
                "FatalAssertionPassed","AssumptionPassed"];
            eventRecordGatherer.FixtureEvents = setdiff(eventRecordGatherer.FixtureEvents, passingEvents);
            eventRecordGatherer.TestCaseEvents = setdiff(eventRecordGatherer.TestCaseEvents, passingEvents);
            
            % XMLPlugin does not currently support logged event diagnostics
            loggedEvent = "DiagnosticLogged";
            eventRecordGatherer.FixtureEvents = setdiff(eventRecordGatherer.FixtureEvents, loggedEvent);
            eventRecordGatherer.TestCaseEvents = setdiff(eventRecordGatherer.TestCaseEvents, loggedEvent);
        end
        
        function txt = getFormattedDiagnosticText(plugin, eventRecord)
            formattedStr = eventRecord.getFormattedReport(plugin.JUnitXMLFormatter);
            txt = char(formattedStr.Text); %Always get unenriched version
        end
        
        function setFinalAttributesAndPrint(plugin)
            if isempty(plugin.LastClassBoundaryMarker)
                plugin.createAndInitializeTestSuiteNode();
                plugin.LastClassBoundaryMarker = matlab.unittest.internal.ClassBoundaryMarker;
            end
            plugin.finalizeLastTestSuiteAttributes();
            xmlwrite(plugin.Filename, plugin.DocumentNode);
        end
        
        function createAndInitializeTestSuiteNode(plugin)
            docRootNode = plugin.DocumentNode.getDocumentElement;
            plugin.TestSuiteNode = plugin.DocumentNode.createElement('testsuite');
            docRootNode.appendChild(plugin.TestSuiteNode);
            
            plugin.NumTests    = 0;
            plugin.NumFailures = 0;
            plugin.NumErrors   = 0;
            plugin.NumSkipped  = 0;
            plugin.TestSuiteDuration    = 0;
        end
        
        function [className,methodName] = getNames(~,testName)
            nameParts = strsplit(testName, '/');
            methodName = nameParts{2};
            className = nameParts{1};
        end
        
        function setDefaultPropertyValues(plugin)
            plugin.LastSuiteName = '';
            plugin.LastClassBoundaryMarker = matlab.unittest.internal.ClassBoundaryMarker.empty;
        end
    end
end

% LocalWords:  testsuite testsuites CPROPLC unenriched scalartext
