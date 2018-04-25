classdef NumericTypable < handle
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods (Sealed)
        
        function uitype(actor, number)
            
            narginchk(2, 2);
            
            H = actor.Component;
            if any({H.Editable, H.Enable} == "off")
                error( message('MATLAB:uiautomation:Driver:MustBeEditableAndEnabled') );
            end
            
            validateattributes(number, {'numeric'}, {'scalar', 'real'});
            
            text = num2str(number);
            actor.Dispatcher.dispatchEventAndWait(H, 'uitype', 'Text', text);
        end
        
    end
    
end