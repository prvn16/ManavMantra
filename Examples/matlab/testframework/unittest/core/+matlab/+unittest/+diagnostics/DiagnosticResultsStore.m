classdef(Hidden) DiagnosticResultsStore
    % This class is undocumented and may change in a future release
    
    % Copyright 2016 The MathWorks, Inc.
    properties(Access=private)
        DiagnosticResultCache (1,:) matlab.unittest.internal.diagnostics.DiagnosticResultCache;
        GetResultsArgumentParser (1,1) inputParser;
    end
    
    methods
        function diagResults = getResults(store,varargin)
            formattableDiagResults = store.getFormattableResults(varargin{:});
            diagResults = formattableDiagResults.toDiagnosticResults();
        end
    end
    
    methods(Hidden)
        function formattableDiagResults = getFormattableResults(store,varargin)
            import matlab.unittest.internal.diagnostics.FormattableDiagnosticResult;
            
            store.GetResultsArgumentParser.parse(varargin{:});
            diagData = matlab.unittest.diagnostics.DiagnosticData(...
                store.GetResultsArgumentParser.Results);
            
            cellOfDiagResults = arrayfun(@(cache) cache.getFormattableResultFor(diagData), ...
                store.DiagnosticResultCache, 'UniformOutput',false);
            formattableDiagResults = [FormattableDiagnosticResult.empty(1,0),...
                cellOfDiagResults{:}];
        end
    end
    
    methods(Hidden, Static)
        function store = fromDiagnostics(diags, defaultDiagData)
            import matlab.unittest.internal.diagnostics.DiagnosticResultCache;
            import matlab.unittest.diagnostics.DiagnosticResultsStore;
            
            diagnosticResultCacheCell = arrayfun(@DiagnosticResultCache,diags,...
                'UniformOutput',false);
            diagnosticResultCacheArray = [DiagnosticResultCache.empty(1,0) ...
                diagnosticResultCacheCell{:}];
            
            parser = inputParser();
            cellfun(@(propName) parser.addParameter(propName,defaultDiagData.(propName)),...
                properties(defaultDiagData));
            
            store = DiagnosticResultsStore(diagnosticResultCacheArray, parser);
        end
    end
    
    methods(Access=private)
        function store = DiagnosticResultsStore(diagnosticResultCacheArray, getResultsArgumentParser)
            store.DiagnosticResultCache = diagnosticResultCacheArray;
            store.GetResultsArgumentParser = getResultsArgumentParser;
        end
    end
end