classdef SelectedNodesChangedData < matlab.ui.eventdata.internal.AbstractEventData
    % This class is for the event data of 'SelectionChanged' events
    
    
    properties(SetAccess = 'private')
        SelectedNodes;
        
        PreviousSelectedNodes;
    end
    
    methods
        function obj = SelectedNodesChangedData(newValue, oldValue)
            % The new and old value are required input.
            
            narginchk(2, 2);
                                    
            % Populate the properties
            obj.SelectedNodes = newValue;
            obj.PreviousSelectedNodes = oldValue;
                        
        end
    end
end

