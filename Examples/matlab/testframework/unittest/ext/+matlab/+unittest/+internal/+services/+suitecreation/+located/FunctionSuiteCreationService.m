classdef FunctionSuiteCreationService < matlab.unittest.internal.services.suitecreation.FileBasedStaticAnalysisSuiteCreationService
    % This class is undocumented and will change in a future release.
    
    % FunctionSuiteCreationService - Suite creation service for function-based tests.
    
    % Copyright 2015 The MathWorks, Inc.
    
    methods (Access=protected)
        function parseTree = getParseTree(~, liaison)
            parseTree = liaison.ParseTree;
        end
        
        function selectFactoryUsingParseTree(~, liaison, parseTree)
            import matlab.unittest.internal.isFunctionBasedTest;
            import matlab.unittest.internal.FunctionTestFactory;
            
            if isFunctionBasedTest(parseTree)
                liaison.Factory = FunctionTestFactory(liaison.ParentName);
            end
        end
    end
end

% LocalWords:  suitecreation
