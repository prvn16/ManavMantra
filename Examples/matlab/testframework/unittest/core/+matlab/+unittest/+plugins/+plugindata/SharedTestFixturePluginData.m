classdef SharedTestFixturePluginData < matlab.unittest.plugins.plugindata.PluginData
    % SharedTestFixturePluginData - Data about shared test fixtures.
    %
    %   The SharedTestFixturePluginData class holds information about
    %   shared test fixtures.
    %
    %   SharedTestFixturePluginData properties:
    %       Name - Name of shared test fixture.
    %       Description - Action performed by the shared fixture.
    %       QualificationContext - Context for performing qualifications.
    %
    %   See also: matlab.unittest.plugins.TestRunnerPlugin, matlab.unittest.fixtures.Fixture
    %
    
    %  Copyright 2013-2017 The MathWorks, Inc.
    
    
    properties (SetAccess = ?matlab.unittest.TestRunner)
        % Description - Action performed by the shared fixture.
        %
        %   The Description property is a string which contains information about
        %   the actions performed during the setup or teardown of a shared test
        %   fixture.
        Description = '';
    end
    
    properties (Dependent, SetAccess=private)
        % QualificationContext - Context for performing qualifications.
        %   QualificationContext provides the context for plugins to perform
        %   qualifications on fixtures. To perform a qualification, a plugin should
        %   derive from the matlab.unittest.plugins.QualifyingPlugin interface and
        %   use one of its qualification methods: assumeUsing, assertUsing, or
        %   fatalAssertUsing.
        %
        %   See Also: matlab.unittest.plugins.QualifyingPlugin
        QualificationContext;
    end
    
    properties (Access=?matlab.unittest.TestRunner)
        Fixture;
    end
    
    methods (Access = {?matlab.unittest.TestRunner, ?matlab.unittest.plugins.plugindata.SharedTestFixturePluginData})
        function p = SharedTestFixturePluginData(name, description, fixture)
            p@matlab.unittest.plugins.plugindata.PluginData(name);
            p.Description = description;
            p.Fixture = fixture;
        end
    end
    
    methods
        function context = get.QualificationContext(pluginData)
            context = matlab.unittest.plugins.plugindata.QualificationContext(pluginData.Fixture);
        end

        function set.Description(pluginData,value)
            validateattributes(value,{'char','string'},{'scalartext'},'','Description');
            pluginData.Description = char(value);
        end
    end
end

% LocalWords:  plugindata scalartext
