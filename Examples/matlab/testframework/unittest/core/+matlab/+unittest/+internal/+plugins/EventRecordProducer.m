classdef EventRecordProducer < handle
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016 The MathWorks, Inc.
    
    properties
        %VerbosityLevels - Verbosity levels at which LoggedDiagnosticEventRecord instances will be produced
        %
        %   When listening to LoggedDiagnostic events, only events with verbosity
        %   listed in VerbosityLevels will produce a corresponding EventRecord.
        VerbosityLevels = matlab.unittest.internal.plugins.EventRecordProducer.AllVerbosityLevels;
        
        %FixtureEvents - Fixture events from which to produce event records
        %
        %   The FixtureEvents property is a string array containing the names of
        %   the Fixture events to listen to in order to produce corresponding
        %   EventRecords.
        FixtureEvents = matlab.unittest.internal.plugins.EventRecordProducer.AllFixtureEvents;
        
        %TestCaseEvents - TestCase events from which to produce event records
        %
        %   The TestCaseEvents property is a string array containing the names of
        %   the TestCase events to listen to in order to produce corresponding
        %   EventRecords.
        TestCaseEvents = matlab.unittest.internal.plugins.EventRecordProducer.AllTestCaseEvents;
    end
    
    properties(Constant,Access=private)
        AllVerbosityLevels = matlab.unittest.Verbosity(1:4);
        
        AllFixtureEvents = ["DiagnosticLogged","ExceptionThrown",...
            "AssertionPassed","FatalAssertionPassed","AssumptionPassed",...
            "AssertionFailed","FatalAssertionFailed","AssumptionFailed"];
        
        AllTestCaseEvents = ["DiagnosticLogged","ExceptionThrown",...
            "AssertionPassed","FatalAssertionPassed","AssumptionPassed","VerificationPassed",...
            "AssertionFailed","FatalAssertionFailed","AssumptionFailed","VerificationFailed"];
    end
    
    methods(Abstract, Access=protected)
        processEventRecord(producer,eventRecord,index,eventScope,distributeLoop)
    end
    
    methods
        function set.VerbosityLevels(producer,value)
            value = toUniqueRow(matlab.unittest.Verbosity(value));
            producer.VerbosityLevels = value;
        end
        
        function set.FixtureEvents(producer,value)
            value = toUniqueRow(string(value));
            assert(isempty(setdiff(value,producer.AllFixtureEvents))); %Internal validation
            producer.FixtureEvents = value;
        end
        
        function set.TestCaseEvents(producer,value)
            value = toUniqueRow(string(value));
            assert(isempty(setdiff(value,producer.AllTestCaseEvents))); %Internal validation
            producer.TestCaseEvents = value;
        end
        
        function addListenersToSharedTestFixture(producer, fixture, eventLocation, indices)
            validateattributes(eventLocation,{'char'},{'nonempty','row'},'','eventLocation');
            eventScope = matlab.unittest.Scope.SharedTestFixture;
            eventNames = producer.FixtureEvents;
            producer.addListenersForEvents(eventNames, fixture, eventScope, eventLocation, indices, true);
        end
        
        function addListenersToTestClassInstance(producer, testClassInstance, eventLocation, indices)
            validateattributes(eventLocation,{'char'},{'nonempty','row'},'','eventLocation');
            eventScope = matlab.unittest.Scope.TestClass;
            eventNames = producer.TestCaseEvents;
            producer.addListenersForEvents(eventNames, testClassInstance, eventScope, eventLocation, indices, true);
        end
        
        function addListenersToTestRepeatLoopInstance(producer, testRepeatLoopInstance, eventLocation, indices)
            validateattributes(eventLocation,{'char'},{'nonempty','row'},'','eventLocation');
            eventScope = matlab.unittest.Scope.TestMethod;
            eventNames = producer.TestCaseEvents;
            producer.addListenersForEvents(eventNames, testRepeatLoopInstance, eventScope, eventLocation, indices, true);
        end
        
        function addListenersToTestMethodInstance(producer, testMethodInstance, eventLocation, indices)
            validateattributes(eventLocation,{'char'},{'nonempty','row'},'','eventLocation');
            eventScope = matlab.unittest.Scope.TestMethod;
            eventNames = producer.TestCaseEvents;
            producer.addListenersForEvents(eventNames, testMethodInstance, eventScope, eventLocation, indices, false);
        end
    end
    
    methods(Access=private)
        function addListenersForEvents(producer, eventNames, instance, eventScope, eventLocation, indices, distributeLoop)
            for k=1:numel(eventNames)
                eventName = eventNames{k};
                if strcmp(eventName,"DiagnosticLogged") && ~isempty(producer.VerbosityLevels)
                    instance.addlistener(eventName,@(~,eventData) ...
                        producer.produceLoggedDiagnosticEventRecord(eventData,eventScope,eventLocation,indices,distributeLoop));
                elseif strcmp(eventName,"ExceptionThrown")
                    instance.addlistener(eventName,@(~,eventData) ...
                        producer.produceExceptionEventRecord(eventData,eventScope,eventLocation,indices,distributeLoop));
                else % Qualification
                    instance.addlistener(eventName,@(~,eventData) ...
                        producer.produceQualificationEventRecord(eventData,eventScope,eventLocation,indices,distributeLoop));
                end
            end
        end
        
        function produceLoggedDiagnosticEventRecord(producer,eventData,eventScope,eventLocation,indices,distributeLoop)
            import matlab.unittest.internal.eventrecords.LoggedDiagnosticEventRecord;
            
            if producer.supportsVerbosity(eventData.Verbosity)
                eventRecord = LoggedDiagnosticEventRecord.fromEventData(eventData,eventScope,eventLocation);
                producer.produceEventRecordAtAffectedIndices(eventRecord,eventScope,indices,distributeLoop);
            end
        end
        
        function produceExceptionEventRecord(producer,eventData,eventScope,eventLocation,indices,distributeLoop)
            import matlab.unittest.internal.eventrecords.ExceptionEventRecord;
            
            eventRecord = ExceptionEventRecord.fromEventData(eventData,eventScope,eventLocation);
            producer.produceEventRecordAtAffectedIndices(eventRecord,eventScope,indices,distributeLoop);
        end
        
        function produceQualificationEventRecord(producer,eventData,eventScope,eventLocation,indices,distributeLoop)
            import matlab.unittest.internal.eventrecords.QualificationEventRecord;
            
            eventRecord = QualificationEventRecord.fromEventData(eventData,eventScope,eventLocation);
            producer.produceEventRecordAtAffectedIndices(eventRecord,eventScope,indices,distributeLoop);
        end
        
        function bool = supportsVerbosity(producer, verbosity)
            bool = any(producer.VerbosityLevels == verbosity);
        end
        
        function produceEventRecordAtAffectedIndices(producer,eventRecord,eventScope,indices,distributeLoop)
            arrayfun(@(ind) producer.processEventRecord(eventRecord,ind,eventScope,distributeLoop),indices);
        end
    end
end

function value = toUniqueRow(value)
value = unique(reshape(value,1,[]));
end

% LocalWords:  eventrecords
