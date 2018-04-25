classdef Panel < matlab.ui.internal.toolstrip.base.Container
    % Layout Container (Panel)
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Panel.Panel">Panel</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Panel.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Panel.addColumn">addColumn</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.Section, matlab.ui.internal.toolstrip.Column
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    properties (Access = private)
        AllowAddAfterRendering = false
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Panel()
            % Constructor "Panel": 
            %
            %   Create a panel.
            %
            %   Examples:
            %       panel1 = matlab.ui.internal.toolstrip.Panel;
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('Panel');
        end
        
        %% Public API
        function add(this, column, varargin)
            % Method "add":
            %
            %   "add(panel, column)": add a column at the end of the panel.
            %   Example:
            %       sec = matlab.ui.internal.toolstrip.Panel
            %       col = matlab.ui.internal.toolstrip.Column
            %       sec.add(col)
            %
            %   "add(panel, column, index)": insert a column at a specified location in the panel.
            %   Example:
            %       sec = matlab.ui.internal.toolstrip.Panel
            %       col1 = matlab.ui.internal.toolstrip.Column
            %       sec.add(col1)
            %       col2 = matlab.ui.internal.toolstrip.Column
            %       sec.add(col2, 1) % insert col2 as the first one
            if isa(column, 'matlab.ui.internal.toolstrip.Column')
                if hasPeerNode(this) && ~this.AllowAddAfterRendering
                    error(message('MATLAB:toolstrip:container:cannotAddToContainer','Column','Panel'));                    
                end
                for ct=1:length(column.Children)
                    if isa(column.Children(ct),'matlab.ui.internal.toolstrip.Panel')
                        error(message('MATLAB:toolstrip:container:invalidPanelInPanel'));
                    end
                end
                add@matlab.ui.internal.toolstrip.base.Container(this, column, varargin{:});
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', class(column), class(this)));
            end
        end
        
        function col = addColumn(this, varargin)
            % Method "addColumn":
            %
            %   "col = addColumn(panel)": create a column object at
            %   the end of the panel and returns its handle. 
            %   Example:
            %       sec = matlab.ui.internal.toolstrip.Panel
            %       col = tab.addColumn()
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
            rules.input0 = true;
        end
        
        function buildWidgetPropertyMaps(this)
            % Abstract method defined in @component
            %
            % build maps between private MCOS property names and peer node
            % property names for widget properties.  The map for action
            % properties are automatically built when creating Action
            % object.
            [mcos, peer] = this.getWidgetPropertyNames_Container();
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
