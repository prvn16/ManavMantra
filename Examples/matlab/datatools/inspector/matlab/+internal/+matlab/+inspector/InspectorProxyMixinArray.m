classdef InspectorProxyMixinArray < ...
        internal.matlab.inspector.InspectorProxyMixin
    
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Extends the InspectorProxyMixin class to provide functionality for
    % multiple InspectorProxyMixins opened in the Property Inspector at
    % once.  This class is created by the Inspector class when an array of
    % InspectorProxyMixin's is passed to the inspect() method.
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    properties(Hidden = true)
        % Keep a reference to all of the InspectorProxyMixin objects in the
        % array
        ProxyObjects = [];
        
        % Keep track of properties added to this class, so that the
        % ordering can be maintained
        PropertiesAdded = {};
                
        ListenersPaused = false;
    end
    
    methods
        % Creates a new InspectorProxyMixinArray with the specified
        % ProxyObjects.
        function this = InspectorProxyMixinArray(ProxyObjects, ...
                multiplePropertyCombinationMode, ...
                multipleValueCombinationMode)
            this@internal.matlab.inspector.InspectorProxyMixin([]);
            this.ProxyObjects = ProxyObjects;
            
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
            
            this.combineData(this.MultipleValueCombinationMode);
            
            % Assign the group list to be the groups from the first object
            % (all objects should have the same group)
            this.GroupList = ProxyObjects(1).getGroups;
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
        
        % Combines the data for multiple InspectorProxyMixin's into
        % properties on this Array object, where each property's value is
        % an array of all of the property's values for all objects.  For
        % example, if the object array contains two objects with property
        % 'a', but different values of 10 and 50, the value of 'a' on this
        % array object will be [10 50].
        function combineData(this, multipleValueCombinationMode)
            props = properties(this.ProxyObjects(1));
            
            % For each object in the ProxyObjects array
            for object = this.ProxyObjects
                
                % For each property
                for prop = 1:length(props)
                    propName = props{prop};
                    p = findprop(object, propName);
                    
                    % Is the property already defined on this object?
                    if isempty(findprop(this, propName))
                        
                        % If not, add the property to this object
                        d = addprop(this, propName);
                        this.PropertiesAdded = [this.PropertiesAdded; ...
                            propName];
                        
                        % Set value to the initial value from the
                        % object.  Don't need to set get/set methods on
                        % the property - since these are properties of
                        % this mixin object directly.
                        this.(propName) = object.(propName);
                        
                        % Retain the Description and DetailedDescription
                        d.DetailedDescription = p.Description;
                        d.DetailedDescription = p.DetailedDescription;
                        d.SetObservable = true;
                        
                        % d.Type = prop.Type;  This is not allowed by MCOS
                    else
                        % For properties which exist on multiple objects,
                        % use the multipleValueCombinationMode setting to
                        % determine what value to store
                        this.(propName) = internal.matlab.inspector.InspectorProxyMixin.getCombinedValue(...
                            this.(propName), object.(propName), ...
                            multipleValueCombinationMode);
                    end
                    
                    if p.SetObservable
                        % Create a listener for observable properties
                        this.PropChangedListeners{...
                            length(this.PropChangedListeners)+1,1} = ...
                            event.proplistener(object, p, 'PostSet', ...
                            @this.multiObjPropChangedCallback);
                    end
                end
            end
        end
        
        % Override the InspectorProxyMixin's setPropertyValue method in
        % order to set the properties on any of the additional ProxyObjects
        % as well.
        function b = setPropertyValue(this, propName, value)
            this.ListenersPaused = true;
            b = true;
            % this will be reinitialized with all of the values, based on
            % the multiple values combination mode
            this.(propName) = [];  
            if ~isempty(this.ProxyObjects)
                % Apply the value to any additional objects as well
                for object = this.ProxyObjects
                    setPropertyValue(object, propName, value);
                    
                    this.(propName) = internal.matlab.inspector.InspectorProxyMixin.getCombinedValue(...
                        this.(propName), object.(propName), ...
                        this.MultipleValueCombinationMode);
                end
            end
            this.ListenersPaused = false;
        end
        
        % Called when a property of one of the InspectorProxyMixin object's
        % properties are changed.  Recomputes the array of values for this
        % array object's properties.
        function multiObjPropChangedCallback(this, es, ~)
            if ~this.ListenersPaused
                propName = es.Name;
                % Set the value on the mixin object for the value which was set
                % Need to recompare values for all properties

                % this will be reinitialized with all of the values, based on
                % the multiple values combination mode
                this.(propName) = [];

                for o = this.ProxyObjects
                    if isprop(o, propName)
                        if isempty(this.(propName))
                            this.(propName) = o.(propName);
                        else
                            this.(propName) = ...
                                internal.matlab.inspector.InspectorProxyMixin.getCombinedValue(...
                                this.(propName), o.(propName), ...
                                this.MultipleValueCombinationMode);
                        end
                    end
                end
            end
        end
    end
end