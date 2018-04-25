classdef ClassSpecification < matlab.unittest.internal.constraints.ExpectedAlertSpecification
    % ClassSpecification - This class is undocumented. 
    
    % Copyright 2015 The MathWorks, Inc.
    properties(Dependent)
        MetaClass;
    end
    
    methods(Static)
        function str = formatForDisplay(actualAlert)
            str = actualAlert.toStringForDisplayClass();
        end
    end
    
    methods
        function tf = accepts(expectedAlertSpecification, actualAlert)
            tf = actualAlert.conformsToClass(expectedAlertSpecification);
        end
        
        function str = toStringForDisplay(spec)
            str = ['?' spec.Specification.Name];
        end
        
        function metaClass = get.MetaClass(spec)
            metaClass = spec.Specification;
        end
        
        tf = eq(spec1, spec2);
    end
    
    methods(Access=?matlab.unittest.internal.constraints.ExpectedAlertSpecification)
        function spec = ClassSpecification(classes)
            classesCell = num2cell(classes);
            spec = spec@matlab.unittest.internal.constraints.ExpectedAlertSpecification(classesCell);
        end
    end
    
end

