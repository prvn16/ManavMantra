classdef ParameterObjectResult < fxptds.AbstractSimulinkObjectResult
    % SIGNALOBJECTRESULT Class definition for result corresponding to a signal object
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods
        function this = ParameterObjectResult(data)
            this@fxptds.AbstractSimulinkObjectResult(data);
        end
        
        function icon = getDisplayIcon(this)
            icon = '';
            if this.isResultValid
                icon = fullfile('toolbox','fixedpoint','fixedpointtool','resources',['ParameterObject' this.Alert '.png']);
            end
        end
    end
    
    methods(Hidden)
        function computeIfInheritanceReplaceable(this)
            % Inheritance is replaceable for parameter objects
            this.IsInheritanceReplaceable  = true;
        end
    end
end

