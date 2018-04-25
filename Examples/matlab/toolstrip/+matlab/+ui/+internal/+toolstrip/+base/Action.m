classdef Action < handle & dynamicprops & matlab.ui.internal.toolstrip.base.PeerInterface
    % Action Class
    %
    % Action objects are used in toolstrip components to share common data
    % and common actions in response to events.
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.Action">Action</a>
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.Description">Description</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.Enabled">Enabled</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.Shortcut">Shortcut</a>
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.addProperty">addProperty</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.addCallbackFcn">addCallbackFcn</a>
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.ActionPerformed">ActionPerformed</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.ActionPropertySet">ActionPropertySet</a>
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, Access = public)
        % Property "Description":
        %
        %   The description of a control, displayed when mouse is hoving over.
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       action.Description = 'Submit Button'
        Description
        % Property "Enabled":
        %
        %   The enabling status of a control.
        %   It is a logical and the default value is true.
        %   It is writable.
        %
        %   Example:
        %       action.Enabled = false
        Enabled
        % Property "Shortcut":
        %
        %   The shortcut key of an action
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       action.Shortcut = 'S'
        Shortcut
    end
    
    properties (Access = protected)
        % common properties
        DescriptionPrivate = ''
        EnabledPrivate = true
        ShortcutPrivate = ''
        % optional properties
        % char
        TextPrivate = ''
        LabelPrivate = ''
        PlaceholderTextPrivate = ''
        SelectionModePrivate = 'single'
        SelectedItemPrivate = ''
        NumberFormatPrivate = 'integer'
        % numbers
        ValuePrivate = 50
        MinimumPrivate = 0
        MaximumPrivate = 100
        MinorStepSizePrivate = 1
        MajorStepSizePrivate = 10
        StepsPrivate = 100
        TicksPrivate = 11
        % boolean
        SelectedPrivate = false
        EditablePrivate = false
        IsFavoritePrivate = false
        IsInQuickAccessPrivate = false
        % Nx1 cell array
        SelectedItemsPrivate = {}
        LabelsPrivate = {}
        LocationsPrivate = []
        % Nx2 cell array
        ItemsPrivate = {}
        % icon
        IconPrivate = []
        IconJavaScript = ''
        IconSwing = ''
        QuickAccessIconPrivate = []
        QuickAccessIconJavaScript = ''
        QuickAccessIconSwing = ''
        % others
        PopupPrivate = []
        DynamicPopupFcnPrivate = []
        HasDynamicPopup = false
        ButtonGroupPrivate = []
        % track all properties
        MCOSProperties = {'DescriptionPrivate';'EnabledPrivate';'ShortcutPrivate'}
        PeerProperties = {'description';'enabled';'shortcut'}
    end
    
    %% -----------  User-invisible properties --------------------
    properties (Access = protected)
        Type = 'Action';
    end
    
    properties (Hidden, SetAccess = private)
        % Property "Id":
        %
        %   The name of an action.  It is a string and the value is
        %   automatically generated . It is read only.
        Id
    end
    
    events
        % General event when an action is performed.
        ActionPerformed
        % ActionPropertySet events
        ActionPropertySet
    end
    
    methods
        
        %% constructor
        function this = Action()
        end
        
        %% overload delete
        function delete(this)
            this.destroyPeer();
        end
        
        %% Get/Set methods
        % Enabled
        function value = get.Enabled(this)
            % GET function for Enabled property.
            value = this.EnabledPrivate;
        end
        function set.Enabled(this, value)
            % SET function for Enabled property.
            OK = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'logical');
            if OK
                this.EnabledPrivate = value;
                this.setPeerProperty('enabled',value);
            else
                error(message('MATLAB:toolstrip:control:invalidLogicalProperty', 'Enabled'))
            end
        end
        % Description
        function value = get.Description(this)
            % GET function for Description property.
            value = this.DescriptionPrivate;
        end
        function set.Description(this, value)
            % SET function for Description property.
            [OK, value] = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'string');
            if OK
                this.DescriptionPrivate = value;
                this.setPeerProperty('description',value);
            else
                error(message('MATLAB:toolstrip:control:invalidCharProperty', 'Description'))
            end
            
        end
        % Shortcut
        function value = get.Shortcut(this)
            % GET function for Shortcut property.
            value = this.ShortcutPrivate;
        end
        function set.Shortcut(this, value)
            % SET function for Shortcut property.
            [OK, value] = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'string');
            if OK
                this.ShortcutPrivate = value;
                this.setPeerProperty('shortcut',value);
            else
                error(message('MATLAB:toolstrip:control:invalidCharProperty', 'Shortcut'))
            end
        end
        
        %% Add dynamic properties
        function addProperty(this, name)
            % Method "addProperty":
            %
            %   "addProperty(action, prop)": adds a dynamic property to the
            %   action object.
            %
            %   Example:
            %       action = matlab.ui.internal.toolstrip.base.Action();
            %       action.addProperty('Text')
            %       action.addProperty('Icon')
            %       label = matlab.ui.internal.toolstrip.Label(action)
            switch name
                % char
                case 'Text'
                    prop = this.addprop('Text');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'TextPrivate');
                    prop.SetMethod = @(this, data) setCharProperty(this, 'TextPrivate', 'text', data);
                    this.MCOSProperties = [this.MCOSProperties; {'TextPrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'text'}];
                case 'Label'
                    prop = this.addprop('Label');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'LabelPrivate');
                    prop.SetMethod = @(this, data) setCharProperty(this, 'LabelPrivate', 'label', data);
                    this.MCOSProperties = [this.MCOSProperties; {'LabelPrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'label'}];
                case 'PlaceholderText'
                    prop = this.addprop('PlaceholderText');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'PlaceholderTextPrivate');
                    prop.SetMethod = @(this, data) setCharProperty(this, 'PlaceholderTextPrivate', 'placeholderText', data);
                    this.MCOSProperties = [this.MCOSProperties; {'PlaceholderTextPrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'placeholderText'}];
                case 'SelectionMode'
                    prop = this.addprop('SelectionMode');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'SelectionModePrivate');
                    prop.SetMethod = @(this, data) setSelectionModeProperty(this, data);
                    this.MCOSProperties = [this.MCOSProperties; {'SelectionModePrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'selectionMode'}];
                case 'SelectedItem'
                    prop = this.addprop('SelectedItem');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'SelectedItemPrivate');
                    prop.SetMethod = @(this, data) setSelectedItemProperty(this, data);
                    this.MCOSProperties = [this.MCOSProperties; {'SelectedItemPrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'selectedItem'}];
                    % numeric
                case 'Value'
                    prop = this.addprop('Value');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'ValuePrivate');
                    prop.SetMethod = @(this, data) setRealProperty(this, 'ValuePrivate', 'value', data);
                    this.MCOSProperties = [this.MCOSProperties; {'ValuePrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'value'}];
                case 'Minimum'
                    prop = this.addprop('Minimum');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'MinimumPrivate');
                    prop.SetMethod = @(this, data) setRealProperty(this, 'MinimumPrivate', 'minimum', data);
                    this.MCOSProperties = [this.MCOSProperties; {'MinimumPrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'minimum'}];
                case 'Maximum'
                    prop = this.addprop('Maximum');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'MaximumPrivate');
                    prop.SetMethod = @(this, data) setRealProperty(this, 'MaximumPrivate', 'maximum', data);
                    this.MCOSProperties = [this.MCOSProperties; {'MaximumPrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'maximum'}];
                case 'MinorStepSize'
                    prop = this.addprop('MinorStepSize');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'MinorStepSizePrivate');
                    prop.SetMethod = @(this, data) setRealProperty(this, 'MinorStepSizePrivate', 'minorStepSize', data);
                    this.MCOSProperties = [this.MCOSProperties; {'MinorStepSizePrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'minorStepSize'}];
                case 'MajorStepSize'
                    prop = this.addprop('MajorStepSize');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'MajorStepSizePrivate');
                    prop.SetMethod = @(this, data) setRealProperty(this, 'MajorStepSizePrivate', 'majorStepSize', data);
                    this.MCOSProperties = [this.MCOSProperties; {'MajorStepSizePrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'majorStepSize'}];
                case 'NumberFormat'
                    prop = this.addprop('NumberFormat');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'NumberFormatPrivate');
                    prop.SetMethod = @(this, data) setNumberFormatProperty(this, data);
                    this.MCOSProperties = [this.MCOSProperties; {'NumberFormatPrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'numberFormat'}];
                case 'Steps'
                    prop = this.addprop('Steps');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'StepsPrivate');
                    prop.SetMethod = @(this, data) setIntegerProperty(this, 'StepsPrivate', 'steps', data);
                    this.MCOSProperties = [this.MCOSProperties; {'StepsPrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'steps'}];
                case 'Ticks'
                    prop = this.addprop('Ticks');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'TicksPrivate');
                    prop.SetMethod = @(this, data) setIntegerProperty(this, 'TicksPrivate', 'numberOfTicks', data);
                    this.MCOSProperties = [this.MCOSProperties; {'TicksPrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'numberOfTicks'}];
                    % logical
                case 'Selected'
                    prop = this.addprop('Selected');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'SelectedPrivate');
                    prop.SetMethod = @(this, data) setLogicalProperty(this, 'SelectedPrivate', 'selected', data);
                    this.MCOSProperties = [this.MCOSProperties; {'SelectedPrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'selected'}];
                case 'Editable'
                    prop = this.addprop('Editable');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'EditablePrivate');
                    prop.SetMethod = @(this, data) setLogicalProperty(this, 'EditablePrivate', 'editable', data);
                    this.MCOSProperties = [this.MCOSProperties; {'EditablePrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'editable'}];
                case 'IsFavorite'
                    prop = this.addprop('IsFavorite');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'IsFavoritePrivate');
                    prop.SetMethod = @(this, data) setLogicalProperty(this, 'IsFavoritePrivate', 'isFavorite', data);
                    this.MCOSProperties = [this.MCOSProperties; {'IsFavoritePrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'isFavorite'}];
                case 'IsInQuickAccess'
                    prop = this.addprop('IsInQuickAccess');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'IsInQuickAccessPrivate');
                    prop.SetMethod = @(this, data) setLogicalProperty(this, 'IsInQuickAccessPrivate', 'isInQAB', data);
                    this.MCOSProperties = [this.MCOSProperties; {'IsInQuickAccessPrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'isInQAB'}];
                    % Nx1 cell vector of strings
                case 'SelectedItems'
                    prop = this.addprop('SelectedItems');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'SelectedItemsPrivate');
                    prop.SetMethod = @(this, data) setSelectedItemsProperty(this, 'SelectedItemsPrivate', 'selectedItems', data);
                    this.MCOSProperties = [this.MCOSProperties; {'SelectedItemsPrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'selectedItems'}];
                    % Nx2 cell vector of strings
                case 'Items'
                    prop = this.addprop('Items');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'ItemsPrivate');
                    prop.SetMethod = @(this, data) setItemsProperty(this, data);
                    this.MCOSProperties = [this.MCOSProperties; {'ItemsPrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'items'}];
                    % Nx2 cell vector of strings and values
                case 'Labels'
                    prop = this.addprop('Labels');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getLabelsProperty(this);
                    prop.SetMethod = @(this, data) setLabelsProperty(this, data);
                    this.MCOSProperties = [this.MCOSProperties; {'LabelsPrivate'}; {'LocationsPrivate'}];
                    this.PeerProperties = [this.PeerProperties; {'labels'}; {'locations'}];
                    % icons
                case 'Icon'
                    prop = this.addprop('Icon');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'IconPrivate');
                    prop.SetMethod = @(this, data) setIconProperty(this, data);
                    this.MCOSProperties = [this.MCOSProperties; {'IconJavaScript'}; {'IconSwing'}];
                    this.PeerProperties = [this.PeerProperties; {'icon'}; {'iconPath'}];
                case 'QuickAccessIcon'
                    prop = this.addprop('QuickAccessIcon');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'QuickAccessIconPrivate');
                    prop.SetMethod = @(this, data) setQuickAccessIconProperty(this, data);
                    this.MCOSProperties = [this.MCOSProperties; {'QuickAccessIconJavaScript'}; {'QuickAccessIconSwing'}];
                    this.PeerProperties = [this.PeerProperties; {'quickAccessIcon'}; {'quickAccessIconPath'}];
                    % others
                case 'Popup'
                    prop = this.addprop('Popup');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'PopupPrivate');
                    prop.SetMethod = @(this, data) setPopupProperty(this, data);
                case 'DynamicPopupFcn'
                    prop = this.addprop('DynamicPopupFcn');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'DynamicPopupFcnPrivate');
                    prop.SetMethod = @(this, data) setDynamicPopupFcnProperty(this, data);
                    this.MCOSProperties = [this.MCOSProperties; {'HasDynamicPopup'}];
                    this.PeerProperties = [this.PeerProperties; {'hasDynamicPopup'}];
                case 'ButtonGroup'
                    prop = this.addprop('ButtonGroup');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getProperty(this, 'ButtonGroupPrivate');
                    prop.SetMethod = @(this, data) setButtonGroupProperty(this, data);
                otherwise
                    error(message('MATLAB:toolstrip:control:invalidActionProperty', name))
            end
        end
        
        %% Add callback function properties
        function addCallbackFcn(this, name)
            % Method "addCallbackFcn":
            %
            %   "addProperty(action, callbackfcn)": adds a dynamic callback
            %   function to the action object.  The following callback
            %   function names are accepted:
            %       'PushPerformed', used by Button, ListItem and SplitButton
            %       'ItemSelected', used by DropDown and ListBox
            %       'SelectionChanged', used by ToggleButton, CheckBox, RadioButton and ListItemWithCheckBox
            %       'TextChanged', used by EditField and TextArea
            %       'ValueChanged', used by Slider and Spinner
            %
            %   Example:
            %       action = matlab.ui.internal.toolstrip.base.Action();
            %       action.addProperty('Text')
            %       action.addProperty('Icon')
            %       action.addCallbackFcn('PushPerformed')
            %       btn = matlab.ui.internal.toolstrip.Button(action)
            if any(strcmp(name,{'PushPerformed','ItemSelected','SelectionChanged','TextChanged','ValueChanged'}))
                private_prop = [name 'FcnPrivate'];
                public_prop = [name 'Fcn'];
                prop = this.addprop(private_prop);
                prop.Access = 'private';
                prop = this.addprop(public_prop);
                prop.Dependent = true;
                prop.GetMethod = @(this) getCallbackFcn(this, private_prop);
                prop.SetMethod = @(this, data) setCallbackFcn(this, private_prop, data);
            else
                error(message('MATLAB:toolstrip:control:invalidActionCallbackFcn', name))
            end
        end
        
    end
    
    %% Common and special Get/Set methods
    methods (Access = protected)
        
        %% Getter
        function value = getProperty(this, prop)
            value = this.(prop);
        end
        
        %% Setter: char
        function setCharProperty(this, mcos_prop, peer_prop, value)
            [OK, value] = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'string');
            if OK
                this.(mcos_prop) = value;
                this.setPeerProperty(peer_prop, value);
            else
                error(message('MATLAB:toolstrip:control:invalidCharProperty', peer_prop))
            end
        end
        
        %% Setter: numeric
        function setIntegerProperty(this, mcos_prop, peer_prop, value)
            OK = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer');
            if OK
                this.(mcos_prop) = value;
                this.setPeerProperty(peer_prop, value);
            else
                error(message('MATLAB:toolstrip:control:invalidIntegerProperty', peer_prop))
            end
        end
        
        function setRealProperty(this, mcos_prop, peer_prop, value)
            OK = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'real');
            if OK
                this.(mcos_prop) = value;
                this.setPeerProperty(peer_prop, value);
            else
                error(message('MATLAB:toolstrip:control:invalidRealProperty', peer_prop))
            end
        end
        
        %% Setter: logical
        function setLogicalProperty(this, mcos_prop, peer_prop, value)
            OK = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'logical');
            if OK
                this.(mcos_prop) = value;
                this.setPeerProperty(peer_prop, value);
            else
                error(message('MATLAB:toolstrip:control:invalidLogicalProperty', peer_prop))
            end
        end
        
        %% Setter: Nx1 cell array of strings
        function setSelectedItemsProperty(this, mcos_prop, peer_prop, value)
            % check for cell array of strings or empty cell
            [OK, value] = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'stringNx1');
            if OK
                this.(mcos_prop) = value;
                this.setPeerProperty(peer_prop, value);
            else
                error(message('MATLAB:toolstrip:control:invalidSelectedItemsProperty', peer_prop))
            end
        end
        
        %% special set methods
        % NumberFormat: must be integer or double
        function setNumberFormatProperty(this, value)
            [OK, value] = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'string');
            if OK
                if ~contains(lower(value), {'integer', 'double'})
                    error(message('MATLAB:toolstrip:control:invalidNumberFormat'))
                else
                    this.NumberFormatPrivate = lower(value);
                    this.setPeerProperty('numberFormat', lower(value));
                end
            else
                error(message('MATLAB:toolstrip:control:invalidNumberFormat'))
            end
        end
        % SelectionMode: must be single or multiple
        function setSelectionModeProperty(this, value)
            [OK, value] = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'string');
            if OK
                if ~contains(lower(value), {'single', 'multiple'})
                    error(message('MATLAB:toolstrip:control:invalidSelectionMode'))
                else
                    this.SelectionModePrivate = lower(value);
                    this.setPeerProperty('selectionMode', lower(value));
                end
            else
                error(message('MATLAB:toolstrip:control:invalidSelectionMode'))
            end
        end
        % SelectedItem: string including ''
        function setSelectedItemProperty(this, value)
            [OK, value] = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'string');
            if OK
                this.SelectedItemPrivate = value;
                this.setPeerProperty('selectedItem', value);
            else
                error(message('MATLAB:toolstrip:control:invalidCharProperty', 'SelectedItem'))
            end
        end
        % Items: Nx2 cell array of strings for states and labels, {} is OK
        function setItemsProperty(this, value)
            IsList = isempty(findprop(this,'SelectedItem'));
            if isempty(value)
                this.ItemsPrivate = {};
                if IsList
                    this.SelectedItemsPrivate = {};
                else
                    this.SelectedItemPrivate = '';
                end
                combined = {};
            else
                [OK, value] = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'stringNx1');
                if OK
                    % states only
                    selected = false(size(value));
                    if IsList
                        for ct=1:length(this.SelectedItems)
                            matched = find(strcmp(this.SelectedItems(ct), value));
                            if ~isempty(matched)
                                selected(matched) = true;
                            end
                        end
                    elseif any(strcmp(this.SelectedItem, value))
                        selected(strcmp(this.SelectedItem, value)) = true;
                    end
                    this.ItemsPrivate = [value value];
                    if IsList
                        if any(selected)
                            this.SelectedItemsPrivate = value(selected);
                        else
                            this.SelectedItemsPrivate = {};
                        end
                    else
                        if any(selected)
                            this.SelectedItemPrivate = value(selected);
                        else
                            this.SelectedItemPrivate = '';
                        end
                    end
                    combined = struct('value',value,'label',value,'selected',num2cell(selected),'forceArray',true);
                else
                    [OK, value] = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'stringNx2');
                    if OK
                        % states and labels
                        selected = false(size(value(:,1)));
                        if IsList
                            for ct=1:length(this.SelectedItems)
                                matched = find(strcmp(this.SelectedItems(ct), value(:,1)));
                                if ~isempty(matched)
                                    selected(matched) = true;
                                end
                            end
                        else
                            idx = strcmp(this.SelectedItem, value(:,1));
                            if any(idx)
                                selected(idx) = true;
                            end
                        end
                        this.ItemsPrivate = value;
                        if IsList
                            if any(selected)
                                this.SelectedItemsPrivate = value(selected,1);
                            else
                                this.SelectedItemsPrivate = {};
                            end
                        else
                            if any(selected)
                                this.SelectedItemPrivate = value{selected,1};
                            else
                                this.SelectedItemPrivate = '';
                            end
                        end
                        combined = struct('value',value(:,1),'label',value(:,2),'selected',num2cell(selected),'forceArray',true);
                    else
                        error(message('MATLAB:toolstrip:control:invalidItems'))
                    end
                end
            end
            this.setPeerProperty('items',combined);
        end
        % Labels: Nx2 cell array of strings and values, {} is OK
        function value = getLabelsProperty(this)
            value1 = this.LabelsPrivate;
            value2 = num2cell(this.LocationsPrivate);
            value = [value1 value2];
        end        
        function setLabelsProperty(this, value)
            [OK, value] = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'cellNx2');
            if OK
                if isempty(value)
                    this.LabelsPrivate = {};
                    this.LocationsPrivate = [];
                else
                    this.LabelsPrivate = value(:,1);
                    this.LocationsPrivate = cell2mat(value(:,2));
                end
                % for swing rendering, must set labels after locations
                this.setPeerProperty('locations', this.LocationsPrivate);
                this.setPeerProperty('labels', this.LabelsPrivate); 
            else
                error(message('MATLAB:toolstrip:control:invalidLabels'));
            end
        end
        % Icon
        function setIconProperty(this, value)
            value = matlab.ui.internal.toolstrip.base.Utility.hString2Char(value);
            if isempty(value)
                this.IconPrivate = [];
                this.IconSwing = '';
                this.setPeerProperty('iconPath','');
                this.IconJavaScript = '';
                this.setPeerProperty('icon','');
            elseif ischar(value)
                icon = matlab.ui.internal.toolstrip.Icon(value);
                setIconProperty(this, icon);
            elseif isa(value, 'matlab.ui.internal.toolstrip.Icon')
                this.IconPrivate = value;
                % must set iconPath first
                this.IconSwing = value.getIconFile();
                this.setPeerProperty('iconPath',value.getIconFile());
                % must set icon second (listenered by swing widgets)
                if isCSS(value) 
                    % built-in or custom class
                    str = value.getIconClass();
                    this.IconJavaScript = str;
                    this.setPeerProperty('icon',str);
                else
                    % file or ImageIcon
                    str = value.getBase64URL();
                    this.IconJavaScript = str;
                    this.setPeerProperty('icon',str);
                end
            else
                error(message('MATLAB:toolstrip:control:invalidIcon'))
            end
        end
        % QuickAccessIcon
        function setQuickAccessIconProperty(this, value)
            if isempty(value)
                this.QuickAccessIconPrivate = [];
                this.QuickAccessIconJavaScript = '';
                this.setPeerProperty('quickAccessIcon','');
                this.QuickAccessIconSwing = '';
                this.setPeerProperty('quickAccessIconPath','');
            elseif isa(value, 'matlab.ui.internal.toolstrip.Icon')
                this.QuickAccessIconPrivate = value;
                if isCSS(value)
                    str = value.getIconClass();
                    this.QuickAccessIconJavaScript = str;
                    this.setPeerProperty('quickAccessIcon',str);
                    this.QuickAccessIconSwing = '';
                    this.setPeerProperty('quickAccessIconPath','');
                else
                    str = value.getBase64URL();
                    this.QuickAccessIconJavaScript = str;
                    this.setPeerProperty('quickAccessIcon',str);
                    this.QuickAccessIconSwing = value.Description;
                    this.setPeerProperty('quickAccessIconPath',value.Description);
                end
            else
                error(message('MATLAB:toolstrip:control:invalidIcon'))
            end
        end
        % Popup: generate "popupId"
        function setPopupProperty(this, value)
            if isempty(value)
                this.PopupPrivate = [];
            elseif isa(value, 'matlab.ui.internal.toolstrip.PopupList')
                this.PopupPrivate = value;
            else
                error(message('MATLAB:toolstrip:control:invalidPopupList'))
            end
        end
        % DynamicPopupFcn: generate "hasDynamicPopup"
        function setDynamicPopupFcnProperty(this, value)
            OK = internal.Callback.validate(value);
            if OK
                this.DynamicPopupFcnPrivate = value;
                this.HasDynamicPopup = ~isempty(value);
                this.setPeerProperty('hasDynamicPopup',this.HasDynamicPopup);
            else
                error(message('MATLAB:toolstrip:general:invalidFunctionHandle', 'DynamicPopupFcn'))
            end
        end
        % ButtonGroup
        function setButtonGroupProperty(this, value)
            if isa(value, 'matlab.ui.internal.toolstrip.ButtonGroup')
                this.ButtonGroupPrivate = value;
            else
                error(message('MATLAB:toolstrip:control:invalidPopupList'))
            end
        end
        
        %% callback property
        function value = getCallbackFcn(this, name)
            value = this.(name);
        end
        
        function value = setCallbackFcn(this, name, value)
            if internal.Callback.validate(value)
                this.(name) = value;
            else
                error(message('MATLAB:toolstrip:general:invalidFunctionHandle', name))
            end
        end
        
        %% peer model event callbacks
        function PropertySetCallback(this,src,data) %#ok<*INUSL>
            originator = data.getOriginator();
            if ~(isa(originator, 'java.util.HashMap') && strcmp(originator.get('source'),'MCOS'))
                % get event data
                eventdata = matlab.ui.internal.toolstrip.base.Utility.processPropertySetData(data);
                % Execute callback functions
                switch eventdata.EventData.Property
                    case 'Selected'
                        % update property
                        this.SelectedPrivate = eventdata.EventData.NewValue;
                        % force to be Value
                        eventdata.EventData.Property = 'Value';
                        % run callback fcn
                        if ~isempty(findprop(this,'SelectionChangedFcn'))
                            internal.Callback.execute(this.SelectionChangedFcn, this, eventdata);
                        end
                    case 'SelectedItem'
                        % update property only if selection is changed
                        % (this is to prevent unnecessary events coming
                        % from JS widget when adding/removing items)
                        if strcmp(this.SelectedItemPrivate, eventdata.EventData.NewValue)
                            return
                        else
                            this.SelectedItemPrivate = eventdata.EventData.NewValue;
                            % force to be Value
                            eventdata.EventData.Property = 'Value';
                            % run callback fcn
                            if ~isempty(findprop(this,'ItemSelectedFcn'))
                                internal.Callback.execute(this.ItemSelectedFcn, this, eventdata);
                            end
                        end
                    case 'SelectedItems'
                        % update property
                        newvalue = eventdata.EventData.NewValue;
                        if isempty(newvalue)
                            % empty java object array
                            this.SelectedItemsPrivate = {};
                        else
                            % cell
                            this.SelectedItemsPrivate = newvalue;
                        end
                        % force to be Value
                        eventdata.EventData.Property = 'Value';
                        % run callback fcn
                        if ~isempty(findprop(this,'ItemSelectedFcn'))
                            internal.Callback.execute(this.ItemSelectedFcn, this, eventdata);
                        end
                    case 'Text'
                        % update property
                        this.TextPrivate = eventdata.EventData.NewValue;
                        % force to be Value
                        eventdata.EventData.Property = 'Value';
                        % run callback fcn
                        if ~isempty(findprop(this,'TextChangedFcn'))
                            % EditField, TextArea and ListItemWithEditField
                            internal.Callback.execute(this.TextChangedFcn, this, eventdata);
                        end
                        if ~isempty(findprop(this,'ItemSelectedFcn'))
                            % Editable DropDown
                            internal.Callback.execute(this.ItemSelectedFcn, this, eventdata);
                        end
                    case 'Value'
                        % update property
                        this.ValuePrivate = eventdata.EventData.NewValue;
                end
                % send out event
                this.notify('ActionPropertySet', eventdata);
            end
        end
        
        function PeerEventCallback(this,src,data)
            % get event data
            eventdata = matlab.ui.internal.toolstrip.base.Utility.processPeerEventData(data);
            % execute attached callback functions
            switch eventdata.EventData.EventType
                case {'ButtonPushed', 'ItemPushed'}
                    if ~isempty(findprop(this,'PushPerformedFcn'))
                        internal.Callback.execute(this.PushPerformedFcn, this, eventdata);
                    end
                case 'ValueChanged'
                    if ~isempty(findprop(this,'ValueChangedFcn'))
                        internal.Callback.execute(this.ValueChangedFcn, this, eventdata);
                    end
            end
            this.notify('ActionPerformed', eventdata);
        end
        
    end
    
    %% hidden methods
    methods (Hidden)
        
        function setPrivateProperty(this, name, value)
            switch name
                case 'Icon'
                    this.IconPrivate = value;
                case 'ButtonGroup'
                    this.ButtonGroupPrivate = value;
            end
        end
        
        function peer = getPeer(this)
            peer = this.Peer;
        end
        
        function synchronize(this)
            this.dispatchEvent(struct);
        end
        
        function render(this, channel)
            % Method "render"
            %
            %   create the peer node for the action
            this.PeerModelChannel = channel;            
            if ~hasPeerNode(this)
                % to be visited: special treatment of "items" property
                for ct=1:length(this.MCOSProperties)
                    if strcmp(this.PeerProperties{ct},'items')
                        value = this.ItemsPrivate;
                        if isempty(value)
                            combined = {};
                        else
                            selected = false(size(value(:,1)));
                            combined = struct('value',value(:,1),'label',value(:,2),'selected',num2cell(selected),'forceArray',true);
                        end
                        properties.items = combined;
                    else
                        properties.(this.PeerProperties{ct}) = this.(this.MCOSProperties{ct});
                    end
                end
                % create peer node
                this.createPeer(properties);
                this.Id = char(this.Peer.getId());
                this.setPeerProperty('id', this.Id);
            end
        end
        
    end
    
end