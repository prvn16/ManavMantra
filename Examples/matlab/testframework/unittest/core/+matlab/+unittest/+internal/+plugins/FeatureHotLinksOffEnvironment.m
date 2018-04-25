classdef FeatureHotLinksOffEnvironment < handle
        % Copyright 2015 The MathWorks, Inc.
    properties(SetAccess=immutable)
        PreviousState;
    end
    methods
        function obj = FeatureHotLinksOffEnvironment()
            obj.PreviousState = feature('hotlinks', 'off');
        end
        
        function delete(obj)
            feature('hotlinks', obj.PreviousState);
        end
    end
end