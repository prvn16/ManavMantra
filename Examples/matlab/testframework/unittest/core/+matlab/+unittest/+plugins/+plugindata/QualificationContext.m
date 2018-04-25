classdef QualificationContext
    % QualificationContext - Context for QualifyingPlugins.
    %   The QualificationContext is constructed by the test framework to
    %   provide the context for QualifyingPlugins to perform qualifications.
    %
    %   See Also: matlab.unittest.plugins.QualifyingPlugin
    
    % Copyright 2015 The MathWorks, Inc.
    
    
    properties (Hidden, SetAccess=immutable, GetAccess=?matlab.unittest.plugins.QualifyingPlugin)
        TestContent_;
    end
    
    methods (Hidden, Access=?matlab.unittest.plugins.plugindata.PluginData)
        function context = QualificationContext(content)
            context.TestContent_ = content;
        end
    end
end

% LocalWords:  plugindata
