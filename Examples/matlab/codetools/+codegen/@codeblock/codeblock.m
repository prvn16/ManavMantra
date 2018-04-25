classdef codeblock < matlab.mixin.SetGet & matlab.mixin.Copyable & matlab.mixin.internal.TreeNode & codegen.Root
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties
        Name
        Argin
        Argout
        PostConstructorFunctions
        PreConstructorFunctions
        FunctionObjects
        Constructor
        MomentoRef
        SubFunctionList
        PostChildFunctions
    end
    
    methods
        function hThis = codeblock(varargin)
            % Constructor for the codeblock object.
            % Recursively traverse momento hierarchy and create a parallel
            % hierarchy of code objects. Each code object encapsulates
            % the constructor and helper functions.
            % Syntax: codegen.codeblock(momento)
            %         codegen.codeblock(momento,code_parent)
            
            if ~isempty(varargin)
                hThis = constructObj(hThis,varargin{:});
            end
        end         
        addComment(hThis,varargin)
        addFunction(hThis,hFunc)
        addPostChildFunction(hThis,hFunc)
        addPostConstructorComment(hThis,varargin)
        addProperty(hThis,propnames)
        addPropertyIfChanged(hCode,propname,defaultValue)
        addSubFunction(hCode,hSubFunc)
        newName = cleanName(hCode,name,defaultName)
        varargout = constructObj(hThis,momento,code_parent)
        hFunc = findSubFunction(hCode,funcName)
        generateProperty(hThis,propnames,reverseTraverse)
        hProp = getProperty(hThis,propname)
        [hRequire,hProvide] = getVariableUsage(hCode)
        bool = hasProperty(hThis,propname)
        ignoreProperty(hThis,propnames)
        markAsParameter(hThis,propnames)
        setDataTypeDescriptor(hThis,prop_name,descriptor_name)
        subFunctionsToMCode(hCode,hText,varargin)
        movePropertyBefore(hThis,propname,otherpropnames)
        toMCode(hCode,hText)
        toText(hCode,hVariableTable,hFunctionTable)
        
        % returns the parent of the object - for backward UDD
        % compatibility 
        function hPar = up(hThis)
            hPar = hThis.getParent();
        end
        
        % returns the first child of the object - for backward UDD
        % compatibility 
        function hChild = down(hThis)
            hChild = hThis.getFirstChild();
        end        
     end
    
    
    methods (Hidden)
        addConstructorArgin(hThis,hArgin)
        addConstructorArgout(hThis,hArgout)
        addPostConstructorFunction(hThis,varargin)
        addPostConstructorText(hThis,varargin)
        addPreConstructorFunction(hThis,varargin)
        addText(hThis,varargin)
        generateDefaultPropValueSyntax(hThis)
        generateDefaultPropValueSyntaxNoOutput(hThis)
        hFunc = getConstructor(hThis)
        setConstructorName(hThis,name)
    end
    
end

