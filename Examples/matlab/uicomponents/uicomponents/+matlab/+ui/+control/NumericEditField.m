classdef (ConstructOnLoad=true) NumericEditField < ...
        matlab.ui.control.internal.model.AbstractNumericComponent 
    %

    % Do not remove above white space
    % Copyright 2014-2016 The MathWorks, Inc.
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = NumericEditField(varargin)
            %
            
            % Do not remove above white space
            % Defaults
            defaultSize = [100, 22];
            obj.PrivateInnerPosition(3:4) = defaultSize;
            obj.PrivateOuterPosition(3:4) = defaultSize;
            obj.Type = 'uinumericeditfield';
            
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
            
            names = {'Value',...
                'ValueDisplayFormat',...
                'RoundFractionalValues',...
                'Limits',...
                'LowerLimitInclusive',...
                'UpperLimitInclusive',...
                ...Callbacks
                'ValueChangedFcn'};
                
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            str = num2str(obj.Value);
        
        end
    end
        
end
