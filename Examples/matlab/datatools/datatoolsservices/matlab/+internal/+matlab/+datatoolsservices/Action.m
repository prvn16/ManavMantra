
classdef Action < handle & dynamicprops
    %ACTION class 
    
    %This class defines an Action that the user can perform along with 
    % it's properties. Any changes to properties of the action will 
    % dispatch events notifying that the values have changed. 
    
    % Copyright 2017 The MathWorks, Inc.
    
    events
        ActionStateChanged;  % Fired when 'Enabled' state changes
        CallbackChanged; % Fired if 'Callback' changes
        PropertyValueChanged; % Fired if any other property is set
    end
    
    properties (Access=protected, Hidden)
        ID_I;
        Enabled_I logical = true;
        Callback_I;
    end
    
    properties (Dependent)
        ID;
        Enabled;
        Callback;
    end
    
    methods
        % Constructor class expecting Action properties as a struct. 
        % ID, Enabled and Callback are special properties of the Action and
        % are handled separately. 
        function this = Action(props)
            if (nargin>0) && isstruct(props)                
                % If no ID was provided, generate a default Action ID.
                if ~(isfield(props,'ID'))
                    props.ID = internal.matlab.datatoolsservices.Action.generateDefaultActionId();
                end
                propNames = fieldnames(props);
                for i=1:length(propNames)                
                    propName = propNames{i};
                    propVal = props.(propName);
                    switch propName
                        case 'ID'
                            this.ID_I = propVal;
                        case 'Enabled'
                            this.Enabled_I = propVal;
                        case 'Callback'
                            this.Callback_I = propVal;
                        otherwise
                            this.setProperty(propName, propVal, false);
                    end                   
                end               
            else
                error(message('MATLAB:codetools:datatoolsservices:PropertiesAsStruct'));
            end
        end       
        
        function set.Enabled(this, newValue)
            this.Enabled_I = newValue;
            this.notify('ActionStateChanged');
        end
        
        function value = get.Enabled(this)
            value = this.Enabled_I;
        end
        
        function set.Callback(this, newValue)
            this.Callback_I = newValue;
            this.notify('CallbackChanged');
        end
        
        function value = get.Callback(this)
            value = this.Callback_I;
        end
        
        function set.ID(this, newValue)
            this.ID_I = newValue;
        end

        function value = get.ID(this)
            value = this.ID_I;
        end
        
        % If a property does not exist, create a new class property and add
        % setters/getters to it, Else modify the existing property.
        function setProperty(this, name, newValue, doNotify)            
            if ~isprop(this, name)
                internalProp = addprop(this, [name '_I']);
                internalProp.Hidden = true;

                p = addprop(this, name);
                p.Dependent = true;

                p.SetMethod = @(this, newValue)internalSetProperty(this, name, newValue);
                p.GetMethod = @(this)internalGetProperty(this, name);
            end
            this.internalSetProperty(name, newValue, doNotify);
        end         
     
        function value = getProperty(this, name)
            value = this.(name);
        end       
    end
    
    % Internal methods used to get and set properties.
    methods (Access='protected')
        function value = internalGetProperty(this, name)
            value = this.([name '_I']);
        end
        
        function internalSetProperty(this, name, newValue, doNotify)
            if nargin<4 || isempty(doNotify)
                doNotify = true;
            end
            
            aed = internal.matlab.datatoolsservices.ActionEventData;
            aed.Action = this;
            aed.Property = name;
            aed.OldValue = this.(name);
            aed.NewValue = newValue; 
            aed.src = 'server';
            
            this.([name '_I']) = newValue;
            if (doNotify)
                this.notify('PropertyValueChanged', aed);
            end
        end
    end
    
    % Generates a default Action ID.
    % For E.g. this function returns 'action0', 'action1'... etc
     methods(Static)
        function id = generateDefaultActionId()
           mlock; % Keep persistent variables until MATLAB exits
           persistent ID ;
             if isempty(ID)
                ID = 0;
             end
           id = ['action' num2str(ID)];
           ID = ID +1;
        end        
    end
end

