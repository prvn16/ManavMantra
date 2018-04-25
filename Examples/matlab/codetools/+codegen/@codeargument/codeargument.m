classdef codeargument < matlab.mixin.SetGet & matlab.mixin.Copyable
    % Copyright 2016 The MathWorks, Inc.
    
    properties
        ArgumentType@codegen.ArgumentType             = codegen.ArgumentType.None
        DataTypeDescriptor@codegen.DataTypeDescriptor = codegen.DataTypeDescriptor.Auto
        Comment
        IsParameter      = false;
        Ignore           = false;
        IsOutputArgument = false;
        Name
        Value
    end
    
    properties (Hidden)
        AllowRemovalList
        ActiveVariable
        String
        VariableTable
        FunctionList = {};
    end
    
    methods  % constructor block
        function [hThis] = codeargument(varargin)
            % By default, the active variable is itself:
            hThis.ActiveVariable = hThis;
            if nargin>0
                for n = 1:2:length(varargin)
                    set(hThis,varargin{n},varargin{n+1});
                end
            end
            
        end
        res = canRemove(hArg,hFunc)
        str = getCommentString(hArg)
        ret = isFunctionInput(hArg)
        bool = isequal(hArg1,hArg2)
        setRemovalPermissions(hArg,status,hFunc)
        err = toText(hArg,hVariableTable)
    end
    
end

