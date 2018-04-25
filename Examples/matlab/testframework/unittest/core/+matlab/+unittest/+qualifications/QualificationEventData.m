classdef QualificationEventData < event.EventData
    % QualificationEventData - EventData passed to callbacks listening to qualification events
    %
    %   The QualificationEventData class holds information about a
    %   qualification. It is passed to callback functions that are
    %   registered to listen to passing and/or failing qualifications.
    %
    %   Qualifications can be assertions, fatal assertions, assumptions or
    %   verifications performed on test content. The events associated with
    %   these qualifications are defined in the corresponding qualification
    %   classes.
    %
    %   QualificationEventData properties:
    %       ActualValue                - Value to which the Constraint is applied
    %       Constraint                 - Constraint used for the qualification
    %       TestDiagnostic             - Diagnostics specified in the qualification
    %       TestDiagnosticResults      - Results of diagnostics specified in the qualification
    %       FrameworkDiagnosticResults - Results of diagnostics from constraint used for the qualification
    %       Stack                      - Function call stack leading up to the qualification
    %
    %   See also
    %       matlab.unittest.qualifications.Assertable
    %       matlab.unittest.qualifications.FatalAssertable
    %       matlab.unittest.qualifications.Assumable
    %       matlab.unittest.qualifications.Verifiable
    %       matlab.unittest.fixtures.Fixture
    
    % Copyright 2011-2017 The MathWorks, Inc.
    
    properties(SetAccess=immutable)
        % ActualValue - Value to which the Constraint is applied
        %
        %   Constraint operates on this value to determine satisfaction
        %   of its qualification logic.
        ActualValue;
    end
    
    properties(Dependent, SetAccess=immutable)
        % Constraint - Constraint used for the qualification
        %
        %   See also:
        %       matlab.unittest.constraints.Constraint
        Constraint;
    end
    
    properties(SetAccess=immutable)
        % TestDiagnostic - Diagnostics specified in the qualification
        %
        %   The TestDiagnostic property holds onto the character vector, string
        %   array, function handle, or Diagnostic array that was passed to the
        %   qualification.
        %
        %   See also:
        %       matlab.unittest.diagnostics.Diagnostic
        TestDiagnostic = matlab.unittest.diagnostics.Diagnostic.empty(1,0);
    end
    
    properties(Dependent, SetAccess=immutable)
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
        
        % Stack - Function call stack leading up to the qualification
        %
        %   The stack property is a structure array the provides
        %   information about the location of the call leading up to the
        %   qualification.
        Stack;
    end
    
    properties(Hidden, Dependent, SetAccess=immutable)
        % TestDiagnosticResult - TestDiagnosticResult is not recommended. Use TestDiagnosticResults instead.
        TestDiagnosticResult;
        
        % FrameworkDiagnosticResult - FrameworkDiagnosticResult is not recommended. Use FrameworkDiagnosticResults instead.
        FrameworkDiagnosticResult;
        
    end
    
    properties (Hidden, SetAccess=private)
        TestDiagnosticResultsStore = [];
        FrameworkDiagnosticResultsStore = [];
        AdditionalDiagnosticResultsStore = [];
    end
    
    properties (Hidden, SetAccess=immutable, GetAccess=?matlab.unittest.TestRunner)
        QualificationFailedExceptionMarker;
    end
    
    properties (Hidden, SetAccess=immutable)
        DiagnosticResultsStoreFactory
    end
    
    properties (GetAccess=private, SetAccess=immutable)
        RawStack;
        RawConstraint;
    end
    
    properties (Access=private)
        InternalStack = [];
        
        AdditionalDiagnostics = matlab.unittest.diagnostics.Diagnostic.empty(1,0);
    end
    
    properties(Constant, Access=private)
        StackParser = createStackParser();
    end
    
    methods (Hidden)
        function evd = QualificationEventData(stack, actual, constraint, marker, defaultDiagData, additionalDiagnostics, rawTestDiag)
            import matlab.unittest.internal.diagnostics.validateRawDiagnosticInput;
            import matlab.unittest.internal.diagnostics.DiagnosticResultsStoreFactory;
            
            if isa(stack, 'matlab.unittest.qualifications.QualificationEventData')
                % Copy constructor  - EventData instance should be used to notify only one event
                original = stack;
                evd.RawStack = original.RawStack;
                evd.ActualValue = original.ActualValue;
                evd.RawConstraint = original.RawConstraint;
                evd.QualificationFailedExceptionMarker = original.QualificationFailedExceptionMarker;
                evd.DiagnosticResultsStoreFactory = original.DiagnosticResultsStoreFactory;
                evd.TestDiagnostic = original.TestDiagnostic;
                evd.AdditionalDiagnostics = original.AdditionalDiagnostics;
                evd.AdditionalDiagnosticResultsStore = original.AdditionalDiagnosticResultsStore;
                return;
            end
            
            evd.StackParser.parse(stack);
            evd.RawStack = stack;
            evd.ActualValue = actual;
            evd.RawConstraint = constraint;
            evd.QualificationFailedExceptionMarker = marker;
            evd.DiagnosticResultsStoreFactory = DiagnosticResultsStoreFactory(defaultDiagData);
            evd.AdditionalDiagnostics = additionalDiagnostics;
            if nargin > 6
                validateRawDiagnosticInput(rawTestDiag);
                evd.TestDiagnostic = rawTestDiag;
            end
        end
    end
    
    methods (Hidden)
        function destEvd = copy(sourceEvd)
            % Copy of a QualificationEventData instance from a source
            % QualificationEventData. This is usually useful to forward an
            % event notification re-using the information held by the
            % source event data.
            destEvd = matlab.unittest.qualifications.QualificationEventData(sourceEvd);
        end
    end
    
    methods
        function constraint = get.Constraint(evd)
            if isa(evd.RawConstraint, 'matlab.unittest.internal.constraints.ConstraintDecorator')
                constraint = evd.RawConstraint.RootConstraint;
            else
                constraint = evd.RawConstraint;
            end
        end
        
        function results = get.TestDiagnosticResults(evd)
            results = evd.TestDiagnosticResultsStore.getResults();
        end
        
        function results = get.FrameworkDiagnosticResults(evd)
            results = evd.FrameworkDiagnosticResultsStore.getResults();
        end
        
        function results = get.AdditionalDiagnosticResults(evd)
            results = evd.AdditionalDiagnosticResultsStore.getResults();
        end
        
        function stack = get.Stack(evd)
            import matlab.unittest.internal.trimStack
            if isempty(evd.InternalStack)
                evd.InternalStack = trimStack(evd.RawStack);
            end
            stack = evd.InternalStack;
        end
        
        function cellOfChars = get.TestDiagnosticResult(evd)
            cellOfChars = {evd.TestDiagnosticResults.DiagnosticText};
        end
        
        function cellOfChars = get.FrameworkDiagnosticResult(evd)
            cellOfChars = {evd.FrameworkDiagnosticResults.DiagnosticText};
        end
        
        function store = get.TestDiagnosticResultsStore(evd)
            if isempty(evd.TestDiagnosticResultsStore)
                factory = evd.DiagnosticResultsStoreFactory;
                evd.TestDiagnosticResultsStore = ...
                    factory.createStoreFromRawDiagnosticInput(evd.TestDiagnostic);
            end
            store = evd.TestDiagnosticResultsStore;
        end
        
        function store = get.FrameworkDiagnosticResultsStore(evd)
            if isempty(evd.FrameworkDiagnosticResultsStore)
                factory = evd.DiagnosticResultsStoreFactory;
                evd.FrameworkDiagnosticResultsStore = ...
                    factory.createStoreFromValueAndConstraint(evd.ActualValue,evd.RawConstraint);
            end
            store = evd.FrameworkDiagnosticResultsStore;
        end
        
        function store = get.AdditionalDiagnosticResultsStore(evd)
            if isempty(evd.AdditionalDiagnosticResultsStore)
                factory = evd.DiagnosticResultsStoreFactory;
                evd.AdditionalDiagnosticResultsStore = ...
                    factory.createStoreFromRawDiagnosticInput(evd.AdditionalDiagnostics);
            end
            store = evd.AdditionalDiagnosticResultsStore;
        end
    end
end


function p = createStackParser
p = inputParser;
p.addRequired('stack', @(s) isstruct(s) && all(isfield(s,{'file','name','line'})));
end

% LocalWords:  evd dest