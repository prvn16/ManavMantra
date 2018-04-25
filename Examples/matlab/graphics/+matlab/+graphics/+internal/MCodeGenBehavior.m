classdef MCodeGenBehavior < matlab.graphics.internal.HGBehavior
% This is an undocumented class and may be removed in a future release.

% Copyright 2013 MathWorks, Inc.


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
    Name = 'MCodeGeneration';
end

properties 
    %MCODECONSTRUCTORFCN Property is of type 'MATLAB callback' 
    MCodeConstructorFcn = [];
    %MCODEIGNOREHANDLEFCN Property is of type 'MATLAB callback' 
    MCodeIgnoreHandleFcn = [];
end

methods 
    function [ret] = dosupport(~,hTarget)
        % axes or axes children
        ret = ~isempty([ancestor(hTarget,'axes') ancestor(hTarget,'polaraxes')]);
    end  
end  

end  % classdef

