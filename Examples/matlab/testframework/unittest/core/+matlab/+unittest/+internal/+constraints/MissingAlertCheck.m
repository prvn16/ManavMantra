classdef MissingAlertCheck < matlab.unittest.internal.constraints.AlertDescriptionCheck
    % This class is undocumented.
    
    % MissingAlertCheck - Used in Throws and IssuesWarnings to check
    % whether alerts are missing.
    %
    %   See also
    %       matlab.unittest.internal.constraints.AlertDescriptionCheck
    
    % Copyright 2015 The MathWorks, Inc.
    properties (SetAccess = private)
        UnhitAlertSpecifications;
    end
    
    methods
        function alertCheck = MissingAlertCheck(expectedAlertSpecifications)
            alertCheck.UnhitAlertSpecifications = expectedAlertSpecifications;
        end
        
        function check(alertCheck,actualAlert)
            if alertCheck.isDone()
                return;
            end
            
            foundMask = alertCheck.UnhitAlertSpecifications.accepts(actualAlert);
            alertCheck.UnhitAlertSpecifications(foundMask) = [];
        end
        
        function tf = isDone(alertCheck)
            tf = alertCheck.isSatisfied();
        end
        
        function tf = isSatisfied(alertCheck)
            tf = isempty(alertCheck.UnhitAlertSpecifications);
        end
    end
end