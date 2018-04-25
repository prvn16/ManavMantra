classdef PeerUnsupportedViewModel < internal.matlab.variableeditor.MLUnsupportedViewModel & internal.matlab.variableeditor.peer.PeerVariableNode
    %PEERARRAYVIEWMODEL Peer Model Unsupported View Model
    
    % Copyright 2013-2014 The MathWorks, Inc.
    
    properties (Constant)
        % PeerNodeType
        PeerNodeType = '_VariableEditorViewModel_';
        TextLengthLimit = 8000;
    end
    
    methods
        function this = PeerUnsupportedViewModel(parentNode, variable)
            this@internal.matlab.variableeditor.MLUnsupportedViewModel(variable.DataModel);
            this = this@internal.matlab.variableeditor.peer.PeerVariableNode(parentNode,internal.matlab.variableeditor.peer.PeerUnsupportedViewModel.PeerNodeType,'name',variable.Name);
        end
        
        function handlePropertySet(~,~,~)
        end
        
        function handlePropertyDeleted(~,~,~)
        end
        
        function handlePeerEvents(this, ~, ed)
            if isfield(ed.EventData,'source') && strcmp('server',ed.EventData.source)
                return;
            end
            if isfield(ed.EventData,'type')
                switch ed.EventData.type
                    case 'getData'
                        this.cachedData(ed.EventData);
                    otherwise
                        this.sendErrorMessage(getString(message(...
                            'MATLAB:codetools:variableeditor:UnsupportedRequest', ... 
                            ed.EventData.type)));
                end
            end
        end
        
        function data=cachedData(this, varargin)
            data = this.getRenderedData();
            this.PeerNode.dispatchEvent(struct('type', 'setData', 'source', 'server',...
                                        'data',data));
        end
        
        function renderedData = getRenderedData(this,varargin)
            renderedData = getRenderedData@internal.matlab.variableeditor.MLUnsupportedViewModel(this);
                        
            % Truncate the length of the text to avoid excessive bandwidth
            % consumption.
            if length(renderedData)>internal.matlab.variableeditor.peer.PeerUnsupportedViewModel.TextLengthLimit
                 renderedData = sprintf('%s\n...',renderedData(1:internal.matlab.variableeditor.peer.PeerUnsupportedViewModel.TextLengthLimit));
            end
                 
            % For the UnknownView client class all HTML should be removed.
            % Do this after we truncate the length above.
            renderedData = regexprep(renderedData,'<(?:.|\n)*?>','');
        end
    end
    
    methods(Access=protected)
        function refresh(this, varargin)
            cachedData(this, varargin{:});
        end
    end
end
