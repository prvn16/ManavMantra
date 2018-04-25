classdef (Hidden, Abstract, HandleCompatible) CasualDiagnosticMixin
    % This class is undocumented.
    
    %   The CasualDiagnosticMixin can be included as a part of Constraint
    %   class that supports providing casual diagnostics. A Constraint
    %   inheriting from this mixin must implement getCasualDiagnosticFor()
    %
    %   See also
    %       matlab.unittest.internal.constraints.CasualDiagnosticDecorator
    
    %  Copyright 2013-2017 The MathWorks, Inc.
    
    methods (Abstract, Hidden)
        % Method responsible to provide casual constraint diagnostics
        diag = getCasualDiagnosticFor(constraint, actual)
    end
end