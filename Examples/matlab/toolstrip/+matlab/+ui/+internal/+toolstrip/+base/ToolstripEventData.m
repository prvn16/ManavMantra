classdef (ConstructOnLoad) ToolstripEventData < event.EventData
    % Event data associated with ComponentChanged events.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent)
        % Describes what has changed (read-only, default = []).
        EventData
    end
    
    properties (Access = protected)
        % Version
        Version = 1.0;
    end
    
    properties (Access = private)
        % MATLAB object.
        EventData_
    end
    
    % ----------------------------------------------------------------------------
    methods
        function this = ToolstripEventData(data)
            % Creates an event data object describing the component change.
            if nargin == 1
                this.EventData = data;
            end
        end
        
        function value = get.EventData(this)
            % GET function for EventData property.
            value = this.EventData_;
        end
        
        function set.EventData(this, value)
            % SET function for EventData property.
            this.EventData_ = value;
        end
    end
end
