function obj = getExistingInstance
% GETEXISTINGINSTANCE Gets the existing instance of the tool.

% Copyright 2015-2016 The MathWorks, Inc.

    obj =  fxptui.FixedPointTool.Instance;
    if isempty(obj.Model)
        obj = [];
    end
end
