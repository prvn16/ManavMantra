classdef PeerVariableNode < handle
    %PEERVARIABLENODE Variable Editor Peer Node MixIn

    % Copyright 2013 The MathWorks, Inc.
    
    % PeerNode
    properties (SetObservable=true, SetAccess='public', GetAccess='public', Dependent=false, Hidden=false)
        % PeerNode Property
        PeerNode;
    end %properties
    methods
        function storedValue = get.PeerNode(this)
            storedValue = this.PeerNode;
        end
        
        function set.PeerNode(this, newValue)
            reallyDoCopy = ~isequal(this.PeerNode, newValue);
            if reallyDoCopy
                this.PeerNode = newValue;
            end
        end
    end
    
    % Event Listeners
    properties (SetObservable=false, SetAccess='protected', GetAccess='protected', Dependent=false, Hidden=false)
        PropertySetListener;
        PropertyDeletedListener;
        PeerEventListener;
    end

    % Constructor & Destructor
    methods(Access='public')
        function this=PeerVariableNode(parentNode,nodeType,varargin)
            props = varargin;

            % Get Properties from Widget Registry
            widgetRegistry = internal.matlab.variableeditor.peer.WidgetRegistry.getInstance();
            widgets = widgetRegistry.getWidgets(class(this),'');
            props{end+1} = 'Editor';
            props{end+1} = widgets.Editor;
            props{end+1} = 'InPlaceEditor';
            props{end+1} = widgets.InPlaceEditor;
            props{end+1} = 'CellRenderer';
            props{end+1} = widgets.CellRenderer;
            
            % Create our node by adding ourselves to the parent node
            this.PeerNode = parentNode.addChild(nodeType,props{:});
            
            % Setup Listeners
            this.PropertySetListener = event.listener(this.PeerNode,'PropertySet',@this.handlePropertySet);
            this.PropertyDeletedListener = event.listener(this.PeerNode,'PropertyDeleted',@this.handlePropertyDeleted);
            this.PeerEventListener = event.listener(this.PeerNode,'PeerEvent',@this.handlePeerEvents);
        end

        function delete(this)
            if ~isempty(this.PeerNode) && isvalid(this.PeerNode)
                delete(this.PeerNode);
            end
        end
        
        function sendErrorMessage(this, message)
            this.PeerNode.dispatchEvent(struct('type','error','message',message,'source','server'));
        end
        
        function fieldValue = getStructValue(~, s, field)
            fieldValue = [];
            
            if isstruct(s) && isfield(s, field)
                fieldValue = s.(field);
            elseif isobject(s) && isprop(s, field)
                fieldValue = s.get(field);
            elseif isa(s,'java.util.HashMap') && s.containsKey(field)
                fieldValue = s.get(field);
            else
                l = lasterror; %#ok<LERR>
                try
                    fieldValue = s.get(field);
                catch
                    % Clear last error because we don't want to hunt
                    % invlaid error message when we could have just been u
                    if ~isempty(l)
                        lasterror(l); %#ok<LERR>
                    else
                        lasterror('reset'); %#ok<LERR>
                    end
                end
            end
        end
        
        function setProperty(this, propertyName, propertyValues)
            %TODO: Is there a way to eliminate the HashMap usage?  Would
            % require modifying the MCOS peer model API to allow a structure
            % for the setProperty method.
            
            if ~isstruct(propertyValues)
                if isa(propertyValues,'java.util.HashMap') && ~propertyValues.containsKey('source')
                    propertyValues.put('source', 'server');
                end
                this.PeerNode.setProperty(propertyName, propertyValues);
                return;
            end
            
            map = java.util.HashMap();
            fields = fieldnames(propertyValues);
            for i=1:length(fields)
                map.put(fields{i}, propertyValues.(fields{i}));
            end
            if ~map.containsKey('source')
                map.put('source', 'server');
            end
            
            this.PeerNode.setProperty(propertyName, map);
        end
    end
    
    % Abstract Methods
    methods(Access='public', Abstract=true)
        handlePropertySet(this, es, ed);
        
        handlePropertyDeleted(this, es, ed);
        
        handlePeerEvents(this, es, ed);
    end
    
end

