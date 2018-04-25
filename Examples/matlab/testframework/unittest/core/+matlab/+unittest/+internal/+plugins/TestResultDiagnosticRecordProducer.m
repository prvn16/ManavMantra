classdef TestResultDiagnosticRecordProducer < matlab.unittest.internal.plugins.EventRecordProducer & ...
        matlab.unittest.internal.plugins.TestResultEnhancerMixin
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016 The MathWorks, Inc.
    methods
        function producer = TestResultDiagnosticRecordProducer(testSuiteRunPluginData)
            producer = producer@matlab.unittest.internal.plugins.EventRecordProducer;
            producer = producer@matlab.unittest.internal.plugins.TestResultEnhancerMixin(...
                testSuiteRunPluginData);
            producer.initializeDiagnosticRecordPropertyOnTestResults(testSuiteRunPluginData);
        end
    end
    
    methods(Access=protected)
        function processEventRecord(producer,eventRecord,index,~,distributeLoop)
            diagRecord = eventRecord.toDiagnosticRecord();
            producer.appendDetails('DiagnosticRecord',diagRecord,index,distributeLoop);
        end
    end
    
    methods(Access=private)
        function initializeDiagnosticRecordPropertyOnTestResults(producer,testSuiteRunPluginData)
            import matlab.unittest.plugins.diagnosticrecord.DiagnosticRecord;
            import matlab.unittest.Scope;
            emptyRecord = DiagnosticRecord.empty(1,0);
            for idx = 1:numel(testSuiteRunPluginData.TestSuite)
                producer.appendDetails('DiagnosticRecord', emptyRecord, idx, true);
            end
        end
    end
end

% LocalWords:  diagnosticrecord
