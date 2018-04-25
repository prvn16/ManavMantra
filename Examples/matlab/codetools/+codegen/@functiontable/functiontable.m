classdef functiontable < matlab.mixin.SetGet & matlab.mixin.Copyable
    % Copyright 2016 The MathWorks, Inc.
    properties
        FunctionList
        FunctionNameList = {}
        FunctionNameListCount
    end
    
    %    codegen.functiontable methods:
    %       addFunction -  Add the function object, hFunc, to the function
    
    methods 
        addFunction(hFunctionTable,hFunc)
    end
    
end

