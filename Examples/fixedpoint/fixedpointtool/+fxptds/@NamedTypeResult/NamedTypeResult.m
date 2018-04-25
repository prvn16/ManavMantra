classdef NamedTypeResult < fxptds.AbstractSimulinkObjectResult
    % NAMEDTYPERESULT is the result class for SimulinkFixedPoint.NamedTypeHandle

    % Copyright 2016-2017 The MathWorks, Inc.

    methods
        function this = NamedTypeResult(data)
            this@fxptds.AbstractSimulinkObjectResult(data);
        end

        function icon = getDisplayIcon(this)
            icon = '';
            if this.isResultValid
                icon = fullfile('toolbox','fixedpoint','fixedpointtool','resources',['NamedNumericType' this.Alert '.png']);
            end
        end
    end
end

% LocalWords:  fixedpointtool
