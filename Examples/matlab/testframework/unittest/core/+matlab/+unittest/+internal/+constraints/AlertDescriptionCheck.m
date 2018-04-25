classdef AlertDescriptionCheck < handle & matlab.mixin.Heterogeneous
    % This class is undocumented.
    
    % Copyright 2015 The MathWorks, Inc.
    methods (Abstract)
        check(alertCheck,causeDescription)
        tf = isDone(alertCheck)
        tf = isSatisfied(alertCheck)
    end
end