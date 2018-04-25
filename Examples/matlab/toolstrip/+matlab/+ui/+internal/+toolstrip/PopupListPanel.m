classdef PopupListPanel < matlab.ui.internal.toolstrip.base.Container
    % Popup List Panel
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupListPanel.PopupListPanel">PopupListPanel</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupListPanel.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupListPanel.addSeparator">addSeparator</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupListPanel.remove">remove</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %
    % See also matlab.ui.internal.toolstrip.ListItem, matlab.ui.internal.toolstrip.PopupList
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    properties (Access = private)
        ChildTypes = {'matlab.ui.internal.toolstrip.ListItem', ...
                'matlab.ui.internal.toolstrip.ListItemWithCheckBox', ...
                'matlab.ui.internal.toolstrip.ListItemWithEditField', ...
                'matlab.ui.internal.toolstrip.ListItemWithRadioButton', ...
                'matlab.ui.internal.toolstrip.ListItemWithPopup', ...
                'matlab.ui.internal.toolstrip.PopupListHeader', ...
                'matlab.ui.internal.toolstrip.PopupListSeparator'};
    end
    
    %% ----------- User-visible properties --------------------------
    properties (Dependent, GetAccess = public, SetAccess = private)
        % Property "MaxHeight": 
        %
        %   The maximum height in pixels after which to show a scroll bar.
        %   It is a positive finite integer in the unit of pixels.
        %   It is read-only.  You have to specify it during construction.
        %
        %   Example:
        %       column = matlab.ui.internal.toolstrip.PopupListPanel('MaxHeight',200)
        MaxHeight
    end
    
    % ----------------------------------------------------------------------------
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        MaxHeightPrivate = 600
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = PopupListPanel(varargin)
            % Constructor "PopupListPanel": 
            %
            %   Creates a popup list panel.  
            %
            %   Examples:
            %
            %       panel = matlab.ui.internal.toolstrip.PopupListPanel();
            %       panel = matlab.ui.internal.toolstrip.PopupListPanel('MaxHeight', 200);
            %
            %       item1 = matlab.ui.internal.toolstrip.ListItem('Add Plot',matlab.ui.internal.toolstrip.Icon.ADD_16,'This is the description');
            %       item2 = matlab.ui.internal.toolstrip.ListItemWithCheckBox('Delete Plot');
            %       panel.add(item1);
            %       panel.add(item2);
            %
            %       popup = matlab.ui.internal.toolstrip.PopupList();
            %       popup.addItem(panel);
            %
            %       btn = matlab.ui.internal.toolstrip.DropDownButton('this is a drop down button');
            %       btn.Popup = popup;

            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('PopupListPanel');
            % process custom property
            this.processCustomProperties(varargin{:});
        end
        
        %% Public API
        % Width
        function value = get.MaxHeight(this)
            % GET function for MaxHeight property.
            value = this.MaxHeightPrivate;
        end
        function set.MaxHeight(this, value)
            % SET function for HorizontalAlignment property.
            this.MaxHeightPrivate = value;
        end

        %% Public API: add and remove
        function add(this, item, varargin)
            % Method "add":
            %
            %   "add(popuplist, item)": add an item at the end of the popup.
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.PopupList
            %       item = matlab.ui.internal.toolstrip.ListItem('new')
            %       popup.add(item)
            %
            %   "add(popuplist, item, index)": insert an item at a specified location in the popup.
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.PopupList
            %       item1 = matlab.ui.internal.toolstrip.ListItem('new')
            %       item2 = matlab.ui.internal.toolstrip.ListItem('old')
            %       popup.add(item1)
            %       popup.add(item2, 1)
            str = class(item);
            ok = any(strcmp(str, this.ChildTypes));
            if ok
                add@matlab.ui.internal.toolstrip.base.Container(this, item, varargin{:});
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', str, class(this)));
            end
        end
        
        function remove(this, item)
            % Method "remove":
            %
            %   "remove(popuplist, item)": remove an item from the popup.
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.PopupList
            %       item1 = matlab.ui.internal.toolstrip.ListItem('new')
            %       item2 = matlab.ui.internal.toolstrip.ListItem('old')
            %       popup.remove(item1)
            str = class(item);
            ok = any(strcmp(str, this.ChildTypes));
            if ok
                if this.isChild(item)
                    remove@matlab.ui.internal.toolstrip.base.Container(this, item);
                else
                    error(message('MATLAB:toolstrip:container:invalidChild'));
                end
            else
                error(message('MATLAB:toolstrip:container:invalidObjectRemovedFromParent', class(item), class(this)));
            end
        end
        
        function separator = addSeparator(this)
            % Method "addSeparator":
            %
            %   "separator = addSeparator(popup)": add a separator in the popup list.
            %   Example:
            %       item1 = matlab.ui.internal.toolstrip.ListItem('Add Plot',matlab.ui.internal.toolstrip.Icon.ADD_16,'This is the description','This is the help');
            %       item2 = matlab.ui.internal.toolstrip.ListItem('Delete Plot',matlab.ui.internal.toolstrip.Icon.DELETE,'This is the description','This is the help');
            %       popup = matlab.ui.internal.toolstrip.PopupList;
            %       popup.addItem(item1);
            %       popup.addSeparator;
            %       popup.addItem(item2);
            separator = matlab.ui.internal.toolstrip.PopupListSeparator();
            this.add(separator);
        end
        
    end
    
    %% You must initialize all the abstract methods here
    methods (Access = protected)

        function rules = getInputArgumentRules(this) %#ok<MANU>
            % Abstract method defined in @component
            %
            % specify the rules for constructor syntax without using PV
            % pairs.  For constructor using PV pairs such as column, you
            % still need to create a dummy function though.
            rules.input0 = true; % this is a dummy
        end
        
        function buildWidgetPropertyMaps(this)
            % Abstract method defined in @component
            %
            % build maps between private MCOS property names and peer node
            % property names for widget properties.  The map for action
            % properties are automatically built when creating Action
            % object.
            [mcos1, peer1] = this.getWidgetPropertyNames_Container();
            mcos = [mcos1;{'MaxHeightPrivate'}];
            peer = [peer1;{'maxHeight'}];
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end
        
    end
    
    %% You must put all the overloaded methods here
    methods (Access = protected)
        
        function processCustomProperties(this, varargin)
            % set optional properties
            ni = nargin-1;
            if ni==0
                return
            end
            if rem(ni,2)~=0,
                error(message('MATLAB:toolstrip:general:invalidPropertyValuePairs'))
            end
            PublicProps = {'MaxHeight'};
            for ct=1:2:ni
                name = matlab.ui.internal.toolstrip.base.Utility.matchProperty(varargin{ct},PublicProps);
                switch name
                    case 'MaxHeight'
                        value = varargin{ct+1};
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, name);
                        if ok
                            widget_properties.(name) = lower(value);
                        else
                            error(message('MATLAB:toolstrip:container:invalidMaxHeight'))
                        end
                end
            end
            props = fieldnames(widget_properties);
            for ct=1:length(props)
                this.(props{ct}) = widget_properties.(props{ct});
            end
        end
        
    end
    
end
