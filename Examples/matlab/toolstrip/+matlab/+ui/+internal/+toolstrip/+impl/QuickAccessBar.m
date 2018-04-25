classdef QuickAccessBar < matlab.ui.internal.toolstrip.base.Container
    % Quick Access Bar (per toolstrip)
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    methods
        
        %% Constructor
        function this = QuickAccessBar()
            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('QuickAccessBar');
        end
        
        %% Add/Remove
        function add(this, item, varargin)
            if isa(item, 'matlab.ui.internal.toolstrip.impl.QuickAccessGroup')
                add@matlab.ui.internal.toolstrip.base.Container(this, item, varargin{:});
            end
        end
        
        function remove(this, item)
            if isa(item, 'matlab.ui.internal.toolstrip.impl.QuickAccessGroup')
                if this.isChild(item)
                    remove@matlab.ui.internal.toolstrip.base.Container(this, item);
                end
            end
        end
        
    end
    
    %% You must initialize all the abstract methods here
    methods (Access = protected)
        
        function rules = getInputArgumentRules(this)
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
    
end
