classdef (Hidden) LayoutableController <  appdesservices.internal.interfaces.controller.AbstractControllerMixin
    % Mixin Controller Class for the Layoutable mixin
    
    % Copyright 2017 The MathWorks, Inc.
    
    
    methods (Static = true)
        
        function additionalProperties = getAdditonalLayoutPropertyNamesForView()
            % These are non - public properties that need to be explicitly
            % added
            additionalProperties = {...
                'LayoutConstraints';...
                };            
        end
    end
    
    
    methods
        
        function viewPvPairs = getLayoutConstraintsForView(obj, propertyNames)
            % Format the LayoutConstraints property so it can be sent to
            % the view
            
            viewPvPairs = {};
            
            if(any(strcmp('LayoutConstraints', propertyNames)))
                
                constraints = obj.Model.LayoutConstraints;
                
                % Convert the object into a struct via 'get'
                constraintsStruct = get(constraints);
                
                % Add a 'type' field to the struct
                % so the view knows which type of layout
                % container the component is in 
                %
                % The type is determined by looking at the class name of
                % the LayoutConstraints property, which is of the form
                % [LayoutType]LayoutConstraints, e.g. GridLayoutConstraints                
                fullClassName = class(constraints);                
                shortClassNameStartIdx = regexp(fullClassName, '\.\w*LayoutConstraints');
                offset = length('LayoutConstraints');                
                constraintsShortClassName = fullClassName(shortClassNameStartIdx+1 : end-offset);                
                constraintsStruct.Type = constraintsShortClassName;
                
                viewPvPairs = [viewPvPairs, ...
                    {'LayoutConstraints', constraintsStruct} ...
                    ];
            end
        end
    end
    
end

