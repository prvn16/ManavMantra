classdef DataDescriptorBehavior < matlab.graphics.internal.HGBehavior
% This is an undocumented class may be removed in a future release.

% Copyright 2013 The MathWorks, Inc.

properties 
    Enable = true;
    Serialize = false;
end

properties (Constant)
    %NAME Property is of type 'string' (read only)
    Name = 'DataDescriptor';
end


methods 
    function [ret] = dosupport(~,hTarget)
        % axes or axes child
        ret = ~isempty(ancestor(hTarget,'matlab.graphics.axis.AbstractAxes','node'));
    end
    
end  

end  % classdef

