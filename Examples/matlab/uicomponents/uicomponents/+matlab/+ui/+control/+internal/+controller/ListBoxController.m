classdef (Hidden) ListBoxController < ...
        matlab.ui.control.internal.controller.StateComponentController
    
    % ListBoxController - This is the controller for the object:
    % matlab.ui.control.ListBox.
    % Copyright 2014 The MathWorks, Inc.
    
    methods
        function obj = ListBoxController(varargin)

            obj@matlab.ui.control.internal.controller.StateComponentController(varargin{:});
            
            % Scroll can be called on the model before the controller is
            % created.  In this case, scroll to the stored value.
            if ~isempty(obj.Model.InitialIndexToScroll)
                obj.scroll(obj.Model.InitialIndexToScroll);
                
                % Reset index to default
                obj.Model.InitialIndexToScroll = [];
            end
        end
        
    end
    
    methods
        
        function scroll(obj, index)
            % SCROLL - Send message to view to scroll listbox.  This does
            % not affect the selected component.
                    obj.ProxyView.sendEventToClient(...
                        'scroll',...
                        { ...
                    'Index', index;
                    } ...
                    );
        end
    end
    
    methods(Access = 'protected')
        
        function handleEvent(obj, src, event)
            
            
            % Handle changes in the property editor that needs a
            % server side validation
            if(strcmp(event.Data.Name, 'PropertyEditorEdited'))
                
                propertyName = event.Data.PropertyName;
                propertyValue = event.Data.PropertyValue;
                
                if(strcmp(propertyName, 'Value'))
                    if(isempty(propertyValue))
                        % convert empty values to {} to indicate no
                        % selection
                        propertyValue = {};
                    end
                    if(strcmp(obj.Model.Multiselect, 'off') && ...
                            iscell(propertyValue) && ...
                            length(propertyValue) == 1)
                        % Convert something like {'One'} to 'One'
                        %
                        % The value from the view comes as an array
                        % regardless of multi selection state
                        propertyValue = propertyValue{1};
                    end
                    
                    setModelProperty(obj, propertyName, propertyValue, event);
                    return;                
                end                                
            end
            
            % Allow super classes to handle their events
            handleEvent@matlab.ui.control.internal.controller.StateComponentController(obj, src, event);
            
        end
        
    end
end

