classdef variabletable < matlab.mixin.SetGet & matlab.mixin.Copyable
% Copyright 2016 The MathWorks, Inc.
        
    properties               
        ParameterList
        VariableList
        VariableNameList
        VariableNameListCount
    end    
    methods  
        addVariable(hVariableTable,hArg)
        clearTable(hVariableTable)
    end  
    
end  

