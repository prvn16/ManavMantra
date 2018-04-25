classdef InspectorUndoableCommand < internal.matlab.datatoolsservices.UndoableCommand
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % UndoableCommand for the Inspector.
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        UndoPropertyInfo
        RedoPropertyInfo
        EditedObject
        EditedObjectModel
    end
    
    methods(Access = public)
        % Creates a new InspectorUndoableCommand instance.
        %
        % dataModel - the Inspector Data Model for the object being
        %             acted upon.  This has access to the object itself.
        % propertyName - the Property Name for this command
        % newPropertyValue - the new Property Value
        % newPropertyDispValue - the new property value's display
        %                        value.  This is needed in the case of
        %                        value objects.
        % varName - The variable name. This is needed in the case of
        %           value objects.
        function obj = InspectorUndoableCommand(dataModel, propertyName, ...
                newPropertyValue, newPropertyDispValue, varName)
            obj.captureState(dataModel, propertyName, newPropertyValue, ...
                newPropertyDispValue, varName);
        end
        
        % Called to execute the command
        function status = execute(obj)
            status = obj.setProperty(obj.EditedObjectModel, obj.EditedObject, obj.RedoPropertyInfo);
        end
        
        % Called to undo the command
        function undo(obj)
            obj.setProperty(obj.EditedObjectModel, obj.EditedObject, obj.UndoPropertyInfo);
        end
        
        % Called to redo the command
        function redo(obj)
            obj.setProperty(obj.EditedObjectModel, obj.EditedObject, obj.RedoPropertyInfo);
        end
    end
    
    methods(Access = private)
        
        % Called to set a property value.
        %
        % editedObjectModel - the Inspector Data Model for the object being
        % acted upon.  This has access to the object itself.
        %
        % editedObject - the object being edited.  This is used if the
        % model is empty or invalid (which can happen if the object is no
        % longer being inspected)
        %
        % propertyInfo - a struct which contains the Undo and Redo
        % information for the command (the property name and value)
        function status = setProperty(~, editedObjectModel, editedObject, propertyInfo)
            if isobject(editedObjectModel) && isvalid(editedObjectModel)
                % If we have the model, use it to set the Property Value
                % since it will properly sync between proxy view and the
                % actual object.
                status = editedObjectModel.setPropertyValue(...
                    propertyInfo.PropertyName, ...
                    propertyInfo.PropertyValue, ...
                    propertyInfo.DisplayValue, ...
                    propertyInfo.VarName);
            else
                % But if not, apply the value to the object itself.  This
                % can happen if the inspector is closed and the proxy is
                % deleted, but the undo is triggered from other mechanisms
                status = internal.matlab.inspector.InspectorProxyMixin.staticSetPropertyValue(...
                    editedObject, ...
                    propertyInfo.PropertyName, ...
                    propertyInfo.PropertyValue);
            end
        end
        
        % Called to capture the state for a given object's property
        % value.  These are saved as the object's properties
        % UndoPropertyInfo and RedoPropertyInfo, which are structs
        % that contain the property name and value.
        %
        % obj - the Inspector Data Model for the object being
        %       acted upon, or the object itself (in the case of nested
        %       objects).
        % propertyName - the property that is going to be set
        % newPropertyValue - the property value that is going to be set.
        % newPropertyDispValue - the new property value's display
        %                        value.  This is needed in the case of
        %                        value objects.
        % varName - The variable name. This is needed in the case of
        %           value objects.
        function captureState(this, obj, propertyName, ...
                newPropertyValue, newPropertyDispValue, varName)
            if isa(obj, 'internal.matlab.inspector.MLInspectorDataModel') || isfield(obj, 'getData')
                editedObject = obj.getData;
                
                % Save the EditedObject and model
                this.EditedObjectModel = editedObject;
                this.EditedObject = editedObject.OriginalObjects;
            else
                editedObject = obj;
                
                this.EditedObjectModel = [];
                this.EditedObject = obj;
            end
            changedPropertiesStruct.(propertyName) = editedObject.(propertyName);
            
            % If multiple objects are selected, get the new values for all
            % the selected objects by replicating them
            if iscell(newPropertyValue)
                this.RedoPropertyInfo.AllPropertyValues = repmat(newPropertyValue,numel(this.EditedObject),1);
            else
                this.RedoPropertyInfo.AllPropertyValues = repmat({newPropertyValue},numel(this.EditedObject),1);
            end
            
            import matlab.ui.control.internal.model.PropertyHandling;
            [siblingProperties, ~] = PropertyHandling.getPropertiesWithMode(...
                class(editedObject), changedPropertiesStruct, false);
            
            if(any(strcmp(siblingProperties, propertyName)))
                % the user is changing a property that has a mode
                modePropertyName = sprintf('%sMode', propertyName);
                modeValue = editedObject.(modePropertyName);
                
                if(strcmp(modeValue, 'auto'))
                    % we are changing a property that is currently in auto
                    %
                    % The state to restore will be flipping mode back to
                    % auto
                    this.UndoPropertyInfo.PropertyName = modePropertyName;
                    this.UndoPropertyInfo.PropertyValue = 'auto';
                    this.UndoPropertyInfo.DisplayValue = 'auto';
                    this.UndoPropertyInfo.VarName = varName;
                    
                    this.RedoPropertyInfo.PropertyName = propertyName;
                    this.RedoPropertyInfo.PropertyValue = newPropertyValue;
                    this.RedoPropertyInfo.DisplayValue = newPropertyDispValue;
                    this.RedoPropertyInfo.VarName = varName;
                    return;
                end
            end
            
            % Pass extra information for a mode property. This is needed so
            % that when XLimMode property is changed from manual to auto,
            % the XLim property gets set. So, the undo action should have
            % information on both XLim and XLimMode which can be reset in
            % one undo action
            if endsWith(propertyName, 'Mode')
                affectedPropertyName = erase(propertyName,'Mode');
                if isprop(editedObject, affectedPropertyName)
                    % If multiple objects are selected, get the old values of all
                    % the selected objects
                    if numel(this.EditedObject) > 1
                        oldValues = arrayfun(@(obj) obj.(affectedPropertyName),...
                            this.EditedObject,'UniformOutput',false);
                        affectedPropertyValue = oldValues';
                    else
                        affectedPropertyValue = editedObject.(affectedPropertyName);
                    end
                    
                    this.UndoPropertyInfo.AffectedPropertyName = affectedPropertyName;
                    this.UndoPropertyInfo.AffectedPropertyValue = affectedPropertyValue;
                end
            end
            
            % we are changing a property that is either:
            %
            % - already in manual mode
            %
            % - doesn't have a Mode property
            %
            % to restore, we just need to remember the current
            % value
            this.UndoPropertyInfo.PropertyName = propertyName;            
            % If multiple objects are selected, get the old values of all
            % the selected objects
            if numel(this.EditedObject) > 1
                oldValues = arrayfun(@(obj) obj.(propertyName),...
                    this.EditedObject,'UniformOutput',false);
                this.UndoPropertyInfo.PropertyValue = oldValues';
            else
                this.UndoPropertyInfo.PropertyValue = editedObject.(propertyName);
            end
            
            if ~ischar(this.UndoPropertyInfo.PropertyValue)
                currDispValue = internal.matlab.variableeditor.peer.PeerStructureViewModel.getDisplayEditValue(...
                    this.UndoPropertyInfo.PropertyValue);
            else
                currDispValue = this.UndoPropertyInfo.PropertyValue;
            end
            this.UndoPropertyInfo.DisplayValue = currDispValue;
            this.UndoPropertyInfo.VarName = varName;
            
            this.RedoPropertyInfo.PropertyName = propertyName;
            this.RedoPropertyInfo.PropertyValue = newPropertyValue;
            this.RedoPropertyInfo.DisplayValue = newPropertyDispValue;
            this.RedoPropertyInfo.VarName = varName;
        end
    end
end