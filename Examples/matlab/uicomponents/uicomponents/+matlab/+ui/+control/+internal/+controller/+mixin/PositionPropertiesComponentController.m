classdef (Hidden) PositionPropertiesComponentController < appdesservices.internal.interfaces.controller.AbstractControllerMixin
    % Mixin Controller Class for 
    % Any "positionable" component controller
    % Run time or design time
    
    % Copyright 2016 - 2017 The MathWorks, Inc.
    
    methods (Static = true, Access='private')
        function viewPvPairs = getSizeLocationPropertiesForView(objModel, propertyNames)
            viewPvPairs = {};            
            
            if(any(ismember({'InnerPosition', 'Position_I'}, propertyNames)))
                % Position_I would only be sent by components that have
                % transitioned to using the GBT position mixin. 
                % For std/HMI components, Position_I == InnerPosition.
                % However, this will need to be updated when the position
                % mixin differenciates between inner and outer.
                
                viewPvPairs = [viewPvPairs, ...
                    ... Send the size/location properties because the view only
                    ... knows how to work with those
                    {'Location', objModel.InnerPosition(1:2)},...
                    {'Size', objModel.InnerPosition(3:4)},...                    
                    ];
            end
            
            if(any(ismember({'OuterPosition'}, propertyNames)))
                
                viewPvPairs = [viewPvPairs, ...
                    ... Send the size/location properties because the view only
                    ... knows how to work with those
                    {'OuterLocation', objModel.OuterPosition(1:2)},...
                    {'OuterSize', objModel.OuterPosition(3:4)},...
                    ];
            end
            
        end        
    end
    
    methods (Static = true)
        
        function additionalProperties = getAdditonalPositionPropertyNamesForView(objModel)
            % These are non - public properties that need to be explicitly
            % added
            additionalProperties = {...
                'AspectRatioLimits';...
                'IsSizeFixed'; ...
                };

            % Need to include Position_I for those components, whose
            % run time controllers do not use Property Management Service
            % e.g. HMI/Standard components
            % Without PMS, these components do not rename Position_I to Position
            % But view position properties need to be set if Position_I is changed
            % It will be removed through Excluded properties
            if (objModel.isprop('Position_I'))
                additionalProperties = [additionalProperties;...
                                        'Position_I'; ...
                                       ];
            end
            
        end
    
        
        function viewPvPairs = getPositionPropertiesForView(objModel, propertyNames)
            % Gets all properties for view based related to Size,
            % Location, etc...
            
            viewPvPairs = {};  
            
            viewPvPairs =  [viewPvPairs, ...
                matlab.ui.control.internal.controller.mixin.PositionPropertiesComponentController.getSizeLocationPropertiesForView(objModel, propertyNames)];
            
            viewPvPairs =  [viewPvPairs, ...
                matlab.ui.control.internal.controller.mixin.PositionPropertiesComponentController.getPositionUnitsPropertiesForView(objModel, propertyNames)];
            
            viewPvPairs =  [viewPvPairs, ...
                matlab.ui.control.internal.controller.mixin.PositionPropertiesComponentController.getPositionRestrictionPropertiesForView(objModel, propertyNames)];
        end
                
        function viewPvPairs = getPositionUnitsPropertiesForView(objModel, propertyNames)
            viewPvPairs = {}; 
            
            if(any(strcmp('Units', propertyNames)))
                % During design-time, the Units by default is pixels
                viewPvPairs = [viewPvPairs, ...
                    {'Units', 'pixels' }...
                    ];
            end
        end
        
        function viewPvPairs = getPositionRestrictionPropertiesForView(objModel, propertyNames)
            viewPvPairs = {}; 
            
            if(any(strcmp('AspectRatioLimits', propertyNames)))
                
                % The view needs the AspectRatioLimits for resizing in the
                % app designer
                
                % To avoid issues with Inf not being handled well in
                % JavaScript, instead pass a large integer
                % Todo: 1) In the future, will try to move the below
                % converting inf/-inf into a central place when unifying
                % the way to get PV pairs for sending to client side while
                % loading an app; or 2) if g1342092 is fixed from 
                % MATLAB External Interfaces team, probably no need to do
                % any convertion here
                
                aspectRatioLimits = [0, +Inf];
                if (objModel.isprop('AspectRatioLimits'))
                    aspectRatioLimits = objModel.AspectRatioLimits;
                end
                
                viewPvPairs = [viewPvPairs, ...
                    {'AspectRatioLimits', aspectRatioLimits }...
                    ];
            end
            
            if (any(strcmp('IsSizeFixed', propertyNames)))
                
                if (objModel.isprop('IsSizeFixed') == false)
                    viewPvPairs = [viewPvPairs, ...
                        {'IsSizeFixed', [false false] }...
                        ];                    
                end
            end
        end
        
        function excludedProperties = getExcludedPositionPropertyNamesForView()
            % Get the position related properties that should be excluded
            % from the list of properties sent to the view
            
            % The view only updated Size/Location.
            % Remove Position, Inner/OuterPosition otherwise their peer
            % node value will become stale and also potentially trigger
            % unwanted propertiesSet events (g1396296)
            excludedProperties = {...
                'Position'; ...
                'InnerPosition'; ...
                'OuterPosition'; ...
                'Position_I'; ...
                };
        end
        
    end
end
