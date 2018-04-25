classdef CodyNoTestCellScriptModel < connector.internal.academy.testmodels.CodyTestScriptModel
    % The CodyNoTestCellScriptModel is a TestScriptFileModel that describes
    % script based tests that have no cell markers
    
    %  Copyright 2015 The MathWorks, Inc.
    
    
    properties(Dependent, SetAccess=immutable)
        TestCellNames
        TestCellContent
    end

    properties(SetAccess=immutable)
        TestCellExecutionCode = '';
        ImplicitCellContent = '';
        ImplicitCellExecutionCode = '';
    end
    
    methods(Static)
        function model = fromString(contents, scriptName)
            model = connector.internal.academy.testmodels.CodyNoTestCellScriptModel(contents, scriptName);
        end
    end
    
    methods
        
        function content = get.TestCellContent(model)
            content = {model.FileContents};
        end
        
        function names = get.TestCellNames(model)
            names = {model.ScriptName};
        end
        
    end
    
    methods(Access=private)
        function model = CodyNoTestCellScriptModel(contents, scriptName)
            model = model@connector.internal.academy.testmodels.CodyTestScriptModel(contents, scriptName);
        end
    end
    
end

