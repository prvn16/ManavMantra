classdef ScriptSuiteCreationService < matlab.unittest.internal.services.suitecreation.FileBasedStaticAnalysisSuiteCreationService
    % This class is undocumented and will change in a future release.
    
    % ScriptSuiteCreationService - Suite creation service for script-based tests.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    methods (Access=protected)
        function parseTree = getParseTree(~, liaison)
            parseTree = mtree(liaison.Filename, '-file', '-cell');
        end
        
        function selectFactoryUsingParseTree(~, liaison, parseTree)
            import matlab.unittest.internal.ScriptTestFactory;
            
            if parseTree.FileType == mtree.Type.ScriptFile
                liaison.Factory = ScriptTestFactory(liaison.Filename, parseTree);
            end
        end
    end
end

% LocalWords:  suitecreation
