classdef codefunction < matlab.mixin.SetGet & matlab.mixin.Copyable & codegen.Root
    % Copyright 2016 The MathWorks, Inc.
        
    properties
        Name
        Argout
        Argin
        CodeRef
        Comment
        SubFunction
        NeedPragma = false;
    end
    
    methods
        function hThis = codefunction(varargin)
            if nargin>0
                for n = 1:2:length(varargin)
                    set(hThis,varargin{n},varargin{n+1});
                end
            end
            
        end
        
        function set.Name(obj,value)
            obj.Name = exclusiveSet(obj,value,'Name','SubFunction');
        end
        
        function set.SubFunction(obj,value)
            obj.SubFunction = exclusiveSet(obj,value,'SubFunction','Name');
        end
        hNewFuncs = generatePropValueList(hFunc,hPropList,CommentName,hObjectArg)
        [hRequire,hProvide] = getVariableUsage(hFunc)
        toMCode(hFunc,hText)
        toText(hFunc,hVariableTable)
    end
    
    
    methods (Hidden)
        addArgin(hThis,varargin)
        addArgout(hThis,varargin)
    end
    
    methods (Static)
        hAllFuncs = createSetCall(hObjectArg,hPropList,CommentName)
    end
    
end

function newValue = exclusiveSet(hThis,valueProposed,propName,conflictName)
if ~isempty(hThis.(conflictName))
    error(message('MATLAB:codetools:codegen:IncorrectProperty', ...
        propName, conflictName));
end
newValue = valueProposed;
end
