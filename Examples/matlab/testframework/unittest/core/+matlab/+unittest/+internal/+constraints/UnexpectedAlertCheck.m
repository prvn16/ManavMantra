classdef UnexpectedAlertCheck < matlab.unittest.internal.constraints.AlertDescriptionCheck
    % This class is undocumented.
    
    % UnexpectedAlertCheck - Used in IssuesWarnings to perform RespectingSet check.
    %
    %   See also
    %       matlab.unittest.internal.constraints.AlertDescriptionCheck
    
    % Copyright 2015 The MathWorks, Inc.
    properties (SetAccess = immutable, GetAccess = private)
        ExpectedAlertSpecifications;
    end
    
    properties (SetAccess = private)
        UnexpectedAlertSpecifications;
    end
    
    methods
        function alertCheck = UnexpectedAlertCheck(expectedAlertSpecifications)
            import matlab.unittest.internal.constraints.ActualAlertVisitor;
            alertCheck.ExpectedAlertSpecifications = expectedAlertSpecifications;
            alertCheck.UnexpectedAlertSpecifications = ActualAlertVisitor.empty(0,0);
        end
        
        function check(alertCheck,actualAlert)
            
            foundMask = alertCheck.ExpectedAlertSpecifications.accepts(actualAlert);
            if ~any(foundMask)
                alertCheck.UnexpectedAlertSpecifications(end+1) = actualAlert;
            end
        end
        
        function tf = isDone(alertCheck)
            tf = ~alertCheck.isSatisfied();
        end
        
        function tf = isSatisfied(alertCheck)
            tf = isempty(alertCheck.UnexpectedAlertSpecifications);
        end
    end
end