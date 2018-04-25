classdef ExceptionAlert < matlab.unittest.internal.constraints.ActualAlertVisitor
    % ExceptionAlert - This class is undocumented. It represents an
    % exception.
    
    % Copyright 2015-2016 The MathWorks, Inc.
    properties (Constant, Access=private)
        EmptyMetaClass = getEmptyMetaClass;
    end
    
    properties(Dependent, Access=private)
        MetaClass;
    end
    
    methods
        function alertObj = ExceptionAlert(exceptions)
            alertObj = alertObj@matlab.unittest.internal.constraints.ActualAlertVisitor(exceptions);
        end
        
        function metaClass = get.MetaClass(thisAlert)
            metaClass = metaclass(thisAlert.Alert);
        end
        
        function tf = isEquivalentTo(alert1, alert2)
            tf = isequal(alert1.Alert.identifier, alert2.Alert.identifier) &&  isequal(alert1.Alert.arguments, alert2.Alert.arguments);
        end
        
        function tf = conformsToID(thisAlert, expectedAlertSpec)
            tf = arrayfun(@(x)strcmp(thisAlert.Alert.identifier, x.Identifier), expectedAlertSpec);
        end
        
        function tf = conformsToMessageObject(thisAlert, expectedAlertSpec)
            tf = strcmp(thisAlert.Alert.identifier, {expectedAlertSpec.Identifier}) & ...
                 arrayfun(@(x)isequal(x.Arguments, thisAlert.Alert.arguments), expectedAlertSpec);
        end
        
        function str = toStringForDisplayID(thisAlert)
            import matlab.unittest.internal.constraints.getIdentifierString;
            str = getIdentifierString(thisAlert.Alert.identifier);
        end
        
        function str = toStringForDisplayMessageObject(thisAlert)
            import matlab.unittest.internal.constraints.AlertDiagnosticDisplayHelper;
            import matlab.unittest.internal.diagnostics.getValueDisplay;
            
            displayHelper = AlertDiagnosticDisplayHelper(...
                            thisAlert.Alert.identifier, ...
                            thisAlert.Alert.message, ...
                            thisAlert.Alert.arguments);         
            
            str = char(getValueDisplay(displayHelper));
            str = regexprep(str, {'^    ', '\n    '},{'','\n'});
        end
        
        function tf = conformsToClass(thisAlert, expectedAlertSpec)
            import matlab.unittest.internal.constraints.ExceptionAlert;
            tf = reshape([ExceptionAlert.EmptyMetaClass, thisAlert.MetaClass], size(thisAlert)) <= ...
                reshape([ExceptionAlert.EmptyMetaClass, expectedAlertSpec.MetaClass], size(expectedAlertSpec));
        end
        
        function str = toStringForDisplayClass(thisAlert)
            classInfo = metaclass(thisAlert.Alert);
            str = ['?' classInfo.Name];
        end
        
    end
end

function mc = getEmptyMetaClass
mc = ?matlab.unittest.internal.constraints.ExceptionAlert;
mc(:) = [];
end