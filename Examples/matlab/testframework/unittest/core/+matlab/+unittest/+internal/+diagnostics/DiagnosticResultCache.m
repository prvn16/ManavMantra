classdef(Hidden) DiagnosticResultCache < handle
    % This class is undocumented and may change in a future release
    
    % Copyright 2016 The MathWorks, Inc.
    properties(Hidden, SetAccess=private)
        Diagnostic (1,1) matlab.unittest.diagnostics.Diagnostic = ...
            matlab.unittest.internal.diagnostics.EmptyDiagnostic;
        CachedDataArray (1,:) matlab.unittest.diagnostics.DiagnosticData;
        CachedResultArray (1,:) matlab.unittest.internal.diagnostics.FormattableDiagnosticResult;
    end
    
    methods
        function cache = DiagnosticResultCache(diag)
            cache.Diagnostic = diag;
        end
        
        function formattableDiagResult = getFormattableResultFor(cache,diagData)
            diag = cache.Diagnostic;
            for k = 1:numel(cache.CachedDataArray)
                savedDiagData = cache.CachedDataArray(k);
                if diag.producesSameResultFor(diagData,savedDiagData)
                    formattableDiagResult = cache.CachedResultArray(k);
                    return;
                end
            end
            
            formattableDiagResult = captureFormattableResult(diag,diagData);
            cache.CachedDataArray(end+1) = diagData;
            cache.CachedResultArray(end+1) = formattableDiagResult;
        end
    end
end


function formattableDiagResult = captureFormattableResult(diag, diagData)
import matlab.unittest.internal.diagnostics.FormattableDiagnosticResult;
diag = safelyDiagnoseWith(diag, diagData);
formattableDiagResult = FormattableDiagnosticResult(diag.Artifacts,...
    diag.FormattableDiagnosticText);
end


function diag = safelyDiagnoseWith(diag, diagData)
import matlab.unittest.internal.diagnostics.ExceptionDiagnostic;
try
    diag.diagnoseWith(diagData);
    diag.Artifacts;
    diag.DiagnosticText;
catch exception
    diag = ExceptionDiagnostic(exception,...
        'MATLAB:unittest:Diagnostic:ErrorCapturingDiagnostics');
    diag.diagnoseWith(diagData);
end
end