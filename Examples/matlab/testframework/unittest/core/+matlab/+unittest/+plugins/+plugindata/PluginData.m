classdef PluginData < handle
    % PluginData - Interface for implementing plugin data.
    %
    %   The PluginData class is the fundamental interface for creating plugin
    %   data to be passed to various plugin methods.
    %
    %   PluginData properties:
    %       Name - Name of content being executed.
    %
    %   See also: matlab.unittest.plugins.TestRunnerPlugin
    %
    
    %  Copyright 2013 The MathWorks, Inc.
    
    
    properties (SetAccess = immutable)
        % Name - Name of content being executed.
        %
        %   The Name property is a string which labels the content being executed
        %   within the scope of a plugin method. The Name property is intended for
        %   informational, labeling, and display purposes. The Name should not be
        %   used programmatically to introspect into the content being executed.
        Name = '';
    end
    
    methods (Access = {?matlab.unittest.TestRunner, ?matlab.unittest.plugins.plugindata.PluginData})
        function p = PluginData(name)
            if nargin == 1
                p.Name = name;
            end
        end
    end
    
end

% LocalWords:  plugindata
