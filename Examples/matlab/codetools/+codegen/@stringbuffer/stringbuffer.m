classdef stringbuffer < matlab.mixin.SetGet & matlab.mixin.Copyable
% Copyright 2016 The MathWorks, Inc.
            
    properties
        Text
    end
    methods  
        add(hText,str)
        addln(hText,str)
        lineLength = getLineLength(hStringBuffer)
    end  
end 

