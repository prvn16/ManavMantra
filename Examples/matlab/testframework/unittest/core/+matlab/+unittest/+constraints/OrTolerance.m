classdef OrTolerance < matlab.unittest.internal.constraints.CombiningTolerance
    % OrTolerance - Boolean disjunction of two tolerances.
    %   An OrTolerance is produced when the "|" operator is used to denote
    %   the disjunction of two tolerances.
    
    %  Copyright 2012-2014 The MathWorks, Inc.
    
    properties (Hidden, Constant, GetAccess = protected)
        BooleanOperator = @or;
    end
    
    methods (Access = ?matlab.unittest.internal.constraints.ElementwiseTolerance)
        function orTolerance = OrTolerance(varargin)
            orTolerance = orTolerance@matlab.unittest.internal.constraints.CombiningTolerance(varargin{:});
        end
    end    
end