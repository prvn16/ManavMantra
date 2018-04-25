classdef (Hidden) MethodEvaluationPluginData < matlab.unittest.plugins.plugindata.PluginData
    % This class is undocumented and may change in a future release.
    
    %  Copyright 2013 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % AddedTeardown - Boolean that indicates whether content was added dynamically.
        %
        %   The AddedTeardown property is a boolean that indicates whether the
        %   method being evaluated is an actual method defined in the class (in
        %   which case AddedTeardown is false) or if it is a function that was
        %   passed to the addTeardown method (in which case AddedTeardown is true).
        AddedTeardown
    end
    
    properties (Hidden, SetAccess=immutable)
        % Method - meta.method.
        %
        %   The Method property is a meta.method instance describing the method
        %   being evaluated.
        Method
        
        % Content - Content being evaluated.
        %
        %   The Content property holds the TestCase or Fixture instance on which
        %   the method is being evaluated.
        Content
    end
    
    properties (SetAccess=immutable, GetAccess=?matlab.unittest.TestRunner)
        Arguments
    end
    
    methods (Access = {?matlab.unittest.TestRunner, ?matlab.unittest.plugins.plugindata.PluginData})
        function p = MethodEvaluationPluginData(name, addedTeardown, method, content, arguments)
            p@matlab.unittest.plugins.plugindata.PluginData(name)
            p.AddedTeardown = addedTeardown;
            p.Method = method;
            p.Content = content;
            p.Arguments = arguments;
        end
    end
end

% LocalWords:  plugindata
