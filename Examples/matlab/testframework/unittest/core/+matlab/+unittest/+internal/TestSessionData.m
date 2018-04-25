classdef TestSessionData < handle
    %This class is undocumented and may change in a future release.
    
    % Copyright 2017 The MathWorks, Inc.
    properties(SetAccess=immutable)
        %TestSuite - A matlab.unittest.Test array
        TestSuite
        
        %TestResults - A matlab.unittest.TestResult array
        TestResults
    end
    
    properties(Hidden, SetAccess=immutable)
        CommandWindowText
    end
    
    properties(Dependent, Hidden, SetAccess=immutable)
        PassedMask
        FilteredMask
        FailedMask
        UnreachedMask
        
        BaseFolders
        EventRecordsList
        NumberOfTests
    end
    
    properties(Access=private)
        InternalBaseFolders = string.empty(1,0);
        InternalEventRecordsList = cell(1,0);
    end
    
    methods
        function testSessionData = TestSessionData(suite,results,varargin)
            validateattributes(suite,{'matlab.unittest.Test'},{'row'});
            validateattributes(results,{'matlab.unittest.TestResult'},{'row'});
            assert(numel(suite)==numel(results)); %Internal validation
            
            parser = matlab.unittest.internal.strictInputParser;
            parser.addParameter('CommandWindowText','',@(x) validateattributes(x,{'char'},{'scalartext'}));
            parser.addParameter('EventRecordsList',cell(1,0),@validateEventRecordsList);
            parser.parse(varargin{:});
            options = parser.Results;
            
            testSessionData.TestSuite = suite;
            testSessionData.TestResults = results;
            
            assert(ismember(numel(options.EventRecordsList),[0,numel(results)])); %Internal validation
            testSessionData.InternalEventRecordsList = options.EventRecordsList;
            testSessionData.CommandWindowText = options.CommandWindowText;
        end
        
        function value = get.BaseFolders(testSessionData)
            if numel(testSessionData.InternalBaseFolders) ~= testSessionData.NumberOfTests
                testSessionData.InternalBaseFolders = string({testSessionData.TestSuite.BaseFolder});
            end
            value = testSessionData.InternalBaseFolders;
        end
        
        function value = get.EventRecordsList(testSessionData)
            if numel(testSessionData.InternalEventRecordsList) ~= testSessionData.NumberOfTests
                testSessionData.InternalEventRecordsList = ...
                    createEventRecordsList(testSessionData.TestResults);
            end
            value = testSessionData.InternalEventRecordsList;
        end
        
        function value = get.NumberOfTests(testSessionData)
            value = numel(testSessionData.TestSuite);
        end
        
        function value = get.PassedMask(testSessionData)
            value = [testSessionData.TestResults.Passed];
        end
        
        function value = get.FilteredMask(testSessionData)
            value = ~testSessionData.FailedMask & [testSessionData.TestResults.Incomplete];
        end
        
        function value = get.FailedMask(testSessionData)
            value = [testSessionData.TestResults.Failed];
        end
        
        function value = get.UnreachedMask(testSessionData)
            value = ~testSessionData.PassedMask & ~testSessionData.FilteredMask ...
                & ~testSessionData.FailedMask;
        end
    end
end


function validateEventRecordsList(value)
validateattributes(value,{'cell'},{'row'});
cellfun(@(x) validateattributes(x,{'matlab.unittest.internal.eventrecords.EventRecord'},{'row'}),value);
end


function eventRecordsList = createEventRecordsList(results)
import matlab.unittest.internal.eventrecords.EventRecord;

if isfield(results(1).Details,'DiagnosticRecord') % Assumes that results are nonempty
    eventRecordsList = arrayfun(@(result) toEventRecord(result.Details.DiagnosticRecord),...
        results,'UniformOutput',false);
else
    eventRecordsList = repmat({EventRecord.empty(1,0)},1,numel(results));
end
end