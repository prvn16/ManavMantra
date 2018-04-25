classdef TestContentCreationPluginData < matlab.unittest.plugins.plugindata.PluginData
    % TestContentCreationPluginData - Data about creating test content.
    %
    %   The TestContentCreationPluginData class holds information about test
    %   content being created.
    %
    %   TestContentCreationPluginData properties:
    %       Name - Name of the content being created.
    %
    %   See also:
    %       matlab.unittest.plugins.TestRunnerPlugin
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Hidden, SetAccess=immutable)
        % AffectedIndices is undocumented and will change in a future release.
        AffectedIndices double;
    end
    
    methods (Hidden, Access={?matlab.unittest.TestRunner,?matlab.unittest.plugins.plugindata.PluginData})
        function p = TestContentCreationPluginData(name, indices)
            p@matlab.unittest.plugins.plugindata.PluginData(name);
            p.AffectedIndices = indices;
        end
    end
end

% LocalWords:  plugindata
