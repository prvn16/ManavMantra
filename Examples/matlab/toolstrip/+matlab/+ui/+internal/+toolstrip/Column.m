classdef Column < matlab.ui.internal.toolstrip.base.Container
    % Layout Container (Column)
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Column.Column">Column</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Column.HorizontalAlignment">HorizontalAlignment</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Column.Width">Width</a>
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Column.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Column.addEmptyControl">addEmptyControl</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.Section, matlab.ui.internal.toolstrip.Panel
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    %% ----------- User-visible properties --------------------------
    properties (Dependent, GetAccess = public, SetAccess = private)
        % Property "HorizontalAlignment": 
        %
        %   The horizontal alignment of all the controls in the column.
        %   It is a string of 'left' (default), 'center' and 'right'.
        %   It is read-only.  You have to specify it during construction.
        %
        %   Example:
        %       column = matlab.ui.internal.toolstrip.Column('HorizontalAlignment','center')
        HorizontalAlignment        
        % Property "Width": 
        %
        %   The custom width of the column.
        %   It is a positive finite integer in the unit of pixels.
        %   It is read-only.  You have to specify it during construction.
        %
        %   Example:
        %       column = matlab.ui.internal.toolstrip.Column('Width',100)
        Width
    end
    
    % ----------------------------------------------------------------------------
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        HorizontalAlignmentPrivate = 'left'
        WidthPrivate = 0;
    end
    
    properties (Access = private)
        AllowAddAfterRendering = false
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Column(varargin)
            % Constructor "Column": 
            %
            %   Create a column.
            %
            %   Examples:
            %       column = matlab.ui.internal.toolstrip.Column(); 
            %       column = matlab.ui.internal.toolstrip.Column('HorizontalAlignment','center'); 
            %       column = matlab.ui.internal.toolstrip.Column('Width',100); 
            %       column = matlab.ui.internal.toolstrip.Column('HorizontalAlignment','center','Width',100); 
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('Column');
            % process custom property
            this.processCustomProperties(varargin{:});
        end
        
        %% Get/Set Properties
        % HorizontalAlignment
        function value = get.HorizontalAlignment(this)
            % GET function for HorizontalAlignment property.
            value = this.HorizontalAlignmentPrivate;
        end
        function set.HorizontalAlignment(this, value)
            % SET function for HorizontalAlignment property.
            this.HorizontalAlignmentPrivate = value;
        end
        % Width
        function value = get.Width(this)
            % GET function for Width property.
            value = this.WidthPrivate;
            if value == 0
                value = [];
            end
        end
        function set.Width(this, value)
            % SET function for Width property.
            if isempty(value)
                value = 0;
            end
            this.WidthPrivate = value;
        end
        
        %% Add/Remove
        function add(this, control, varargin)
            % Method "add":
            %
            %   "add(column, control)": add a control at the end of the column.
            %   Example:
            %       col = matlab.ui.internal.toolstrip.Column
            %       btn = matlab.ui.internal.toolstrip.Button
            %       col.add(btn)
            %
            %   "add(column, control, index)": insert a control at a specified location in the column.
            %   Example:
            %       col = matlab.ui.internal.toolstrip.Column
            %       btn1 = matlab.ui.internal.toolstrip.Button
            %       col.add(btn1)
            %       btn2 = matlab.ui.internal.toolstrip.Button
            %       col.add(btn2, 1) % insert btn2 as the first button
            if hasPeerNode(this) && ~this.AllowAddAfterRendering
                error(message('MATLAB:toolstrip:container:cannotAddToContainer',control.getType(),'Column'));                    
            end
            if isa(control, 'matlab.ui.internal.toolstrip.base.Control')
                ok = ~isa(control, 'matlab.ui.internal.toolstrip.PopupListHeader') && ~isa(control, 'matlab.ui.internal.toolstrip.GalleryItem') && ~isa(control, 'matlab.ui.internal.toolstrip.ToggleGalleryItem');
            else 
                ok = isa(control, 'matlab.ui.internal.toolstrip.Panel') || isa(control, 'matlab.ui.internal.toolstrip.Gallery') || isa(control, 'matlab.ui.internal.toolstrip.EmptyControl');
            end
            if ok
                if isa(control, 'matlab.ui.internal.toolstrip.Panel') && isa(this.Parent, 'matlab.ui.internal.toolstrip.Panel')
                    error(message('MATLAB:toolstrip:container:invalidPanelInPanel'));
                elseif length(this.Children)<3
                    % add to column after validation
                    add@matlab.ui.internal.toolstrip.base.Container(this, control, varargin{:});
                else
                    error(message('MATLAB:toolstrip:container:maximumControlReachedInColumn'));                    
                end
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', class(control), class(this)));
            end
        end
        
        function emptycontrol = addEmptyControl(this)
            % Method "addEmptyControl":
            %
            %   "emptycontrol = addEmptyControl(column)": add an empty control filler in the column.
            %   Example:
            %       col = matlab.ui.internal.toolstrip.Column
            %       btn1 = matlab.ui.internal.toolstrip.Button('OK')
            %       col.add(btn1)
            %       col.addEmptyControl();
            %       btn2 = matlab.ui.internal.toolstrip.Button('Cancel')
            %       col.add(btn2) % Two horizontal buttons in the same column, occupying row #1 and #3
            emptycontrol = matlab.ui.internal.toolstrip.EmptyControl();
            this.add(emptycontrol);
        end
        
    end
    
    methods (Hidden)
    
        function remove(this, varargin) %#ok<INUSD>
            % Method "remove"
            error(message('MATLAB:toolstrip:container:removeDisabled'))
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
            mcos = [mcos1;{'HorizontalAlignmentPrivate';'WidthPrivate'}];
            peer = [peer1;{'horizontalAlignment';'width'}];
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
            PublicProps = {'HorizontalAlignment','Width'};
            for ct=1:2:ni
                name = matlab.ui.internal.toolstrip.base.Utility.matchProperty(varargin{ct},PublicProps);
                switch name
                    case 'HorizontalAlignment'
                        value = varargin{ct+1};
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, name);
                        if ok
                            widget_properties.(name) = lower(value);
                        else
                            error(message('MATLAB:toolstrip:container:invalidHorizontalAlignment'))
                        end
                    case 'Width'
                        value = varargin{ct+1};
                        if isempty(value)
                            widget_properties.(name) = [];
                        else
                            ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, name);
                            if ok
                                widget_properties.(name) = value;
                            else
                                error(message('MATLAB:toolstrip:container:invalidWidth'))
                            end
                        end
                end
            end
            props = fieldnames(widget_properties);
            for ct=1:length(props)
                this.(props{ct}) = widget_properties.(props{ct});
            end
        end
        
    end
    
    methods (Hidden)
        
        function qeAdd(this, control, varargin)
            this.AllowAddAfterRendering = true;
            add(this, control, varargin{:});
            this.AllowAddAfterRendering = false;
        end
        
    end
    
end

