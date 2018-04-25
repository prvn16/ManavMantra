classdef QualifyingPlugin < matlab.unittest.plugins.TestRunnerPlugin
    % QualifyingPlugin - Interface for plugins that perform qualification.
    %   QualifyingPlugin is an interface for TestRunnerPlugins that perform
    %   qualifications (verifications, assumptions, assertions, and fatal
    %   assertions) on test content. QualifyingPlugins provide the ability to
    %   add system-wide qualification to a suite of tests which can be
    %   selectively enabled by adding the plugin to a TestRunner.
    %
    %   Assumptions, assertions, and fatal assertions can be performed in the
    %   following plugin methods:
    %       * setupSharedTestFixture
    %       * teardownSharedTestFixture
    %
    %   Verifications, assumptions, assertions, and fatal assertions can be
    %   performed in the following plugin methods:
    %       * setupTestClass
    %       * teardownTestClass
    %       * setupTestMethod
    %       * teardownTestMethod
    %
    %   QualifyingPlugin Methods:
    %       verifyUsing - Verify that a value meets a constraint.
    %       assumeUsing - Assume that a value meets a constraint.
    %       assertUsing - Assert that a value meets a constraint.
    %       fatalAssertUsing - Fatally assert that a value meets a constraint.
    %
    %   Example:
    %
    %     classdef VerifyNoPathChangePlugin < matlab.unittest.plugins.QualifyingPlugin
    %         % This plugin ensures that tests leave the path unchanged by failing
    %         % any test which leaves the path in a different state from when the
    %         % test started.
    %
    %         properties (Access=private)
    %             OriginalPath;
    %         end
    %
    %         methods (Access=protected)
    %             function setupTestClass(plugin, pluginData)
    %                 plugin.OriginalPath = path;
    %                 setupTestClass@matlab.unittest.plugins.QualifyingPlugin(plugin, pluginData);
    %             end
    %             function teardownTestClass(plugin, pluginData)
    %                 import matlab.unittest.constraints.IsEqualTo;
    %                 teardownTestClass@matlab.unittest.plugins.QualifyingPlugin(plugin, pluginData);
    %                 plugin.verifyUsing(pluginData.QualificationContext, ...
    %                     path, IsEqualTo(plugin.OriginalPath), ...
    %                     sprintf('%s modified the path.', pluginData.Name));
    %             end
    %         end
    %     end
    %
    %
    %   See Also
    %       matlab.unittest.plugins.TestRunnerPlugin
    %       matlab.unittest.plugins.plugindata.QualificationContext
    
    % Copyright 2014-2017 The MathWorks, Inc.
    
    methods (Sealed, Access=protected)
        function plugin = QualifyingPlugin
        end
        
        function verifyUsing(~, context, varargin)
            % verifyUsing - Verify that a value meets a given constraint.
            %
            %   PLUGIN.verifyUsing(CONTEXT, ACTUAL, CONSTRAINT) uses CONTEXT to verify
            %   that ACTUAL is a value that satisfies the CONSTRAINT provided.
            %
            %   PLUGIN.verifyUsing(CONTEXT, ACTUAL, CONSTRAINT, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %
            %   See Also: matlab.unittest.qualifications.Verifiable/verifyThat
            
            validateContext(context);
            validateTestContent(context.TestContent_);
            context.TestContent_.verifyThat(varargin{:});
        end
        
        function assumeUsing(~, context, varargin)
            % assumeUsing - Assume that a value meets a given constraint.
            %
            %   PLUGIN.assumeUsing(CONTEXT, ACTUAL, CONSTRAINT) uses CONTEXT to
            %   assume that ACTUAL is a value that satisfies the CONSTRAINT
            %   provided.
            %
            %   PLUGIN.assumeUsing(CONTEXT, ACTUAL, CONSTRAINT, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %
            %   See Also: matlab.unittest.qualifications.Assumable/assumeThat
            
            validateContext(context);
            context.TestContent_.assumeThat(varargin{:});
        end
        
        function assertUsing(~, context, varargin)
            % assertUsing - Assert that a value meets a given constraint.
            %
            %   PLUGIN.assertUsing(CONTEXT, ACTUAL, CONSTRAINT) uses CONTEXT to
            %   assert that ACTUAL is a value that satisfies the CONSTRAINT
            %   provided.
            %
            %   PLUGIN.assertUsing(CONTEXT, ACTUAL, CONSTRAINT, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %
            %   See Also: matlab.unittest.qualifications.Assertable/assertThat
            
            validateContext(context);
            context.TestContent_.assertThat(varargin{:});
        end
        
        function fatalAssertUsing(~, context, varargin)
            % fatalAssertUsing - Fatally assert that a value meets a given constraint.
            %
            %   PLUGIN.fatalAssertUsing(CONTEXT, ACTUAL, CONSTRAINT) uses CONTEXT to
            %   fatally assert that ACTUAL is a value that satisfies the CONSTRAINT
            %   provided.
            %
            %   PLUGIN.fatalAssertUsing(CONTEXT, ACTUAL, CONSTRAINT, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %
            %   See Also: matlab.unittest.qualifications.FatalAssertable/fatalAssertThat
            
            validateContext(context);
            context.TestContent_.fatalAssertThat(varargin{:});
        end
    end
    
    methods (Hidden, Sealed, Access=protected)
        function handlePluginAssertionOrAssumptionFailedException_(~, ~, ~)
        end
    end
end

function validateContext(context)
if ~isa(context, 'matlab.unittest.plugins.plugindata.QualificationContext')
    error(message('MATLAB:unittest:QualifyingPlugin:InvalidContext'));
end
end

function validateTestContent(testContent)
if isa(testContent, 'matlab.unittest.fixtures.Fixture')
    error(message('MATLAB:unittest:QualifyingPlugin:VerifyUsingWithFixture'));
end
end

% LocalWords:  plugindata
