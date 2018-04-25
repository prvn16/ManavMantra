classdef LoggedDiagnosticEventData < event.EventData
    % LoggedDiagnosticEventData - EventData passed to callbacks listening to the DiagnosticLogged event
    %
    %   The LoggedDiagnosticEventData class holds information about a call to
    %   the log method. It is passed to callback functions listening to the
    %   DiagnosticLogged event.
    %
    %   LoggedDiagnosticEventData properties:
    %       Verbosity         - The verbosity of the logged message
    %       Timestamp         - The date and time of the call to the log method
    %       Diagnostic        - Diagnostics specified in the log method call
    %       DiagnosticResults - Results of diagnostics specified in the log method call
    %       Stack             - Function call stack leading up to the log method call
    %
    %   See also:
    %       matlab.unittest.TestCase/log
    %       matlab.unittest.TestCase/DiagnosticLogged
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Verbosity - The verbosity of the logged message
        %
        %   The Verbosity property is an instance of the matlab.unittest.Verbosity
        %   enumeration. It describes the level of verbosity of the logged message.
        Verbosity
        
        % Timestamp - The date and time of the call to the log method
        %
        %   The Timestamp property is a datetime instance that records the
        %   moment when the log method was called.
        Timestamp
        
        % Diagnostic - Diagnostics specified in the log method call
        %
        %   The Diagnostic property holds onto the character vector, string array,
        %   function handle, or Diagnostic array that was passed to the log method
        %   call.
        %
        %   See also:
        %       matlab.unittest.diagnostics.Diagnostic
        Diagnostic
    end
    
    properties (Dependent, SetAccess=immutable)
        % DiagnosticResults - Results of diagnostics specified in the log method call
        %
        %   The DiagnosticResults property is a DiagnosticResult array holding the
        %   results from diagnosing the diagnostics specified in the log method
        %   call.
        %
        %   See also:
        %       matlab.unittest.diagnostics.DiagnosticResult
        DiagnosticResults
        
        % Stack - Function call stack leading up to the log method call
        %
        %   The stack property is a structure array the provides information about
        %   the location of the call to the log method.
        Stack
    end
    
    properties (Hidden, Dependent, SetAccess=immutable)
        % DiagnosticResult - DiagnosticResult is not recommended. Use DiagnosticResults instead.
        DiagnosticResult
    end
    
    properties (Hidden, SetAccess=private)
        DiagnosticResultsStore = [];
    end
    
    properties(Hidden, SetAccess=immutable)
        DiagnosticResultsStoreFactory
    end
    
    properties (GetAccess=private, SetAccess=immutable)
        RawStack
    end
    
    properties (Access=private)
        InternalStack = [];
    end
    
    methods (Hidden, Access=?matlab.unittest.internal.Loggable)
        function evd = LoggedDiagnosticEventData(verbosity, rawDiag, stack, timestamp, defaultDiagData)
            import matlab.unittest.internal.diagnostics.validateRawDiagnosticInput;
            import matlab.unittest.internal.diagnostics.DiagnosticResultsStoreFactory;
            
            if isa(verbosity, 'matlab.unittest.diagnostics.LoggedDiagnosticEventData')
                % Copy constructor
                original = verbosity;
                evd.Verbosity = original.Verbosity;
                evd.Diagnostic = original.Diagnostic;
                evd.RawStack = original.RawStack;
                evd.Timestamp = original.Timestamp;
                evd.DiagnosticResultsStoreFactory = original.DiagnosticResultsStoreFactory;
                return;
            end
            
            evd.Verbosity = verbosity;
            validateRawDiagnosticInput(rawDiag);
            evd.Diagnostic = rawDiag;
            evd.RawStack = stack;
            evd.Timestamp = timestamp;
            evd.DiagnosticResultsStoreFactory = DiagnosticResultsStoreFactory(defaultDiagData);
        end
    end
    
    methods
        function results = get.DiagnosticResults(evd)
            results = evd.DiagnosticResultsStore.getResults();
        end
        
        function stack = get.Stack(evd)
            import matlab.unittest.internal.trimStack;
            if isempty(evd.InternalStack)
                evd.InternalStack = trimStack(evd.RawStack);
            end
            stack = evd.InternalStack;
        end
        
        function cellOfChars = get.DiagnosticResult(evd)
            cellOfChars = {evd.DiagnosticResults.DiagnosticText};
        end
        
        function store = get.DiagnosticResultsStore(evd)
            if isempty(evd.DiagnosticResultsStore)
                factory = evd.DiagnosticResultsStoreFactory;
                evd.DiagnosticResultsStore = ...
                    factory.createStoreFromRawDiagnosticInput(evd.Diagnostic);
            end
            store = evd.DiagnosticResultsStore;
        end
    end
    
    methods (Hidden)
        function destEvd = copy(sourceEvd)
            % Copy of a LoggedDiagnosticEventData instance from a source
            % LoggedDiagnosticEventData. This is usually useful to forward an
            % event notification re-using the information held by the
            % source event data.
            destEvd = matlab.unittest.diagnostics.LoggedDiagnosticEventData(sourceEvd);
        end
    end
end

% LocalWords:  evd Loggable dest