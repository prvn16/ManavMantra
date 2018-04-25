classdef AppDesignerChildModelFactory < appdesservices.internal.interfaces.model.DesignTimeModelFactory
    % AppDesignerChildModelFactory  Factory to create children of the AppDesignerModel

    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods
 
        function model = createModel(obj, parentModel, peerNode)
            % create a model with the proxyView as a child of the parentModel
            
            % Create the proxyView for this child peerNode
            proxyView = ...
                appdesigner.internal.view.DesignTimeProxyView(peerNode);
            
            switch (proxyView.getType())
                case 'AppModel'
                    % get the file name from the peer node
                    fullFileName = peerNode.getProperty('FullFileName');
                    uifigure  = [];
                    if ~isempty(fullFileName)
                        % if its an app that is being opened, get the
                        % UIFigure so it and its components can be reused
                        % on load
                        componentProvider = appdesigner.internal.serialization.util.ComponentProvider.instance();
                        uifigure = componentProvider.getUIFigure(fullFileName);
                    end
                    
                    % construct an AppModel 
                    model = appdesigner.internal.model.AppModel(parentModel, proxyView, uifigure);
                    
                otherwise
                    assert(false,sprintf('Unhandled proxyView type: %s', proxyView.getType()));
            end
            
        end
    end
end

