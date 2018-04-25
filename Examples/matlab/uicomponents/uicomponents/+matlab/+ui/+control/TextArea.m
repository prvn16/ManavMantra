classdef (ConstructOnLoad=true) TextArea < ...
        matlab.ui.control.internal.model.ComponentModel & ...        
        matlab.ui.control.internal.model.mixin.EditableComponent & ...
        matlab.ui.control.internal.model.mixin.HorizontallyAlignableComponent & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent & ...
        matlab.ui.control.internal.model.mixin.BackgroundColorableComponent & ...
        matlab.ui.control.internal.model.mixin.PositionableComponent& ...
        matlab.ui.control.internal.model.mixin.EnableableComponent & ...
        matlab.ui.control.internal.model.mixin.VisibleComponent
    %
    
    % Do not remove above white space
    % Copyright 2013-2016 The MathWorks, Inc.

    properties(Dependent)
        Value = {''};
    end
    
    properties(NonCopyable, Dependent)
        ValueChangedFcn@matlab.graphics.datatype.Callback = [];
    end
    
    properties(Access = {?appdesservices.internal.interfaces.controller.AbstractController})
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateValue = {''};
    end 
    
    properties(NonCopyable, Access = 'private')
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateValueChangedFcn@matlab.graphics.datatype.Callback = [];
    end
    
    events(NotifyAccess = {?matlab.ui.control.internal.controller.ComponentController})
        ValueChanged
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = TextArea(varargin)
            %
            
            % Do not remove above white space
            % Defaults
            defaultSize = [150, 60];
            obj.PrivateInnerPosition(3:4) = defaultSize;
            obj.PrivateOuterPosition(3:4) = defaultSize;
            obj.Type = 'uitextarea';
            
            parsePVPairs(obj,  varargin{:});
            
            % Wire callbacks
            obj.attachCallbackToEvent('ValueChanged', 'PrivateValueChangedFcn');
        end
        
        % ----------------------------------------------------------------------
        
        function set.Value(obj, newValue)
            % Error Checking for data type
            try
                newValue = matlab.ui.control.internal.model.PropertyHandling.validateMultilineText(newValue);
            catch %#ok<CTCH>
                messageObj = message('MATLAB:ui:components:invalidMultilineTextValue', ...
                    'Value');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidMultilineTextValue';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting PrivateValue setter does conversions
            obj.PrivateValue = newValue;
            
            % Update View
            markPropertiesDirty(obj, {'Value'});
        end
        
        function value = get.Value(obj)
            value = obj.PrivateValue;
        end
        
        function set.PrivateValue(obj, newValue)          
            
            % Treat single chars as a cell
            if(~iscell(newValue))
                newValue = {newValue};
            end
            
            % convert all formatted \n's to new elements in the cell array
            % (Note: this will also turn all 1xN cell arrays into Nx1's)
            cellToStore = {};
            %asciiNewLine = char(10);
            
            % if text has been set to '' i.e. newValue will be a cell with one empty char
            % {''}  which is what we want
            cellToStore = newValue;               
            % Do the conversion only if otherwise. else it results in a 0x1
            % cell array
            if(~isempty(newValue{1}))
                cellToStore = obj.convertFormattedStrToCell(newValue);
            end
                         
            % at this point, it is a valid cell array
            % transpose to Nx1
            cellToStore = cellToStore(:);
            
            % Property Setting
            obj.PrivateValue = cellToStore;
            
        end
        % ----------------------------------------------------------------------
        
        function set.ValueChangedFcn(obj, newValue)
            % Property Setting
            obj.PrivateValueChangedFcn = newValue;
            
            obj.markPropertiesDirty({'ValueChangedFcn'});
        end
        
        function value = get.ValueChangedFcn(obj)
            value = obj.PrivateValueChangedFcn;
        end
    end
    
    
    % ---------------------------------------------------------------------
    % Custom Display Functions
    % ---------------------------------------------------------------------
    methods(Access = protected)
        
        function names = getPropertyGroupNames(obj)
            % GETPROPERTYGROUPNAMES - This function returns common
            % properties for this class that will be displayed in the
            % curated list properties for all components implenenting this
            % class.
            
            names = {'Value',...
                ...Callbacks
                'ValueChangedFcn'};
            
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            str = obj.Value;
            
        end
    end
    
    %Helper method to convert a formatted string to a cell array
    methods(Access = 'private')
        function cellToStore = convertFormattedStrToCell(varargin)
            
            %the 2nd param is the one we are interested in, the 1st one is obj
            newValue = varargin{2};
            
            cellToStore = {};
            asciiNewLine = char(10);
            for idx = 1:length(newValue)
                
                thisElement = newValue{idx};
                
                if(~isempty(thisElement))
                    % For a formatted string like 'a\nb\nc', this will return:
                    % {'a' ; 'b'; 'c'}
                    tempCell = textscan(thisElement, '%s', ...
                        'delimiter', asciiNewLine, ...
                        'whitespace','' ...  % preserve the white spaces
                        );
                    brokenUpString = tempCell{1};
                    
                else
                    % If the text is '', don't do the conversion, otherwise
                    % it results in a 0x1 cell array and the '' is lost.
                    % We need to wrap the empty string in a cell otherwise it
                    % gets lost in the concatenation that follows
                    brokenUpString = {thisElement};
                end
                
                % add to the bottom of the incremental cell we are building
                % up
                cellToStore = [cellToStore; brokenUpString];
            end
        end
        
    end
end
