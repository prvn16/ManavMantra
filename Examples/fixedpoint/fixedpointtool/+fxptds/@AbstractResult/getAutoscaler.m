function entityAutoscaler = getAutoscaler(this)
    % GETAUTOSCALER returns the appropriate autoscaler for the result
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    
    entityAutoscaler = [];
    if ~isempty(this.UniqueIdentifier)
        
        if isempty(this.EntityAutoscaler)
            % get the interface for the Entity Autoscalers
            eaInterface = SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();
            
            % query the Entity Autoscaler associated with the result
            this.EntityAutoscaler = eaInterface.getAutoscaler(this.UniqueIdentifier.getObject);
        end
        
        entityAutoscaler = this.EntityAutoscaler;
    end
end