classdef BusObjectResult < fxptds.AbstractSimulinkObjectResult
    % BUSOBJECTRESULT Class definition for result corresponding to a leaf element of a bus.
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    
    methods
        function this = BusObjectResult(data)
            this@fxptds.AbstractSimulinkObjectResult(data);
        end
        
        function icon = getDisplayIcon(this)
            icon = '';
            if this.isResultValid
                icon = fullfile('toolbox','fixedpoint','fixedpointtool','resources',['SimulinkBus' this.Alert '.png']);
            end
        end
    end
end