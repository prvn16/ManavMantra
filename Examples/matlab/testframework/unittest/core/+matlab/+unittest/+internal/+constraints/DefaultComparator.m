% This class is undocumented.

% DefaultComparator - A concrete Comparator implementation
%
%   The DefaultComparator class is a Comparator implementation which
%   provides no actual comparison capability.

%  Copyright 2012-2016 The MathWorks, Inc.

classdef DefaultComparator < matlab.unittest.constraints.Comparator
    methods(Access=protected)
        function bool = containerSatisfiedBy(~, ~, ~)
            bool = false;
        end
        
        function bool = supportsContainer(~, ~)
            bool = false;
        end
    end
end