classdef PublishExtension < handle
% Copyright 1984-2009 The MathWorks, Inc.

    properties
        options = [];
    end
    methods
        function obj = PublishExtension(options)
            obj.options = options;
        end
    end
    methods(Abstract)
        enteringCell(obj,iCell)
        leavingCell(obj,iCell)
    end
end