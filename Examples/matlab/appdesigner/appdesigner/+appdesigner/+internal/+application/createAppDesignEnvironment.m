function [appDesignEnvironment, appDesignerModel] = createAppDesignEnvironment(componentAdapterMap)
%CREATEAPPDESIGNENVIRONMENT Internal function to create
% AppDesignEnvironment, and AppDesignerModel
%
%
% Copyright 2017 The MathWorks, Inc.

    narginchk(1, 1);

    % get PeerModelManager
    peerModelManager = appdesigner.internal.application.AppDesignEnvironment.getPeerModelManager( ...
        appdesigner.internal.application.AppDesignEnvironment.NameSpace);
    
    % create AppDesignerModel
    appDesignerModel = appdesigner.internal.model.AppDesignerModel(componentAdapterMap, peerModelManager);

    % the AppDesignEnvironment
    appDesignEnvironment = appdesigner.internal.application.AppDesignEnvironment(peerModelManager, appDesignerModel);
    addlistener(appDesignEnvironment,'ObjectBeingDestroyed', ...
                 @(source, event)delete(appDesignerModel));    
end