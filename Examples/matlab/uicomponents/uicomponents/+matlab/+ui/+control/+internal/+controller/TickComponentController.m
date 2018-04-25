classdef (Hidden) TickComponentController < ...
        matlab.ui.control.internal.controller.ComponentController
    
    % TICKCOMPONENTCONTROLLER This is controller class for any component
    % with tick properties.
    
    % Copyright 2011-2012 The MathWorks, Inc.
    
    methods
        function obj = TickComponentController(varargin)
            obj@matlab.ui.control.internal.controller.ComponentController(varargin{:});
            
            obj.NumericProperties = [obj.NumericProperties, {'Value', 'MajorTicks', 'MinorTicks', 'Limits'}];
        end
    end
    
    methods(Access = 'protected')
        
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
            
            % Properties from Super
            viewPvPairs = [viewPvPairs, ...
                getPropertiesForView@matlab.ui.control.internal.controller.ComponentController(obj, propertyNames), ...
                ];
            
            % Tick - related
            if(any(strcmp('MajorTickLabelsMode', propertyNames)))
                % Labels should always the server value, no matter
                % if MajorTickLabelsMode is auto or manual, the client will
                % take care of this requirement
                viewPvPairs = [viewPvPairs, ...
                    {'WidgetMajorTickLabelsMode', obj.Model.MajorTickLabelsMode}
                    ];
            end
            
            if(any(strcmp('MajorTicksMode', propertyNames)))
                % When either changes, need to populate the Major Tick
                % labels
                viewPvPairs = [viewPvPairs, ...
                    {'WidgetMajorTicksMode', obj.Model.MajorTicksMode}
                    ];
            end
            
            if(any(strcmp('MinorTicksMode', propertyNames)))
                % When either changes, need to populate the Major Tick
                % labels
                viewPvPairs = [viewPvPairs, ...
                    {'WidgetMinorTicksMode', obj.Model.MinorTicksMode}
                    ];
            end
        end
        
        function handlePropertiesChanged(obj, changedPropertiesStruct)
            
            changedPropertiesStruct = privatelyUpdateTicksProperties(obj, changedPropertiesStruct);
            
            % superclass method
            handlePropertiesChanged@matlab.ui.control.internal.controller.ComponentController(obj, changedPropertiesStruct);
        end
        
        function handleEvent(obj, src, event)
            switch(lower(event.Data.Name))
                
                case 'setpropertiesonmodel'
                    % At runtime, tick related properties are updated via an event                    
                    [~] = obj.privatelyUpdateTicksProperties(event.Data);                    
            end
            
            handleEvent@matlab.ui.control.internal.controller.ComponentController(obj, src, event)
        end
    end
    
    methods ( Access = 'private' ) 
       
        function changedPropertiesStruct = privatelyUpdateTicksProperties(obj, changedPropertiesStruct)
            
            % Update Private version of MajorTicks, MinorTicks and
            % MajorTickLabels so that the mode property is not flipped.
            
            % Handle a MajorTickLabels changed
            % If MajorTickLabels is empty, it will be passed to the server
            % as the empty double array []. We need to convert it to a cell
            % since MajorTickLabels only accept cells.
            if(isfield(changedPropertiesStruct, 'MajorTickLabels'))
                newLabels = changedPropertiesStruct.MajorTickLabels;
                if(isempty(newLabels) && isa(newLabels, 'double'))
                    newLabels = num2cell(newLabels);
                end
                % Change the value of MajorTickLabels on the structure
                % itself and let the super class handle the property
                % change.
                % The super class has some logic that sets MajorTickLabels
                % or not depending on the mode property. If we were to set
                % MajorTickLabels here, we would loose the logic in the
                % super class.
                obj.Model.handleMajorTickLabelsChanged(newLabels);
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'MajorTickLabels');
            end                        
            
            if(isfield(changedPropertiesStruct, 'MajorTicks'))
               
                obj.Model.handleMajorTicksChanged(changedPropertiesStruct.MajorTicks);
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'MajorTicks');
                
            end
            
            if(isfield(changedPropertiesStruct, 'MinorTicks'))
               
                obj.Model.handleMinorTicksChanged(changedPropertiesStruct.MinorTicks);
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'MinorTicks');
            end
        end
    end
        
end

