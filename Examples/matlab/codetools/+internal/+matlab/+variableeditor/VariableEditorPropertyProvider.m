classdef VariableEditorPropertyProvider 
%VARIABLEEDITORPROPERTYPROVIDER Support class for Variable Editor

% Copyright 2012 The MathWorks, Inc.

% Abstract mixin to enable MCOS objects to customize the display of
% properties in the Variable Editor. The main use of this class is to
% enable properties to be represented in the MCOS object Variable Editor
% without having to get the property value. This enables objects with
% dependent properties, to generate a display without calling the get
% function, which may be slow or require a large amount of memory.

    methods (Hidden = true)
        % Returns true if the other methods of
        % VariableEditorPropertyProvider should be used to derive the
        % property display in the Variable Editor
        function isVirtual = isVariableEditorVirtualProp(this,propName) %#ok<INUSD>
            isVirtual = false;
        end
        
        %  Returns true if the Variable Editor should indicate that the
        % contents of the specified property is complex
        function isComplex = isVariableEditorComplexProp(this,propName)
            isComplex = isreal(this.(propName));
        end
        
        % Returns true if the Variable Editor should indicate that the
        % contents of the specified property is sparse       
        function isSparse = isVariableEditorSparseProp(this,propName)
            isSparse = issparse(this.(propName));
        end
        
        % Returns the class name that the Variable Editor should use to
        % derive the property display         
        function className = getVariableEditorClassProp(this,propName)
            className = class(this.(propName));
        end
        
        
        % Returns the size vector that the Variable Editor should use to
        % derive the property display       
        function sizeArray = getVariableEditorSize(this,propName)
            sizeArray = size(this.(propName)); 
        end
    end
    
end