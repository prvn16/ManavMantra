classdef ExceptionEventData < event.EventData
    % ExceptionEventData - EventData passed to 'ExceptionThrown' event listeners.
    %
    %   The ExceptionEventData is EventData passed to listeners listening
    %   to the ExceptionThrown event, which is notified when TestRunner
    %   encounters an error during test content execution.
    %
    %   ExceptionEventData properties:
    %       Exception - Unexpected exception caught
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Exception - Unexpected exception caught
        %   
        %   The unexpected exception caught by TestRunner during test
        %   execution. 
        %
        %   See also:
        %       matlab.unittest.TestRunner
        Exception
    end
    
    properties (Hidden, SetAccess=private)
        AdditionalDiagnosticResultsStore = [];
    end
    
    properties (Access = private)
        AdditionalDiagnostics = matlab.unittest.diagnostics.Diagnostic.empty(1,0);
    end
    
    properties (Hidden, SetAccess=immutable)
        DiagnosticResultsStoreFactory
    end
    
    properties (SetAccess = immutable, Dependent)
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
    
    methods(Hidden)
        function evd = ExceptionEventData(exception, defaultDiagData, additionalDiagnostics)
            import matlab.unittest.internal.diagnostics.DiagnosticResultsStoreFactory;
            
            validateattributes(exception, {'MException'}, {'scalar'}, '', 'exception');
            evd.Exception = exception;
            
            evd.DiagnosticResultsStoreFactory = DiagnosticResultsStoreFactory(defaultDiagData);
            evd.AdditionalDiagnostics = additionalDiagnostics;
        end
    end
    methods
        
        function results = get.AdditionalDiagnosticResults(evd)
            results = evd.AdditionalDiagnosticResultsStore.getResults();
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
% LocalWords:  evd
