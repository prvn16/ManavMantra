classdef CodeSegmentInformation < matlab.mixin.Heterogeneous
 
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (Abstract, SetAccess = private)
        ExecutableLines
    end
    
    properties (Access = protected)
        ElementTreeNode
    end 
end

