classdef FPTTreeUpdateEventData < event.EventData
    % FPTTreeUpdateEventData Relays the information to the subscribers
    
    % Copyright 2013 MathWorks, Inc
    
    properties (SetAccess = private)
        Data
        BlockName
    end
    
    methods
        function this =  FPTTreeUpdateEventData(functionID, blockName)
            if ~isa(functionID, 'fxptds.MATLABFunctionIdentifier')
                DAStudio.error(...
                    'FixedPointTool:fixedPointTool:incorrectObjectClass',...
                    'fxptds.MATLABFunctionIdentifier',...
                    class(functionID));
            end
            this.Data = functionID;
            this.BlockName = blockName;          
        end
    end
end
