classdef (Hidden) AbstractMutualExclusiveComponent < ...
        matlab.ui.control.internal.model.ComponentModel & ...
        matlab.ui.container.ButtonGroupSelectable & ...
        matlab.ui.control.internal.model.mixin.PositionableComponent& ...
        matlab.ui.control.internal.model.mixin.EnableableComponent & ...
        matlab.ui.control.internal.model.mixin.VisibleComponent
    
    
    % This undocumented class may be removed in a future release.
    
    % This is a mixin parent class for all visual components which, when
    % parented to a button group, are mutually exclusive.
    %
    % Example: RadioButton, ToggleButton
    %
    % Those components have a 'Selected' property. Only one of the mutually
    % exclusive components can be selected at any point in time.
    %
    % Those components have a 'Value' property. It must be unique within
    % the mutual exclusive components of a button group
    
    % Copyright 2013-2015 The MathWorks, Inc.
    
    properties (Dependent)
        
        % Logical scalar indicating whether the component is selected
        Value = false;
    end
    
    properties (Hidden=true, ...
                Access = {...
                    ?matlab.ui.control.internal.controller.MutualExclusiveComponentController, ... % give access to subclasses
                })
        isInteractiveSelectionChanged = false;
    end
    
    properties (Access = {...
            ?matlab.ui.control.internal.model.AbstractMutualExclusiveComponent, ... % give access to subclasses
            ?appdesservices.internal.interfaces.controller.AbstractController})
       
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control for each property
        %
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        % New components are created unselected by default.
        % This is so that when we add multiple new components to a button
        % group, the first component of the group remains selected (adding
        % a selected component to a button group makes it the selected one)
        PrivateValue = false;
        
    end
    
    properties(	GetAccess = {...
            ?appdesservices.internal.interfaces.controller.AbstractController, ...
            ?appdesservices.internal.interfaces.controller.AbstractControllerMixin, ...
            ?matlab.ui.internal.WebButtonGroupController, ...
            }, ...
            SetAccess = 'private')
        % Giving access to ComponentController because the ComponentController
        % needs to get the value of ButtonId to push it to the view.
        % The view sets the id on the dijits.
        
        % Unique identifier of the button. This is used to establish a
        % communication with the view.
        % When a component is selected, the view indicates to the server
        % which one was selected through this id.
        ButtonId = 1;
    end
    
    events (NotifyAccess = 'private', ...
            ListenAccess = {?matlab.ui.container.ButtonGroup} ...
            )
        
        % The events below are essentially the PostSet event for the
        % Selected and Value properties.
        % If/when all properties become Observable, we should replace the use
        % of those events with PostSet
        
        % Event fired after Value is set.
        ValuePostSet;
        
    end
    
    methods
        
        function obj = AbstractMutualExclusiveComponent(varargin)
            % Call super()
            obj@matlab.ui.control.internal.model.ComponentModel(varargin{:});
            
        end
        
        % -----------------------------------------------------------------
        % Property Getters / Setters
        % -----------------------------------------------------------------
        
        function set.Value(obj, newValue)
            
            % Construct SelectionChanged event data with
            % isInteractiveSelectionChanged flag.
            eventdata = matlab.ui.eventdata.MutualExclusiveComponentSelectionChangeData(obj.isInteractiveSelectionChanged);
            % clear isInteractiveSelectionChanged flag
            obj.isInteractiveSelectionChanged = false;
            
            % Error Checking
            try
                newValue = matlab.ui.control.internal.model.PropertyHandling.validateLogicalScalar(newValue);
                
            catch %#ok<*CTCH>
                messageObj = message('MATLAB:ui:components:invalidBooleanProperty', ...
                    'Selected');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidValue';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            if(~isempty(obj.Parent) && ...
                    (isa(obj.Parent,'matlab.ui.container.ButtonGroup')))
                % The component is parented to a button group
                
                if(newValue == false && obj.Parent.getNumberOfMutualExclusiveChildren() == 1)
                    % The component is the only component in its parent's set
                    % of mutually exclusive objects, thus it cannot be set to
                    % false
                    messageObj = message('MATLAB:ui:components:noButtonSelected', ...
                        'Value', 'matlab.ui.control.RadioButton', 'matlab.ui.control.ToggleButton');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'noButtonSelected';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                end
            end
            
            if(isequal(obj.PrivateValue, newValue))
                % The selection did not change, return
                % The logic in the Button Group assumes that when the
                % ValuePostSet event is emitted, the selection has indeed
                % changed.
                return
            end
            
            % set the property
            obj.doSetValue(newValue);
            
            % notify
            notify(obj, 'ValuePostSet', eventdata);
            

        end
        
        function value = get.Value(obj)
            value = obj.PrivateValue;
        end
        
        
    end
    
    methods(Access = {?matlab.ui.control.ButtonGroup})
        
        function doSetValue(obj, newValue)
            % Set the private Value property and mark it dirty
            %
            % Provide access to this method to ButtonGroup for the case
            % where the value of the ButtonGroup is changed.
            % When the ButtonGroup Value is changed, the Button Group takes
            % care of setting the Selected property of the previously
            % selected button and the newly selected one. Those sets should
            % not go back to the Button Group, so providing this method to
            % the Button Group.
            
            % Property Setting
            obj.PrivateValue = newValue;
            
            % Update View
            markPropertiesDirty(obj, {'Value'});
        end
    end
    
    methods(Access = 'protected')
        
        function validateParentAndState(obj, newParent)
            % Override the default validator for 'Parent'
            %
            % Mutual Exclusive components can only be parented to a Button Group.
            
            if(isempty(newParent))
                return
            end
            
            % Validate that the Parent is a button group
            try
                validateattributes(newParent, ...
                    {'matlab.ui.container.ButtonGroup'}, ...
                    {});
            catch ex
                messageObj = message('MATLAB:ui:components:invalidClass', ...
                    'Parent', 'ButtonGroup');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidClassForParent';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Verify that the button group does not already contain another
            % type of mutual exclusive components
            % e.g. a radio button cannot be added to a button group that
            % already contains toggle buttons
            
            
            
            % Leverage unique id generation in GBT's ButtonGroup.
            % Mutual exclusivity will be handled at the time of actual parenting.
            % During the parenting, if it is discovered that the button group has
            % another type of mutual exclusive component an error will be encountered.
            obj.ButtonId = newParent.generateUniqueId();
            markPropertiesDirty(obj, {'ButtonId'});
        end
    end
end

