classdef ComboBoxEditor < ...
        internal.matlab.variableeditor.peer.editors.EditorConverter
    
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % This class provides the editor conversion needed for categoricals and
    % enumerations.
    
    % Copyright 2015-2017 The MathWorks, Inc.

    properties
        value;
        dataType;
        classname;
        propCategories;        
    end
    
    methods
        
        % Called to set the server-side value
        function setServerValue(this, value, dataType, ~)
            this.value = value;
            this.dataType = dataType;
        end
        
        % Called to set the client-side value
        function setClientValue(this, value)
            this.value = value;
        end
        
        % Called to get the server-side representation of the value
        function value = getServerValue(this)
            if strcmp(this.classname, 'categorical')
                % Create a categorical with the new value, and the current
                % set of categories (plus the new value, if the user
                % entered a new category)
                if strcmp(this.value, '<undefined>')
                    value = categorical(missing, this.propCategories);
                else
                    value = categorical({this.value}, ...
                        unique([this.propCategories{:} {this.value}]));
                end
            else
                % Add back the quotes for
                % enumeration/categoricals
                value = ['''' this.value ''''];
            end
        end
        
        % Called to get the client-side representation of the value
        function varValue = getClientValue(this)
            % Remove quotes from value if scalar (otherwise its a
            % summary value like 1x5 categorical)
            varValue = this.value;
            if isscalar(this.value) || ischar(this.value)
                if ~ischar(this.value)
                    varValue = char(this.value);
                end
                
                varValue = strrep(varValue, '''', '');
            end
        end
        
        % Called to get the editor state, which contains properties
        % specific to the editor
        function props = getEditorState(this)
            [isCatOrEnum, ~, values, isProtected, showUndefined] = ...
                internal.matlab.variableeditor.peer.editors.ComboBoxEditor.isCategoricalOrEnum(...
                class(this.value), this.dataType, this.value);
            if isCatOrEnum
                props = struct;
                props.categories = values;
                props.isProtected = isProtected;
                props.showUndefined = showUndefined;
                props.clientValidation = false;
            else
                props = [];
            end
        end
        
        % Called to set the editor state.  
        function setEditorState(this, editorState)
            this.classname = class(editorState.currentValue);
            if iscategorical(editorState.currentValue) 
                this.propCategories = categories(editorState.currentValue);
            end
        end
    end
    
    methods(Static = true)
        function [isCatOrEnum, dataType, values, isProtected, showUndefined] = ...
                isCategoricalOrEnum(default, propType, value)
            
            % Returns the property data type.  This may be the name of a
            % type, like double or matlab.graphics.datatype.AutoManual, or
            % it could be 'any' if the property is not typed.  values will
            % be set to the possible values if it is an enumeration or
            % categorical.
            values = [];
            isProtected = false;
            showUndefined = false;
            
            % The type will either be a meta.type object, or it could
            % be just a class name, depending on if the metaclass
            % object had data for the property or not
            if isa(propType, 'meta.type') || isa(propType, 'meta.class')           
                if strcmp(propType.Name, 'any')
                    % If the property type is any, use our default
                    % value determined from the value.
                    dataType = default;
                else
                    % Otherwise, use the type as defined
                    dataType = propType.Name;
                end
            else
                dataType = class(value);
            end

            if internal.matlab.variableeditor.peer.editors.ComboBoxEditor.isEnumerationFrompropType(propType)
                % Enumerated Types have their possible values
                % defined
                if isa(propType, 'meta.class')
                    values = {propType.EnumerationMemberList.Name};
                else
                    values = propType.PossibleValues;
                end 
                
                % Enumerated types can be treated as protected
                % - the user cannot add a new type to the list
                % by editing the value.
                isProtected = true;
            elseif any(dataType == ["categorical", "nominal", "ordinal"])
                % For categoricals, nominals, and ordinals, use
                % their defined categories
                values = categories(value);
                isProtected = isprotected(value);
                
                % Categoricals should show undefined in the
                % dropdown menu (enumerations do not)
                showUndefined = true;
            elseif isobject(value) && ...
                    ~any(dataType == ["string", "table", "datetime", "duration", "calendarDuration"])
                [~, values] = enumeration(value);
                % Enumerated types can be treated as protected
                % - the user cannot add a new type to the list
                % by editing the value.
                isProtected = true;
            end
            isCatOrEnum = ~isempty(values);
        end
        
       function isEnum = isEnumerationFrompropType(propType)
            if  isa(propType, 'meta.class')
                isEnum = propType.Enumeration;
            else
                isEnum = isa(propType, 'meta.EnumeratedType');
            end            
       end    
    end
end
