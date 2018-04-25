classdef PeerActionWrapper < handle
    %PEERACTION class has an Action class instance.
    
    % This class takes care of synchronizing actions with it's peernode such
    % that the client and server remain in sync. This class responds to
    % changes made to properties of the Actions and updates it's corresponding peernode properties. 
    % It also listens for changes on the peernode and updates the
    % corresponding action's properties.
    
    % Copyright 2017 The MathWorks, Inc.

    
    properties (Access = 'private')
        PeerNode
        DefaultEventType = 'PeerEvent'
    end
    
    properties (SetAccess='private')
        Action internal.matlab.datatoolsservices.Action
    end    
    
    %Listener Properties
    properties (SetObservable=false, Access='private', Dependent=false, Hidden=false)
        PropertySetListener; % Listens to propertySet changes in Actions.
        ActionStateChangedListener; % Listents to Enabled state change in Actions.
        CallbackChangedListener; % Listens to Callback change in Actions.
        PropertyValueChangedListener; % Listens to changes in property values on the PeerNode.
        PeerNodeListener % Listens to events on the PeerNode.
    end 
    
    
    methods

        % Creates a PeerAction from properties provided as struct. A
        % peernode of type 'Action' is created and added on parentNode.        
        function this = PeerActionWrapper(action, parentNode) 
            if ~isa(action, 'internal.matlab.datatoolsservices.Action')
                error(message('MATLAB:codetools:datatoolsservices:InvalidAction'))
            end
            this.Action = action;
            peerNodeProps = struct;
            fns = properties(this.Action);
            for i=1:length(fns)
                key = fns{i};
                if strcmpi(key, 'ID')
                    peerNodeProps.id = this.Action.(key);
                elseif strcmpi(key, 'Enabled')
                    peerNodeProps.enabled = this.Action.(key);
                elseif strcmpi(key, 'Callback')
                    % Do not add 'Callback' as a peernode property.
                else
                    peerNodeProps.(key) = this.Action.(key);
                end
            end
            this.PeerNode = parentNode.addChild('Action',peerNodeProps);           
            
            this.PropertySetListener = event.listener(this.PeerNode,'PropertySet',@this.handlePropertySet);
            this.PeerNodeListener = event.listener(this.PeerNode, this.DefaultEventType, @this.executeCallBack);
            this.ActionStateChangedListener = event.listener(this.Action, 'ActionStateChanged', @(es, ed)this.setPeerProperty('Enabled',this.Action.Enabled));
            this.CallbackChangedListener = event.listener(this.Action, 'CallbackChanged', @(es, ed)this.addActionCallBack(this.Action.Callback));
            this.PropertyValueChangedListener = event.listener(this.Action, 'PropertyValueChanged', @(es, ed)this.setPeerProperty(ed.Property, ed.NewValue));
        end       
        
        
        function addActionCallBack(this, callBack)
            this.Action.Callback = callBack;
        end
        
        function executeCallBack(this, es, ed)
            if ~isempty(this.Action.Callback) && isa(this.Action.Callback, 'function_handle')
                this.Action.Callback();
            end
        end        
        
        % Iterate through name-value pairs provided as Action properties
        % and set them on the Action.
        function this = updateActionProperty(this, args)
            props = args;
            % For name value args
            for index = 1:2:length(props)
                propName = props{index};
                propVal = props{index+1};
                if (strcmpi(propName, 'ID'))
                   error(message('MATLAB:codetools:datatoolsservices:ActionIDUpdate'));                     
                end
                this.setActionProperty(propName, propVal, true);
            end            
        end        
        
        function delete(this)
            delete(this.PeerNodeListener);
            delete(this.PeerNode);            
        end      
        
        function setActionProperty(this, name, newValue, doNotify)
            this.Action.setProperty(name, newValue, doNotify);
        end        
    end
    
    methods (Access='protected')
        % Sets Action's property values on the PeerNode.
        function setPeerProperty(this, name, newValue)
            if strcmpi(name, 'ID')
                name = 'id';
            end
            if strcmpi(name, 'Callback')
                this.addActionCallBack(newValue);
                return;
            end
            if strcmpi(name, 'Enabled')
                name = 'enabled';
            end
            this.PeerNode.setProperty(name ,newValue); 
        end
        
        % Sets PeerNode's property values on the Action.
        function handlePropertySet(this, ~, ed)            
            name = ed.EventData.key;                        
            newValue = ed.EventData.newValue;
            if ~isempty(name) && ~isempty(newValue)                
                if strcmpi(name, 'id')
                    name = 'ID';
                elseif strcmpi(name, 'callback')
                    name = 'Callback';
                elseif strcmpi(name, 'enabled')
                    name = 'Enabled';
                end
                % This could be getting logicals, function handles or chars
                if isprop(this, name) && (isequal(newValue , this.(name)))
                    return;
                end
                this.updateActionProperty({name, newValue});
            end
        end
    end
end

