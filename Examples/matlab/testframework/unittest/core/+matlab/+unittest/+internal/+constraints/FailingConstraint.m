classdef FailingConstraint < matlab.unittest.constraints.Constraint
    %FAILINGCONSTRAINT This class is a Constraint to be used in the event of
    %unconditional failure. It is utilized by the <qualify>Fail methods.
    
    % Copyright 2011-2016 The MathWorks, Inc.
    
    methods
        function bool = satisfiedBy(~,~)
            bool = false;
        end
        function diag = getDiagnosticFor(~,~)
            diag = matlab.unittest.diagnostics.Diagnostic.empty(1,0);
        end
    end
end