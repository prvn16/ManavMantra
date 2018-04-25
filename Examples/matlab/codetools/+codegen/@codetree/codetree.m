classdef codetree < matlab.mixin.SetGet & matlab.mixin.Copyable & codegen.Root
    % Copyright 2016 The MathWorks, Inc.
    %        
    properties        
        ParentRef
    end
    
    properties (Access=protected, Hidden)
        VariableTable
        CodeRoot
    end
    
    properties (Hidden)        
        String = '';
    end
    
    properties (SetAccess=protected)
        Name = '';
    end    
    
    events
        MomentoComplete
    end 

    
    methods  % constructor block
        function hThis = codetree(varargin)
            % Given an object, construct a code tree. Optionally notify the caller when
            % the momento object's creation is created.                        
            % Generate the momento object
            hMomento = codegen.momento(varargin{:});
            notify(hThis,'MomentoComplete');
            
            hThis.CodeRoot = codegen.codeblock(hMomento);
            hThis.VariableTable = codegen.variabletable;
            name = get(hThis.CodeRoot,'Name');
            if isempty(name)
                name = 'object';
            end
            name = strrep(name,'.','_');   % Avoid use of dots in function name
            function_name = sprintf('create%s',name);
            hThis.Name = function_name;
        end                             
        hFunc = findSubFunction(hCodeTree,funcName)
        toMCode(hCodeTree,hText,options,isFirst)
        toText(hCodeTree,hFunctionTable,outputTopNode)
    end 
    
end

