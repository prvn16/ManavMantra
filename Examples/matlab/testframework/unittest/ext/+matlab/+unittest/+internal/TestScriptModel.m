classdef(Hidden) TestScriptModel
    % The TestScriptModel an interface for defining models of test scripts
    
    %  Copyright 2013-2016 The MathWorks, Inc.
    
    properties(Abstract, SetAccess=immutable)
        ScriptName
        
        TestSectionNameList
        TestSectionCodeList
        TestSectionExecutionCodeList
        
        SharedVariableSectionCode
        SharedVariableSectionExecutionCode
        
        FunctionSectionCode
        
        ScriptValidationFcn
    end
end