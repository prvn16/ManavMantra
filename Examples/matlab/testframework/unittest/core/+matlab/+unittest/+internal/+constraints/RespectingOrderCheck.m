classdef RespectingOrderCheck < matlab.unittest.internal.constraints.AlertDescriptionCheck
    % This class is undocumented.
    
    % RespectingOrderCheck - Used in IssuesWarnings to help examine the
    % warnings
    %
    %   See also
    %       matlab.unittest.internal.constraints.AlertDescriptionCheck
    
    % Copyright 2015 The MathWorks, Inc.    
    properties(Access=private)
        ExpectedAlertSpecifications;
        NumExpectedSpecification;
        CurrentPointer;
        IsFailed;
    end
    
    properties(Access=private, Dependent)
        CurrentSpecification;
        NextSpecification;
    end
    
    properties(SetAccess=private)
        ActualThatMatchedExpectedSpecifications;
    end
    
    methods
        
        function orderCheck = RespectingOrderCheck(expAlertSpecifications)
            import matlab.unittest.internal.constraints.ActualAlertVisitor;
            
            orderCheck.ExpectedAlertSpecifications = trimRepeatedElements(expAlertSpecifications);
            orderCheck.NumExpectedSpecification = numel(orderCheck.ExpectedAlertSpecifications);
            orderCheck.ActualThatMatchedExpectedSpecifications = ActualAlertVisitor.empty(1, 0);
            orderCheck.CurrentPointer = 0;
            orderCheck.IsFailed = false;
        end
        
        function check(orderCheck, actAlert)
            
            if orderCheck.actualConformsToCurrentPointer(actAlert)
                orderCheck.ActualThatMatchedExpectedSpecifications(end+1) = actAlert;
            elseif orderCheck.actualConformsToNext(actAlert)
                orderCheck.CurrentPointer = orderCheck.CurrentPointer + 1;
                orderCheck.ActualThatMatchedExpectedSpecifications(end+1) = actAlert;
            elseif orderCheck.actualConformsToSomethingElse(actAlert)
                orderCheck.IsFailed = true;
                orderCheck.ActualThatMatchedExpectedSpecifications(end+1) = actAlert;
            end
            
        end
        
        function tf = isDone(orderCheck)
            tf = orderCheck.IsFailed;
        end
        
        function tf = isSatisfied(orderCheck)
            tf = orderCheck.CurrentPointer == orderCheck.NumExpectedSpecification && ~orderCheck.IsFailed;
        end
        
        function currDesc = get.CurrentSpecification(orderCheck)
            currDesc = orderCheck.ExpectedAlertSpecifications(orderCheck.CurrentPointer);
        end
        
        function nextDesc = get.NextSpecification(orderCheck)
            nextDesc = orderCheck.ExpectedAlertSpecifications(orderCheck.CurrentPointer+1);
        end
        
    end
    
    methods(Access=private)

        function tf = actualConformsToCurrentPointer(orderCheck, actAlert)
            tf = orderCheck.CurrentPointer ~= 0 && orderCheck.CurrentSpecification.accepts(actAlert);
        end
        
        function tf = actualConformsToNext(orderCheck, actAlert)
            tf = orderCheck.CurrentPointer ~= orderCheck.NumExpectedSpecification && ...
                orderCheck.NextSpecification.accepts(actAlert);
        end
        
        function tf = actualConformsToSomethingElse(orderCheck, actAlert)
            tf = false;
            for idx = [1:orderCheck.CurrentPointer-1, orderCheck.CurrentPointer+2:orderCheck.NumExpectedSpecification]
                if orderCheck.ExpectedAlertSpecifications(idx).accepts(actAlert)
                    tf = true;
                    return;
                end
            end
        end
        
    end
end