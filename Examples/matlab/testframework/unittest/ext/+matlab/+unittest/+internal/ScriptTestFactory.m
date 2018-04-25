classdef ScriptTestFactory < matlab.unittest.internal.TestSuiteFactory
    %This class is undocumented and may change in a future release.
    
    % ScriptTestFactory - Factory for creating suites for script-based tests.
    
    %  Copyright 2014-2017 The MathWorks, Inc.
    
    properties(Constant)
        CreatesSuiteForValidTestContent = true;
    end
    
    properties (Access=private)
        Filename;
        ParseTree;
    end
    
    methods
        function factory = ScriptTestFactory(filename, parseTree)
            factory.Filename = filename;
            factory.ParseTree = parseTree;
        end
        
        function suite = createSuiteExplicitly(factory, selector)
            suite = factory.createSuite(selector);
        end
        
        function suite = createSuiteImplicitly(factory, selector)
            suite = factory.createSuite(selector);
        end
    end
    
    methods (Access=private)
        function suite = createSuite(factory, selector)
            import matlab.unittest.Test;
            import matlab.unittest.internal.TestScriptMFileModel;
            import matlab.unittest.internal.TestScriptMLXFileModel;
            import matlab.unittest.internal.ScriptTestCaseProvider;
            import matlab.unittest.internal.LiveScriptTestCaseProvider;

            filename = factory.Filename;
            [~,~,ext] = fileparts(filename);
            
            if strcmpi(ext,'.m')
                model = TestScriptMFileModel.fromFile(filename, factory.ParseTree);
                provider = ScriptTestCaseProvider(model);
            elseif strcmp(ext,'.mlx')
                model = TestScriptMLXFileModel.fromFile(filename);
                provider = LiveScriptTestCaseProvider(model);
            end
            
            suite = selectIf(Test.fromProvider(provider), selector);
        end
    end
end