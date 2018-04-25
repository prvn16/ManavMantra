classdef EventRecordGatherer < matlab.unittest.internal.plugins.EventRecordProducer
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2016 The MathWorks, Inc.
    properties(SetAccess=private)
        %EventRecordsCell = Cell array of EventRecord instances
        %
        %   The size of the EventRecordsCell property corresponds with the
        %   size of the test suite. That is, the array of EventRecord
        %   instances corresponding to the kth matlab.unittest.Test element is
        %   found in EventRecordsCell{k}.
        EventRecordsCell
    end
    
    methods
        function recordGatherer = EventRecordGatherer(numSuiteElements)
            import matlab.unittest.internal.eventrecords.EventRecord;
            recordGatherer.EventRecordsCell = repmat({EventRecord.empty(1,0)},1,numSuiteElements);
        end
    end
    
    methods(Access=protected)
        function processEventRecord(recordGatherer,eventRecord,index,~,~)
            recordGatherer.EventRecordsCell{index} = ...
                [recordGatherer.EventRecordsCell{index},eventRecord];
        end
    end
end

% LocalWords:  kth eventrecords
