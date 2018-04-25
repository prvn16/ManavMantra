% Copyright 2014-2017 The MathWorks, Inc.

classdef DataTipEvent < matlab.mixin.SetGet
    properties
        Target
        Position
    end

    properties(Hidden)
        DataIndex
        InterpolationFactor
    end

    properties(SetAccess = private, Hidden)
        DataTipHandle
    end

    methods
        function hThis = DataTipEvent(hDatatip)
            if nargin > 1
                hThis.DataTipHandle = hDatatip;
            end
        end
    end
end
