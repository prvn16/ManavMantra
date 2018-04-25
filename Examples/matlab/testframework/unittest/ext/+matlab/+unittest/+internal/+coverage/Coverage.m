classdef (Abstract) Coverage < matlab.mixin.Heterogeneous & handle
    % Class is undocumented and may change in a future release.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (Abstract, SetAccess = private)
        ExecutableLineCount
        ExecutedLineCount
        SourceList
    end
    
    properties(Dependent,SetAccess = private)
        LineRate
    end
    
    methods (Abstract)
        varargout = formatCoverageData(coverage,coverageFormatter,varargin)
    end
    
    methods
        function rate = get.LineRate(coverage)
            rate = coverage.ExecutedLineCount/coverage.ExecutableLineCount;
        end
    end
end