classdef Section < matlab.ui.internal.toolstrip.base.Container & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Title & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic
    % Layout Container (Section)
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Section.Section">Section</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Section.CollapsePriority">CollapsePriority</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Title.Title">Title</a>        
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Section.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Section.addColumn">addColumn</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.Tab, matlab.ui.internal.toolstrip.Column
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    % -----------------------------------------------------------------------------------------
    % ATTENTION: the following settings are only valid for JavaScript rendering
    %   Properties:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.Section.CollapsePriority">CollapsePriority</a>
    %   Methods:
    %       N/A
    %   Events:
    %       N/A
    % -----------------------------------------------------------------------------------------

    %% ----------------------------------------------------------------------------
    properties (Dependent)
        % Property "CollapsePriority": 
        %
        %   The section with highest priority collapse last in the tab.
        %   It is an integer and the default value is 0.
        %   It is writable.
        %
        %   Example:
        %       section1 = matlab.ui.internal.toolstrip.Section('FOO')
        %       section1.CollapsePriority = 10;
        CollapsePriority
    end
    
    % ----------------------------------------------------------------------------
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        CollapsePriorityPrivate = 0
    end
    
    properties (Access = private)
        AllowAddAfterRendering = false
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Section(varargin)
            % Constructor "Section": 
            %
            %   Create a section.
            %
            %   Examples:
            %       section1 = matlab.ui.internal.toolstrip.Section('title1'); 

            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('Section');
            % process custom property
            this.processCustomProperties(varargin{:});
        end
        
        %% Public API: Get/Set
        % CollapsePriority
        function value = get.CollapsePriority(this)
            % GET function for CollapsePriority property.
            value = this.CollapsePriorityPrivate;
        end
        function set.CollapsePriority(this, value)
            % SET function for Title property.
            OK = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'CollapsePriority');
            if OK
                this.CollapsePriorityPrivate = value;
                this.setPeerProperty('collapsePriority',value);
            else
                error(message('MATLAB:toolstrip:container:invalidCollapsePriority'))
            end
        end
        
        %% Public API: control management
        function add(this, column, varargin)
            % Method "add":
            %
            %   "add(section, column)": add a column at the end of the section.
            %   Example:
            %       sec = matlab.ui.internal.toolstrip.Section('title')
            %       col = matlab.ui.internal.toolstrip.Column
            %       sec.add(col)
            %
            %   "add(section, column, index)": insert a column at a specified location in the section.
            %   Example:
            %       sec = matlab.ui.internal.toolstrip.Section('title')
            %       col1 = matlab.ui.internal.toolstrip.Column
            %       sec.add(col1)
            %       col2 = matlab.ui.internal.toolstrip.Column
            %       sec.add(col2, 1) % insert col2 as the first one
            if isa(column, 'matlab.ui.internal.toolstrip.Column')
                if hasPeerNode(this) && ~this.AllowAddAfterRendering
                    error(message('MATLAB:toolstrip:container:cannotAddToContainer','Column','Section'));                    
                end
                add@matlab.ui.internal.toolstrip.base.Container(this, column, varargin{:});
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', class(column), class(this)));
            end
        end
        
        function col = addColumn(this, varargin)
            % Method "addColumn":
            %
            %   "col = addColumn(section)": create a column object at
            %   the end of the section and returns its handle. 
            %   Example:
            %       sec = matlab.ui.internal.toolstrip.Section('FOO')
            %       col = tab.addColumn()
            %       col = tab.addColumn('HorizontalAlignment', 'center')
            %       col = tab.addColumn('Width', 100)
            col = matlab.ui.internal.toolstrip.Column(varargin{:});
            this.add(col);
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
            rules.properties.Title = struct('type','string','isAction',false);
            rules.input0 = true;
            rules.input1 = {{'Title'}};
        end
        
        function buildWidgetPropertyMaps(this)
            % Abstract method defined in @component
            %
            % build maps between private MCOS property names and peer node
            % property names for widget properties.  The map for action
            % properties are automatically built when creating Action
            % object.
            [mcos1, peer1] = this.getWidgetPropertyNames_Container();
            [mcos2, peer2] = this.getWidgetPropertyNames_Mnemonic();
            [mcos3, peer3] = this.getWidgetPropertyNames_Title();
            mcos = [mcos1;mcos2;mcos3;{'CollapsePriorityPrivate'}];
            peer = [peer1;peer2;peer3;{'collapsePriority'}];
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end
        
    end
    
    methods (Hidden)
        
        function qeAdd(this, column, varargin)
            this.AllowAddAfterRendering = true;
            add(this, column, varargin{:});
            this.AllowAddAfterRendering = false;
        end
        
        function column = qeAddColumn(this, varargin)
            column = matlab.ui.internal.toolstrip.Column(varargin{:});
            qeAdd(this, column);
        end
        
    end
    
end

