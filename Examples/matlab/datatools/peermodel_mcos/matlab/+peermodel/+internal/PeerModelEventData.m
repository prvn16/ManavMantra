classdef (ConstructOnLoad) PeerModelEventData < event.EventData
    % Event data associated with ComponentChanged events.
    
    % Author(s): Rong Chen
    % Copyright 2009-2011 The MathWorks, Inc.
    % $Revision: 1.1.4.1 $ $Date: 2014/03/26 02:40:39 $
    
    % ----------------------------------------------------------------------------
    properties (Dependent, GetAccess = public, SetAccess = private)
        % Describes what has changed (read-only, default = []).
        EventData
    end
    
    properties (Access = private)
        % MATLAB object.
        EventData_
    end
    
    % ----------------------------------------------------------------------------
    methods
        function this = PeerModelEventData(data)
            % Creates an event data object describing the peer node change.
            %
            % Example:
            %
            % data = struct('Name', 'Ident', 'Type', 'CLOSED');
            % obj = toolpack.PeerNodeEventData(data)
            
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
