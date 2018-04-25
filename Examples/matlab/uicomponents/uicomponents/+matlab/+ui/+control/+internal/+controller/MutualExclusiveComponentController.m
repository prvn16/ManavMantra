classdef (Hidden) MutualExclusiveComponentController < ...
        matlab.ui.control.internal.controller.ComponentController    
    % MUTUALEXCLUSIVECOMPONENTCONTROLLER controller class for AbstractMutualExclusiveComponent   
    
    % Copyright 2014 The MathWorks, Inc.
    
    methods
        function obj = MutualExclusiveComponentController(varargin)            
            obj = obj@matlab.ui.control.internal.controller.ComponentController(varargin{:});  
        end
    end
    
    methods(Access = 'protected')
        
        function propertyNames = getAdditionalPropertyNamesForView(obj)
            % Get additional properties to be sent to the view
            
            propertyNames = getAdditionalPropertyNamesForView@matlab.ui.control.internal.controller.ComponentController(obj);
            
            % Non - public properties that need to be sent to the view
            propertyNames = [propertyNames; {...
                'ButtonId'; ...
                }];    
        end
        
        function handleEvent(obj, src, event)
            
            if(strcmp(event.Data.Name, 'ViewSelectionChanged'))
                % indicate button is selected interactively, not programatically
                obj.Model.isInteractiveSelectionChanged = true;
                
                % set Value property
                obj.Model.Value = event.Data.Value;
            end
            
            % Allow super classes to handle their events
            handleEvent@matlab.ui.control.internal.controller.ComponentController(obj, src, event);
        end    
    end
    
end
