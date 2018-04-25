classdef Items
    % This class is unsupported and might change or be removed without
    % notice in a future version.

    % Copyright 2017 The MathWorks, Inc.

    properties(Access = private)
        Value;
    end

    methods
        function this = Items(v)
            this.Value = v;
        end

        function v = getItems(this)
            v = this.Value;
        end
    end
end
