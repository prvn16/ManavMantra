classdef (ConstructOnLoad=true) ListBox < ...
        matlab.ui.control.internal.model.AbstractStateComponent & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent & ...
        matlab.ui.control.internal.model.mixin.BackgroundColorableComponent & ...
        matlab.ui.control.internal.model.mixin.PositionableComponent
    %
    
    % Do not remove above white space
    % Copyright 2014-2016 The MathWorks, Inc.
    
    properties(Dependent)
        % When set to 'on', the user can select multiple entries
        Multiselect@matlab.graphics.datatype.on_off = 'off';                
    end        
    
    properties(Access = 'private')
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateMultiselect@matlab.graphics.datatype.on_off = 'off';
    end
    
    properties(Access = {?matlab.ui.control.internal.controller.ListBoxController})
        
        % Stored index to scroll.  This value is used to store scroll index 
        % if user calls scroll method before view is ready. 
       InitialIndexToScroll = []; 
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = ListBox(varargin)
            %
            
            % Do not remove above white space
            % List states can be between [0, Inf]
            sizeConstraints = [0, Inf];
            obj = obj@matlab.ui.control.internal.model.AbstractStateComponent(sizeConstraints);

            defaultSize = [100, 74];
            obj.PrivateOuterPosition(3:4) = defaultSize;
            obj.PrivateInnerPosition(3:4) = defaultSize;
            
            % Initialize the selection strategy
            obj.updateSelectionStrategy();
            
            % ListBox has specific default values for properties
            obj.Items = {  getString(message('MATLAB:ui:defaults:item1State')), ...
                getString(message('MATLAB:ui:defaults:item2State')), ...
                getString(message('MATLAB:ui:defaults:item3State')), ...
                getString(message('MATLAB:ui:defaults:item4State')) };
            
            obj.Value =  obj.Items{1};
            
            obj.Type = 'uilistbox';
            
            parsePVPairs(obj,  varargin{:});
            
        end
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        
        function set.Multiselect(obj, newMultiselect)
            % Since this setting directly affects the Value,
            % and the current Value may violate this constraint, we update
            % the Value silently instead of the throwing an error message
            % which would have asked the user to change Value before updating this
            % property.
            % Eg:
            % Lets say, the Value were currently {'Item 1', 'Item 2'}
            % Now, the user sets Multiselect to false
            % The code below updates value to be the first item from cell
            % array above. So it will become a scalar like so: 'Item 1'
            
            % Error Checking done through the datatype specification
            
            % Property Setting
            obj.PrivateMultiselect = newMultiselect;
            
            % Update selection strategy
            obj.updateSelectionStrategy();
            
            % Update selected index based on this new Selection Strategy            
            obj.SelectionStrategy.calibrateSelectedIndexAfterSelectionStrategyChange();
            
            % marking dirty to update view
            obj.markPropertiesDirty({'Multiselect', 'SelectedIndex', 'Value'});
        end
        
        function value = get.Multiselect(obj)
            value = obj.PrivateMultiselect;
        end                
        
        function scroll(obj, scrollTarget)
            % SCROLL - Scroll listbox to target
            narginchk(2, 2);
            scrollTarget = convertStringsToChars(scrollTarget);
            
            % Scroll target will be matched with ItemsData first, then
            % Items.  Find will return the first value that matches.
            if strcmp(obj.Multiselect, 'off')
                targetIndex = obj.ValueStrategy.getIndexGivenValue(scrollTarget);
            else
                % ListBox in multiselect mode expects value to be a cell
                targetIndex = obj.ValueStrategy.getIndexGivenValue({scrollTarget});
            end
            
            % If ItemsData exists, ValueStrategy will not check Items.  
            % Check if scrollTarget is in Items
            if ~isempty(obj.ItemsData) && isempty(targetIndex)
                targetIndex = find(cellfun(@(items) isequal(scrollTarget, items), obj.Items), 1);
            end
            
            if isempty(targetIndex) && strcmpi(scrollTarget, 'top')
                    % Scroll to top
                    targetIndex = 1;
            elseif isempty(targetIndex) && strcmpi(scrollTarget, 'bottom')
                    % Scroll to bottom
                    targetIndex = numel(obj.Items);                  
            end

            % Do error checking and throw error if necessary
            if isempty(targetIndex) || targetIndex == -1 
                % throw error
                messageObj =  message('MATLAB:ui:components:invalidScrollTarget');
                
                % Use string from object
                messageText = getString(messageObj);

                error('MATLAB:ui:ListBox:invalidScrollTarget', messageText);
            end

            if isempty(obj.Controller)
                % If the view has not been created, store the targetIndex
                % for use when the view is created.
                obj.InitialIndexToScroll = targetIndex;
            else
                % Forward scroll to view
                obj.Controller.scroll(targetIndex);
            end
        end
    end
    
    methods(Access = private)
        
        % Update the Selection Strategy property
        function updateSelectionStrategy(obj)           
            if(strcmp(obj.PrivateMultiselect, 'on'))
                obj.SelectionStrategy = matlab.ui.control.internal.model.ZeroToManySelectionStrategy(obj);
            else
                obj.SelectionStrategy = matlab.ui.control.internal.model.ZeroToOneSelectionStrategy(obj);
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
            
            names = {...
                'Value',...
                'Items',...
                'ItemsData',...
                'Multiselect',...
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

