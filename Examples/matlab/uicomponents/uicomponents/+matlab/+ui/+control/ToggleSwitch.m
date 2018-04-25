classdef (ConstructOnLoad=true) ToggleSwitch < ...
        matlab.ui.control.internal.model.AbstractSwitchComponent   
    %
    
    % Do not remove above white space
    % Copyright 2011-2016 The MathWorks, Inc.
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = ToggleSwitch(varargin)

            obj = obj@matlab.ui.control.internal.model.AbstractSwitchComponent(...
                'vertical');

            % Initialize Layout Properties
            locationOffset = [0, 21];
            obj.PrivateOuterPosition(1:2) = obj.PrivateInnerPosition(1:2) - locationOffset;
            obj.PrivateInnerPosition(3:4) = [20 45];
            obj.PrivateOuterPosition(3:4) = [20 87];
            obj.AspectRatioLimits = [20/45 20/45];
            
            obj.Type = 'uitoggleswitch';
            
            parsePVPairs(obj,  varargin{:});

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
                'ItemsData', ...
                'Orientation',...
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

