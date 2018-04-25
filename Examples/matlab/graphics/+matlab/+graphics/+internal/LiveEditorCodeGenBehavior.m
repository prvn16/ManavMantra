classdef LiveEditorCodeGenBehavior < matlab.graphics.internal.HGBehavior
% This is an undocumented class and may be removed in a future release.

% Copyright 2016 MathWorks, Inc.


properties 
    %ENABLE Property is of type 'bool' 
    Enable = true;
end


properties (Transient, AbortSet)
    %SERIALIZE Property is of type 'MATLAB array' 
    Serialize = true;
end

properties (Constant)
    %NAME Property is of type 'string' (readonly)
    Name = 'LiveEditorCodeGeneration';
end

properties 
    %InteractionCodeFcn Property is of type 'MATLAB callback' 
    InteractionCodeFcn = [];
    IgnoreCodeGeneration = false;
end

methods 
    function [ret] = dosupport(~,hTarget)
        ret = ishghandle(hTarget);
    end  
end  

end  % classdef

