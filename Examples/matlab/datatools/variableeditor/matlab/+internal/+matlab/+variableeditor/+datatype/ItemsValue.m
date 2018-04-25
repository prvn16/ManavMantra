classdef ItemsValue
    % This class is used for the value of the items when it can only be a
    % single, scalar object, and not multiple things
    %
    % Ex: drop down
    % Ex: not list box

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
