classdef (Hidden) OverriddenParameter 
    % Copyright 2016 The MathWorks, Inc.
    properties(SetAccess=immutable)
        Value;
        Name;
    end
    methods
        function obj = OverriddenParameter(name, value)
            obj.Name = name;
            if ~iscell(value)
                obj.Value = num2cell(value);
            else
                obj.Value = value;
            end
        end
    end
end