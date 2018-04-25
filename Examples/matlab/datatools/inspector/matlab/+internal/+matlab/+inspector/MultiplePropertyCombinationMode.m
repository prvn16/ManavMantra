classdef MultiplePropertyCombinationMode
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % This class represents the ways in which properties from multiple
    % objects can be combined when passed as arguments to inspect:
    %
    % Union:  Show the union of properties 
    % Intersection: Show the intersection of properties 
    % First: Show the properties from the first object only 
    % Last: Show the properties from the last object only
    
    % Copyright 2015 The MathWorks, Inc.
    
    enumeration
        UNION
        INTERSECTION
        FIRST
        LAST
    end
    
    methods (Static)
        % Returns the default MultiplePropertyCombinationMode value, which
        % is intersection (like on the desktop)
        function default = getDefault
            default = ...
                internal.matlab.inspector.MultiplePropertyCombinationMode.INTERSECTION;
        end
        
        % Returns  valid MultiplePropertyCombinationMode enumeration, based
        % on the input argument multiComboMode.  If multiComboMode is
        % invalid, the default of INTERSECTION is returned.
        function comboMode = getValidMultiPropComboMode(multiComboMode)
            if isa(multiComboMode, ...
                    'internal.matlab.inspector.MultiplePropertyCombinationMode')
                comboMode = multiComboMode;
            else
                [enums, enumStrs] = enumeration...
                    ('internal.matlab.inspector.MultiplePropertyCombinationMode');
                idx = strcmpi(enumStrs, multiComboMode);
                if any(idx)
                    comboMode = enums(idx);
                else
                    % Default to Intersection (like in the desktop version)
                    comboMode = ...
                        internal.matlab.inspector.MultiplePropertyCombinationMode.getDefault;
                end
            end
        end
    end
end