classdef CompositeAlertCheck < matlab.unittest.internal.constraints.AlertDescriptionCheck
    % This class is undocumented.
    
    % CompositeAlertCheck - Used in Throws and IssuesWarnings to perform
    % various checks.
    %
    %   See also
    %       matlab.unittest.internal.constraints.CauseCheck
    
    % Copyright 2015 The MathWorks, Inc.
    properties(SetAccess = private)
        AlertChecks = matlab.unittest.internal.constraints.AlertDescriptionCheck.empty(0,0);
    end
    
    methods
        function addAlertCheck(composite,alertCheck)
            composite.AlertChecks(end+1) = alertCheck;
        end
        
        function check(composite,alertDescription)
            arrayfun(@(alertCheck) alertCheck.check(alertDescription),composite.AlertChecks);
        end
        
        function tf = isSatisfied(composite)
            tf = all(arrayfun(@isSatisfied,composite.AlertChecks));
        end
        
        function tf = isDone(composite)
            tf = all(arrayfun(@isDone,composite.AlertChecks));
        end
    end
end