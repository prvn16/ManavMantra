classdef ScriptContentsDiagnostic < matlab.unittest.diagnostics.StringDiagnostic
    
   % Copyright 2013 The MathWorks, Inc.
   methods
       function diag = ScriptContentsDiagnostic(varargin)
           diag@matlab.unittest.diagnostics.StringDiagnostic(varargin{:});
       end
   end
    
end