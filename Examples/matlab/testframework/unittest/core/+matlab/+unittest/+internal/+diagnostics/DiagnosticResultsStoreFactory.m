classdef(Hidden) DiagnosticResultsStoreFactory
    % This class is undocumented and may change in a future release
    
    % Copyright 2016 The MathWorks, Inc.
    properties(Hidden, SetAccess=private)
        DefaultDiagnosticData (1,1) matlab.unittest.diagnostics.DiagnosticData;
    end
    
    methods
        function factory = DiagnosticResultsStoreFactory(defaultDiagData)
            factory.DefaultDiagnosticData = defaultDiagData;
        end
        
        function store = createStoreFromRawDiagnosticInput(factory, rawDiagInput)
            import matlab.unittest.diagnostics.DiagnosticResultsStore;
            diags = createDiagnosticFromRawDiagnosticInput(rawDiagInput);
            store = DiagnosticResultsStore.fromDiagnostics(diags,factory.DefaultDiagnosticData);
        end
        
        function store = createStoreFromValueAndConstraint(factory, value, constraint)
            import matlab.unittest.diagnostics.DiagnosticResultsStore;
            diags = captureDiagnosticsFromValueAndConstraint(value, constraint);
            store = DiagnosticResultsStore.fromDiagnostics(diags,factory.DefaultDiagnosticData);
        end
    end
end


function diags = createDiagnosticFromRawDiagnosticInput(rawInput)
import matlab.unittest.diagnostics.StringDiagnostic;
import matlab.unittest.diagnostics.FunctionHandleDiagnostic;
if isa(rawInput,'matlab.unittest.diagnostics.Diagnostic')
    diags = rawInput;
elseif ischar(rawInput) || isstring(rawInput)
    diags  = StringDiagnostic(rawInput);
elseif isa(rawInput,'function_handle')
    diags = FunctionHandleDiagnostic(rawInput);
end % else do not assign diags as a internal validation check
end


function diags = captureDiagnosticsFromValueAndConstraint(value, constraint)
import matlab.unittest.internal.diagnostics.ExceptionDiagnostic;

if isa(value, 'matlab.unittest.constraints.ActualValueProxy')
    [value,constraint] = deal(constraint,value); % perform a swap
end

try
    diags = constraint.getDiagnosticFor(value);
catch exception
    diags = ExceptionDiagnostic(exception,...
        'MATLAB:unittest:Diagnostic:ErrorEvaluatingDiagnostic');
end

validateattributes(diags, {'matlab.unittest.diagnostics.Diagnostic'}, ...
    {}, '', 'diagnostic');
end