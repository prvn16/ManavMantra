classdef(Abstract,Hidden,HandleCompatible) DiagnosticDataMixin
    % This class is undocumented and may change in a future release.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    properties(Hidden, SetAccess={?matlab.unittest.TestRunner})
        DiagnosticData (1,1) matlab.unittest.diagnostics.DiagnosticData = ...
            matlab.unittest.diagnostics.DiagnosticData();
    end
end