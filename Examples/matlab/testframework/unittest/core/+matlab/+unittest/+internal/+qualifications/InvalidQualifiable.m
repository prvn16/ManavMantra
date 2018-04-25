classdef InvalidQualifiable < matlab.unittest.qualifications.Assertable & ...
        matlab.unittest.qualifications.Assumable & ...
        matlab.unittest.qualifications.FatalAssertable
    
    % Copyright 2016 The MathWorks, Inc.
    
    events (NotifyAccess=private)
        DiagnosticLogged
    end
    
    methods
        function qualifiable = InvalidQualifiable()
            assertionInvalidDelegate = matlab.unittest.internal.qualifications.InvalidAssertionDelegate;
            assumptionInvalidDelegate = matlab.unittest.internal.qualifications.InvalidAssumptionDelegate;
            fatalAssertionInvalidDelegate = matlab.unittest.internal.qualifications.InvalidFatalAssertionDelegate;
            
            qualifiable@matlab.unittest.qualifications.Assertable(assertionInvalidDelegate);
            qualifiable@matlab.unittest.qualifications.Assumable(assumptionInvalidDelegate);
            qualifiable@matlab.unittest.qualifications.FatalAssertable(fatalAssertionInvalidDelegate);
        end
        
        function log(varargin)
            throwAsCaller(MException(message('MATLAB:unittest:Fixture:LogMethodMustBeCalledFromSetupOrTeardown')));
        end
        
        function onFailure(~,~)
            throwAsCaller(MException(message('MATLAB:unittest:Fixture:OnFailureMustBeCalledFromSetupOrTeardown')));
        end
    end
end

