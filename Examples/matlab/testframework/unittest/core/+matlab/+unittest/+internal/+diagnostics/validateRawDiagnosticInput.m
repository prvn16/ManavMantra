function validateRawDiagnosticInput(rawDiag)
% This function is undocumented and may change in a future release.
    
% Copyright 2016 The MathWorks, Inc.

validateattributes(rawDiag, {'char','string','function_handle', ...
    'matlab.unittest.diagnostics.Diagnostic'}, {}, '', 'diagnostic');
if ischar(rawDiag)
    validateattributes(rawDiag, {'char'}, {'2d'}, '', 'diagnostic');
elseif isstring(rawDiag) && any(ismissing(rawDiag(:)))
    error(message('MATLAB:unittest:StringDiagnostic:InvalidValueMissingElement'));
end
end