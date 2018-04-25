classdef QualificationDiagnosticRecord < matlab.unittest.plugins.diagnosticrecord.DiagnosticRecord
    % QualificationDiagnosticRecord - Data structure representing qualification events
    %
    %   QualificationDiagnosticRecord is a data structure that represents
    %   diagnostic information about qualification events. In addition to
    %   providing information about the event that caused the record to be
    %   created, the scope of the event, the location of the event, the stack
    %   at the time of creation of the record, and the complete report, it
    %   provides information about the test diagnostics and the framework
    %   diagnostics.
    %
    %   QualificationDiagnosticRecord methods:
    %       selectFailed     - Return the diagnostic records for failed events
    %       selectPassed     - Return the diagnostic records for passed events
    %       selectIncomplete - Return the diagnostic records for incomplete events
    %       selectLogged     - Return the diagnostic records for logged events
    %
    %   QualificationDiagnosticRecord properties:
    %       Event                       - Name of the event that caused this diagnostic to be recorded
    %       EventScope                  - Scope where the event originated
    %       EventLocation               - Location where the event originated
    %       TestDiagnosticResults       - Results of diagnostics specified in the qualification
    %       FrameworkDiagnosticResults  - Results of diagnostics from constraint used for the qualification    
    %       AdditionalDiagnosticResults - Results of additional diagnostics specified in the test content
    %       Stack                       - Stack at the time the event originated
    %       Report                      - Summary of the diagnostic record
    %
    %   See also:
    %       matlab.unittest.plugins.DiagnosticsRecordingPlugin
    %       matlab.unittest.plugins.diagnosticrecord.DiagnosticRecord
    %       matlab.unittest.plugins.diagnosticrecord.LoggedDiagnosticRecord
    %       matlab.unittest.plugins.diagnosticrecord.ExceptionDiagnosticRecord
    
    % Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=private)
        % TestDiagnosticResults - Results of diagnostics specified in the qualification
        %
        %   The TestDiagnosticResults is a DiagnosticResult array holding the
        %   results from diagnosing the diagnostics specified in the qualification.
        %
        %   See also:
        %       matlab.unittest.diagnostics.DiagnosticResult
        TestDiagnosticResults;
        
        % FrameworkDiagnosticResults - Results of diagnostics from constraint used for the qualification
        %
        %   The FrameworkDiagnosticResults is a DiagnosticResult array holding the
        %   results from diagnosing the diagnostics from the constraint used for
        %   the qualification.
        %
        %   See also:
        %       matlab.unittest.diagnostics.DiagnosticResult
        FrameworkDiagnosticResults;
        
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

        % Stack - Stack at the time of the qualification event
        %
        %   The Stack property is a structure that represents the call stack
        %   at the time of the qualification event.
        Stack;
    end
    
    properties(Hidden, Dependent, Access=protected)
        Passed;
        Failed;
        Incomplete;
    end
    
    properties(Hidden, Access=protected)
        Logged = false;
    end
    
    properties(Hidden, Dependent, SetAccess=immutable)
        % TestDiagnosticResult - TestDiagnosticResult is not recommended. Use TestDiagnosticResults instead.
        TestDiagnosticResult
        
        % FrameworkDiagnosticResult - FrameworkDiagnosticResult is not recommended. Use FrameworkDiagnosticResults instead.
        FrameworkDiagnosticResult
    end
    
    methods
        function failed = get.Failed(record)
            failed = any(strcmp(record.Event, ...
                {'VerificationFailed', 'AssertionFailed', 'FatalAssertionFailed'}));
        end
        
        function incomplete = get.Incomplete(record)
            incomplete = any(strcmp(record.Event, ...
                {'AssumptionFailed', 'AssertionFailed', 'FatalAssertionFailed'}));
        end
        
        function passed = get.Passed(record)
            passed = ~record.Failed && ~record.Incomplete;
        end
        
        function cellOfChars = get.TestDiagnosticResult(record)
            cellOfChars = {record.TestDiagnosticResults.DiagnosticText};
        end
        
        function cellOfChars = get.FrameworkDiagnosticResult(record)
            cellOfChars = {record.FrameworkDiagnosticResults.DiagnosticText};
        end
    end
    
    methods(Hidden)
        function record = QualificationDiagnosticRecord(varargin)
            record = record@matlab.unittest.plugins.diagnosticrecord.DiagnosticRecord(varargin{:});
            if nargin == 0
                return;
            end
            
            eventRecord = varargin{1};
            record.TestDiagnosticResults = ...
                eventRecord.FormattableTestDiagnosticResults.toDiagnosticResultsWithoutFormat();
            record.FrameworkDiagnosticResults = ...
                eventRecord.FormattableFrameworkDiagnosticResults.toDiagnosticResultsWithoutFormat();
            record.AdditionalDiagnosticResults = ...
                eventRecord.FormattableAdditionalDiagnosticResults.toDiagnosticResultsWithoutFormat();
            record.Stack = eventRecord.Stack;
        end
        
        function recordStruct = saveobj(record)
            recordStruct = saveobj@matlab.unittest.plugins.diagnosticrecord.DiagnosticRecord(record);
            
            recordStruct.SubVersion1.TestDiagnosticResults = record.TestDiagnosticResults;
            recordStruct.SubVersion1.FrameworkDiagnosticResults = record.FrameworkDiagnosticResults;
            recordStruct.SubVersion1.AdditionalDiagnosticResults = record.AdditionalDiagnosticResults;            
            recordStruct.SubVersion1.Stack = record.Stack;
        end
    end
    
    methods(Hidden,Static)
        function record = loadobj(recordStruct)
            record = matlab.unittest.plugins.diagnosticrecord.QualificationDiagnosticRecord();
            record.reload(recordStruct);
        end
    end
    
    methods(Hidden, Access=protected)
        function record = reload(record,recordStruct)
            import matlab.unittest.diagnostics.DiagnosticResult;
            record.reload@matlab.unittest.plugins.diagnosticrecord.DiagnosticRecord(recordStruct);
            if isfield(recordStruct,'SubVersion1')  % R2017b and later
                record.TestDiagnosticResults = recordStruct.SubVersion1.TestDiagnosticResults;
                record.FrameworkDiagnosticResults = recordStruct.SubVersion1.FrameworkDiagnosticResults;
                record.AdditionalDiagnosticResults = recordStruct.SubVersion1.AdditionalDiagnosticResults;
                record.Stack = recordStruct.SubVersion1.Stack;
            elseif isfield(recordStruct, 'V2') % R2017a
                record.TestDiagnosticResults = recordStruct.V2.TestDiagnosticResults;
                record.FrameworkDiagnosticResults = recordStruct.V2.FrameworkDiagnosticResults;
                record.AdditionalDiagnosticResults = DiagnosticResult.empty(1,0);
                record.Stack = recordStruct.V2.Stack;
            else %R2016a, R2016b
                record.TestDiagnosticResults = cellStrToDiagnosticResults(...
                    recordStruct.TestDiagnosticResult);
                record.FrameworkDiagnosticResults = cellStrToDiagnosticResults(...
                    recordStruct.FrameworkDiagnosticResult);
                record.AdditionalDiagnosticResults = DiagnosticResult.empty(1,0);
                record.Stack = recordStruct.Stack;
            end
        end

        function str = getFormattedReport(record, formatter)
            str = formatter.getFormattedQualificationReport(record.convertToEventRecord());
        end
        
        function propList = getPropertyList(~)
            propList = {'Event','EventScope','EventLocation','TestDiagnosticResults',...
                'FrameworkDiagnosticResults','AdditionalDiagnosticResults','Stack','Report'};
        end
        
        function eventRecord = convertToEventRecord(record)
            import matlab.unittest.internal.eventrecords.QualificationEventRecord;
            eventRecord = QualificationEventRecord.fromDiagnosticRecord(record);
        end
    end
end


function diagnosticResults = cellStrToDiagnosticResults(cellOfChars)
import matlab.unittest.diagnostics.DiagnosticResult;
import matlab.unittest.diagnostics.FileArtifact;
diagnosticResultsCell = cellfun(@(x) DiagnosticResult(...
    FileArtifact.empty(1,0),x), cellOfChars, 'UniformOutput', false);
diagnosticResults = [DiagnosticResult.empty(1,0), diagnosticResultsCell{:}];
end

% LocalWords:  diagnosticrecord Formattable formatter