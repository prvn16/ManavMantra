classdef (ConstructOnLoad=true) DropDown < ...
        matlab.ui.control.internal.model.AbstractStateComponent & ...                
        matlab.ui.control.internal.model.mixin.FontStyledComponent & ...
        matlab.ui.control.internal.model.mixin.BackgroundColorableComponent & ...
        matlab.ui.control.internal.model.mixin.PositionableComponent         
    %
    
    % Do not remove above white space
    % Copyright 2013-2016 The MathWorks, Inc.
    
    properties(Dependent)
        % When true, the user can type in a string in addition to selecting
        % an item from the list. 
        % This property allows switching between the regular drop down and
        % the combo box.
        Editable@matlab.graphics.datatype.on_off = 'off';                  
    end        
    
    properties(Access = 'private')
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateEditable@matlab.graphics.datatype.on_off = 'off';                        
    end
    
    
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = DropDown(varargin)                       
            %
            
            % Do not remove above white space
            % Drop Down states can be between [0, Inf]
            sizeConstraints = [0, Inf];
            
            obj = obj@matlab.ui.control.internal.model.AbstractStateComponent(...
                sizeConstraints);
            
            defaultSize = [100, 22];
            obj.PrivateOuterPosition(3:4) = defaultSize;
            obj.PrivateInnerPosition(3:4) = defaultSize;
            
            if strcmp(obj.Editable, 'off')
                % Set default BackgroundColor
                obj.BackgroundColor = obj.DefaultGray;
            end
            
            % Initialize the selection strategy
            obj.updateSelectionStrategy();
            
            % ComboBox has specific default values for properties
            obj.Items = {  getString(message('MATLAB:ui:defaults:option1State')), ... 
                            getString(message('MATLAB:ui:defaults:option2State')), ... 
                            getString(message('MATLAB:ui:defaults:option3State')), ... 
                            getString(message('MATLAB:ui:defaults:option4State')) }; 
            
            obj.Value = getString(message('MATLAB:ui:defaults:option1State'));

            obj.Type = 'uidropdown';
            
            parsePVPairs(obj,  varargin{:});
            
        end
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        
        function set.Editable(obj, newValue)
            
            % Error Checking done through the datatype specification
            
            % If the user has not updated the color, change the color to
            % the factory default when togglign the Editable property
            if strcmp(newValue, 'on') && strcmp(obj.PrivateEditable, 'off')...
                    && isequal(obj.BackgroundColor, obj.DefaultGray)
                obj.BackgroundColor = obj.DefaultWhite;
            elseif strcmp(newValue, 'off') && strcmp(obj.PrivateEditable, 'on')...
                    && isequal(obj.BackgroundColor, obj.DefaultWhite)
                obj.BackgroundColor = obj.DefaultGray;
            end
            
            % Property Setting
            obj.PrivateEditable = newValue;
            
            % Update selection strategy
            obj.updateSelectionStrategy();
            
            % Update selected index based on this new Selection Strategy            
            obj.SelectionStrategy.calibrateSelectedIndexAfterSelectionStrategyChange();            
            
            % marking dirty to update view
            obj.markPropertiesDirty({'Editable', 'SelectedIndex'});
        end
        
        function value = get.Editable(obj)
            value = obj.PrivateEditable;
        end
    end
    
    methods(Access = private)
        
        % Update the Selection Strategy property
        function updateSelectionStrategy(obj)
            if(strcmp(obj.PrivateEditable, 'on'))
                obj.SelectionStrategy = matlab.ui.control.internal.model.EditableSelectionStrategy(obj);
            else
                obj.SelectionStrategy = matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj);
            end
        end
    end
    
    % ---------------------------------------------------------------------
    % Custom Display Functions
    % ---------------------------------------------------------------------
    methods(Access = protected)
        
        function names = getPropertyGroupNames(obj)
            % GETPROPERTYGROUPNAMES - This function returns common
            % properties for this class that will be displayed in the
            % curated list properties for all components implementing this
            % class.
            
            names = {
                'Value',...
                'Items',...
                'ItemsData',...
                'Editable',...
                ...Callbacks
                'ValueChangedFcn'};
                
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.

            % Return the text of the selected item
            % Note that this is the same as Value when ItemsData is empty
            index = obj.SelectedIndex;
            str = obj.SelectionStrategy.getSelectedTextGivenIndex(index); 

        end
    end
end
