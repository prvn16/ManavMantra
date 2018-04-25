classdef AndTolerance < matlab.unittest.internal.constraints.CombiningTolerance
    % AndTolerance - Boolean conjunction of two tolerances.
    %   An AndTolerance is produced when the "&" operator is used to denote
    %   the conjunction of two tolerances.
    
    %  Copyright 2012-2014 The MathWorks, Inc.
    
    properties (Hidden, Constant, GetAccess = protected)
        BooleanOperator = @and;
    end
    
    methods (Access = ?matlab.unittest.internal.constraints.ElementwiseTolerance)
        function andTolerance = AndTolerance(varargin)
            andTolerance = andTolerance@matlab.unittest.internal.constraints.CombiningTolerance(varargin{:});
        end
    end
end