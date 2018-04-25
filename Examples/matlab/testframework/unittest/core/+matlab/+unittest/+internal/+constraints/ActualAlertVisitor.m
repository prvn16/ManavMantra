classdef ActualAlertVisitor < matlab.mixin.Heterogeneous & ...
                              matlab.unittest.internal.mixin.UnsortedUniqueMixin & ...
                              matlab.unittest.internal.mixin.TrimRepeatedElementsMixin
    % ActualAlertVisitor - Abstract interface that holds on to an alert, e.g.,
    % an exception or warning.
    
    % Copyright 2015 The MathWorks, Inc.
    properties(Access=protected)
        Alert;
    end
    
    methods(Access=protected) 
        
        function thisAlertObject = ActualAlertVisitor(actualAlerts)
            thisAlertObject = repmat(thisAlertObject, 1, numel(actualAlerts));           
            alertsCell = num2cell(actualAlerts);
            if ~isempty(thisAlertObject)
                [thisAlertObject.Alert] = alertsCell{:};
            end
        end
    end
    
    methods
        
        function tf = eq(alert1, alert2)
            if isempty(alert1) && isempty(alert2)
                tf = logical.empty(1, 0);
            elseif size(alert1) == size(alert2)
                tf = arrayfun(@(x, y)isEquivalentTo(x, y), alert1, alert2);
            elseif isscalar(alert2) && numel(alert1) > 1
                tf = arrayfun(@(x)isEquivalentTo(x, alert2), alert1);
            end
        end
        
    end
    
    methods(Abstract)
        tf = conformsToID(thisAlert, expectedAlertSpec);
        tf = conformsToMessageObject(thisAlert, expectedAlertSpec);
        tf = conformsToClass(thisAlert, expectedAlertSpec);
        
        tf = isEquivalentTo(alert1, alert2);
        
        str = toStringForDisplayID(thisAlert);
        str = toStringForDisplayMessageObject(thisAlert)
        str = toStringForDisplayClass(thisAlert);
    end
end