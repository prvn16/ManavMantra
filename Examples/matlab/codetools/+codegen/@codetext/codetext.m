classdef codetext < matlab.mixin.SetGet & matlab.mixin.Copyable & codegen.Root
    % Copyright 2016 The MathWorks, Inc.
    
    properties
        Text
        Ignore
    end
    
    methods
        function hThis = codetext(varargin)
            %codetext  Construct a new codegen.codetext instance
            %
            %   codegen.codetext creates a new instance of a codegen.codetext object
            %   with an empty Text property.
            %
            %   codegen.codetext(...) adds all input arguments as a cell array to the
            %   Text property.
            %
            %   codegen.codetext supports sequences of strings, message objects, and
            %   codegen.codeargument objects.  message objects will be converted to
            %   strings as the code is generated.
            
            if nargin
                set(hThis, 'Text', varargin);
            end
        end                    
        [hRequire,hProvide] = getVariableUsage(hTextLine)
        toMCode(hCodeLine,hText)
        toText(hTextLine,hVariableTable)
    end      
end 

