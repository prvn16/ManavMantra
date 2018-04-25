classdef codeprogram < matlab.mixin.SetGet & matlab.mixin.Copyable
    %codegen.codeprogram class
    
    properties (Access=protected, Hidden)
        SubFunctionList
        FunctionTable
    end
    
    events
        TextComplete
    end
    
    methods
        function hThis = codeprogram
            % Constructor for the base code generator
            hThis.FunctionTable = codegen.functiontable;
        end                
        addSubFunction(hCodeProgram,hSubFunc)
        hFunc = findSubFunction(hRoutine,funcName)
        out = toMCode(hCodeProgram,options)
    end     
end

