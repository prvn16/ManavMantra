classdef(HandleCompatible) TestResultEnhancerMixin
    % This class is undocumented and may change in a future release.
    
    %  Copyright 2015 The MathWorks, Inc.
    properties(GetAccess=private,SetAccess=immutable)
        TestSuiteRunPluginData;
    end
    
    methods
        function mixin = TestResultEnhancerMixin(testSuiteRunPluginData)
            mixin.TestSuiteRunPluginData = testSuiteRunPluginData;
        end
    end
    
    methods(Access=protected)
        function appendDetails(mixin, varargin)
            mixin.TestSuiteRunPluginData.appendDetails(varargin{:});
        end
    end
end