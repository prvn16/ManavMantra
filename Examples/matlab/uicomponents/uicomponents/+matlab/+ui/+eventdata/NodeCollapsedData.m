classdef NodeCollapsedData < matlab.ui.eventdata.internal.AbstractEventData
    % This class is for the event data of 'NodeCollapsedData' events
    
    
    properties(SetAccess = 'private')
        Node;
    end
    
    methods
        function obj = NodeCollapsedData(node)
            % The node, new and old value are required input.
            
            narginchk(1, 1);
                                    
            % Populate the properties
            obj.Node = node;                        
        end
    end
end

