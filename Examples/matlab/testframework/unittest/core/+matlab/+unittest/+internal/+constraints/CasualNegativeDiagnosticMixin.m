classdef (Hidden, Abstract, HandleCompatible) CasualNegativeDiagnosticMixin 
    % This class is undocumented.
    
    %   The CasualDiagnosticMixin can be included as a part of Constraint
    %   class that supports providing casual diagnostics. A Constraint
    %   inheriting from this mixin must implement getCasualNegativeDiagnosticFor()
    %
    %   See also
    %       matlab.unittest.internal.constraints.CasualDiagnosticDecorator
    %       matlab.unittest.internal.constraints.CasualDiagnosticMixin
    
    %  Copyright 2013-2017 The MathWorks, Inc.
    
    methods (Abstract, Access = protected, Hidden)
        % Method responsible to provide casual negative constraint diagnostics
        diag = getCasualNegativeDiagnosticFor(constraint, actual)
    end
end