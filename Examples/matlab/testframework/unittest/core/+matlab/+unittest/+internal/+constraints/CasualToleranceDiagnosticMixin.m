classdef (Hidden, Abstract, HandleCompatible) CasualToleranceDiagnosticMixin
    % This class is undocumented.
    
    %   The CasualToleranceDiagnosticMixin can be included as a part of
    %   Tolerance class that supports providing casual diagnostics. A
    %   Tolerance inheriting from this mixin must implement
    %   getCasualDiagnosticFor()
    
    %  Copyright 2014-2017 The MathWorks, Inc.
    
    methods (Abstract, Hidden)
        % Method responsible to provide casual tolerance diagnostics
        diag = getCasualDiagnosticFor(tolerance, actual, expected)
    end
end