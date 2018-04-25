classdef(Hidden) TestScriptFileModel < matlab.unittest.internal.TestScriptModel
    %This class is undocumented and may change in a future release.
    
    %  Copyright 2013-2017 The MathWorks, Inc.
    
    properties(SetAccess = immutable)
        Filename
    end
    
    properties(Dependent, SetAccess=immutable)
        ScriptName
        SharedVariableSectionCode
        SharedVariableSectionExecutionCode
        TestSectionCodeList
        TestSectionExecutionCodeList
        FunctionSectionCode
    end
    
    properties(Abstract, SetAccess=immutable)
        FileCode
        TestSectionCodeExtentList
        SharedVariableSectionCodeExtent
        FunctionSectionCodeExtent
    end
    
    methods
        function model = TestScriptFileModel(fileName)
            model.Filename = fileName;
        end
        
        function scriptName = get.ScriptName(model)
            import matlab.unittest.internal.getParentNameFromFilename;
            scriptName = getParentNameFromFilename(model.Filename);
        end
        
        function value = get.SharedVariableSectionCode(model)
            value = model.getCodeFromCodeExtent(model.SharedVariableSectionCodeExtent);
        end
        
        function value = get.TestSectionCodeList(model)
            value = cellfun(@(codeExtent) model.getCodeFromCodeExtent(codeExtent),...
                model.TestSectionCodeExtentList,'UniformOutput',false);
        end
        
        function value = get.FunctionSectionCode(model)
            value = model.getCodeFromCodeExtent(model.FunctionSectionCodeExtent);
        end
        
        function value = get.SharedVariableSectionExecutionCode(model)
            codeExtent = model.SharedVariableSectionCodeExtent;
            value = model.getExecutionCodeFromCodeExtent(codeExtent);
        end
        
        function value = get.TestSectionExecutionCodeList(model)
            value = cellfun(@model.getExecutionCodeFromCodeExtent,...
                model.TestSectionCodeExtentList,'UniformOutput',false);
        end
    end
    
    methods(Access=private)
        function code = getCodeFromCodeExtent(model,codeExtent)
            startPos = codeExtent(1);
            endPos = startPos + codeExtent(2) - 1;
            code = model.FileCode(startPos:endPos);
        end
        
        function value = getExecutionCodeFromCodeExtent(model,codeExtent)
            sectionStartIndex = codeExtent(1);
            sectionLength = codeExtent(2);
            value = sprintf('matlab.unittest.internal.executeCodeBlock(''%s'',%d,%d);', ...
                model.ScriptName, sectionStartIndex, sectionLength);
        end
    end
end