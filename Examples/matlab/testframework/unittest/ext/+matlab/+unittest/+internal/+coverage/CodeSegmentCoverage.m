classdef CodeSegmentCoverage
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (Abstract, SetAccess = private)
        ExecutableLines
        HitCount
    end
    
    properties (Dependent)
        LineRate
    end
    
    methods
        function rate = get.LineRate(coverage)
             rate = nnz(coverage.HitCount)/numel(coverage.ExecutableLines);
         end
    end
    
end

