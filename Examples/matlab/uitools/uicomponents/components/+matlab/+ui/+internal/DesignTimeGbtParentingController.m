classdef DesignTimeGbtParentingController < ...
        matlab.ui.internal.DesignTimeGBTComponentController & ...
        appdesservices.internal.interfaces.controller.DesignTimeParentingController & ...
        matlab.ui.internal.componentframework.services.optional.ControllerInterface

    %  Copyright 2014-2017 The MathWorks, Inc.
    
    methods 
        
        function obj = DesignTimeGbtParentingController(varargin)
            obj = obj@matlab.ui.internal.DesignTimeGBTComponentController(varargin{:});
            
            factory = appdesigner.internal.componentmodel.DesignTimeComponentFactory;            
            obj = obj@appdesservices.internal.interfaces.controller.DesignTimeParentingController( factory );            
        end
    end

    methods (Access=protected)
             
        function deleteChild(~, ~, child)
            % implement the delete of a child
            delete( child );
        end
        
        function viewPvPairs = getPropertiesForView(obj, propertyNames)
            % GETPROPERTIESFORVIEW(OBJ, PROPERTYNAME) returns view-specific
            % properties, given the PROPERTYNAMES
            %
            % Inputs:
            %
            %   propertyNames - list of properties that changed in the
            %                   component model.
            %
            % Outputs:
            %
            %   viewPvPairs   - list of {name, value, name, value} pairs
            %                   that should be given to the view.
            
            viewPvPairs = {};
            
            % Base class
            viewPvPairs = [viewPvPairs, ...
                getPropertiesForView@matlab.ui.internal.DesignTimeGBTComponentController(obj, propertyNames)];   
            
            % AutoResizeChildren
            viewPvPairs = [viewPvPairs, ...
                getAutoResizePropertyForView(obj, propertyNames);
                ];
        end
        
        
        function viewPvPairs = getAutoResizePropertyForView(obj, propertyNames)
            % @TODO This is handling a COMPATIBILITY issue.  Therefore:
            % 1) It should be probably be provided at run-time, b/c
            % eventually save/load will be available at run-time
            % 2) It should be separated out from general infrastructure,
            % so that new components would not have this code.
            %
            % Design time controller method, invoked to restore auto resize
            % related values from the model
            
            viewPvPairs = {};
            
            if(any(ismember('AutoResizeChildren', propertyNames)))
                % Suppress the warning at the command line when setting
                % AutoResizeChildren at design time.
                % The warning would otherwise display if AutoResizeChildren
                % is set to 'on' and SizeChangedFcn is not empty
                ws = warning('off', 'MATLAB:ui:containers:SizeChangedFcnDisabledWhenAutoResizeOn');
                c = onCleanup(@()warning(ws));
                
                % Initialize the auto resize property.
                % Apps created in 16a/16b do not define the AutoResizeChildren
                % property. Initialize auto resize with the parent's setting
                % since:
                % - Auto resize can only be enabled for all or none of the containers
                % - The uifigure was initialized correctly using the saved
                % dynamic property defined for 16a/16b apps
                model = obj.getModel();
                model.AutoResizeChildren = model.Parent.AutoResizeChildren;
                
                viewPvPairs = [viewPvPairs, ...
                    {'AutoResizeChildren', model.AutoResizeChildren},...
                    ];
            end
        end
        
        function handleDesignTimePropertiesChanged(obj, peerNode, valuesStruct)
            
            % Handle resize related properties
            resizePropertyNames = {'SizeChangedFcn', 'AutoResizeChildren'};
            if(any(isfield(valuesStruct, resizePropertyNames)))
                
                % Suppress the warning at the command line when setting
                % SizeChangedFcn or AutoResizeChildren at design time.
                % The warning would otherwise display if AutoResizeChildren
                % is set to 'on' and SizeChangedFcn is not empty or vice
                % versa
                ws = warning('off', 'MATLAB:ui:containers:SizeChangedFcnDisabledWhenAutoResizeOn');
                c = onCleanup(@()warning(ws));
                
                for k = 1:length(resizePropertyNames)                    
                    propertyName = resizePropertyNames{k};
                    
                    if(isfield(valuesStruct, propertyName))
                        % Update the model
                        updatedValue = valuesStruct.(propertyName);
                        obj.getModel().(propertyName) = updatedValue;

                        % Remove the property that was handled from the struct
                        valuesStruct = rmfield(valuesStruct, propertyName);
                    end
                end                
            end
            
            % let the base class handle the rest
            handleDesignTimePropertiesChanged@matlab.ui.internal.DesignTimeGBTComponentController(obj, peerNode, valuesStruct);
        end
    end
end
