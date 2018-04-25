classdef ValueChangingData < matlab.ui.eventdata.internal.AbstractEventData
    % This class is the event data class for 'ValueChanging' events
    
    properties(SetAccess = 'private')
        Value;
    end
    
    methods
        function obj = ValueChangingData(newValue)
            % The new value is a required input.
           
            narginchk(1,1);
            
            obj.Value = newValue;
            
        end
    end
end

