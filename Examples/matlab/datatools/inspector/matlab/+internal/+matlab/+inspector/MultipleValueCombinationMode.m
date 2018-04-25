classdef MultipleValueCombinationMode
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % This class represents the ways in which values from multiple objects
    % can be combined when passed as arguments to inspect:
    %
    % All:  Combine all of the values into an array
    % Blank: Show the value as blank (empty)
    % First: Show the values from the first object only
    % Last: Show the values from the last object only
    
    % Copyright 2015 The MathWorks, Inc.
    
    enumeration
        ALL
        BLANK
        FIRST
        LAST
    end
    
    
    methods(Static)
        % Returns the default MultipleValueCombinationMode value, which is
        % all
        function default = getDefault
            default = ...
                internal.matlab.inspector.MultipleValueCombinationMode.LAST;
        end
        
        % Returns a valid MultipleValueCombinationMode enumeration, based
        % on the input argument multiComboMode.  If multiComboMode is
        % invalid, the default of ALL is returned.
        function comboMode = getValidMultiValueComboMode(multiComboMode)
            if isa(multiComboMode, ...
                    'internal.matlab.inspector.MultipleValueCombinationMode')
                comboMode = multiComboMode;
            else
                [enums, enumStrs] = enumeration...
                    ('internal.matlab.inspector.MultipleValueCombinationMode');
                idx = strcmpi(enumStrs, multiComboMode);
                if any(idx)
                    comboMode = enums(idx);
                else
                    % Default to All
                    comboMode = ...
                        internal.matlab.inspector.MultipleValueCombinationMode.getDefault;
                end
            end
        end
    end
end