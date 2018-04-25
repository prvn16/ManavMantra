 classdef DefaultInspectorProxyMixin < ...
        internal.matlab.inspector.InspectorProxyMixin
    
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % This class is used by the Inspector when inspecting an object, if the
    % object doesn't already inherit from the InspectorProxyMixin.  It
    % sets up the Proxy Mixin on the fly based on the public properties of
    % the original object.  This class handles array of objects as well.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Hidden = true)
        PropertiesAdded = {};
        PropRemovedListeners = {};
        PropAddedListeners = {};
    end
    
    methods
        % Create a new InspectorProxyMixin instance.
        function this = DefaultInspectorProxyMixin(OriginalObjects, ...
                multiplePropertyCombinationMode, ...
                multipleValueCombinationMode)
            
            this@internal.matlab.inspector.InspectorProxyMixin(...
                OriginalObjects);
            this.OriginalObjects = OriginalObjects;
            
            % Setup MultiplePropertyCombinationMode
            if nargin < 2 || isempty(multiplePropertyCombinationMode)
                this.MultiplePropertyCombinationMode = ...
                    internal.matlab.inspector.MultiplePropertyCombinationMode.getDefault;
            else
                this.MultiplePropertyCombinationMode = ...
                    internal.matlab.inspector.MultiplePropertyCombinationMode.getValidMultiPropComboMode(...
                    multiplePropertyCombinationMode);
            end
            
            % Setup MultipleValueCombinationMode
            if nargin < 3 || isempty(multipleValueCombinationMode)
                this.MultipleValueCombinationMode = ...
                    internal.matlab.inspector.MultipleValueCombinationMode.getDefault;
            else
                this.MultipleValueCombinationMode = ...
                    internal.matlab.inspector.MultipleValueCombinationMode.getValidMultiValueComboMode(...
                    multipleValueCombinationMode);
            end
            
            % Get the property list for the objects, taking into account
            % the multi-property combination mode.  This returns a list of
            % only properties which have GetAccess = public, and are not
            % hidden.
            propertyList = this.getPropertyListForMode(OriginalObjects, ...
                this.MultiplePropertyCombinationMode);
            
            % Create properties on this class for each of the original
            % object's unique properties.
            for j=1:length(OriginalObjects)
                o = OriginalObjects(j);
                this.addListeners(o);
                m = metaclass(o);
                
                if j>1
                    % The first PreviousData struct was already created by
                    % the InspectorProxyMixin constructor
                    s = warning('off', 'all');
                    this.PreviousData{j} = ...
                        internal.matlab.inspector.Utils.createStructForObject(o);
                    warning(s);
                end
                
                metaclassProperties = m.PropertyList;
                metaclassPropNames = {metaclassProperties.Name};
                classProperties = properties(o);
                for i = 1:length(propertyList)
                    idx = strcmp(metaclassPropNames, propertyList{i});
                    if any(idx)
                        % Does this property actually exist in the metadata
                        % for the class?  Prefer to use this, as it has the
                        % other property data (description, type, etc...)
                        prop = metaclassProperties(idx);
                        propName = prop.Name;
                    elseif ismember(propertyList{i}, classProperties)
                        % Some classes use some trickery to have
                        % 'properties'.  Continue, but it won't have all of
                        % the other property data.
                        prop = [];
                        propName = propertyList{i};
                    else
                        % This property isn't defined for this object (this
                        % can happen in the case of arrays of objects)
                        continue;
                    end
                    
                    if isempty(findprop(this, propName))
                        % This is the first time we've encountered this
                        % property, add it to this object
                        d = addprop(this, propName);
                        this.PropertiesAdded = [this.PropertiesAdded; propName];
                        
                        % Also add an internal property (with suffix _PI)
                        % to help coordinate changes between the proxy and
                        % the original object
                        internalProp = addprop(this, [propName '_PI']);
                        internalProp.Hidden = true;
                        
                        try
                            % Set value to the initial value from the
                            % object.  Don't need to set get/set methods on
                            % the property - since these are properties of
                            % this mixin object directly.
                            this.(propName) = o.(propName);

                            
                            % Also set the initial value of the internal
                            % property, and add get/set methods for it
                            this.([propName '_PI']) = o.(propName);
                            
                            if iscategorical(o.(propName))
                                % Save list of categorical properties for
                                % comparison later, to check when categories
                                % are added or removed
                                this.CategoricalProperties{end+1} = propName;
                            end
                        catch
                            % Typically this won't fail, but it can sometimes with
                            % dependent properties that become invalid (for
                            % example, property d is determined by a+b, but b is a
                            % matrix and b is a char array).  Set to empty in this
                            % case.
                            this.(propName) = [];
                            this.([propName '_PI']) = [];
                        end

                        d.SetMethod = @(this, newValue) ...
                            this.setOriginalPropValue(...
                            propName, newValue);
                        d.GetMethod = @(this) this.([propName '_PI']);

                        if ~isempty(prop)
                            % Retain the Description and
                            % DetailedDescription
                            d.DetailedDescription = prop.Description;
                            d.DetailedDescription = prop.DetailedDescription;
                            
                            % d.Type = prop.Type;  This is not allowed by
                            % MCOS Store in a map instead
                            % Now the map contains Type and Validation two
                            % kinds of data
                            this.PropertyTypeMap(propName) = internal.matlab.inspector.Utils.getProp(prop);                        
                            
                            % Also retain the SetAccess (so that read-only
                            % properties remain as such)
                            d.SetAccess = prop.SetAccess;
                        else
                            this.PropertyTypeMap(propName) = ...
                                class(o.(propName));
                        end
                        d.SetObservable = true;
                        d.GetObservable = true;
                    else
                        % For properties which exist on multiple objects,
                        % use the multipleValueCombinationMode setting to
                        % determine what value to store
                        this.InternalPropertySet = true;
                        this.([propName '_PI']) = ...
                            internal.matlab.inspector.InspectorProxyMixin.getCombinedValue(...
                            this.(propName), o.(propName), ...
                            this.MultipleValueCombinationMode);
                        this.InternalPropertySet = false;
                    end
                    
                    if ~isempty(prop) && prop.SetObservable
                        % Create a listener for observable properties
                        this.PropChangedListeners{...
                            length(this.PropChangedListeners)+1,1} = ...
                            event.proplistener(o, prop, 'PostSet', ...
                            @this.multiObjPropChangedCallback);
                    end
                end
            end
        end
        
        function delete(this)
            delete@internal.matlab.inspector.InspectorProxyMixin(this);
                        
            if ~isempty(this.PropAddedListeners)
                cellfun(@(x) delete(x), this.PropAddedListeners);
            end
            this.PropAddedListeners = {};
            
            if ~isempty(this.PropRemovedListeners)
                cellfun(@(x) delete(x), this.PropRemovedListeners);
            end
            this.PropRemovedListeners = {};

        end
        
        % Override fieldnames to return the list of properties which were
        % added - this assures that the order is as expected.
        function f = fieldnames(this)
            f = this.PropertiesAdded;
        end
        
        % Override properties to return the list of properties which were
        % added - this assures that the order is as expected.
        function f = properties(this)
            f = this.PropertiesAdded;
        end
        
        function multiObjPropChangedCallback(this, es, ~)
            propName = es.Name;
            this.InternalPropertySet = true;
            this.updatePropertyForChange(propName);
            this.InternalPropertySet = false;
        end
        
        function updatePropertyForChange(this, propName)
            % Set the value on the mixin object for the value which was set
            % Need to recompare values for all properties, and take into
            % account the Multiple Value Combination Mode.
            
            % This will be reinitialized with all of the values, based on
            % the multiple values combination mode
            tempValue = [];
            
            for i = 1:length(this.OriginalObjects)
                o = this.OriginalObjects(i);
                if this.isPropertyOfObject(o, propName)
                    if isempty(this.(propName))
                        tempValue = o.(propName);
                    else
                        tempValue = ...
                            internal.matlab.inspector.InspectorProxyMixin.getCombinedValue(...
                            tempValue, o.(propName), ...
                            this.MultipleValueCombinationMode);
                    end
                end
            end
            
            % Only set the actual property once, so any listeners will get
            % the accurate value at the end
            this.(propName) = tempValue;
            
            % Does a property inspector internal property exist?  If
            % so, set this value as well
            if isprop(this, [propName '_PI'])
                this.([propName '_PI']) = tempValue;
            end
        end
        
        % Returns the property value.  It first tries to access the value
        % directly.  If the result is empty, it checks to see if the
        % OriginalObjects has the property value set.
        function val = getPropertyValue(this, propertyName)
            try
                % Try to access the property directly
                val = this.(propertyName);
            catch
                val = [];
            end
        end
        
        % set the property value
        function status = setPropertyValue(this, varargin)
            status = '';
            propertyName = varargin{1};
            value = varargin{2};
            if nargin > 3
                % Required for value objects
                displayValue = varargin{3};
                varName = varargin{4};
            end

            % Set the property value on all objects which contain that
            % property
            isAnyProperty = false;
            this.InternalPropertySet = true;
            for idx = 1:length(this.OriginalObjects)
                obj = this.OriginalObjects(idx);
                
                % Check to make sure this property is a property of this
                % object in the array, and that its not read-only
                [isProperty, readOnly] = this.isPropertyOfObject(...
                    obj, propertyName);
                if isProperty && ~readOnly
                    if isa(obj, 'handle')
                        if iscategorical(obj.(propertyName)) && ...
                                isscalar(obj.(propertyName))
                            % Need to assign scalar categorical by index,
                            % otherwise it will change the type to char
                            obj.(propertyName)(1) = value;
                        else
                            obj.(propertyName) = value;
                        end
                        isAnyProperty = true;
                    else
                        this.setValueObjectProperty(propertyName, ...
                            displayValue, varName);
                        try
                            this.OriginalObjects(idx).(propertyName) = value;
                        catch
                            if length(this.OriginalObjects) == 1
                                % Some objects fail on indexing like above,
                                % so retry. Let this fail and throw the
                                % exception -- it will be caught and the
                                % error will be displayed.
                                this.OriginalObjects.(propertyName) = value;
                            end
                        end
                        this.(propertyName) = value;
                        isAnyProperty = true;
                    end
                end
            end
            
            if isAnyProperty
                this.InternalPropertySet = true;
                % Update the current value for this object, based on the
                % Multiple Object Value Combination Mode.
                this.updatePropertyForChange(propertyName)
            end

            this.InternalPropertySet = false;
        end
        
        function setValueObjectProperty(this, propertyName, ...
                displayValue, varName)
            evalStr = sprintf('%s.%s = %s;', varName, ...
                propertyName, displayValue);
            errorMsg = ...
                'internal.matlab.inspector.peer.InspectorFactory.getInstance.sendErrorMessage(''%1$s'');';
            
            if ischar(this.Workspace)
                if ~com.mathworks.datatools.variableeditor.web.WebWorker.TESTING
                    com.mathworks.datatools.variableeditor.web.WebWorker.executeCommandAndFormatError(...
                        evalStr, errorMsg);
                end
            end
        end
    end
    
    methods (Access = protected)
        function propertyAdded = addPropertyToProxy(this, propertyName)
            % Called to see if a property needs to be added to the proxy
            % object (for when dynamic properties are added to the original
            % object).
            propertyAdded = addPropertyToProxy@internal.matlab.inspector.InspectorProxyMixin(...
                this, propertyName);
            if propertyAdded
                this.PropertiesAdded = [this.PropertiesAdded; propertyName];
            end
        end
    end
    
    methods (Access = private)
        function [isProperty, readOnly] = isPropertyOfObject(~, obj, ...
                propertyName)
            
            % Returns true if the propertyName is a property of the given
            % object, obj.  If possible, also returns whether the property
            % is read-only or not.
            readOnly = false;
            
            if isprop(obj, propertyName)
                isProperty = true;
                
                if ismethod(obj, 'findprop')
                    prop = findprop(obj, propertyName);
                else
                    % If findprop is not defined, try to find the property
                    % in the metaclass PropertyList
                    m = metaclass(obj);
                    prop = findobj(m.PropertyList, 'Name', propertyName);
                end
                
                if ~isempty(prop)
                    readOnly = ~strcmp(prop.SetAccess, 'public');
                end
            else
                % Some objects redefine their properties (like timer), so
                % need to handle this case as well
                props = properties(obj);
                isProperty =  ismember(propertyName, props);
            end
        end
        
        function addListeners(this, obj)      
            if isa(obj, 'handle') && isa(obj, 'dynamicprops')
                    % Add listeners for dynamic properties being added or
                    % removed
                    this.PropAddedListeners{end+1} = event.listener(obj, ...
                        'PropertyAdded', @this.propAddedCallback);
                    this.PropRemovedListeners{end+1} = event.listener(obj, ...
                        'PropertyRemoved', @this.propRemovedCallback);
            end
        end
        
        function propAddedCallback(this, es, ed)
            % Redisplay the object by setting DataChanged = true
%             this.DataChanged = true;
%             
%             this.firePropertyAddedEvent('', '');
        end
        
        function propRemovedCallback(this, es, ed)
            % Redisplay the object by setting DataChanged = true
%             this.DataChanged = true;
%             
%             this.firePropertyRemovedEvent('', '');
        end
    end
end
