classdef IDSpecification < matlab.unittest.internal.constraints.ExpectedAlertSpecification
    % IDSpecification - This class is undocumented. 
    
    % Copyright 2015 The MathWorks, Inc.
    properties(Dependent)
        Identifier;
    end
    
    methods(Static)        
        function str = formatForDisplay(actualAlert)
            str = actualAlert.toStringForDisplayID();
        end
    end
    
    methods
        
        function tf = accepts(expectedAlertSpecification, actualAlert)
            tf = actualAlert.conformsToID(expectedAlertSpecification);
        end
        
        function tf = eq(spec1, spec2)
            tf = strcmp({spec1.Identifier}, {spec2.Identifier});
        end
        
        function str = toStringForDisplay(spec)
            import matlab.unittest.internal.constraints.getIdentifierString;
            str = getIdentifierString(spec.Specification);
        end
        
        function id = get.Identifier(spec)
            id = spec.Specification;
        end
    end
    
    methods(Access=?matlab.unittest.internal.constraints.ExpectedAlertSpecification)                    
        function idSpec = IDSpecification(ids)
            idSpec = idSpec@matlab.unittest.internal.constraints.ExpectedAlertSpecification(ids);
        end
    end
    
end