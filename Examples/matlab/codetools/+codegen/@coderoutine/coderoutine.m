classdef coderoutine < matlab.mixin.SetGet & matlab.mixin.Copyable & codegen.Root
    % Copyright 2016 The MathWorks, Inc.          
    
    properties       
        Name       
        ParentRef@handle       
        Comment = '';       
        SeeAlsoList
    end
    
    properties (Access=protected, Hidden)
        VariableTable
    end
    
    properties (Hidden)       
        String       
        Argout       
        Argin       
        Functions
        SubFunctionList
    end
           
    methods
        function hThis = coderoutine
            % Constructor for the code routine.
            hThis.VariableTable = codegen.variabletable;
        end
        addComment(hThis,varargin)
        addSubFunction(hCodeRoutine,hSubFunc)
        hFunc = findSubFunction(hRoutine,funcName)
        toMCode(hRoutine,hText,options,isFirst)
        toText(hRoutine,hFunctionTable,options)
    end 
       
    methods (Hidden) 
        addArgin(hThis,hArg)
        addArgout(hThis,hArg)
        addFunction(hThis,hFunc)
        addText(hThis,varargin)
    end  
    
end

