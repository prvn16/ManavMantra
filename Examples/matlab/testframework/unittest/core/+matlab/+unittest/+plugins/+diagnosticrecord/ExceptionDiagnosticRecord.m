classdef ExceptionDiagnosticRecord < matlab.unittest.plugins.diagnosticrecord.DiagnosticRecord
    % ExceptionDiagnosticRecord - Data structure that represents diagnostic information about errors
    %
    %   ExceptionDiagnosticRecord is a data structure that represents
    %   diagnostic information about errors thrown in tests. In addition to
    %   providing information about the event that caused the record to be
    %   created, the scope of the event, the location of the event, the stack
    %   at the time of creation of the record, and the complete report, it also
    %   provides information about the exception that resulted in the creation
    %   of the record.
    %
    %   ExceptionDiagnosticRecord methods:
    %       selectFailed     - Return the diagnostic records for failed events
    %       selectPassed     - Return the diagnostic records for passed events
    %       selectIncomplete - Return the diagnostic records for incomplete events
    %       selectLogged     - Return the diagnostic records for logged events
    %
    %   ExceptionDiagnosticRecord properties:
    %       Event                       - Name of the event that caused this diagnostic to be recorded
    %       EventScope                  - Scope where the event originated
    %       EventLocation               - Location where the event originated
    %       Exception                   - MException that caused this diagnostic to be recorded
    %       AdditionalDiagnosticResults - Results of additional diagnostics specified in the test content
    %       Stack                       - Stack at the time the exception was thrown
    %       Report                      - Summary of the diagnostic record
    %
    %   See also:
    %       matlab.unittest.plugins.DiagnosticsRecordingPlugin
    %       matlab.unittest.plugins.diagnosticrecord.DiagnosticRecord
    %       matlab.unittest.plugins.diagnosticrecord.QualificationDiagnosticRecord
    %       matlab.unittest.plugins.diagnosticrecord.LoggedDiagnosticRecord
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties(SetAccess=private)
        % Exception - MException that caused this diagnostic to be recorded
        %
        %   Exception records the actual MException object that resulted in
        %   the diagnostic to be recorded.
        Exception;
        
        % AdditionalDiagnosticResults - Results of additional diagnostics specified in the test content
        %
        %   Results of additional diagnostics specified in a test, represented as
        %   an array of DiagnosticResult instances. For example,
        %   AdditionalDiagnosticResults includes results from diagnostics added
        %   using the testCase.onFailure method.
        %
        %   See also:
        %       matlab.unittest.diagnostics.DiagnosticResult
        AdditionalDiagnosticResults;
    end
    
    properties(Dependent, SetAccess=private)
        % Stack - Stack at the time the exception was thrown
        %
        %   The Stack property is a structure that represents the call stack
        %   at the time the exception was thrown.
        Stack;
    end
    
    properties(Hidden, Access=protected)
        Passed = false;
        Failed = true;
        Incomplete = true;
        Logged = false;
    end
    
    methods
        function stack = get.Stack(record)
            import matlab.unittest.internal.trimStack;
            stack = trimStack(record.Exception.stack);
        end
    end
    
    methods(Hidden)
        function record = ExceptionDiagnosticRecord(varargin)
            record = record@matlab.unittest.plugins.diagnosticrecord.DiagnosticRecord(varargin{:});
            if nargin == 0
                return;
            end
            
            eventRecord = varargin{1};
            record.AdditionalDiagnosticResults = ...
                eventRecord.FormattableAdditionalDiagnosticResults.toDiagnosticResultsWithoutFormat();
            record.Exception = eventRecord.Exception;
        end
        
        function recordStruct = saveobj(record)
            recordStruct = saveobj@matlab.unittest.plugins.diagnosticrecord.DiagnosticRecord(record);
            recordStruct.SubVersion1.Exception = record.Exception;
            recordStruct.SubVersion1.AdditionalDiagnosticResults = record.AdditionalDiagnosticResults;
        end
    end
    
    methods(Hidden,Static)
        function record = loadobj(recordStruct)
            record = matlab.unittest.plugins.diagnosticrecord.ExceptionDiagnosticRecord();
            record.reload(recordStruct);
        end
    end
    
    methods(Hidden, Access=protected)
        function record = reload(record,recordStruct)
            import matlab.unittest.diagnostics.DiagnosticResult;
            record.reload@matlab.unittest.plugins.diagnosticrecord.DiagnosticRecord(recordStruct);
            if isfield(recordStruct, 'SubVersion1') % R2017b and later
                record.Exception = recordStruct.SubVersion1.Exception;
                record.AdditionalDiagnosticResults = recordStruct.SubVersion1.AdditionalDiagnosticResults;
            elseif isfield(recordStruct, 'V2') % R2017a
                record.Exception = recordStruct.V2.Exception;
                record.AdditionalDiagnosticResults = DiagnosticResult.empty(1,0);
            else %R2016a, R2016b
                record.Exception = recordStruct.Exception;
                record.AdditionalDiagnosticResults = DiagnosticResult.empty(1,0);
            end
        end
        
        function str = getFormattedReport(record, formatter)
            import matlab.unittest.internal.eventrecords.ExceptionEventRecord;
            eventRecord = ExceptionEventRecord.fromDiagnosticRecord(record);
            str = formatter.getFormattedExceptionReport(eventRecord);
        end
        
        function propList = getPropertyList(~)
            propList = {'Event','EventScope','EventLocation','Exception','AdditionalDiagnosticResults','Stack','Report'};
        end
        
        function eventRecord = convertToEventRecord(record)
            import matlab.unittest.internal.eventrecords.ExceptionEventRecord;
            eventRecord = ExceptionEventRecord.fromDiagnosticRecord(record);
        end
    end
end

% LocalWords:  diagnosticrecord formatter