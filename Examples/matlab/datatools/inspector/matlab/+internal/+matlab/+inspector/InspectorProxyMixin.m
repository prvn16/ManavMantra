classdef (Abstract) InspectorProxyMixin < ...
        dynamicprops & matlab.mixin.CustomDisplay
    
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Inspector Proxy Mixin class.  Classes which wish to provide a custom
    % view in the Property Inspector may extend this mixin, and define the
    % properties that should be displayed.  It acts as a proxy between the
    % original object and the inspector classes which introspect the
    % object.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Hidden = true)
        % Keep a reference to the original object
        OriginalObjects;
        
        % The list of defined groups
        GroupList;
        
        % Property change listeners created
        PropChangedListeners = {};
        
        % Track the property types in a map, since they cannot be set on a
        % dynamic object
        PropertyTypeMap;
        
        NonOrigProperties = {};
        
        Workspace;
        
        PreviousData = {};
        
        % Specifies how to handle properties when multiple objects are
        % selected
        MultiplePropertyCombinationMode@internal.matlab.inspector.MultiplePropertyCombinationMode = ...
            internal.matlab.inspector.MultiplePropertyCombinationMode.FIRST;
        
        % Specifies how to handle values when multiple objects are selected
        MultipleValueCombinationMode@internal.matlab.inspector.MultipleValueCombinationMode = ...
            internal.matlab.inspector.MultipleValueCombinationMode.LAST
        
        InternalPropertySet = false;
        
        CategoricalProperties = {};
        
        AllGroupsExpanded = false;
        
        DeletionListeners = {};
        
        % This is used to create a list of properties which we need to assure
        % are sent to the server as a property change.  Sometimes quick updates
        % in succession can get lost in the periodic comparisons done by the
        % functions called by the timer, and we need to assure the changes get
        % propagated.
        ForcePropertyChange = strings(0);
    end
    
    methods
        % Create a new InspectorProxyMixin instance.
        function this = InspectorProxyMixin(OriginalObject, ...
                multiplePropertyCombinationMode, ...
                multipleValueCombinationMode)
            
            this.OriginalObjects = OriginalObject;
            
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
            
            this.PropertyTypeMap = containers.Map;
            m = metaclass(this);
            p = m.PropertyList;
            
            % Create properties on this class for each of the original
            % object's unique properties.
            for j=1:length(OriginalObject)
                o = OriginalObject(j);
                m = metaclass(o);
                
                if isa(OriginalObject, 'handle')
                    this.DeletionListeners{end+1} = event.listener(o, ...
                        'ObjectBeingDestroyed', @this.deletionCallback);
                    
                    this.PreviousData{j} = ...
                        internal.matlab.inspector.Utils.createStructForObject(...
                        o);
                end
                
                for i = 1:length(p)
                    prop = p(i);
                    
                    % For each property not defined by the one of the inspector
                    % classes themselves
                    if ~contains(prop.DefiningClass.Name, "InspectorProxyMixin")
                        if j == 1 
                            internalProp = addprop(this, [prop.Name '_PI']);
                            internalProp.Hidden = true;
                            
                            if isprop(o, prop.Name)
                                try
                                    % Assign the initial value of the property to that
                                    % of the original object, if they are the same
                                    if isempty(prop.GetMethod)
                                        if isempty(prop.SetMethod)
                                            origObjValue = this.OriginalObjects.(prop.Name);
                                            if ischar(origObjValue) && internal.matlab.inspector.Utils.isEnumeration(prop) %~isempty(enumeration(this.(prop.Name)))
                                                try
                                                    % Although the property we got
                                                    % from the original object
                                                    % above is char, the property
                                                    % type is an enumeration, so we
                                                    % should try to convert it.  If
                                                    % it fails, that's ok too, as
                                                    % many of the HG properties
                                                    % accept char values
                                                    origObjValue = eval([internal.matlab.inspector.Utils.getPropDataType(prop) '.' origObjValue]);
                                                catch
                                                end
                                            end
                                            
                                            this.(prop.Name) = origObjValue;
                                        end
                                        
                                        if strcmp(internal.matlab.inspector.Utils.getPropDataType(prop), 'categorical')
                                            % Save list of categorical properties for
                                            % comparison later, to check when categories
                                            % are added or removed
                                            this.CategoricalProperties{end+1} = prop.Name;
                                        end
                                        
                                        this.([prop.Name '_PI']) = origObjValue;
                                    else
                                        internalProp.GetMethod = prop.GetMethod;
                                    end
                                catch
                                    % Its possible the types are different
                                    % (redefining a string as an enumerated value,
                                    % for example).  Don't worry about setting the
                                    % value and assume its done already
                                end
                                
                                % Assign a PostSet listener to the original
                                % object, so that the values can be kept in sync
                                originalProp = findprop(o, ...
                                    prop.Name);
                                if originalProp.SetObservable
                                    this.PropChangedListeners{...
                                        length(this.PropChangedListeners)+1,1} = ...
                                        event.proplistener(o, ...
                                        originalProp, 'PostSet', ...
                                        @this.propChangedCallback);
                                end
                                
                                if j == 1
                                    if ~isequal(internal.matlab.inspector.Utils.getPropDataType(prop), 'any')
                                        % The mixin class has redefined a property type
                                        % to be more restrictive/different than the
                                        % original type (for example, the original type
                                        % may be text while the new type is an
                                        % enumeration), so use this definition
                                        this.PropertyTypeMap(prop.Name) = internal.matlab.inspector.Utils.getProp(prop);
                                    else
                                        % Otherwise, use the original property's type
                                        % definition
                                        this.PropertyTypeMap(prop.Name) = ...
                                            internal.matlab.inspector.Utils.getProp(originalProp);
                                    end
                                end
                            else
                                this.NonOrigProperties{end+1} = prop.Name;
                                this.PropertyTypeMap(prop.Name) = internal.matlab.inspector.Utils.getProp(prop);
                                internalProp.GetMethod = @(this)this.(prop.Name);
                            end
                        else
                            if isprop(o, prop.Name)
                                % For properties which exist on multiple
                                % objects, use the multipleValueCombinationMode
                                % setting to determine what value to store
                                this.InternalPropertySet = true;
                                this.(prop.Name) = ...
                                    internal.matlab.inspector.InspectorProxyMixin.getResolvedValueToApply(...
                                    prop, internal.matlab.inspector.InspectorProxyMixin.getCombinedValue(...
                                    this.(prop.Name), o.(prop.Name), this.MultipleValueCombinationMode));
                                this.InternalPropertySet = false;
                                
                                % Assign a PostSet listener to the original
                                % object, so that the values can be kept in sync
                                originalProp = findprop(o, prop.Name);
                                if originalProp.SetObservable
                                    this.PropChangedListeners{end+1,1} = ...
                                        event.proplistener(o, originalProp, 'PostSet', ...
                                        @this.propChangedCallback);
                                end

                            end
                        end
                    end
                end
            end
        end
        
        function delete(this)
            % Remove any Property Changed listeners which have been added
            if ~isempty(this.PropChangedListeners)
                cellfun(@(x) delete(x), this.PropChangedListeners);
                this.PropChangedListeners = {};
            end
            
            if ~isempty(this.DeletionListeners)
                cellfun(@(x) delete(x), this.DeletionListeners);
            end
            this.DeletionListeners = {};
        end
        
        function propChangedCallback(this, es, ~)
            % Handle this event by forwarding the setProperty call to the
            % original object
            propName = es.Name;
            isInternalPropSet = this.InternalPropertySet;
            
            this.InternalPropertySet = true;
            setPropertyValueInternal(this, propName, ...
                this.OriginalObjects.(propName));
            this.InternalPropertySet = isInternalPropSet;
            
            if ~this.InternalPropertySet
                % Force notification of this property change to the server
                this.ForcePropertyChange(end+1) = propName;
                this.ForcePropertyChange = unique(this.ForcePropertyChange);
            end
        end
        
        % Returns the property value.  It first tries to access the value
        % directly.  If the result is empty, it checks to see if the
        % OriginalObject has the property value set.
        function val = getPropertyValue(this, propertyName)
            try
                % Should be able to access the property directly
                val = this.(propertyName);
            catch e
                rethrow(e);
            end
        end
        
        % Returns the property value.  Uses the getPropertyValue method to
        % check for direct access, and if not, access through the original
        % object.
        function val = get(this, propertyName)
            val = getPropertyValue(this, propertyName);
        end
        
        % Set the property value.  This is called when a property change is
        % observed on the original object, so that the proxy object can be
        % similarly updated.  Arguments are:
        %   - Property Name
        %   - Property value.  There should be as many property values as there
        %   are objects.  So for an array of three objects, there will be three
        %   property values.
        function status = setPropertyValueInternal(this, varargin)
            status = '';
            propertyName = varargin{1};
            origValue = this.(propertyName);

            for i = 1:length(this.OriginalObjects)
                value = varargin{1 + i};
                origPropValue = value;
                
                % Set the property value 
                [status, prop] = this.setPropValueOnProxyAndObject(this.OriginalObjects(i), ...
                    propertyName, value, origPropValue);
                if ~isempty(status)
                    break;
                end
            end

            if ~isempty(status)
                % revert value
                if isempty(prop)
                    this.(propertyName) = origValue;
                else
                    this.(propertyName) = internal.matlab.inspector.InspectorProxyMixin.getResolvedValueToApply(...
                        prop, origValue);
                end
            end
        end
        
        % Set the property value.  This is called when setting properties from
        % the inspector UI.  Necessary arguments are:
        %   Property Name - the property name to set
        %   Value - the property value to set
        %
        % Optional arguments to support value objects are:
        %   DisplayValue - the display value of the value to bet set
        %   Variable Name - the Variable Name
        function status = setPropertyValue(this, varargin)
            status = '';
            propertyName = varargin{1};
            value = varargin{2};
            origValue = this.(propertyName);

            for i = 1:length(this.OriginalObjects)
                origPropValue = value;
                
                % Set the property value 
                [status, prop] = this.setPropValueOnProxyAndObject(this.OriginalObjects(i), ...
                    propertyName, value, origPropValue);
                if ~isempty(status)
                    break;
                end
            end

            if ~isempty(status)
                % revert value
                if isempty(prop)
                    this.(propertyName) = origValue;
                else
                    this.(propertyName) = internal.matlab.inspector.InspectorProxyMixin.getResolvedValueToApply(...
                        prop, origValue);
                end
            end
        end
        
        % Called by setPropertyValue and setPropertyValueInternal to apply the
        % property value to the propertyName of the proxy object, and possibly
        % the original object (if this wasn't an internal property set)
        function [status, prop] = setPropValueOnProxyAndObject(this, obj, propertyName, value, origPropValue)
            % Temporariliy change some warnings to errors so that the
            % normal inspector error handling path will be followed.
            w = internal.matlab.inspector.InspectorProxyMixin.disableWarnings(class(obj));
            status = [];

            try
                prop = findprop(this, propertyName);
                
                % Use the resolved value, which may be an enumeration or
                % class value instead of a string, as the value to apply to
                % the object
                value = internal.matlab.inspector.InspectorProxyMixin.getResolvedValueToApply(...
                    prop, value);
                
                if strcmp(prop.SetAccess, 'public')
                    % Assign the proxy class value of the property to the
                    % new value
                    this.(propertyName) = value;
                end
                
                % Pass through to the original object if there is no setter
                % and if this isn't an InternalPropertySet
                if isempty(prop.SetMethod) && ~this.InternalPropertySet
                    status = this.setOriginalPropValue(propertyName, origPropValue);
                end
            catch ex
                status = ex.message;
                prop = [];
            end
            
            % Revert warning state
            if ~isempty(w)
                warning(w);
            end
        end

        function status = setOriginalPropValue(this, propertyName, value)
            status = '';
            try
                if ~this.InternalPropertySet
                    % If we are doing an internal property set (usually on
                    % object creation), then don't set the original
                    % object's values
                    for i = 1:length(this.OriginalObjects)
                        if isprop(this.OriginalObjects(i), propertyName)
                            this.OriginalObjects(i).(propertyName) = value;
                        end
                    end
                end
            catch ex
                status = ex.message;
                try
                    if ~ischar(value) && ~isempty(enumeration(this.(propertyName)))
                        % We are applying an enumeration to the property
                        % type, but it may need to be a char value instead.
                        % Retry as a char and clear the error status if
                        % this succeeds.
                        this.OriginalObjects(i).(propertyName) = char(value);
                        status = '';
                    end
                catch
                end
            end
        end
        
        function updateInternalPropValue(this, propertyName, value, setMethod)
            if nargin<4 || isempty(setMethod)
                setMethod = @this.setOriginalPropValue;
            end
            
            try
                % Does a property inspector internal property exist?  If
                % so, set this value as well
                if isprop(this, [propertyName '_PI'])
                    this.([propertyName '_PI']) = value;
                end
                
                setMethod(this, propertyName, value);
            catch
            end
        end
        
        function set(this, propertyName, value)
            setPropertyValue(this, propertyName, value);
        end
        
        % Called to create an InspectorGroup.  Group ID, title, and
        % description must be specified.  Returns an InspectorGroup object,
        % which can have property names added to it.
        function group = createGroup(this, groupID, groupTitle, ...
                groupDescription)
            group = [];
            if ~isempty(this.GroupList)
                % Check to see if the group with the specified groupID has
                % already been created, and if it has, return it.
                idx = strcmp({this.GroupList.GroupID}, groupID);
                if any(idx)
                    group = this.GroupList(idx);
                end
            end
            
            if isempty(group)
                % Create new group
                group = internal.matlab.inspector.InspectorGroup(...
                    groupID,...
                    groupTitle,...
                    groupDescription);
                if this.AllGroupsExpanded
                    group.Expanded = true;
                end
                
                % Store all created groups in an array
                if isempty(this.GroupList)
                    this.GroupList = group;
                else
                    this.GroupList = [this.GroupList group];
                end
            end
        end
        
        % Return an array of groups which have been created
        function groups = getGroups(this)
            groups = this.GroupList;
        end
        
        % Sets all groups to be expanded
        function expandAllGroups(this)
            this.AllGroupsExpanded = true;
            for i = 1:length(this.GroupList)
                g = this.GroupList(i);
                g.Expanded = true;
            end
        end
        
        function setWorkspace(this, workspace)
            this.Workspace = workspace;
        end
        
        function [changed, changedProperties, changedProxyProperties] = ...
                OrigObjectChange(this)
            % Called to determine if any of the properties of the original
            % objects that this is the proxy for have changed.  Ideally, if
            % all properties are setObservable=true, there would never be a
            % difference.  However, for setObservable=false properties, its
            % possible that they can get out of sync.
            changed = false;
            numPropsChanged = false;
            changedProperties = {};
            changedProxyProperties = {};
            
            combinedValues = [];
            for i=1:length(this.OriginalObjects)
                % Compare against a struct of the original object
                % (necessary for handle objects)
                if ~isa(this.OriginalObjects(i), 'handle') || ...
                        (isa(this.OriginalObjects(i), 'handle') && ...
                        isvalid(this.OriginalObjects(i)))
                    
                    currObjStruct = ...
                        internal.matlab.inspector.Utils.createStructForObject(...
                        this.OriginalObjects(i));
                    origObjProps = fieldnames(currObjStruct);
                    if i <= length(this.PreviousData)
                        prevDataProps = fieldnames(this.PreviousData{i});
                    else
                        prevDataProps = [];
                    end
                    
                    if isequal(sort(origObjProps), sort(prevDataProps))
                        % Check to see which specific properties have changed
                        changedIdx = cellfun(@(x) ~isequaln(...
                            currObjStruct.(x), this.PreviousData{i}.(x)), ...
                            origObjProps);
                        if any(changedIdx)
                            
                            currChangedProperties = origObjProps(changedIdx);
                            realChanges = true(size(currChangedProperties));
                            
                            for j = 1:length(currChangedProperties)
                                currProp = currObjStruct.(currChangedProperties{j});
                                prevProp = this.PreviousData{i}.(currChangedProperties{j});
                                try
                                    if isequaln(currProp, (prevProp)')
                                        % This is just a transpose -- don't
                                        % consider it a change
                                        realChanges(j) = false;
                                    elseif ischar(currProp) && ...
                                            isequaln(currProp, char(prevProp))
                                        % If one of the property values is
                                        % char, and the other is an enum, but
                                        % they are the same, then don't
                                        % consider this a real change to the
                                        % property.
                                        realChanges(j) = false;
                                    elseif internal.matlab.inspector.InspectorProxyMixin.isSmallNumericChange(currProp, prevProp)
                                        % These are non-empty numeric values
                                        % and the difference is miniscule
                                        realChanges(j) = false;
                                    end
                                catch
                                    % Ignore these errors... some property
                                    % types may fail on one of these
                                    % conditions, but that's ok -- just
                                    % consider it a real change in value
                                end
                            end
                            
                            currChangedProperties(~realChanges) = [];
                            %                             if isempty(changedProperties)
                            %                                 changed = false;
                            %                             end
                            
                            % Update the list of changed properties
                            changedProperties = unique(vertcat(changedProperties, ...
                                currChangedProperties), 'stable');
                            changed = true;
                        end
                        
                        if ~isempty(this.CategoricalProperties)
                            % Compare the categories for any categorical
                            % variables
                            categoryChanges = cellfun(@(x) ...
                                ~isequal(categories(currObjStruct.(x)), ...
                                categories(this.PreviousData{i}.((x)))), ...
                                this.CategoricalProperties);
                            if any(categoryChanges)
                                % Update the list of changed properties
                                changedProperties = unique(vertcat(changedProperties, ...
                                    this.CategoricalProperties(categoryChanges)), ...
                                    'stable');
                                changed = true;
                            end
                        end
                        
                        % Limit the changed properties to those properties
                        % which exist on the view object itself
                        thisProperties = properties(this);
                        changedProperties = intersect(changedProperties, thisProperties);
                        
                        if isempty(combinedValues)
                            % The first time through the objects, the combined
                            % values is the object's values, since there's only
                            % one object so far
                            combinedValues = currObjStruct;
                        else
                            % The next time through the objects, combine the
                            % values with the previously determined values, if
                            % the previous value exists.  (When inspecting
                            % multiple objects, its possible they have different
                            % properties and the value may not exist)
                            objFields = fieldnames(currObjStruct);
                            for j=1:length(objFields)
                                propToCombine = objFields{j};
                                if ~isfield(combinedValues, propToCombine)
                                    % This property doesn't exist in the
                                    % combined values yet (due to inspecting
                                    % multiple different objects), just take the
                                    % value
                                    combinedValues.(propToCombine) = currObjStruct.(propToCombine);
                                else
                                    % Combine the property values based on the
                                    % current combination mode
                                    combinedValues.(propToCombine) = ...
                                        internal.matlab.inspector.InspectorProxyMixin.getCombinedValue(...
                                        combinedValues.(propToCombine), currObjStruct.(propToCombine), ...
                                        this.MultipleValueCombinationMode);
                                end
                            end
                        end
                    else
                        numPropsChanged = true;
                        changed = true;
                        changedProperties = unique(vertcat(...
                            changedProperties, ...
                            setdiff(origObjProps, prevDataProps)), ...
                            'stable');
                        
                        if length(origObjProps) > length(prevDataProps)
                            % Property was added to the original object,
                            % need to add it to the proxy as well
                            for c = 1:length(changedProperties)
                                this.addPropertyToProxy(changedProperties{c});
                            end
                        else
                            % Property was removed
                        end
                    end
                end
                
                if changed && ~isempty(this.NonOrigProperties)
                    changedProperties = unique(vertcat(...
                        changedProperties(:), ...
                        this.NonOrigProperties(:)), ...
                        'stable');
                    changedProxyProperties = unique(vertcat(...
                        changedProxyProperties(:), ...
                        this.NonOrigProperties(:)), ...
                        'stable');
                end
            end
            
            if ~isempty(combinedValues)
                objFields = fieldnames(combinedValues);
                % Look for real changes, not counting differences between
                % an enumeration and char of the same value or other
                % similarly equal conditions between the proxy's current
                % value and the new combined value.
                changedIdx = false(size(objFields));
                for k = 1:length(objFields)
                    change = false;
                    x = objFields{k};
                    if isprop(this, x)
                        try
                            if ~isequaln(combinedValues.(x), this.(x))
                                change = true;
                                
                                if iscell(this.(x)) && isequaln(combinedValues.(x), this.(x)')
                                    % cell comparison transposed
                                    change = false;
                                elseif ischar(combinedValues.(x)) && isequaln(combinedValues.(x), char(this.(x)))
                                    % char vs enum comparison
                                    change = false;
                                elseif isobject(this.(x)) && isequal(size(combinedValues.(x)), size(this.(x)))
                                    % handle object comparison via size
                                    change = false;
                                elseif isnumeric(this.(x)) && internal.matlab.inspector.InspectorProxyMixin.isSmallNumericChange(combinedValues.(x), this.(x))
                                    change = false;
                                end
                            end
                        catch
                            change = false;
                        end
                    end
                    
                    changedIdx(k) = change;
                end
                changedProxyProperties = unique(vertcat(changedProxyProperties, ...
                    objFields(changedIdx)), 'stable');
                changed = true;
            end
            
            % Limit the list of changed properties to those which are
            % currently displayed
            propertyList = this.getPropertyListForMode(this.OriginalObjects, ...
                this.MultiplePropertyCombinationMode);
            changedProperties = intersect(propertyList, changedProperties);
            
            % If any proxy properties changed, which are the same as the
            % changed properties, just report the property in the changed
            % property list
            if ~isempty(this.NonOrigProperties)
                changedProxyProperties = intersect(propertyList, changedProxyProperties);
                overlaps = ismember(changedProxyProperties, changedProperties);
                changedProxyProperties(overlaps) = [];
            else
                % There's no need to report any changed proxy properties if the
                % original objects and the proxy objects have the same set. This
                % is only needed for objects which redefine the properties
                changedProxyProperties = [];
            end
            
            if ~isempty(this.ForcePropertyChange)
                % There are properties which we need to notify the server of a
                % change.  These may differ because they changed very quickly
                % (in between the periodic checks done on a timer)
                if isempty(changedProperties)
                    changedProperties = cellstr(this.ForcePropertyChange);
                elseif ~contains(changedProperties, this.ForcePropertyChange)
                    c = cellstr(this.ForcePropertyChange);                    
                    changedProperties = unique([changedProperties(:); c(:)]);
                end
                changed = true;
                
                % Reset the list since we are notifying the server via the
                % return value of this function
                this.ForcePropertyChange = strings(0);
            end
            
            if isempty(changedProperties) && isempty(changedProxyProperties) && ~numPropsChanged
                changed = false;
            end

        end
        
        function reinitializeFromOrigObject(this, changedProperties, ...
                changedProxyProperties)
            % Called to reinitialize the properties of the proxy from the
            % original object.  This is necessary because properties which
            % are SetObservable=false, they can get out of sync with the
            % original object.  changeProperties is a list of properties to
            % reinitialize.
            propertyList = this.getPropertyListForMode(this.OriginalObjects, ...
                this.MultiplePropertyCombinationMode);
            propChangedList = unique(union(changedProperties, changedProxyProperties));
            for j=1:length(propChangedList)
                propName = propChangedList{j};

                isProp = false;
                combinedVal = [];
                
                for i=1:length(this.OriginalObjects)
                    o = this.OriginalObjects(i);
                    
                    % Take the object's property value - it was
                    % updated, but the proxy hasn't been updated
                    % yet
                    try
                        propValue = o.(propName);
                    catch
                        % Typically this won't fail, but it can
                        % sometimes with dependent properties that
                        % become invalid.  Set to empty in this
                        % case.
                        propValue = [];
                    end
                    
                    % Make sure the property being reported as changed is
                    % actually one of the properties which we are
                    % currently displaying (also private properties may
                    % show up as changed, which we don't care about)
                    if ismember(propName, propertyList)
                        isProp = true;
                        if ismember(propName, changedProperties)
                            % Try to resolve the propValue as text into any
                            % enumeration or class types if possible
                            prop = findprop(this, propName);
                            resolvedPropValue = internal.matlab.inspector.InspectorProxyMixin.getResolvedValueToApply(...
                                prop, propValue);
                            
                            combinedVal = ...
                                internal.matlab.inspector.InspectorProxyMixin.getCombinedValue(...
                                combinedVal, resolvedPropValue, ...
                                this.MultipleValueCombinationMode);
                            if strcmp(prop.SetAccess, 'public') && i == length(this.OriginalObjects)
                                % For object arrays, only set on the last of the
                                % original objects, because this is when we have
                                % the combinedValue properly
                                this.InternalPropertySet = true;
                                if length(this.OriginalObjects) == 1
                                    % Use the resolved property value
                                    this.(propName) = resolvedPropValue;
                                else
                                    try
                                        % we have a set method
                                        this.(propName) = combinedVal;
                                    catch e
                                    end
                                end
                                this.InternalPropertySet = false;
                            end
                        else
                            % Take the proxy's property value - it must
                            % have changed to be different from the
                            % original object
                            thisPropValue = this.(propName);
                            combinedVal = ...
                                internal.matlab.inspector.InspectorProxyMixin.getCombinedValue(...
                                combinedVal, thisPropValue, ...
                                this.MultipleValueCombinationMode);
                            
                            prop = findprop(this, propName);
                            
                            % pass through if no setter
                            if isempty(prop.SetMethod) && strcmp(prop.SetAccess, 'public')
                                origProp = findprop(o, propName);
                                if isempty(origProp) || origProp.SetAccess == "public"
                                    o.(propName) = thisPropValue;
                                end
                            end
                            
                            if strcmp(prop.SetAccess, 'public')
                                % we have a set method                                          
                                % if the property is of a special type,
                                % wrap the value in that type before
                                % setting it                                
                               this.(propName) = internal.matlab.inspector.InspectorProxyMixin.getResolvedValueToApply(prop,thisPropValue);                     
                            end
                        end
                        
                        % Update the struct version of the data as well
                        this.PreviousData{i}.(propName) = propValue;
                    end
                end
                
                if isProp
                    % If a property was dynamically added to the object,
                    % we need to also add it to the proxy object
                    this.addPropertyToProxy(propName);
                    
                    if isprop(this, [propName '_PI'])
                        this.InternalPropertySet = true;
                        this.([propName '_PI']) = combinedVal;
                        this.InternalPropertySet = false;
                    else
                        this.(propName) = combinedVal;
                    end
                end
            end
        end
    end
    
    methods (Access = protected)
        % Override the displayScalarObject method so that a disp of an
        % InspectorProxyMixin will only show the properties defined by the
        % class which extends the mixin.
        function displayScalarObject(this)
            header = getHeader(this);
            disp(header);
            
            props = properties(this);
            try
                values = cellfun(@(x) this.(x), props, ...
                    'UniformOutput', false);
            catch
                try
                    values = cellfun(@(x) this.OriginalObjects.(x), props, ...
                        'UniformOutput', false);
                catch
                    values = repmat(' ', length(props), 1);
                end
            end
            if ~iscell(values)
                values = {values};
            end
            s = cell2struct(values, props, 1);
            disp(s);
        end
        
        % Returns a list of the names of the Public, non-hidden properties
        % for the given object obj.
        function propertyList = getPublicNonHiddenProps(~, obj)
            propertyList = properties(obj);
        end
        
        % Returns a list of property names for the properties in the list
        % of objects (objectList), based on the
        % multiplePropertyCombinationMode parameter.  This will be either
        % the union of properties, the intersection of properties, the
        % properties from the first object, or the properties from the last
        % object.
        function propertyList = getPropertyListForMode(this, objectList, ...
                multiplePropertyCombinationMode)
            if multiplePropertyCombinationMode == "UNION"
                propertyList = {};
                for i = 1:length(objectList)
                    p = this.getPublicNonHiddenProps(...
                        objectList(i));
                    propertyList = union(propertyList, p, 'stable');
                end
                
            elseif multiplePropertyCombinationMode == "INTERSECTION"
                propertyList = {};
                for i = 1:length(objectList)
                    p = this.getPublicNonHiddenProps(...
                        objectList(i));
                    if isempty(propertyList)
                        propertyList = p;
                    else
                        propertyList = intersect(propertyList, p, ...
                            'stable');
                    end
                end
                
            elseif multiplePropertyCombinationMode == "FIRST"
                propertyList = this.getPublicNonHiddenProps(...
                    objectList(1));
                
            elseif multiplePropertyCombinationMode == "LAST"
                propertyList = this.getPublicNonHiddenProps(...
                    objectList(end));
            end
        end
        
        function propertyAdded = addPropertyToProxy(this, propertyName)
            % Add a new property to the proxy. This is necessary when a new
            % property is dynamically added to the original object.
            propertyAdded = false;
            if ~isprop(this, propertyName)
                addprop(this, propertyName);
                propertyAdded = true;
            end
        end
        
        function deletionCallback(this, varargin)
            % Called when the object that this is the proxy object for is
            % deleted.  If this is the only object, then the proxy should
            % be deleted as well.
            if length(this.OriginalObjects) == 1
                delete(this);
            end
        end
    end
    
    methods (Static)
        % Returns the combined value for the current value and new value of
        % a property, based on the multipleValueCombinationMode parameter,
        % which can be all, blank, first or last.
        function value = getCombinedValue(currValue, newValue, ...
                multipleValueCombinationMode)
            if multipleValueCombinationMode == "ALL"
                % Combine property values into arrays for those
                % properties which exist in multiple objects
                if isempty(currValue) || isequal(currValue, newValue)
                    % If there's only one value, or if the new value is
                    % equal to the old value, just use it
                    value = newValue;
                else
                    if ~isempty(currValue) && (ischar(currValue) || ...
                            ~isscalar(currValue))
                        if iscell(currValue)
                            currValue{end+1} = newValue;
                            value = currValue;
                        elseif isnumeric(currValue)
                            value = [currValue newValue];
                        else
                            value = {currValue newValue};
                        end
                    else
                        value = [currValue newValue];
                    end
                end
            elseif multipleValueCombinationMode == "BLANK"
                if isempty(currValue) || isequal(currValue, newValue)
                    % If there's only one value, or if the new value is
                    % equal to the old value, just keep it
                    value = newValue;
                else
                    % Otherwise, the value should be blank (empty)
                    value = [];
                end
                
            elseif multipleValueCombinationMode == "FIRST"
                % Value should always be the first value found for the
                % property
                value = currValue;
                
            elseif multipleValueCombinationMode == "LAST"
                % Value should come from the current object
                % (overwriting the previous value)
                value = newValue;
            end
        end
        
        function w = disableWarnings(clsName)
            % Use the warning function to temporarily change a warning
            % to an error, so that the normal error handling path
            % will be followed.
            if contains(clsName, ".")
                s = split(clsName, ".");
                if strlength(s(1)) > 0 && strlength(s(end)) > 0
                    warnmsg = "MATLAB:ui:" + s(end) + ":";
                    w(1) = warning('error', char(warnmsg + "noSizeChangeForRequestedWidth")); %#ok<*CTPCT>
                    w(2) = warning('error', char(warnmsg + "noSizeChangeForRequestedHeight"));
                    w(3) = warning('error', char(warnmsg + "fixedWidth"));
                    w(4) = warning('error', char(warnmsg + "fixedHeight"));
                else
                    w = [];
                end
            else
                w = [];
            end
        end
        
        % Tries to convert a text object to an enumeration or class when it
        % is specified as such in the prop metadata
        function value = getResolvedValueToApply(prop, value)
            if ~isequal(prop.Type.Name, 'any') && ...
                    ~contains(prop.Type.Name, " ") && ...
                    ~isa(value, prop.Type.Name) && ...
                    ~any([internal.matlab.variableeditor.NumericArrayDataModel.NumericTypes, ...
                    "struct", "table", "timetable", "cell", "datetime", ...
                    "duration", "calendarDuration", "char", "string", "categorical"] == prop.Type.Name)
                % Try to convert the value to an actual class if the type
                % isn't 'any', doesn't contain any spaces (like 'double
                % property'), isn't a well known data type, and isn't
                % already a class of that type
                l = lasterror; %#ok<LERR>
                try
                    value = feval(prop.Type.Name, value);
                catch
                end
                lasterror(l); %#ok<LERR>
            end
        end
        
        % set the property value
        function [status, value] = staticSetPropertyValue(obj, propertyName, value)
            status = '';
            origValue = obj.(propertyName);
            
            % Temporariliy change some warnings to errors so that the
            % normal inspector error handling path will be followed.
            w = internal.matlab.inspector.InspectorProxyMixin.disableWarnings(class(obj));
            
            try
                prop = findprop(obj, propertyName);
                
                % Use the resolved value, which may be an enumeration or
                % class value instead of a string, as the value to apply to
                % the object
                value = internal.matlab.inspector.InspectorProxyMixin.getResolvedValueToApply(...
                    prop, value);
                
                if strcmp(prop.SetAccess, 'public')
                    for i = 1:length(obj)
                        obj(i).(propertyName) = value;
                    end
                end
            catch ex
                status = ex.message;
            end
            
            % Revert warning state
            if ~isempty(w)
                warning(w);
            end
            
            if ~isempty(status)
                % revert value
                obj.(propertyName) = internal.matlab.inspector.InspectorProxyMixin.getResolvedValueToApply(...
                    prop, origValue);
            end
        end
        
        function b = isSmallNumericChange(val1, val2)
            b = isnumeric(val1) && ~isempty(val1) && ...
                isnumeric(val2) && ~isempty(val2) && ...
                isequal(size(val1), size(val2)) && ...
                all(all(abs(val1 - val2) < 1e4*eps(min(abs(val1), abs(val2)))));
        end
    end
end
